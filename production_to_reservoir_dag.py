from os import environ
from datetime import datetime, timedelta
from typing import List, Dict
import time

from pytz import UTC
from airflow import models
from airflow.operators import dummy_operator
from airflow.operators import email_operator
from airflow.contrib.operators import bigquery_get_data
from airflow.contrib.operators import bigquery_operator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator
from google.cloud import bigquery
from google.oauth2 import service_account

from dependencies import exponea as ex


DAG_NAME = "ProductionToReservoir_Full_Reload"
DAG_VERSION = "0.1"

KEY_FILE_PATH = "/home/airflow/gcs/data/exponea-dev-sa.json"

MATERIALIZE_PROJECT_NAME = environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = environ.get("SERVICE_ACCOUNT")
GCP_CONN_ID = environ.get("CONNECTION_ID")

REGION = "europe-west1"

TEMPLATE_ID = "download_production_table"
SCRIPT = "gs://dataproc-assets/production/main.py"
GCS_OUTPUT_BUCKET = "gs://production-exports"
OUTPUT_PARQUET = "No"

_PRODUCTION_GCP_PROJECT = "abc-group"
_PRODUCTION_DATASET = "production"
_MATERIALIZE_DATASET = "exponea_temp"  # Reused from Exponea-to-Reservoir effort

DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime(2020, 8, 28),
    "email": [
        "orb@abc.com",
    ],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=2),
}

with models.DAG(
        dag_id="{dag_name}-v{dag_version}".format(
            dag_name=DAG_NAME, dag_version=DAG_VERSION
        ),
        description="Production-to-Reservoir Export DAG",
        schedule_interval=None,
        default_args=DEFAULT_ARGS,
        catchup=False,
) as dag:

    def export_production_data(**kwargs): 
        ti = kwargs['ti']  # get a task instance
        # REM: such a trick is not well documented in the official Airflow documentation
        # Inherited from https://bcb.github.io/airflow/execute-context
        context = ti.get_template_context()  # get a context of the running task

        final_views_list = []

        credentials = service_account.Credentials.from_service_account_file(
            KEY_FILE_PATH, scopes=["https://www.googleapis.com/auth/cloud-platform"],
        )

        start_date_str = '2017-12-31' # TODO: FIXME

        bq_client = bigquery.Client(project=_PRODUCTION_GCP_PROJECT, credentials=credentials)
        tables = bq_client.list_tables(dataset=_PRODUCTION_DATASET)
        for table in tables:
            table_name = table.table_id
            # filter out system tables and temp views
            ignore_view_substring_list = ['_system_', '__']
            if not any(substring in table_name for substring in ignore_view_substring_list):
                final_views_list.append(table_name)
    
        # got through the view  list, spin a new Bash operator to launch 
        # a Dataproc workflow template-based job

        non_particioned_views_patterns = ['customers_']

        # time --async
        for view in final_views_list:
            # introduce the artificial delay of 1s to get rid of the bug per Quota exceeded for quota group 'ReadGroup' and limit 'Read requests per 100 seconds'
            time.sleep(1)
            # proceed
            partitioned_flag = "Yes"
            if any(substring in view for substring in non_particioned_views_patterns):
                partitioned_flag = "No"
            # Note: we supply SINCE_DATE for compatibility with the PySpark job signature
            #       such a parameter won't take any effect in full reload mode
            bash_command = f"""
                gcloud dataproc workflow-templates instantiate \
                {TEMPLATE_ID} --project {MATERIALIZE_PROJECT_NAME} --region {REGION} \
                --parameters MAIN_PYTHON_FILE={SCRIPT},DATASET={_PRODUCTION_DATASET},ENTITY_NAME={view},GCS_OUTPUT_BUCKET={GCS_OUTPUT_BUCKET},MATERIALIZATION_GCP_PROJECT_ID={MATERIALIZE_PROJECT_NAME},MATERIALIZATION_DATASET={_MATERIALIZE_DATASET},OUTPUT_PARQUET={OUTPUT_PARQUET},PARTITIONED={partitioned_flag},FULL_RELOAD=Yes,SINCE_DATE={start_date_str}
            """
            b_op = BashOperator(
                task_id=f'{_PRODUCTION_DATASET}-{view}',
                bash_command=bash_command,
            )
            b_op.execute(context)

    start = dummy_operator.DummyOperator(task_id="START")
    end = dummy_operator.DummyOperator(task_id="FINISH")

    export_production_data = PythonOperator(
        task_id="export-production-data",
        python_callable=export_production_data,
        provide_context=True
    )

    # this task will remove all of the files from the Exponea file output bucket
    # without deleting the bucket itself
    clean_up_bucket = BashOperator(
         task_id='cleanup_bucket', 
         bash_command="gsutil -m rm {}/** || echo 'No files found in the bucket'".format(GCS_OUTPUT_BUCKET)
    )

    start >> clean_up_bucket >> export_production_data >> end

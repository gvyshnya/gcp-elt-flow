from os import environ
import time
from datetime import datetime, timedelta
from typing import List, Dict

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


DAG_NAME = "ExponeaToReservoir_Full_Reload"
DAG_VERSION = "0.2"

KEY_FILE_PATH = "/home/airflow/gcs/data/exponea-dev-sa.json"

MATERIALIZE_PROJECT_NAME = environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = environ.get("SERVICE_ACCOUNT")
GCP_CONN_ID = environ.get("CONNECTION_ID")

REGION = "europe-west1"

TEMPLATE_ID = "load_exponea_table_gzip"
SCRIPT = "gs://dataproc-assets/exponea_gzip/main.py"
GCS_OUTPUT_BUCKET = "gs://exponea-export-gzip"
OUTPUT_PARQUET = "No"

_EXPONEA_GCP_PROJECT = "gcloudltds"
_MATERIALIZE_DATASET = "exponea_temp"

DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime(2020, 7, 24),
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
        description="Exponea-to-Reservoir Export DAG",
        schedule_interval=None,
        default_args=DEFAULT_ARGS,
        catchup=False,
) as dag:

    def export_exponea_views(**kwargs): 
        ti = kwargs['ti']  # get a task instance
        # REM: such a trick is not well documented in the official Airflow documentation
        # Inherited from https://bcb.github.io/airflow/execute-context
        context = ti.get_template_context()  # get a context of the running task

        country_id = kwargs['country_id']
        exponea_dataset_name = kwargs['exponea_dataset_name']
        exponea_pr_name = kwargs['project_name']

        exponea_pr_name = exponea_pr_name.lower()

        final_views_list = []

        credentials = service_account.Credentials.from_service_account_file(
            KEY_FILE_PATH, scopes=["https://www.googleapis.com/auth/cloud-platform"],
        )

        start_date_str = '2017-12-31'
        end_date_str = datetime.utcnow().strftime("%Y-%m-%d")

        bq_client = bigquery.Client(project=_EXPONEA_GCP_PROJECT, credentials=credentials)
        tables = bq_client.list_tables(dataset=exponea_dataset_name)
        for table in tables:
            table_name = table.table_id
            # filter out system tables and temp views
            ignore_view_substring_list = ['_system_']
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
                --parameters MAIN_PYTHON_FILE={SCRIPT},COUNTRY_ID={country_id},COUNTRY_EXPONEA_DATASET={exponea_dataset_name},COUNTRY_EXPONEA_PROJECT_NAME={exponea_pr_name},ENTITY_NAME={view},GCS_OUTPUT_BUCKET={GCS_OUTPUT_BUCKET},MATERIALIZATION_GCP_PROJECT_ID={MATERIALIZE_PROJECT_NAME},MATERIALIZATION_DATASET={_MATERIALIZE_DATASET},OUTPUT_PARQUET={OUTPUT_PARQUET},PARTITIONED={partitioned_flag},FULL_RELOAD=Yes,SINCE_DATE={start_date_str},END_DATE={end_date_str}
            """
            b_op = BashOperator(
                task_id=f'{exponea_dataset_name}-{country_id}-{view}',
                bash_command=bash_command,
            )
            b_op.execute(context)

    start = dummy_operator.DummyOperator(task_id="START")
    end = dummy_operator.DummyOperator(task_id="FINISH")

    dummy1 = dummy_operator.DummyOperator(task_id="DUMMY1")
    dummy2 = dummy_operator.DummyOperator(task_id="DUMMY2")
    dummy3 = dummy_operator.DummyOperator(task_id="DUMMY3")
    dummy4 = dummy_operator.DummyOperator(task_id="DUMMY4")
    dummy5 = dummy_operator.DummyOperator(task_id="DUMMY5")
    dummy6 = dummy_operator.DummyOperator(task_id="DUMMY6")

    export_exponea_data_1 = [
        PythonOperator(
            task_id="".join(["export-", dataset['bigquery_dataset']]),
            python_callable=export_exponea_views,
            op_kwargs={
                'exponea_dataset_name': dataset['bigquery_dataset'],
                'project_name': dataset['project_name'],
                'country_id': dataset['country_id'],
            },
            provide_context=True
        )
        for dataset in ex.EXPONEA_PROJECTS_1
    ]

    export_exponea_data_2 = [
        PythonOperator(
            task_id="".join(["export-", dataset['bigquery_dataset']]),
            python_callable=export_exponea_views,
            op_kwargs={
                'exponea_dataset_name': dataset['bigquery_dataset'],
                'project_name': dataset['project_name'],
                'country_id': dataset['country_id'],
            },
            provide_context=True
        )
        for dataset in ex.EXPONEA_PROJECTS_2
    ]

    export_exponea_data_3 = [
        PythonOperator(
            task_id="".join(["export-", dataset['bigquery_dataset']]),
            python_callable=export_exponea_views,
            op_kwargs={
                'exponea_dataset_name': dataset['bigquery_dataset'],
                'project_name': dataset['project_name'],
                'country_id': dataset['country_id'],
            },
            provide_context=True
        )
        for dataset in ex.EXPONEA_PROJECTS_3
    ]

    export_exponea_data_4 = [
        PythonOperator(
            task_id="".join(["export-", dataset['bigquery_dataset']]),
            python_callable=export_exponea_views,
            op_kwargs={
                'exponea_dataset_name': dataset['bigquery_dataset'],
                'project_name': dataset['project_name'],
                'country_id': dataset['country_id'],
            },
            provide_context=True
        )
        for dataset in ex.EXPONEA_PROJECTS_4
    ]

    export_exponea_data_5 = [
        PythonOperator(
            task_id="".join(["export-", dataset['bigquery_dataset']]),
            python_callable=export_exponea_views,
            op_kwargs={
                'exponea_dataset_name': dataset['bigquery_dataset'],
                'project_name': dataset['project_name'],
                'country_id': dataset['country_id'],
            },
            provide_context=True
        )
        for dataset in ex.EXPONEA_PROJECTS_5
    ]

    export_exponea_data_6 = [
        PythonOperator(
            task_id="".join(["export-", dataset['bigquery_dataset']]),
            python_callable=export_exponea_views,
            op_kwargs={
                'exponea_dataset_name': dataset['bigquery_dataset'],
                'project_name': dataset['project_name'],
                'country_id': dataset['country_id'],
            },
            provide_context=True
        )
        for dataset in ex.EXPONEA_PROJECTS_6
    ]

    export_exponea_data_7 = [
        PythonOperator(
            task_id="".join(["export-", dataset['bigquery_dataset']]),
            python_callable=export_exponea_views,
            op_kwargs={
                'exponea_dataset_name': dataset['bigquery_dataset'],
                'project_name': dataset['project_name'],
                'country_id': dataset['country_id'],
            },
            provide_context=True
        )
        for dataset in ex.EXPONEA_PROJECTS_7
    ]

    # this task will remove all of the files from the Exponea file output bucket
    # without deleting the bucket itself
    clean_up_bucket = BashOperator(
         task_id='cleanup_bucket', 
         bash_command="gsutil -m rm {}/** || echo 'No files found in the bucket'".format(GCS_OUTPUT_BUCKET)
    )

    start >> clean_up_bucket >> export_exponea_data_1 >> dummy1 >> export_exponea_data_2 >> dummy2 >> export_exponea_data_3
    export_exponea_data_3 >> dummy3 >> export_exponea_data_4 >> dummy4 >> export_exponea_data_5 
    export_exponea_data_5 >> dummy5 >> export_exponea_data_6 >> dummy6 >> export_exponea_data_7 >> end

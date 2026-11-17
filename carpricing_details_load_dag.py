from os import environ
import datetime
from itertools import chain
from pytz import UTC
from airflow import models
from airflow.operators import dummy_operator

from dependencies import commons
from dependencies.tables import CAR_PRICING_DETAIL_TABLES

DAG_NAME = "CarPricingDetails_Load"
DAG_VERSION = "0.1"

USER = environ.get("MYSQL_DB_USER")
PASS = environ.get("MYSQL_DB_PASSWORD")

PROJECT_NAME = environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = environ.get("DATAFLOW_SERVICE_ACCOUNT")
GCP_CONN_ID = environ.get("CONNECTION_ID")

QUERIES_BASE_PATH = "/home/airflow/gcs/dags/dependencies/queries/"
QUERIES_RELATIVE_BASE_PATH = "dependencies/queries/"

DATAFLOW_OPTIONS = {
    "project": PROJECT_NAME,
    "zone": "europe-west1-d",
    "region": "europe-west1",
    "tempLocation": f"{commons.DATAFLOW_EXTRAS_BUCKET}/dataflow_tmp/",
    "serviceAccountEmail": SERVICE_ACCOUNT,
}

DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime.datetime(2020, 3, 25, 9),
    "email": [
        "orb@abc.com",
    ],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": datetime.timedelta(minutes=2),
}

JINJA_TEMPLATE_PARAMS = {
    "project_name": PROJECT_NAME,
}

with models.DAG(
    dag_id="{dag_name}-v{dag_version}".format(
        dag_name=DAG_NAME, dag_version=DAG_VERSION
    ),
    description="Performs the load of the content of carDetail tables in MySQL fcg schema into DWH.",
    default_args=DEFAULT_ARGS,
    schedule_interval="@weekly",
    catchup=False,
) as dag:

    start = dummy_operator.DummyOperator(task_id="START")
    end = dummy_operator.DummyOperator(task_id="END")

    car_pricing_details_staging_deletes = commons.delete_table(
        "CarPricingDetails", "staging", gcp_project=PROJECT_NAME
    )

    ingest_to_staging = [
        commons.load_table_to_staging_with_custom_params(
            table_name="CarPricingDetails",
            task_id="carpricingdetails4"+table_info["country"].lower(),
            db_user=table_info["user"],
            db_password=table_info["password"],
            service_db=table_info["service_db"],
            dataset="staging",
            bi_replica_project=table_info["project"],
            bi_replica_region=table_info["region"],
            bi_replica_name=table_info["replica"],
            query_dir=QUERIES_BASE_PATH + "staging",
            service_account=SERVICE_ACCOUNT,
            gcp_project=PROJECT_NAME,
            gcp_conn_id=GCP_CONN_ID,
            dataflow_options=DATAFLOW_OPTIONS,
            base_jinja_templating_params=JINJA_TEMPLATE_PARAMS,
            custom_jinja_templating_params={"table_name": table_info["source_table"]}
        )
        for table_info in CAR_PRICING_DETAIL_TABLES
    ]
    
    car_pricing_details_to_semantics = commons.semantics_bigquery_job_full_reload(
            table_name="CarPricingDetails",
            relative_base_path=QUERIES_RELATIVE_BASE_PATH + "semantics",
            dataset="semantics_central",
            gcp_conn_id=GCP_CONN_ID,
            service_account=SERVICE_ACCOUNT,
            jinja_templating_params=JINJA_TEMPLATE_PARAMS,
            gcp_project=PROJECT_NAME,
    )

    # ingest_to_staging = list(chain(*ingest_to_staging))

    start >> car_pricing_details_staging_deletes >> ingest_to_staging 
    ingest_to_staging >> car_pricing_details_to_semantics >> end
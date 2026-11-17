from os import environ
from datetime import datetime, timedelta
from airflow import models
from airflow.operators import dummy_operator
from dependencies import exponea_from_bq


DAG_NAME = "Exponea_Full_Reload"
DAG_VERSION = "0.2"

PROJECT_NAME = environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = environ.get("DATAFLOW_SERVICE_ACCOUNT")
GCP_CONN_ID = environ.get("CONNECTION_ID")

DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime(2019, 6, 6),
    "email": [
        "orb@abc.com",
    ],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=2),
}

COUNTRY_LIST = ["IN"]

with models.DAG(
    dag_id="{dag_name}-v{dag_version}".format(
        dag_name=DAG_NAME, dag_version=DAG_VERSION
    ),
    description="Expoea BigQuery Export to FCG owned datasets",
    schedule_interval="35 0 * * *",
    default_args=DEFAULT_ARGS,
) as dag:
    start_op = dummy_operator.DummyOperator(task_id="START")

    move_tables_from_exponea = exponea_from_bq.copy_exponea_country_dataset(
        country=COUNTRY_LIST[0],
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        gcp_project=PROJECT_NAME,
    )

    for table_move in move_tables_from_exponea:
        start_op >> table_move

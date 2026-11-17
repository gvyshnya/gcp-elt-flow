from os import environ
import datetime
from airflow import models
from airflow.operators import dummy_operator
from airflow.contrib.operators import mysql_to_gcs, gcs_to_bq

DAG_NAME = "MySQL-GCS-BQ_Test"
DAG_VERSION = "0.0"

USER = environ.get("MYSQL_DB_USER")
PASS = environ.get("MYSQL_DB_PASSWORD")

PROJECT_NAME = environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = environ.get("DATAFLOW_SERVICE_ACCOUNT")

MYSQL_CONN_ID = "bi_replica"
GCP_CONN_ID = environ.get("CONNECTION_ID")

TEST_TABLE = "auction.bid"

DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime.datetime(2019, 8, 13),
    "email": ["orb@abc.com",],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": datetime.timedelta(minutes=2),
}

with models.DAG(
    dag_id=f"{DAG_NAME}_v{DAG_VERSION}",
    description="Testing moving tables using the MySQL operator and the SQL Proxy",
    default_args=DEFAULT_ARGS,
    schedule_interval=None,
) as dag:
    start = dummy_operator.DummyOperator(task_id="START")
    mysql_gcs = mysql_to_gcs.MySqlToGoogleCloudStorageOperator(
        task_id=f"moving-{TEST_TABLE}",
        mysql_conn_id=MYSQL_CONN_ID,
        google_cloud_storage_conn_id=GCP_CONN_ID,
        sql=f"select * from {TEST_TABLE}",
        filename=f"{TEST_TABLE}_v{DAG_VERSION}.json",
        bucket="pedro_dvc_testing",
    )

    start >> mysql_gcs

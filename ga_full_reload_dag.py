from os import environ
from datetime import datetime, timedelta

from airflow import models
from airflow.operators import dummy_operator

from dependencies import google_analytics
from dependencies import ga_admin_app_v1
from dependencies.commons import delete_table
from dependencies.commons import semantics_bigquery_job_full_reload


DAG_NAME = "GoogleAnalytics_Full_Reload"
DAG_VERSION = "0.6"

PROJECT_NAME = environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = environ.get("DATAFLOW_SERVICE_ACCOUNT")
GCP_CONN_ID = environ.get("CONNECTION_ID")

KEY_FILE_PATH = "/home/airflow/gcs/data/ga_key.json"
QUERIES_RELATIVE_BASE_PATH = "dependencies/queries/"

TABLE_NAME = "Visits"
ADMIN_APP_TABLE_NAME = "AdminAppV1CarEdits"


DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime(2019, 6, 1),
    "email": [
        "orb@abc.com",
    ],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=2),
}

COUNTRY_LIST = ["AR", "CL", "CO", "ID", "IN", "MX", "NG", "PK", "PL"]

with models.DAG(
    dag_id="{dag_name}-v{dag_version}".format(
        dag_name=DAG_NAME, dag_version=DAG_VERSION
    ),
    description="Reload GA from 2018",
    schedule_interval=None,
    default_args=DEFAULT_ARGS,
    catchup=False,
) as dag:

    start_date = datetime(2018, 1, 1)
    end_date = datetime.today() - timedelta(days=1)

    start_op = dummy_operator.DummyOperator(task_id="START")
    dummy_after_staging = dummy_operator.DummyOperator(task_id="DummyOp-Staging")

    ingest_to_staging = [
        google_analytics.ga_reload_country(
            country=country,
            start_date=start_date.strftime("%Y-%m-%d"),
            end_date=end_date.strftime("%Y-%m-%d"),
            dataset="staging",
            ga_key_file_path=KEY_FILE_PATH,
            gcp_project_id=PROJECT_NAME,
        )
        for country in COUNTRY_LIST
    ]

    ingest_admin_app_to_staging = ga_admin_app_v1.ga_reload_admin_app_v1(
        start_date=start_date.strftime("%Y-%m-%d"),
        end_date=end_date.strftime("%Y-%m-%d"),
        dataset="staging",
        ga_key_file_path=KEY_FILE_PATH,
        gcp_project_id=PROJECT_NAME,
    )

    delete_visits = delete_table(
        table_name=TABLE_NAME, dataset="staging", gcp_project=PROJECT_NAME
    )

    delete_admin_app_car_edits = delete_table(
        table_name=ADMIN_APP_TABLE_NAME, dataset="staging", gcp_project=PROJECT_NAME
    )

    visits_to_semantics = semantics_bigquery_job_full_reload(
        table_name=TABLE_NAME,
        relative_base_path=QUERIES_RELATIVE_BASE_PATH + "semantics",
        dataset="semantics_central",
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        gcp_project=PROJECT_NAME,
        jinja_templating_params={
            "start_ts": start_date.strftime("%Y-%m-%d"),
            "end_ts": end_date.strftime("%Y-%m-%d"),
            "project_name": PROJECT_NAME,
        },
    )

    admin_app_v1_to_semantics = semantics_bigquery_job_full_reload(
        table_name=ADMIN_APP_TABLE_NAME,
        relative_base_path=QUERIES_RELATIVE_BASE_PATH + "semantics",
        dataset="semantics_central",
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        gcp_project=PROJECT_NAME,
        jinja_templating_params={
            "start_ts": start_date.strftime("%Y-%m-%d"),
            "end_ts": end_date.strftime("%Y-%m-%d"),
            "project_name": PROJECT_NAME,
        },
    )

    start_op >> delete_visits >> ingest_to_staging >> dummy_after_staging >> visits_to_semantics
    start_op >> delete_admin_app_car_edits >> ingest_admin_app_to_staging >> admin_app_v1_to_semantics

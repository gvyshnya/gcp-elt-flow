from os import environ
from datetime import datetime, timedelta
from pytz import UTC
from airflow import models
from airflow.operators import dummy_operator
from dependencies import google_analytics
from dependencies import ga_admin_app_v1
from dependencies.commons import clean_up_table, semantics_bigquery_job_full_reload


DAG_NAME = "GoogleAnalytics_Incremental"
DAG_VERSION = "0.7"

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
    "start_date": datetime(2019, 7, 5),
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
    description="Daily incremental reload for Google Analytics",
    schedule_interval="40 0 * * *",
    default_args=DEFAULT_ARGS,
    catchup=False,
) as dag:

    start_date = datetime.today().replace(
        hour=0, minute=0, second=0, microsecond=0
    ) - timedelta(days=2)
    end_date = datetime.today().replace(
        hour=0, minute=0, second=0, microsecond=0
    ) - timedelta(days=1)

    templating_params = {
        "end_ts": end_date.replace(tzinfo=UTC).strftime("%Y-%m-%d"),
        "start_ts": start_date.replace(tzinfo=UTC).strftime("%Y-%m-%d"),
        "project_name": PROJECT_NAME,
    }

    start_op = dummy_operator.DummyOperator(task_id="START")
    dummy_after_staging = dummy_operator.DummyOperator(task_id="DummyOp-Staging")

    clean_staging_visits = clean_up_table(
        table_name=TABLE_NAME,
        relative_base_path=QUERIES_RELATIVE_BASE_PATH + "staging/clean_up",
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        jinja_templating_params=templating_params,
        gcp_project=PROJECT_NAME,
        extra_id_text="_Staging",
    )

    clean_staging_admin_app = clean_up_table(
        table_name=ADMIN_APP_TABLE_NAME,
        relative_base_path=QUERIES_RELATIVE_BASE_PATH + "staging/clean_up",
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        jinja_templating_params=templating_params,
        gcp_project=PROJECT_NAME,
        extra_id_text="_Staging",
    )

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

    clean_semantics_visits = clean_up_table(
        table_name=TABLE_NAME,
        relative_base_path=QUERIES_RELATIVE_BASE_PATH + "semantics/clean_up",
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        jinja_templating_params=templating_params,
        gcp_project=PROJECT_NAME,
        extra_id_text="_Semantics",
    )

    clean_semantics_admin_app = clean_up_table(
        table_name=ADMIN_APP_TABLE_NAME,
        relative_base_path=QUERIES_RELATIVE_BASE_PATH + "semantics/clean_up",
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        jinja_templating_params=templating_params,
        gcp_project=PROJECT_NAME,
        extra_id_text="_Semantics",
    )

    visits_to_semantics = semantics_bigquery_job_full_reload(
        table_name=TABLE_NAME,
        relative_base_path=QUERIES_RELATIVE_BASE_PATH + "semantics",
        dataset="semantics_central",
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        gcp_project=PROJECT_NAME,
        jinja_templating_params=templating_params,
        truncate_table=False,
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

    start_op >> clean_staging_visits >> ingest_to_staging >> dummy_after_staging
    dummy_after_staging >> clean_semantics_visits >> visits_to_semantics

    start_op >> clean_staging_admin_app >> ingest_admin_app_to_staging
    ingest_admin_app_to_staging >> clean_semantics_admin_app >> admin_app_v1_to_semantics

from os import environ
from datetime import datetime, timedelta
from pytz import UTC
from airflow import models
from airflow.operators import dummy_operator
from dependencies import mixpanel
from dependencies.commons import clean_up_table


DAG_NAME = "Mixpanel_Incremental"
DAG_VERSION = "0.1"

PROJECT_NAME = environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = environ.get("DATAFLOW_SERVICE_ACCOUNT")
GCP_CONN_ID = environ.get("CONNECTION_ID")

TABLE_NAME = "DealerActivityEvents"
QUERIES_RELATIVE_BASE_PATH = "dependencies/queries/"

DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime(2019, 6, 6),
    "email": ["orb@abc.com"],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=2),
}

COUNTRY_LIST = mixpanel.COUNTRY_DATA.keys()
# COUNTRY_LIST = ['ID']

with models.DAG(
    dag_id="{dag_name}-v{dag_version}".format(
        dag_name=DAG_NAME, dag_version=DAG_VERSION
    ),
    description="Daily incremental load of MixPanel Events",
    schedule_interval="25 1 * * *",
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
    }

    start_op = dummy_operator.DummyOperator(task_id="START")
    # dummy_after_staging = dummy_operator.DummyOperator(task_id="DummyOp-Staging")

    clean_staging_visits = clean_up_table(
        table_name=TABLE_NAME,
        relative_base_path=QUERIES_RELATIVE_BASE_PATH + "staging/clean_up",
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        jinja_templating_params=templating_params,
        gcp_project=PROJECT_NAME,
        extra_id_text="_Staging",
    )

    ingest_to_staging = [
        mixpanel.mixpanel_load_country(
            country=country,
            start_date=start_date.strftime("%Y-%m-%d"),
            end_date=end_date.strftime("%Y-%m-%d"),
            dataset="staging",
            table_name=TABLE_NAME,
            gcp_project_id=PROJECT_NAME,
        )
        for country in COUNTRY_LIST
    ]

    start_op >> clean_staging_visits

    for ga_to_dwh in ingest_to_staging:
        clean_staging_visits >> ga_to_dwh

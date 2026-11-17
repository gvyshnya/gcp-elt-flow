from os import environ
from datetime import datetime, timedelta
from pytz import UTC
from airflow import models
from airflow.operators import dummy_operator
from dependencies import open_exchange_rates
from dependencies.commons import clean_up_table, semantics_bigquery_job_full_reload


DAG_NAME = "ExchangeRates_Incremental"
DAG_VERSION = "0.3"

PROJECT_NAME = environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = environ.get("DATAFLOW_SERVICE_ACCOUNT")
GCP_CONN_ID = environ.get("CONNECTION_ID")

OXR_KEY = environ.get("OXR_API_KEY")
QUERIES_RELATIVE_BASE_PATH = "dependencies/queries/"

TABLE_NAME = "ExchangeRates"

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

with models.DAG(
    dag_id="{dag_name}-v{dag_version}".format(
        dag_name=DAG_NAME, dag_version=DAG_VERSION
    ),
    description="Daily incremental reload for Exchange Rates",
    schedule_interval="0 0 * * *",
    default_args=DEFAULT_ARGS,
    catchup=False,
) as dag:

    start_date = datetime.today().replace(
        hour=0, minute=0, second=0, microsecond=0, tzinfo=UTC
    ) - timedelta(days=1)
    end_date = datetime.today().replace(
        hour=0, minute=0, second=0, microsecond=0, tzinfo=UTC
    ) - timedelta(days=1)

    templating_params = {
        "end_ts": end_date.strftime("%Y-%m-%d"),
        "start_ts": start_date.strftime("%Y-%m-%d"),
    }

    start_op = dummy_operator.DummyOperator(task_id="START")

    clean_staging_oxr = clean_up_table(
        table_name=TABLE_NAME,
        relative_base_path=QUERIES_RELATIVE_BASE_PATH + "staging/clean_up",
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        jinja_templating_params=templating_params,
        gcp_project=PROJECT_NAME,
        extra_id_text="_Staging",
    )

    ingest_to_staging = open_exchange_rates.oxr_reload(
        start_date=start_date,
        end_date=end_date,
        dataset="staging",
        open_exchange_rates_key=OXR_KEY,
        gcp_project_id=PROJECT_NAME,
        overwrite=False,
    )

    clean_semantics_oxr = clean_up_table(
        table_name=TABLE_NAME,
        relative_base_path=QUERIES_RELATIVE_BASE_PATH + "semantics/clean_up",
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        jinja_templating_params=templating_params,
        gcp_project=PROJECT_NAME,
        extra_id_text="_Semantics",
    )

    oxr_to_semantics = semantics_bigquery_job_full_reload(
        table_name=TABLE_NAME,
        relative_base_path=QUERIES_RELATIVE_BASE_PATH + "semantics",
        dataset="semantics_central",
        gcp_conn_id=GCP_CONN_ID,
        service_account=SERVICE_ACCOUNT,
        jinja_templating_params=templating_params,
        truncate_table=False,
        gcp_project=PROJECT_NAME,
    )

    start_op >> clean_staging_oxr >> ingest_to_staging >> clean_semantics_oxr >> oxr_to_semantics

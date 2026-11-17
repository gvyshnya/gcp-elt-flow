from os import environ
import datetime
from itertools import chain
from pytz import UTC
from airflow import models
from airflow.operators import dummy_operator

from dependencies import commons
from dependencies.tables import TABLES, SEMANTICS_TABLES, AUXILIARY_STAGING_TABLES
from dependencies.tables import BIG_PARTITIONED_TABLES, LAST_MODIFIED_LOG_TABLE
from dependencies.tables import BQ_CONNECTOR_TABLES, MYSQL_CLOUD_FUNCTION_TABLES

DAG_NAME = "CMS_Full_Reload"
DAG_VERSION = "0.16"

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
    "start_date": datetime.datetime(2020, 9, 16),
    "email": [
        "orb@abc.com",
    ],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": datetime.timedelta(minutes=2),
}

JINJA_TEMPLATE_PARAMS = {
    "end_ts": datetime.datetime.utcnow()
    .replace(microsecond=0, second=0, minute=0, tzinfo=UTC)
    .isoformat(),
    "start_ts": datetime.datetime(2015, 1, 1, tzinfo=UTC).isoformat(),
    "project_name": PROJECT_NAME,
}

with models.DAG(
    dag_id="{dag_name}-v{dag_version}".format(
        dag_name=DAG_NAME, dag_version=DAG_VERSION
    ),
    description="Performs a full reload of CMS data.",
    default_args=DEFAULT_ARGS,
    schedule_interval="2 0 * * *",
) as dag:

    start = dummy_operator.DummyOperator(task_id="START")
    dummy_after_delete = dummy_operator.DummyOperator(task_id="DummyOp-GroupDeletes")
    dummy_after_staging = dummy_operator.DummyOperator(task_id="DummyOp-GroupStaging")
    end = dummy_operator.DummyOperator(task_id="END")

    #dummy_after_logging_regular_tables = dummy_operator.DummyOperator(
    #    task_id="DummyOp-GroupLogging1"
    #)

    tables_deletes = [
        commons.delete_table(table_info["table"], "staging", gcp_project=PROJECT_NAME)
        for table_info in TABLES + BQ_CONNECTOR_TABLES + MYSQL_CLOUD_FUNCTION_TABLES
        if table_info["table"] not in BIG_PARTITIONED_TABLES
    ]

    ingest_to_staging = [
        commons.load_table_to_staging(
            table_info=table_info,
            dataset="staging",
            gcp_conn_id=GCP_CONN_ID,
            dataflow_options=DATAFLOW_OPTIONS,
            jinja_templating_params=JINJA_TEMPLATE_PARAMS,
            query_dir=QUERIES_BASE_PATH + "staging",
            service_account=SERVICE_ACCOUNT,
            gcp_project=PROJECT_NAME,
        )
        for table_info in TABLES
        if table_info["table"] not in BIG_PARTITIONED_TABLES
    ]
    
    ingest_to_staging.extend([
            commons.load_table_to_staging_http_cloud_function(
                table_info=table_info,
                dataset="staging",
                gcp_conn_id=GCP_CONN_ID,
                jinja_templating_params=JINJA_TEMPLATE_PARAMS,
                query_dir=QUERIES_BASE_PATH + "staging",
                service_account=SERVICE_ACCOUNT,
                gcp_project=PROJECT_NAME,
                truncate_table=True,
            )
            for table_info in BQ_CONNECTOR_TABLES
    ])

    ingest_to_staging.extend([
            commons.load_mysql_table_to_staging_http_cloud_function(
                table_info=table_info,
                dataset="staging",
                gcp_conn_id=GCP_CONN_ID,
                jinja_templating_params=JINJA_TEMPLATE_PARAMS,
                query_dir=QUERIES_BASE_PATH + "staging",
                service_account=SERVICE_ACCOUNT,
                gcp_project=PROJECT_NAME,
                truncate_table=True,
            )
            for table_info in MYSQL_CLOUD_FUNCTION_TABLES
    ])

    staging_to_semantics = [
        commons.semantics_bigquery_job_full_reload(
            table_name=tname,
            relative_base_path=QUERIES_RELATIVE_BASE_PATH + "semantics",
            dataset="semantics_central",
            gcp_conn_id=GCP_CONN_ID,
            service_account=SERVICE_ACCOUNT,
            jinja_templating_params=JINJA_TEMPLATE_PARAMS,
            gcp_project=PROJECT_NAME,
        )
        for tname in SEMANTICS_TABLES
        if tname not in BIG_PARTITIONED_TABLES
    ]

    # last_modified_log_table_delete = commons.delete_table(
    #     LAST_MODIFIED_LOG_TABLE, "semantics_central", gcp_project=PROJECT_NAME
    # )

    # last_modified_log_record = [
    #     commons.semantics_bigquery_record_entity_last_modified(
    #         entity_table_name=table_info["table"],
    #         entity_update_field=table_info["update_field"],
    #         dataset="semantics_central",
    #         gcp_conn_id=GCP_CONN_ID,
    #         base_query_dir=QUERIES_BASE_PATH,
    #         service_account=SERVICE_ACCOUNT,
    #         gcp_project=PROJECT_NAME,
    #         truncate_table=False,
    #     )
    #     for table_info in TABLES
    #     if table_info["table"] not in BIG_PARTITIONED_TABLES + AUXILIARY_STAGING_TABLES
    #     # Reasons for table  exlusion above
    #     # - "CarLocations", "CarStatus" are auxiliary tables in Staging and not exposed to Semantics
    #     # - "CarChangesHistory", "CustomerHistory" and "CarFinancialDetailsHistory"
    #     #   are  partitioned tables, and their last modified
    #     #   time stamps will be logged with a different routine
    # ]

    # partitioned_last_modified_log_record = [
    #     commons.semantics_bigquery_record_partitioned_entity_last_modified(
    #         entity_table_name=table_info["table"],
    #         entity_update_field=table_info["update_field"],
    #         dataset="semantics_central",
    #         gcp_conn_id=GCP_CONN_ID,
    #         base_query_dir=QUERIES_BASE_PATH,
    #         service_account=SERVICE_ACCOUNT,
    #         gcp_project=PROJECT_NAME,
    #         truncate_table=False,
    #     )
    #     for table_info in TABLES
    #     if table_info["table"] in BIG_PARTITIONED_TABLES
    # ]

    ingest_to_staging = list(chain(*ingest_to_staging))

    start >> tables_deletes >> dummy_after_delete >> ingest_to_staging
    ingest_to_staging >> dummy_after_staging >> staging_to_semantics >> end
    # >> last_modified_log_table_delete
    # last_modified_log_table_delete >> last_modified_log_record >> dummy_after_logging_regular_tables
    # dummy_after_logging_regular_tables >> partitioned_last_modified_log_record >> end

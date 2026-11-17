from os import environ
import datetime
from pytz import UTC
from airflow import models
from airflow.operators import dummy_operator

from dependencies import commons
from dependencies.tables import TABLES, SEMANTICS_TABLES, AUXILIARY_STAGING_TABLES
from dependencies.tables import BIG_PARTITIONED_TABLES, LAST_MODIFIED_LOG_TABLE
from dependencies.tables import BQ_CONNECTOR_TABLES, MYSQL_CLOUD_FUNCTION_TABLES

DAG_NAME = "CMS_Incremental_Reload"
DAG_VERSION = "0.18"

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
    "start_date": datetime.datetime(2020, 9, 16, 9),
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
    .__str__(),
    "start_ts": (
        datetime.datetime.utcnow().replace(
            microsecond=0, second=0, minute=0, tzinfo=UTC
        )
        - datetime.timedelta(hours=1)
    ).__str__(),
    "project_name": PROJECT_NAME,
}

with models.DAG(
    dag_id="{dag_name}-v{dag_version}".format(
        dag_name=DAG_NAME, dag_version=DAG_VERSION
    ),
    description="Performs an incremental update of CMS data.",
    default_args=DEFAULT_ARGS,
    schedule_interval="2 1-23 * * *",
    catchup=False,
) as dag:

    start = dummy_operator.DummyOperator(task_id="START")
    dummy_after_staging = dummy_operator.DummyOperator(task_id="DummyOp-GroupStaging")
    end = dummy_operator.DummyOperator(task_id="END")

    ingest_to_staging_dedup = [
        [
            commons.load_table_to_staging(
                table_info=table_info,
                dataset="staging",
                gcp_conn_id=GCP_CONN_ID,
                dataflow_options=DATAFLOW_OPTIONS,
                jinja_templating_params=JINJA_TEMPLATE_PARAMS,
                query_dir=QUERIES_BASE_PATH + "staging",
                service_account=SERVICE_ACCOUNT,
                gcp_project=PROJECT_NAME,
            ),
            commons.deduplicate_table_with_latests_records(
                table_name=table_info["table"],
                table_id_field=table_info["id_field"],
                table_update_field=table_info["update_field"],
                dataset="staging",
                gcp_conn_id=GCP_CONN_ID,
                gcp_project=PROJECT_NAME,
            ),
        ]
        for table_info in TABLES
    ]

    ingest_to_staging_dedup.extend(
        [
            [
                commons.load_table_to_staging_http_cloud_function(
                    table_info=table_info,
                    dataset="staging",
                    gcp_conn_id=GCP_CONN_ID,
                    jinja_templating_params=JINJA_TEMPLATE_PARAMS,
                    query_dir=QUERIES_BASE_PATH + "staging",
                    service_account=SERVICE_ACCOUNT,
                    gcp_project=PROJECT_NAME,
                    truncate_table=True,
                ),
                commons.deduplicate_table_with_latests_records(
                    table_name=table_info["table"],
                    table_id_field=table_info["id_field"],
                    table_update_field=table_info["update_field"],
                    dataset="staging",
                    gcp_conn_id=GCP_CONN_ID,
                    gcp_project=PROJECT_NAME,
                ),
            ]
            for table_info in BQ_CONNECTOR_TABLES
        ]
    )

    ingest_to_staging_dedup.extend(
        [
            [
                commons.load_mysql_table_to_staging_http_cloud_function(
                    table_info=table_info,
                    dataset="staging",
                    gcp_conn_id=GCP_CONN_ID,
                    jinja_templating_params=JINJA_TEMPLATE_PARAMS,
                    query_dir=QUERIES_BASE_PATH + "staging",
                    service_account=SERVICE_ACCOUNT,
                    gcp_project=PROJECT_NAME,
                    truncate_table=True,
                ),
                commons.deduplicate_table_with_latests_records(
                    table_name=table_info["table"],
                    table_id_field=table_info["id_field"],
                    table_update_field=table_info["update_field"],
                    dataset="staging",
                    gcp_conn_id=GCP_CONN_ID,
                    gcp_project=PROJECT_NAME,
                ),
            ]
            for table_info in MYSQL_CLOUD_FUNCTION_TABLES
        ]
    )

    staging_to_semantics_incremental = [
        commons.semantics_bigquery_job_incremental(
            table_name=tname,
            base_query_dir=QUERIES_BASE_PATH + "semantics",
            gcp_conn_id=GCP_CONN_ID,
            service_account=SERVICE_ACCOUNT,
            jinja_templating_params=JINJA_TEMPLATE_PARAMS,
            gcp_project=PROJECT_NAME,
        )
        for tname in SEMANTICS_TABLES
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

    for ingest_dedup in ingest_to_staging_dedup:
        start >> ingest_dedup[0] >> ingest_dedup[1] >> dummy_after_staging
    dummy_after_staging >> staging_to_semantics_incremental >> end
    # last_modified_log_table_delete
    # last_modified_log_table_delete >> last_modified_log_record >> dummy_after_logging_regular_tables
    # dummy_after_logging_regular_tables >> partitioned_last_modified_log_record >> end

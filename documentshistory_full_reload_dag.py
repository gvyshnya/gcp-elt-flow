from os import environ
import datetime
from dateutil.relativedelta import relativedelta
from pytz import UTC
from itertools import chain
from airflow import models
from airflow.operators import dummy_operator

from dependencies import commons
from dependencies.tables import TABLES, SEMANTICS_TABLES, LAST_MODIFIED_LOG_TABLE

DAG_NAME = "DocumentsHistory_Full_Reload"
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
    "start_date": datetime.datetime(2020, 4, 8),
    "email": [
        "orb@abc.com",
    ],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": datetime.timedelta(minutes=2),
}

ENTITY_NAME = "DocumentHistory"

jinja_template_parameter_array = []

start_date = datetime.datetime(
    2018, 1, 1, tzinfo=UTC
)  # the start date to load CustomerHistory Data from
end_date = datetime.datetime.utcnow().replace(
    microsecond=0, second=0, minute=0, tzinfo=UTC
)  # final load data - the previous calendar day
month_increment = 1

cur_start_date = start_date
cur_end_date = cur_start_date + relativedelta(months=+month_increment)

while cur_end_date <= end_date:

    jinja_template_parameters = {
        "end_ts": cur_end_date.isoformat(),
        "start_ts": cur_start_date.isoformat(),
        "project_name": PROJECT_NAME,
    }

    jinja_template_parameter_array.append(jinja_template_parameters)

    # go to the next time interval
    cur_start_date = cur_end_date
    cur_end_date = cur_start_date + relativedelta(months=+month_increment)

jinja_template_parameter_array.append(
    {
        "end_ts": end_date.isoformat(),
        "start_ts": cur_start_date.isoformat(),
        "project_name": PROJECT_NAME,
    }
)

JINJA_TEMPLATE_PARAMS = {
    "end_ts": datetime.datetime.utcnow()
    .replace(microsecond=0, second=0, minute=0, tzinfo=UTC)
    .isoformat(),
    "start_ts": datetime.datetime(2018, 1, 1, tzinfo=UTC).isoformat(),
    "project_name": PROJECT_NAME,
}


with models.DAG(
    dag_id="{dag_name}-v{dag_version}".format(
        dag_name=DAG_NAME, dag_version=DAG_VERSION
    ),
    description="Performs a full reload of CMS data in " + ENTITY_NAME,
    default_args=DEFAULT_ARGS,
    schedule_interval=None,
) as dag:

    start = dummy_operator.DummyOperator(task_id="START")
    end = dummy_operator.DummyOperator(task_id="END")
    dummy_after_delete = dummy_operator.DummyOperator(
        task_id="DocumentHistory-DummyOp-GroupDeletes"
    )
    dummy_after_staging = dummy_operator.DummyOperator(
        task_id="DocumentHistory-DummyOp-GroupStaging"
    )

    tables_deletes = [
        commons.delete_table(table_info["table"], "staging", gcp_project=PROJECT_NAME)
        for table_info in TABLES
        if table_info["table"] in [ENTITY_NAME]
    ]

    ingest_to_staging = [
        commons.load_table_time_split_to_staging (
            table_info=table_info,
            dataset="staging",
            gcp_conn_id=GCP_CONN_ID,
            dataflow_options=DATAFLOW_OPTIONS,
            jinja_templating_params=jinja_template_parameters,
            query_dir=QUERIES_BASE_PATH + "staging",
            service_account=SERVICE_ACCOUNT,
            gcp_project=PROJECT_NAME,
        )
        for table_info in TABLES
        if table_info["table"] in [ENTITY_NAME]
        for jinja_template_parameters in jinja_template_parameter_array
    ]

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
        if tname in [ENTITY_NAME]
    ]

    last_modified_log_delete = commons.delete_entity_last_modified_log(
        ENTITY_NAME, "semantics_central", gcp_project=PROJECT_NAME)
    
    partitioned_last_modified_log_record = [
        commons.semantics_bigquery_record_partitioned_entity_last_modified(
            entity_table_name=table_info["table"],
            entity_update_field=table_info["update_field"],
            dataset="semantics_central",
            gcp_conn_id=GCP_CONN_ID,
            base_query_dir=QUERIES_BASE_PATH,
            service_account=SERVICE_ACCOUNT,
            gcp_project=PROJECT_NAME,
            truncate_table=False,
        )
        for table_info in TABLES
        if table_info["table"]  in [ENTITY_NAME]
    ]

    ingest_to_staging = list(chain(*ingest_to_staging))

    start >> tables_deletes >> dummy_after_delete >> ingest_to_staging
    ingest_to_staging >> dummy_after_staging >> staging_to_semantics
    staging_to_semantics >> last_modified_log_delete >> partitioned_last_modified_log_record >> end

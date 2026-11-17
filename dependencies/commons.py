from os import environ
from typing import Dict, List
import datetime
from airflow.contrib.operators.dataflow_operator import DataflowTemplateOperator
from airflow.contrib.operators import bigquery_get_data


DEFAULT_TEMPLATE = "gs://dataflow-templates/latest/Jdbc_to_BigQuery"
DEFAULT_PROJECT = "ABC-BI-dev"

DEFAULT_BI_REPLICA_NAME = "placeholder"

LAST_MODIFIED_LOG_TABLE = "t_TablesLastUpdated"

ENV_CODE = environ.get("ENV_CODE")
DATAFLOW_EXTRAS_BUCKET = f"gs://abc_dataflow_{ENV_CODE}"
DEFAULT_BQ_TEMP_DIR = f"{DATAFLOW_EXTRAS_BUCKET}/bq_tmp"

MYSQL_DRIVER_JARS = (
    f"{DATAFLOW_EXTRAS_BUCKET}/mysql_jars/mysql-connector-java-8.0.13.jar,"
    f"{DATAFLOW_EXTRAS_BUCKET}/mysql_jars/mysql-socket-factory-connector-j-8-1.0.12-jar-with-dependencies.jar"
)
MYSQL_DRIVER_CLASS = "com.mysql.jdbc.Driver"

MYSQL_URL = (
    "jdbc:mysql://google/{service_db}?cloudSqlInstance="
    "{replica_project}:{replica_region}:{replica_name}&socketFactory="
    "com.google.cloud.sql.mysql.SocketFactory&useSSL=false&useOldAliasMetadataBehavior=true"
    "&user={user}&password={password}"
)


def get_data_from_timestamp_table(dataset: str,):
    from airflow.contrib.operators import bigquery_get_data

    return bigquery_get_data.BigQueryGetDataOperator(
        dataset_id=dataset,
        table_id=LAST_MODIFIED_LOG_TABLE,
        max_results="1000",
        task_id="get_timestamp_data_from_bq",
    )


def load_table_to_staging(
    table_info: Dict,
    dataset: str,
    gcp_conn_id: str,
    dataflow_options: Dict[str, str],
    jinja_templating_params: Dict[str, str],
    query_dir: str = "./",
    service_account: str = None,
    gcp_project: str = DEFAULT_PROJECT,
    template: str = DEFAULT_TEMPLATE,
    bq_temp_dir: str = DEFAULT_BQ_TEMP_DIR,
) -> List[DataflowTemplateOperator]:
    query_file = "{}/{}.sql".format(query_dir, table_info["table"])
    with open(query_file, "r") as qf:
        query = qf.read().replace("\n", " ")

    return [
        DataflowTemplateOperator(
            task_id=f'{table_info["table"]}_{replica_instance["country"]}'.lower().replace(
                ",", "-"
            ),
            template=template,
            parameters={
                "driverJars": MYSQL_DRIVER_JARS,
                "driverClassName": MYSQL_DRIVER_CLASS,
                "connectionURL": MYSQL_URL.format(
                    service_db=table_info["service_db"],
                    user=replica_instance["user"],
                    password=replica_instance["password"],
                    replica_project=replica_instance["project"],
                    replica_region=replica_instance["region"],
                    replica_name=replica_instance["replica"],
                ),
                "outputTable": f'{gcp_project}:{dataset}.{table_info["table"]}',
                "bigQueryLoadingTemporaryDirectory": bq_temp_dir,
                "query": query,
            },
            delegate_to=service_account,
            gcp_conn_id=gcp_conn_id,
            dataflow_default_options={
                **dataflow_options,
                "machineType": replica_instance["dataflow_machine_type"],
            },
            params=jinja_templating_params,
        )
        for replica_instance in table_info["instances"]
    ]


def load_table_time_split_to_staging(
    table_info: Dict,
    dataset: str,
    gcp_conn_id: str,
    dataflow_options: Dict[str, str],
    jinja_templating_params: Dict[str, str],
    query_dir: str = "./",
    service_account: str = None,
    gcp_project: str = DEFAULT_PROJECT,
    template: str = DEFAULT_TEMPLATE,
    bq_temp_dir: str = DEFAULT_BQ_TEMP_DIR,
) -> List[DataflowTemplateOperator]:
    query_file = "{}/{}.sql".format(query_dir, table_info["table"])
    with open(query_file, "r") as qf:
        query = qf.read().replace("\n", " ")

    start_date_str = jinja_templating_params["start_ts"][0:10]
    end_date_str = jinja_templating_params["end_ts"][0:10]

    return [
        DataflowTemplateOperator(
            task_id=f'{table_info["table"]}_{start_date_str}_{end_date_str}_{replica_instance["country"]}'.lower().replace(
                ",", "-"
            ),
            template=template,
            parameters={
                "driverJars": MYSQL_DRIVER_JARS,
                "driverClassName": MYSQL_DRIVER_CLASS,
                "connectionURL": MYSQL_URL.format(
                    service_db=table_info["service_db"],
                    user=replica_instance["user"],
                    password=replica_instance["password"],
                    replica_project=replica_instance["project"],
                    replica_region=replica_instance["region"],
                    replica_name=replica_instance["replica"],
                ),
                "outputTable": f'{gcp_project}:{dataset}.{table_info["table"]}',
                "bigQueryLoadingTemporaryDirectory": bq_temp_dir,
                "query": query,
            },
            delegate_to=service_account,
            gcp_conn_id=gcp_conn_id,
            dataflow_default_options={
                **dataflow_options,
                "machineType": replica_instance["dataflow_machine_type"],
            },
            params=jinja_templating_params,
        )
        for replica_instance in table_info["instances"]
    ]


def load_table_to_staging_with_custom_params(
    table_name: str,
    db_user: str,
    db_password: str,
    service_db: str,
    dataset: str,
    query_dir: str,
    gcp_conn_id: str,
    service_account: str,
    gcp_project: str,
    bi_replica_name: str,
    bi_replica_project: str,
    bi_replica_region: str,
    dataflow_options: Dict[str, str],
    base_jinja_templating_params: Dict[str, str],
    custom_jinja_templating_params: Dict[str, str],
    template: str = DEFAULT_TEMPLATE,
    bq_temp_dir: str = DEFAULT_BQ_TEMP_DIR,
    task_id: str = None,
):
    from airflow.contrib.operators import dataflow_operator

    dict_jinja_templating_params = base_jinja_templating_params.copy()
    dict_jinja_templating_params.update(custom_jinja_templating_params)

    task_id_str = ""
    if len(task_id) == 0:
        task_id_str = table_name.lower()
    else:
        task_id_str = task_id

    query_file = "{}/{}.sql".format(query_dir, table_name)
    with open(query_file, "r") as qf:
        query = qf.read().replace("\n", " ")
    return dataflow_operator.DataflowTemplateOperator(
        task_id=task_id_str,
        template=template,
        parameters={
            "driverJars": MYSQL_DRIVER_JARS,
            "driverClassName": MYSQL_DRIVER_CLASS,
            "connectionURL": MYSQL_URL.format(
                user=db_user,
                password=db_password,
                service_db=service_db,
                replica_project=bi_replica_project,
                replica_region=bi_replica_region,
                replica_name=bi_replica_name,
            ),
            "outputTable": "{}:{}.{}".format(gcp_project, dataset, table_name),
            "bigQueryLoadingTemporaryDirectory": bq_temp_dir,
            "query": query,
        },
        delegate_to=service_account,
        gcp_conn_id=gcp_conn_id,
        dataflow_default_options=dataflow_options,
        params=dict_jinja_templating_params,
    )


def full_reload_table(
    table_name: str,
    db_user: str,
    db_password: str,
    service_db: str,
    dataset: str,
    gcp_conn_id: str,
    dataflow_options: Dict[str, str],
    jinja_templating_params: Dict[str, str],
    bi_replica_project: str,
    bi_replica_region: str,
    bi_replica_name: str = DEFAULT_BI_REPLICA_NAME,
    gcp_project: str = DEFAULT_PROJECT,
    template: str = DEFAULT_TEMPLATE,
    bq_temp_dir: str = DEFAULT_BQ_TEMP_DIR,
    query_dir: str = "./",
    service_account: str = None,
):
    from airflow.contrib.operators import dataflow_operator

    query_file = "{}/{}.sql".format(query_dir, table_name)
    with open(query_file, "r") as qf:
        query = qf.read().replace("\n", " ")
    return dataflow_operator.DataflowTemplateOperator(
        task_id=table_name.lower(),
        template=template,
        parameters={
            "driverJars": MYSQL_DRIVER_JARS,
            "driverClassName": MYSQL_DRIVER_CLASS,
            "connectionURL": MYSQL_URL.format(
                user=db_user,
                password=db_password,
                service_db=service_db,
                replica_project=bi_replica_project,
                replica_region=bi_replica_region,
                replica_name=bi_replica_name,
            ),
            "outputTable": "{}:{}.{}".format(gcp_project, dataset, table_name),
            "bigQueryLoadingTemporaryDirectory": bq_temp_dir,
            "query": query,
        },
        delegate_to=service_account,
        gcp_conn_id=gcp_conn_id,
        dataflow_default_options=dataflow_options,
        params=jinja_templating_params,
    )


def load_table_to_staging_http_cloud_function(
    table_info: Dict,
    dataset: str,
    gcp_conn_id: str,
    jinja_templating_params: Dict[str, str],
    query_dir: str = "./",
    service_account: str = None,
    gcp_project: str = DEFAULT_PROJECT,
    truncate_table: bool = True,
):
    from airflow.operators.http_operator import SimpleHttpOperator
    from jinja2 import Template
    import json

    query_file = "{}/{}.sql".format(query_dir, table_info["table"])
    with open(query_file, "r") as qf:
        query_templated = Template(qf.read().replace("\n", " "))

    query = query_templated.render(params=jinja_templating_params)

    operators_by_instance = []

    for replica_instance in table_info["instances"]:
        request_data = {
            "rdbms_engine": "postgresql",
            "db_config": {
                "db_user": replica_instance["user"],
                "db_pass": replica_instance["password"],
                "db_name": table_info["service_db"],
                "cloud_sql_connection_name": '{}:{}:{}'.format(
                    replica_instance["project"],
                    replica_instance["region"],
                    replica_instance["replica"],
                ),
            },
            "source_query": query,
            "target_dataset": dataset,
            "target_table": table_info["table"],
        }

        operators_by_instance.append(
            SimpleHttpOperator(
                task_id=f'{table_info["table"]}_{replica_instance["country"]}'.lower().replace(
                    ",", "-"
                ),
                endpoint="/",
                http_conn_id="bi-flow-cloud-function",
                data=json.dumps(request_data),
                extra_options={"timeout": 550},
                log_response=True,
                headers={"Content-Type": "application/json"},
                response_check=(
                    lambda response: True if response.status_code == 200 else False
                ),
            )
        )
    return operators_by_instance

def load_mysql_table_to_staging_http_cloud_function(
    table_info: Dict,
    dataset: str,
    gcp_conn_id: str,
    jinja_templating_params: Dict[str, str],
    query_dir: str = "./",
    service_account: str = None,
    gcp_project: str = DEFAULT_PROJECT,
    truncate_table: bool = True,
):
    from airflow.operators.http_operator import SimpleHttpOperator
    from jinja2 import Template
    import json

    query_file = "{}/{}.sql".format(query_dir, table_info["table"])
    with open(query_file, "r") as qf:
        query_templated = Template(qf.read().replace("\n", " "))

    query = query_templated.render(params=jinja_templating_params)

    operators_by_instance = []

    for replica_instance in table_info["instances"]:
        request_data = {
            "rdbms_engine": "mysql",
            "db_config": {
                "db_user": replica_instance["user"],
                "db_pass": replica_instance["password"],
                "db_name": table_info["service_db"],
                "cloud_sql_connection_name": '{}:{}:{}'.format(
                    replica_instance["project"],
                    replica_instance["region"],
                    replica_instance["replica"],
                ),
            },
            "source_query": query,
            "target_dataset": dataset,
            "target_table": table_info["table"],
        }

        operators_by_instance.append(
            SimpleHttpOperator(
                task_id=f'{table_info["table"]}_{replica_instance["country"]}'.lower().replace(
                    ",", "-"
                ),
                endpoint="/",
                http_conn_id="bi-flow-cloud-function",
                data=json.dumps(request_data),
                extra_options={"timeout": 550},
                log_response=True,
                headers={"Content-Type": "application/json"},
                response_check=(
                    lambda response: True if response.status_code == 200 else False
                ),
            )
        )
    return operators_by_instance


def semantics_bigquery_job_full_reload(
    table_name: str,
    relative_base_path: str,
    dataset: str,
    gcp_conn_id: str,
    jinja_templating_params: Dict[str, str],
    service_account: str = None,
    gcp_project: str = DEFAULT_PROJECT,
    truncate_table: bool = True,
):
    from airflow.contrib.operators import bigquery_operator

    return bigquery_operator.BigQueryOperator(
        task_id="{}-toSemantics".format(table_name),
        sql="{rel_base_path}/{table}.sql".format(
            rel_base_path=relative_base_path, table=table_name
        ),
        destination_dataset_table="{}.{}.{}".format(gcp_project, dataset, table_name),
        write_disposition="WRITE_TRUNCATE" if truncate_table else "WRITE_APPEND",
        allow_large_results=True,
        bigquery_conn_id=gcp_conn_id,
        delegate_to=service_account,
        location="EU",
        use_legacy_sql=False,
        params=jinja_templating_params,
    )


def delete_table(table_name: str, dataset: str, gcp_project: str = DEFAULT_PROJECT):
    from airflow.contrib.operators import bigquery_operator

    return bigquery_operator.BigQueryOperator(
        task_id="delete-{}".format(table_name.lower()),
        sql="delete FROM `{project}.{dataset}.{table}` where true".format(
            project=gcp_project, dataset=dataset, table=table_name
        ),
        location="EU",
        use_legacy_sql=False,
    )


def delete_entity_last_modified_log(
    entity_name: str, dataset: str, gcp_project: str = DEFAULT_PROJECT
):

    from airflow.contrib.operators import bigquery_operator

    return bigquery_operator.BigQueryOperator(
        task_id="delete-{}-timestamp-log".format(entity_name.lower()),
        sql="DELETE FROM `{project}.{dataset}.{log_table_name}` where table_name ='{entity}'".format(
            project=gcp_project,
            dataset=dataset,
            entity=entity_name,
            log_table_name=LAST_MODIFIED_LOG_TABLE,
        ),
        location="EU",
        use_legacy_sql=False,
    )


def semantics_bigquery_record_entity_last_modified(
    entity_table_name: str,
    entity_update_field: str,
    dataset: str,
    gcp_conn_id: str,
    base_query_dir: str = "./",
    service_account: str = None,
    gcp_project: str = DEFAULT_PROJECT,
    truncate_table: bool = True,
):

    from airflow.contrib.operators import bigquery_operator

    query = (
        "SELECT "
        "table_name, "
        "updated_at, "
        "CAST (TIMESTAMP_SUB( CAST (updated_at as TIMESTAMP), INTERVAL cm.country_timezone_offset_minutes MINUTE) as DATETIME) as updated_at_utc, "
        "latest.country_id "
        "FROM ( "
        "SELECT "
        "'{entity_name}' as table_name, "
        "MAX({update_field}) as updated_at, "
        "e.country_id "
        "FROM `{project_name}.semantics_central.{entity_name}` e "
        "GROUP BY country_id "
        ") latest "
        "JOIN `{project_name}.semantics_central.CountryMetadata` cm "
        "ON cm.country_id = latest.country_id "
    )

    query = query.format(
        project_name=gcp_project,
        entity_name=entity_table_name,
        update_field=entity_update_field,
    )

    return bigquery_operator.BigQueryOperator(
        task_id="{}-lastModifiedLog".format(entity_table_name),
        sql=query,
        destination_dataset_table="{}.{}.{}".format(
            gcp_project, dataset, LAST_MODIFIED_LOG_TABLE
        ),
        write_disposition="WRITE_TRUNCATE" if truncate_table else "WRITE_APPEND",
        bigquery_conn_id=gcp_conn_id,
        delegate_to=service_account,
        location="EU",
        use_legacy_sql=False,
    )


def semantics_bigquery_record_partitioned_entity_last_modified(
    entity_table_name: str,
    entity_update_field: str,
    dataset: str,
    gcp_conn_id: str,
    base_query_dir: str = "./",
    service_account: str = None,
    gcp_project: str = DEFAULT_PROJECT,
    truncate_table: bool = True,
):

    from airflow.contrib.operators import bigquery_operator

    query = (
        "SELECT "
        "table_name, "
        "updated_at, "
        "CAST (TIMESTAMP_SUB( CAST (updated_at as TIMESTAMP), INTERVAL cm.country_timezone_offset_minutes MINUTE) as DATETIME) as updated_at_utc, "
        "latest.country_id "
        "FROM ( "
        "SELECT "
        "'{entity_name}' as table_name, "
        "MAX({update_field}) as updated_at, "
        "e.partition_date, "
        "e.country_id "
        "FROM `{project_name}.semantics_central.{entity_name}` e "
        "GROUP BY country_id, partition_date "
        ") latest "
        "JOIN `{project_name}.semantics_central.CountryMetadata` cm "
        "ON cm.country_id = latest.country_id "
        "JOIN ("
        "SELECT MAX(partition_date) as partition_date "
        "FROM `{project_name}.semantics_central.{entity_name}` ee "
        ") latest_partition "
        "ON latest_partition.partition_date = latest.partition_date"
    )

    query = query.format(
        project_name=gcp_project,
        entity_name=entity_table_name,
        update_field=entity_update_field,
    )

    return bigquery_operator.BigQueryOperator(
        task_id="{}-lastModifiedLog".format(entity_table_name),
        sql=query,
        destination_dataset_table="{}.{}.{}".format(
            gcp_project, dataset, LAST_MODIFIED_LOG_TABLE
        ),
        write_disposition="WRITE_TRUNCATE" if truncate_table else "WRITE_APPEND",
        bigquery_conn_id=gcp_conn_id,
        delegate_to=service_account,
        location="EU",
        use_legacy_sql=False,
    )


def semantics_bigquery_job_full_reload(
    table_name: str,
    relative_base_path: str,
    dataset: str,
    gcp_conn_id: str,
    jinja_templating_params: Dict[str, str],
    service_account: str = None,
    gcp_project: str = DEFAULT_PROJECT,
    truncate_table: bool = True,
):
    from airflow.contrib.operators import bigquery_operator

    return bigquery_operator.BigQueryOperator(
        task_id="{}-toSemantics".format(table_name),
        sql="{rel_base_path}/{table}.sql".format(
            rel_base_path=relative_base_path, table=table_name
        ),
        destination_dataset_table="{}.{}.{}".format(gcp_project, dataset, table_name),
        write_disposition="WRITE_TRUNCATE" if truncate_table else "WRITE_APPEND",
        allow_large_results=True,
        bigquery_conn_id=gcp_conn_id,
        delegate_to=service_account,
        location="EU",
        use_legacy_sql=False,
        params=jinja_templating_params,
    )


def semantics_bigquery_customer_history_job_full_reload(
    table_name: str,
    relative_base_path: str,
    dataset: str,
    gcp_conn_id: str,
    jinja_templating_params: Dict[str, str],
    start_date_str: str,
    end_date_str: str,
    service_account: str = None,
    gcp_project: str = DEFAULT_PROJECT,
    truncate_table: bool = True,
):
    from airflow.contrib.operators import bigquery_operator

    return bigquery_operator.BigQueryOperator(
        task_id="{}-{}-{}-toSemantics".format(table_name, start_date_str, end_date_str),
        sql="{rel_base_path}/{table}.sql".format(
            rel_base_path=relative_base_path, table=table_name
        ),
        destination_dataset_table="{}.{}.{}".format(gcp_project, dataset, table_name),
        write_disposition="WRITE_TRUNCATE" if truncate_table else "WRITE_APPEND",
        allow_large_results=True,
        bigquery_conn_id=gcp_conn_id,
        delegate_to=service_account,
        location="EU",
        use_legacy_sql=False,
        params=jinja_templating_params,
    )


def semantics_bigquery_job_incremental(
    table_name: str,
    gcp_conn_id: str,
    jinja_templating_params: Dict[str, str],
    base_query_dir: str = "./",
    service_account: str = None,
    gcp_project: str = DEFAULT_PROJECT,
):
    from airflow.contrib.operators import bigquery_operator
    from jinja2 import Template

    incremental_queries_dir = "/incremental"
    range_query_file = "{}/{}.sql".format(base_query_dir, table_name)
    incremental_queries_file = "{}/{}.sql".format(
        base_query_dir + incremental_queries_dir, table_name
    )
    with open(range_query_file, "r") as qf:
        range_query_sql = qf.read()
    with open(incremental_queries_file, "r") as iqf:
        incremental_query_templated = Template(iqf.read())
    incremental_query = incremental_query_templated.render(
        range_query=range_query_sql, params=jinja_templating_params
    )
    return bigquery_operator.BigQueryOperator(
        task_id="{}-Incremental-toSemantics".format(table_name),
        sql=incremental_query,
        allow_large_results=True,
        bigquery_conn_id=gcp_conn_id,
        delegate_to=service_account,
        location="EU",
        use_legacy_sql=False,
        params=jinja_templating_params,
    )


def clean_up_table(
    table_name: str,
    relative_base_path: str,
    gcp_conn_id: str,
    jinja_templating_params: Dict[str, str],
    service_account: str = None,
    extra_id_text: str = None,
    gcp_project: str = DEFAULT_PROJECT,
):
    from airflow.contrib.operators import bigquery_operator

    return bigquery_operator.BigQueryOperator(
        task_id="{}-CleanUp{}".format(table_name, extra_id_text),
        sql="{rel_base_path}/{table}.sql".format(
            rel_base_path=relative_base_path, table=table_name
        ),
        bigquery_conn_id=gcp_conn_id,
        delegate_to=service_account,
        location="EU",
        use_legacy_sql=False,
        params=jinja_templating_params,
    )


def deduplicate_table_with_latests_records(
    table_name: str,
    table_id_field: str,
    table_update_field: str,
    dataset: str,
    gcp_conn_id: str,
    gcp_project: str = DEFAULT_PROJECT,
    service_account: str = None,
):
    from airflow.contrib.operators import bigquery_operator

    dedup_query = (
        "CREATE OR REPLACE TABLE `{project}.{dataset}.{table_name}` AS"
        " SELECT * EXCEPT(dedup) FROM ("
        "SELECT *, row_number() OVER(PARTITION BY {table_id_field} ORDER BY {table_update_field} DESC) AS dedup"
        " FROM `{project}.{dataset}.{table_name}`)"
        " WHERE dedup = 1"
    )

    dedup_query = dedup_query.format(
        project=gcp_project,
        dataset=dataset,
        table_name=table_name,
        table_id_field=table_id_field,
        table_update_field=table_update_field,
    )
    return bigquery_operator.BigQueryOperator(
        task_id="{}-{}-Deduplication".format(table_name, dataset),
        sql=dedup_query,
        bigquery_conn_id=gcp_conn_id,
        delegate_to=service_account,
        location="EU",
        use_legacy_sql=False,
    )

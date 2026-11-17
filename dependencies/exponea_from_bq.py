from typing import List
from airflow.contrib.operators import bigquery_operator

# Send to config file
DEFAULT_PROJECT = "ABC-BI-dev"
EXPONEA_PROJECT = "gcloudltds"

COUNTRY_CONFIG = {
    "IN": {
        "exponea_project_name": "India",
        "dataset": "abc_7da87ce4_9170_11e8_8823_0a580a201a47_views",
        "tables": [
            "_system_load_log",
            "affiliate_lead",
            "appointmentupdate__02283a74",
            "banner",
            "booked",
            "campaign",
            "campaign_sent__ab8e6390",
            "car_procured__1bee2095",
            "customers_external_ids",
            "customers_id_history",
            "customers_properties",
            "duplicated_quote",
            "first_session",
            "import",
            "inspection_completed__83fe4c68",
            "merge",
            "page_visit",
            "purchase",
            "quote",
            "session_end",
            "session_start",
            "showup__8c1762dc",
            "subscriptions_changed",
            "webhook_response",
        ],
    }
}


def copy_exponea_country_dataset(
    country: str,
    gcp_conn_id: str,
    service_account: str = None,
    gcp_project: str = DEFAULT_PROJECT,
    exponea_project: str = EXPONEA_PROJECT,
) -> List[bigquery_operator.BigQueryOperator]:
    country_conf = COUNTRY_CONFIG[country]
    country_dataset = "Exponea_{}".format(country_conf["exponea_project_name"])
    tables_operators = [
        bigquery_operator.BigQueryOperator(
            task_id="{}-toExponea_{}".format(
                tname, country_conf["exponea_project_name"]
            ),
            sql="select * from {}.{}.{}".format(
                exponea_project, country_conf["dataset"], tname
            ),
            destination_dataset_table="{}.{}.{}".format(
                gcp_project, country_dataset, tname
            ),
            write_disposition="WRITE_TRUNCATE",
            allow_large_results=True,
            bigquery_conn_id=gcp_conn_id,
            delegate_to=service_account,
            location="EU",
            use_legacy_sql=False,
        )
        for tname in country_conf["tables"]
    ]
    return tables_operators

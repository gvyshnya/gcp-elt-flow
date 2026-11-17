from airflow.operators.python_operator import PythonVirtualenvOperator
from airflow import models
import os
import pytz
import datetime


DAG_NAME = "Salesforce_Integration_ID"
DAG_VERSION = "0.3"

PROJECT_NAME = os.environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = os.environ.get("DATAFLOW_SERVICE_ACCOUNT")
GCP_CONN_ID = os.environ.get("CONNECTION_ID")

SALESFORCE_BUCKET_PREFIX = os.environ.get("SALESFORCE_BUCKET_PREFIX")

DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime.datetime(2020, 8, 9, 12, 00),
    "email": [
        "orb@abc.com",
        "obfuscated@abc.com",
    ],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": datetime.timedelta(minutes=2),
}

generated_at = datetime.datetime.now(tz=pytz.timezone("UTC"))

dealers_query = f"SELECT * FROM `{PROJECT_NAME}.salesforce_integration_ID.Dealers`"
dealer_managers_query = f"SELECT * FROM `{PROJECT_NAME}.salesforce_integration_ID.UserPerformance`"
dealer_performance_query = f"SELECT * FROM `{PROJECT_NAME}.salesforce_integration_ID.CtxPerformance`"


def report_export(query: str, full_file_path: str, gcp_project_id: str) -> None:
    import pandas as pd

    (
        pd.read_gbq(query, project_id=gcp_project_id, dialect="standard").to_csv(
            full_file_path, index=False
        )
    )


with models.DAG(
    dag_id=f"{DAG_NAME}-v{DAG_VERSION}",
    description="Performs an incremental update of CMS data.",
    default_args=DEFAULT_ARGS,
    schedule_interval="1 17 * * *",
    catchup=False,
) as dag:

    generate_dealers_file = PythonVirtualenvOperator(
        task_id="Dealers_File_ID",
        python_callable=report_export,
        requirements=["pandas==1.0.5", "gcsfs", "pandas-gbq==0.9.0"],
        python_version="3",
        op_args=[
            dealers_query,
            "gs://salesforce-integration-jobs/CTx_Jobs/Data/Dealer/Import/Dealers_{}.csv".format(
                generated_at.strftime("%Y%m%d_%H%M%S")
            ),
            PROJECT_NAME,
        ],
    )

    generate_dealer_performance_file = PythonVirtualenvOperator(
        task_id="Dealer_Performance_File_ID",
        python_callable=report_export,
        requirements=["pandas==1.0.5", "gcsfs", "pandas-gbq==0.9.0"],
        python_version="3",
        op_args=[
            dealer_performance_query,
            "gs://salesforce-integration-jobs/CTx_Jobs/Data/CTx_Performance/Import/CtxPerformance_{}.csv".format(
                generated_at.strftime("%Y%m%d_%H%M%S")
            ),
            PROJECT_NAME,
        ],
    )

    generate_dealer_managers_file = PythonVirtualenvOperator(
        task_id="Dealer_Managers_File_ID",
        python_callable=report_export,
        requirements=["pandas==1.0.5", "gcsfs", "pandas-gbq==0.9.0"],
        python_version="3",
        op_args=[
            dealer_managers_query,
            "gs://salesforce-integration-jobs/CTx_Jobs/Data/User_Performance/Import/UserPerformance_{}.csv".format(
                generated_at.strftime("%Y%m%d_%H%M%S")
            ),
            PROJECT_NAME,
        ],
    )

    generate_dealers_file
    generate_dealer_performance_file
    generate_dealer_managers_file

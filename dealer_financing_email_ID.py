from airflow.operators.python_operator import PythonVirtualenvOperator
from airflow.operators import email_operator
from airflow import models
import os
import pytz
import datetime


DAG_NAME = "DealerFinancing_Reports_Emails_ID"
DAG_VERSION = "0.4"

PROJECT_NAME = os.environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = os.environ.get("DATAFLOW_SERVICE_ACCOUNT")
GCP_CONN_ID = os.environ.get("CONNECTION_ID") 

BUCKET_PREFIX = os.environ.get("BUCKET_PREFIX")

DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime.datetime(2020, 11, 12, 0),
    "email": [
        "orb@abc.com"
    ],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": datetime.timedelta(minutes=2),
}

receiver_addresses = [
    "list@abc.com",
]
bcc_addresses = [
    "bcc@abc.com",
]

report_daily_query = f"""
SELECT
fc.internal_id as ABC_ID,
fc.dealership_name as Dealership_Name,
d.dealer_name as Dealer_Name,
JSON_EXTRACT_SCALAR(fl.car_data, "$.make") as Make,
JSON_EXTRACT_SCALAR(fl.car_data, "$.model") as `Model`,
JSON_EXTRACT_SCALAR(fl.car_data, "$.trim") as Trim,
JSON_EXTRACT_SCALAR(fl.car_data, "$.licensePlate") as License_Plate,
fl.status as Loan_Status,
fl.sale_price as Sale_Price,
fl.amount as Loan_Amount,
JSON_EXTRACT_SCALAR(fl.fees , "$['fee.loan']") as Processing_Fee,
fl.created_at as Created_At
FROM `{PROJECT_NAME}.semantics_central.FinancingLoans` fl
INNER JOIN `{PROJECT_NAME}.semantics_central.FinancingCustomers` fc using(financing_customer_id)
INNER JOIN `{PROJECT_NAME}.semantics_central.Dealers` d using(dealer_id)
WHERE fl.country_id = 'ID' 
AND fl.status NOT IN ('CLOSED', 'REJECTED')
AND DATE(fl.created_at) = CURRENT_DATE()  --Daily
"""

report_monthly_query = f"""
SELECT
fc.internal_id as ABC_ID,
fc.dealership_name as Dealership_Name,
d.dealer_name as Dealer_Name,
JSON_EXTRACT_SCALAR(fl.car_data, "$.make") as Make,
JSON_EXTRACT_SCALAR(fl.car_data, "$.model") as `Model`,
JSON_EXTRACT_SCALAR(fl.car_data, "$.trim") as Trim,
JSON_EXTRACT_SCALAR(fl.car_data, "$.licensePlate") as License_Plate,
fl.status as Loan_Status,
fl.sale_price as Sale_Price,
fl.amount as Loan_Amount,
JSON_EXTRACT_SCALAR(fl.fees , "$['fee.loan']") as Processing_Fee,
fl.created_at as Created_At
FROM `{PROJECT_NAME}.semantics_central.FinancingLoans` fl
INNER JOIN `{PROJECT_NAME}.semantics_central.FinancingCustomers` fc using(financing_customer_id)
INNER JOIN `{PROJECT_NAME}.semantics_central.Dealers` d using(dealer_id)
WHERE fl.country_id = 'ID' 
AND fl.status NOT IN ('CLOSED', 'REJECTED')
-- AND DATE(fl.created_at) >= DATE_TRUNC(CURRENT_DATE(), MONTH)  --Monthly
"""

sent_at = datetime.datetime.now(tz=pytz.timezone("Asia/Kolkata"))


def excel_export(query: str, full_file_path: str, gcp_project_id: str) -> None:
    import pandas as pd

    (
        pd.read_gbq(query, project_id=gcp_project_id, dialect='standard').to_excel(
            full_file_path, index=False
        )
    )


with models.DAG(
    dag_id=f"{DAG_NAME}-v{DAG_VERSION}",
    description="sends reports of Loans in ID",
    default_args=DEFAULT_ARGS,
    schedule_interval="30 23 * * 1,2,3,4,7",
    catchup=False,
) as dag:
    generate_daily_report = PythonVirtualenvOperator(
        task_id="Generate_Daily_Report",
        python_callable=excel_export,
        requirements=["pandas==1.0.5", "xlsxwriter", "pandas-gbq==0.9.0"],
        python_version="3",
        op_args=[
            report_daily_query,
            f"/home/airflow/gcs/data/LoanReport_Daily_ID_{sent_at.strftime('%F')}.xlsx",
            PROJECT_NAME,
        ],
    )

    generate_monthly_report = PythonVirtualenvOperator(
        task_id="Generate_Monthly_Report",
        python_callable=excel_export,
        requirements=["pandas==1.0.5", "xlsxwriter", "pandas-gbq==0.9.0"],
        python_version="3",
        op_args=[
            report_monthly_query,
            f"/home/airflow/gcs/data/LoanReport_Monthly_ID_{sent_at.strftime('%F')}.xlsx",
            PROJECT_NAME,
        ],
    )

    send_daily_report = email_operator.EmailOperator(
        task_id="Send_Daily_Report",
        to=receiver_addresses,
        bcc=bcc_addresses,
        subject=f"Loan Performance Daily Report: ID {sent_at.strftime('%F')}",
        html_content="Do not reply this email. This is an auto-generated report. Sent at: {}".format(
            sent_at.strftime("%F")
        ),
        files=[
            f"/home/airflow/gcs/data/LoanReport_Daily_ID_{sent_at.strftime('%F')}.xlsx"
        ],
    )

    send_monthly_report = email_operator.EmailOperator(
        task_id="Send_Monthly_Report",
        to=receiver_addresses,
        bcc=bcc_addresses,
        subject=f"Loan Performance Monthly Report: ID {sent_at.strftime('%F')}",
        html_content="Do not reply this email. This is an auto-generated report. Sent at: {}".format(
            sent_at.strftime("%F")
        ),
        files=[
            f"/home/airflow/gcs/data/LoanReport_Monthly_ID_{sent_at.strftime('%F')}.xlsx"
        ],
    )

    generate_daily_report >> send_daily_report
    generate_monthly_report >> send_monthly_report

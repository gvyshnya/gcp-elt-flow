# DS-centric DAG

from airflow.operators.python_operator import PythonVirtualenvOperator
from airflow import models
import os
import pytz
import datetime
import pandas as pd

from pyisemail import is_email
import phonenumbers

from google.cloud import bigquery
from google.oauth2 import service_account


DAG_NAME = "Exponea_Quote_Proessing_MX"
DAG_VERSION = "0.1"

PROJECT_NAME = os.environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = os.environ.get("DATAFLOW_SERVICE_ACCOUNT")
GCP_CONN_ID = os.environ.get("CONNECTION_ID")

SALESFORCE_BUCKET_PREFIX = os.environ.get("SALESFORCE_BUCKET_PREFIX")



DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime.datetime(2020, 11, 9, 12, 00),
    "email": [
        "orb@abc.com",
    ],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": datetime.timedelta(minutes=2),
}

generated_at = datetime.datetime.now(tz=pytz.timezone("UTC"))

quotes_query = '''SELECT  
    internal_customer_id,
    EXTRACT(DATETIME FROM timestamp AT TIME ZONE "America/Mexico_City") AS quote_datetime,
    properties.quote_phone,
    properties.quote_email
    FROM `gcloudltds.abc_5d1417ae_9170_11e8_8dfb_0a580a206142_views.quote`
    WHERE 
    properties.quote_email NOT LIKE '%@abc%' 
    AND properties.quote_email NOT LIKE '%@abc-group%'
    AND properties.quote_email NOT LIKE '%@curl%'
    AND EXTRACT(DATETIME FROM timestamp AT TIME ZONE "America/Mexico_City") >= "2018-12-31 23:59:59";
'''

def data_export(query: str, full_file_path: str, gcp_project_id: str) -> None:
    import pandas as pd
    import pdpipe as pdp
    from pyisemail import is_email
    import phonenumbers
    import math

    from google.cloud import bigquery
    from google.oauth2 import service_account

    def process_phone(phone_number: str) -> str:
        import phonenumbers
        result = ''
        if not phone_number or pd.isnull(phone_number):
            result = 'Not specified'
        else:
            z = phonenumbers.parse(phone_number, "MX")
            is_valid = phonenumbers.is_valid_number(z)
            if is_valid:
                result = 'Valid'
            else:
                result = 'Fake'
        return result

    def process_email(email_address: str) -> str:
        from pyisemail import is_email
        result = ''
        if not email_address or pd.isnull(email_address):
            result = 'Not specified'
        else:
            try:
                is_valid = is_email(email_address, check_dns=True)
                if is_valid:
                    tokens = email_address.split("@")
                    user_name = tokens[0]
                    domain_name = tokens[1]
                    if ( len(user_name) == 1 or 
                        'test' in user_name or 
                        'test' in domain_name ):
                        result = 'Suspicious'
                    else:
                        result = 'Valid'
                else:
                    result = 'Fake'
            except:
                result = 'Fake'
        return result

    KEY_FILE_PATH = "/home/airflow/gcs/data/exponea-dev-sa.json"

    credentials = service_account.Credentials.from_service_account_file(
        KEY_FILE_PATH, scopes=["https://www.googleapis.com/auth/cloud-platform"],
    )
    
    df=pd.read_gbq(query, project_id=gcp_project_id, dialect="standard", credentials=credentials)
    pipe_pass1 = pdp.PdPipeline([
            pdp.ApplyByCols(['quote_email'], process_email),
            pdp.ApplyByCols(['quote_phone'], process_phone),
    ])
    df = pipe_pass1.apply(df)
    df.to_csv(full_file_path, index=False)
    

with models.DAG(
    dag_id=f"{DAG_NAME}-v{DAG_VERSION}",
    description="Performs processing of Exponea quote email and phone numbers",
    default_args=DEFAULT_ARGS,
    schedule_interval=None,
    catchup=False,
) as dag:

    process_exponea_phones_and_emails_to_file = PythonVirtualenvOperator(
        task_id="Process_Quote_Emails_Phones_to_File_MX",
        python_callable=data_export,
        requirements=["pandas==1.0.5", "scikit-learn", "numpy", "nltk", "pdpipe", "phonenumbers", "pyisemail", "pandas-gbq==0.9.0"],
        python_version="3",
        op_args=[
            quotes_query,
            "gs://exponea_data_mx/Quotes_processed.csv",
            PROJECT_NAME,
        ],
    )

    process_exponea_phones_and_emails_to_file
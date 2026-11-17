from airflow.operators.python_operator import PythonOperator
from airflow.operators import dummy_operator
from airflow import models
from google.cloud import storage

import os
import time
import datetime
from typing import List, Dict
import pytz
import json
import objectpath
import pandas as pd


DAG_NAME = "Inspection_Reports_Schema_Parser"
DAG_VERSION = "0.1"

PROJECT_NAME = os.environ.get("PROJECT_NAME")
SERVICE_ACCOUNT = os.environ.get("DATAFLOW_SERVICE_ACCOUNT")
GCP_CONN_ID = os.environ.get("CONNECTION_ID")

# expected name without 'gs://'
JSON_REPORT_BUCKET_NAME = os.environ.get("INSPECTION_REPORTS_SCHEMA_BUCKET") 

inspection_report_field_token = 'inspection.field'
col_names = ['schema_name', 'fields_number']

DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime.datetime(2020, 10, 19, 0),
    "email": [
        "orb@abc.com",
    ],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": datetime.timedelta(minutes=2),
}

def get_number_of_inspection_report_fields(json_data):
    tree_obj = objectpath.Tree(json_data)

    field_nodes = tree_obj.execute('$..title')
    report_field_count = 0

    for node in field_nodes:
        if inspection_report_field_token in node:
            report_field_count += 1

    return report_field_count

def parse_schema_files():
    print ("Checkpoint 1")
    final_df = pd.DataFrame(columns=col_names)
    print ("Checkpoint 2")
    client = storage.Client()
    print ("Checkpoint 3")
    bucket = client.get_bucket(JSON_REPORT_BUCKET_NAME)

    blobs = bucket.list_blobs(prefix='report')
    print ("Checkpoint 4")
    for blob in blobs:
        json_file_name = blob.name
        if json_file_name.endswith('.json'):
            # read the inspection report schema file from GCS bucket
            data = json.loads(blob.download_as_string(client=None))

            report_field_count = get_number_of_inspection_report_fields(data)
            tokens = json_file_name.split(".")
            schema_name = tokens[0].strip()  # get the file name without extensions as a schema_name
            element_list = [[schema_name, report_field_count]]
            if final_df.shape[0] < 1:
                final_df = pd.DataFrame(data=element_list, columns=col_names)
            else:
                element_df = pd.DataFrame(data=element_list, columns=col_names)
                # concatenate
                frames = [final_df, element_df]
                final_df = pd.concat(frames)
    final_df.to_gbq('semantics_central.InspectionReportSchemas',
        PROJECT_NAME,
        chunksize=None,
        if_exists='replace'
    )
    print("Completed successfully")

with models.DAG(
    dag_id=f"{DAG_NAME}-v{DAG_VERSION}",
    description="Performs parsing of inspection report schema files",
    default_args=DEFAULT_ARGS,
    schedule_interval="30 3 * * *",
    catchup=False,
) as dag:

    start = dummy_operator.DummyOperator(task_id="START")
    end = dummy_operator.DummyOperator(task_id="FINISH")

    parse_inspection_report_schema_files = PythonOperator(
        task_id="parse-inspection-report-schemata",
        python_callable=parse_schema_files,
        provide_context=True
    )

    start >> parse_inspection_report_schema_files >> end
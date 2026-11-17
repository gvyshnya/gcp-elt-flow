import os
from datetime import datetime, timedelta
from pytz import UTC
from airflow import models
from airflow.operators import email_operator

# DAG settings
DAG_NAME = "EmailTest"
DAG_VERSION = "0.1"


DEFAULT_ARGS = {
    "owner": "ABC-BI",
    "depends_on_past": False,
    "start_date": datetime(2019, 5, 15),
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
    description="Testing SendGrid configuration",
    schedule_interval=None,
    default_args=DEFAULT_ARGS,
    catchup=False,
) as dag:

    sent_at = datetime.now()

    email_send = email_operator.EmailOperator(
        task_id="TestEmailSend",
        to=[
            "orb@abc.com",
        ],
        subject="Test from Composer",
        html_content="This is a test from airflow. Sent at: {}".format(
            sent_at.strftime("%F")
        ),
    )

    email_send

import os
from datetime import datetime, timedelta
from pytz import UTC
from tempfile import NamedTemporaryFile
from airflow import models
from airflow.operators import dummy_operator
from airflow.operators import email_operator
from airflow.operators.python_operator import PythonOperator


DAG_NAME = "EmailWithAttachmentTest"
DAG_VERSION = "0.1"

FILES_BASE_PATH = "/home/airflow/gcs/dags/data"
FILES_RELATIVE_BASE_PATH = "data"

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

# Note: there is a good set of documentation on best practices scheduling a DAG 
#       with Airflow available at
#   1/ Official docs: https://airflow.apache.org/docs/stable/scheduler.html
#   2/ https://www.astronomer.io/guides/scheduling-tasks/
#   3/ https://stackoverflow.com/questions/36298756/how-to-work-correctly-airflow-schedule-interval

with models.DAG(
    dag_id="{dag_name}-v{dag_version}".format(
        dag_name=DAG_NAME, dag_version=DAG_VERSION
    ),
    description="Testing SendGrid configuration",
    # schedule_interval="2 * * * *",
    # schedule_interval='@daily',
    schedule_interval=None,
    default_args=DEFAULT_ARGS,
    catchup=False,
) as dag:

    sent_at = datetime.now()

    start = dummy_operator.DummyOperator(task_id="START")
    end = dummy_operator.DummyOperator(task_id="FINISH")

    def build_email(**context):
        attachment_file = "{}/{}".format(FILES_BASE_PATH, "README.txt")

        email_op = email_operator.EmailOperator(
            task_id="SendTestEmailWithAttachment",
            to=[
                "orb@abc.com",
            ],
            subject="Test Email with Attachment from Google Composer/Airflow",
            html_content="This is a test with an attachment from an airflow. Sent at: {}".format(
                sent_at.strftime("%F")
            ),
            files=[attachment_file],
        )
        email_op.execute(context)

    email_op_python = PythonOperator(
        task_id="python_send_email", 
        python_callable=build_email, 
        provide_context=True
    )

    start >> email_op_python >> end


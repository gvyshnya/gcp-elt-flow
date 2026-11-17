import re
from airflow import models

# ideas inherited from https://medium.com/slalom-technology/automated-airflow-testing-a29b6426148b

def test_import_dags():
    """
    Pytest to ensure there will be no import errors in dagbag. These are generally syntax problems.
    """
    dags = models.DagBag()
    
    assert len(dags.import_errors) == 0


def test_alert_email_present():
    """
    Pytest to ensure all dags have a valid email address
    """

    dags = models.DagBag()
    email_regex = re.compile(
        r"^[A-Za-z0-9\.\+_-]+@[A-Za-z0-9\._-]+\.[a-zA-Z]*$"
    )  # regex to check for valid email
    
    for dag_id, dag in dags.dags.items():
        print("test_alert_email_present >> Testing DAG:", dag_id)
        emails = dag.default_args.get("email", [])
        for email in emails:
            assert email_regex.match(email) is not None
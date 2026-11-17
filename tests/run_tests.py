import docker
import configparser
import io

def test_run():
    config = configparser.ConfigParser()

    # Load the configuration file
    with open('config.ini') as f:
        dag_autotests_config = f.read()
    config.readfp(io.BytesIO(dag_autotests_config))

    path_to_airflow_docker_image = config['LOCAL']['AIRFLOW_IMAGE']
    dags_location = config['LOCAL']['DAGS']
    test_case_scripts_location = config['LOCAL']['TEST_CASES']

    test_run_dag_test_script(path_to_airflow_docker_image, dags_location, test_case_scripts_location)


def test_run_dag_test_script(path_to_airflow_docker_image, dags_location, test_case_scripts_location):
    """
    This function runs a docker exec command on the container and will run our airflow DAG testing script. Once the test is complete return the exit status and output messsage from the docker execute command. Then the function stops the container.
    :return: the exit status and output message from the docker exec command of test script.
    """

    print("test_run_dag_test_script>> Before starting the docker container")
    print("test_run_dag_test_script>> Airflow docker image path: ", path_to_airflow_docker_image)
    running_container = airflow_build(
        airflow_docker_image_path=path_to_airflow_docker_image,
        dag_path=dags_location, 
        test_path=test_case_scripts_location
    )

    print("test_run_dag_test_script>> The docker container with the local Airflow instance started")
    
    dag_test_output = running_container.exec_run(
        "pytest /usr/local/airflow/test/dag_pytest.py"
    )
    ex_code = dag_test_output[0]

    running_container.stop()

    assert ex_code == 0

def airflow_build(airflow_docker_image_path, dag_path, test_path):
    """
    This function runs the build for a container with airflow processes locally. Turns on webserver and scheduler.
    :param dag_path: (string) the filepath where dags live locally.
    :param test_path: (string) the filepath where the pytest script lives locally.
    :return: returns the docker container object.
    """

    p1 = airflow_docker_image_path
    print("airflow_build >> Passed Path to the Airflow docker image:", p1)

    print("airflow_build >> Passed Path to the DAGs to test:", dag_path)
    print("airflow_build >> Passed Path to the test case scripts:", test_path)

    client = docker.from_env()

    client.images.pull(p1)
    running_container = client.containers.run(
        p1,
        detach=True,
        ports={"8080/tcp": 8080},  # expose local port 8080 to container
        volumes={
            dag_path: {"bind": "/usr/local/airflow/dags/", "mode": "rw"},
            test_path: {"bind": "/usr/local/airflow/test/", "mode": "rw"},
        },
    )
    running_container.exec_run(
        "airflow initdb", detach=True
    )  # docker execute command to initialize the airflow db
    running_container.exec_run(
        "airflow scheduler", detach=True
    )  # docker execute command to start airflow scheduler

    return running_container

if __name__== "__main__":
    config = configparser.ConfigParser()

    # Load the configuration file
    with open('config.ini') as f:
        dag_autotests_config = f.read()
    config.readfp(io.BytesIO(dag_autotests_config))

    path_to_airflow_docker_image = config['LOCAL']['AIRFLOW_IMAGE']
    dags_location = config['LOCAL']['DAGS']
    test_case_scripts_location = config['LOCAL']['TEST_CASES']

    # path_to_airflow_docker_image = "~/fcg-dev/development/biflow2-exp/tests/docker-airflow"
    # dags_location = "~/fcg-dev/development/biflow2-exp/"
    # test_case_scripts_location = "~/fcg-dev/development/biflow2-exp/tests/"

    print("Path to the Airflow docker image:", path_to_airflow_docker_image)
    test_run_dag_test_script(path_to_airflow_docker_image, dags_location, test_case_scripts_location)
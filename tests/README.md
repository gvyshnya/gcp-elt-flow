# PREFACE

This document will provide you with the keynote details on the local auto-testing suite to test
Airflow-based BI DAG scripts before you submit them to a Google Cloud Composer environment in your
cloud environment

# PRE-REQUISITES

You will have to install the following componentns in your local environment 

- Ubuntu 18.xx subsystem for Windows
- Docker for your target OS
- Python 3 runtime
- PyTest utilities for the above-mentioned python runtime
- Apache Airflow package (use pip install apache-airflow to run it for Python 3 where airflow package is obsolete)
- Python Docker wrapper package
- MS Visual Studio Code IDE

You will also have to configure MS Visual Code in a way to use the above-mentioned Python 3 instance and PyTest there to run tests from it.

*Note*: Ubuntu 18.xx subsystem for Windows, along with MS Visual Studio Code as an IDE, was used to develop and test the suite. It had not been certified under any other OS/IDE combination

# AUTO-TESTING SUITE FILES AND FOLDERS

The components of the DAG auto-testing suite are located under *"bi-flow-repo-root/testing"* subfolder. They are as follows

- *run_tests.py* - the main script orchestrating the execution of the entire test suite (initializing a docker container using the Airflow docker image, mounting test case and DAG script files to it, running the test cases using PyTest etc.)
- *dag_pytest.py* - the script with PyTest tests for BI DAG scripts
- *config.ini* - your configuration file where you override default values with the parameters for your local environment (see below)
- *docker-airflow* folder - the cloned version of the master branch of 'https://github.com/puckel/docker-airflow' repo with the pre-built Airflow docker image (reused under GNU license, the master codebase branch last modified on Nov 22, 2019)
- *README.md* - this README document

# METHOD OF USE

In order to use the DAG auto-testing suite in your environment, you will have to do the actions below

- install and configure all of the pre-requisites as described in *PRE_REQUISITES* section above
- modify the config settings (namely, absolute paths to the root of your *bi-flow repo* clone, tests within such a repo and Airflow docker image within such a repo) in your *config.ini*

Once you do it, the auto-tests will be execute whenever you act as follows

- start MS Visual Studio Code in your clone of *bi-flow repo*
- open *tests/run_tests.py* in your IDE and click Run icon on your toolbar

You will be able to see it in *OUTPUT >> Python* section of your MS Visual Code interactive console

# SET OF AUTO-TESTS

As of Jan 2, 2020, the basic set of auto-tests for BI DAG Scripts has been implemented. It consists of

- the auto test to check for possible DAG integrity issues (such issues will cause the red pop-up overlays in the Airflow Web UI to display, if you upload your DAG with such an integrity issue to your Google Cloud Composer environment)
- the auto test to check validity of email addresses passed in the DAG notification list attributes

Such a set of auto tests is subject to further extension, if the need be.

# KNOWN ISSUES

- if you attempt to run *run_tests.py* from a command-line shell, it may fire 'No such file or directory: 'config.ini' ' error, which is weird
- under some conditions, running the test suite fires the error (in MS Visual Studio Code output panel), *'import-error:Unable to import 'airflow'* - as of this moment, the only suitable work-around is to restart your MS Visual Studio Code application from under Ubuntu subsystem

# REFERENCES

The key ideas to implement such an auto-testing suite have been reviewed in https://medium.com/slalom-technology/automated-airflow-testing-a29b6426148b

You can also read more about the underlying *docker-airflow* image we use to run a local docker container with an Airflow and PyTest auto-tests in its respective README.md (see it at *'repo_root/testing/docker-airflow'*)
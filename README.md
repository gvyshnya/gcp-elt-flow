# BI Flow

This repo contains Google Cloud Composer (Airflow) DAGs and workflow orchestration for the ABC data infrastructure and BI Platform.

**Note:** The code in the repo is the obfuscated version of the real-world data engineering solution of a prominent e-commerce e-marketplace startup that was under the active development/maintenance in 2018-2020 (prior to the startap purchased by a strategic investor, with migrating to the investor's own cloud infrastructure).

## Requirements

1. **GCP Cloud SDK**: Provides CLI tools and client libraries for interacting
with GCP components. [Download](https://cloud.google.com/sdk/)
2. **GCP Account**: With _Developer_ access on the BI Project(s).
3. **Python 3.6+**: [Download](https://www.python.org/downloads/). Also, we recommend the usage of Virtual Environments for
managing project's packages. [Here](https://docs.python-guide.org/dev/virtualenvs/)
is a guide on working with virtual envs. 
4. **Bash environment**: If you're using Windows, you can activate the Windows
Subsystem for Linux (WSL) and have a Linux environment. Follow
[this](https://docs.microsoft.com/en-us/windows/wsl/about) tutorial to get it
running.

## Setup

1. Activate your Python Env.
2. Install the requirements: `pip install -r requirements.txt`
3. Done!

## Components

### [Cloud Composer](https://cloud.google.com/composer/)

It's a _fully_ managed workflow orchestration service.

It's based on [Apache Airflow](https://airflow.apache.org/). Please refer to
the official documentation for getting information on how Airflow works
internally.

GCP provides a simple tutorial to understand Airflow and DAGs basics.

Additionally, GCP contributes to the `airflow.contrib` package and provides
integration with a lot of GCP services. More details
[here](https://airflow.apache.org/_api/airflow/contrib/operators/index.html).

### [Cloud Dataflow](https://cloud.google.com/dataflow/)

Serverless service for performing data transformation in stream or batch modes.

It's based on [Apache Beam](https://beam.apache.org/), but GCP already
provide a set of templates to get started (and that already solves our problem).
Precisely, the [JDBC to BigQuery](https://cloud.google.com/dataflow/docs/guides/templates/provided-batch#jdbctobigquery)
templates.

#### [Cloud SQL JDBC Socket Factory](https://github.com/GoogleCloudPlatform/cloud-sql-jdbc-socket-factory)

Is a library for the MySQL/Postgres JDBC drivers that allows a user with the
appropriate permissions to connect to a Cloud SQL database without having to
deal with IP whitelisting or SSL certificates manually.

We depend on this library for connection and we compile it with dependencies
to facilitate deployment.

### [BigQuery](https://cloud.google.com/bigquery/)

Google's serverless, highly scalable enterprise data warehouse.

Easy to use and easy to get started and Surprisingly well documented.
[Here](https://cloud.google.com/bigquery/docs/) is the documentation.

## How it works

[provide a diagram here]

## Deployment

The `Makefile` provides an easy way to publish DAGs and update dependencies.

### Deployment to Development Environment

To upload/update DAGs:
```bash
make upload_dag DAG=<DAG-FILE.py>
```

To upload/update all dependencies:
```bash
make upload_all_dependencies
```

To upload/update just one file among dependencies:
```bash
make upload_depency FILE=/path/to.file
```

_Note_: Effectively Dec 1, 2019, the ETL flow started to be dependent on a new Airflow connection to a Cloud SQL Proxy instance. It is further referred to from environment variable of *CONNECTION_ID*

In every dev environment, it has a name of _bi_dataflow_dev_. Its full specification is listed below

- Conn Id: *bi_dataflow_dev*
- Conn Type: Google Cloud Platform
- KeyFile Path: _server-side-path-to-a-json-key-file_ (example for ABC-BI-dev project: /home/airflow/gcs/data/ABC-BI-dev-e30b614f7ef2.json)
- Scopes: https://www.googleapis.com/auth/cloud-platform

Please check the following operators to get a hint https://airflow.apache.org/docs/stable/integration.html#cloud-sql

### Deployment to Production Environment

To upload/update DAGs:
```bash
make prod_upload_dag DAG=<DAG-FILE.py>
```

To upload/update all dependencies:
```bash
make prod_upload_all_dependencies
```

To upload/update just one file among dependencies:
```bash
make prod_upload_depency FILE=/path/to.file
```
## Additional Dependencies

In order the BI Flow DAG scripts to work correctly, you should make sure each of your Google Composer environments has the following files in the bucket associated with the environment

- <bucket_root>/data/ga_key.json - the file with the credentials needed to access Google Analytics cloud services
- <bucket_root>/data/<sql_proxy_key_file_name>.json - the file with the credentials needed to access the Google SQL Proxy instance (the full path to such a file will then be used in the Airflow Connection referred from CONNECTION_ID environmental variable of the respective Google Composer environment)

## Tips and Tricks

This section will contain miscellaneous tips and comments to help you work with GC Composer, DAGs and other aspects of BI Flows used in ABC BI Platform.

### Locating and Running DAGs

In order to locate the DAG you deployed using the instructions above, you should use the Airflow Web Server UI for your target Cloud Composer environment (see [the basic Google manual](https://cloud.google.com/composer/docs/how-to/accessing/airflow-web-interface) for more details).

In order to run your DAG, you act as follows 

- Login into Google Cloud Console and go to the Composer panel.
- Check the list of all Composer environments
- Click the 'Airflow' link in 'Airflow webserver' column of the row corresponding to the Composer environment of your interest.
- Airflow Web UI will open in a new browser tab/window, listing all installed DAGs for this Composer enviroment. (_Note: Is a good a idea to save it on the bookmarks bar of your browser._)
- In AirFlow Web UI, find the DAG you would like to run and then click 'Trigger DAG' icon in the links column for its row in the DAGs table.

### Viewing Code of a DAG

If you do not change your DAG script in python drastically and DAG Identifier is therefore constant, you can incrementally update it using _make upload_dag DAG=<DAG-FILE.py>_ command as described in Deployment section above.

To make sure your latest changes are deployed correctly, you can view the source code of your GAG script on the cloud premise. To do so, you act as follows

- locate your DAG in the Airflow Web UI site as described in the section above
- click 'Code View' icon the links column for the row with the DAG of your interest in the DAGs table

### Debugging DAGs

This section will document a number of practical debugging cases/scenarios that you may get use of in your development process.

_*Note:*_ The useful generic guideline on common Dataflow error messages and troubleshooting is available [here](https://cloud.google.com/dataflow/docs/guides/common-errors).

## Troubleshooting

### "The job failed because a work item failed 4 times" issue

When you run your DAG, it generates one or more jobs on Dataflow side (corresponding to the steps in your DAG that really handle data retrieval from  external sources).

In the course of developing / testing your workflow, you can face a tricky issue per, "The job failed because a work item failed 4 times".

The explanations/suggestions available [here](https://cloud.google.com/dataflow/docs/guides/common-errors#job-failed-four-times) are not very informative and somewhat misleading.

In fact, this problem is often indicative of a data load task to be too big for the number/computational powers of the cloud workers allocated for it. Some of the possible strategies to tackle this issue could be

- choosing a different machine type (with higher capacities/power) for the operation in your DAG that fires this error
- changing the technical design of your DAG to split it into more granular data processing steps

_*Note:*_ You can refer to https://cloud.google.com/compute/pricing#machinetype for the comparison of computational power/pricing for each type of machines supported by Workers.

## Files with TODOs

- ./dependencies/google_analytics.py
- ./dependencies/queries/semantics/Auctions.sql
- ./dependencies/queries/semantics/Bids.sql
- ./dependencies/queries/semantics/CarOfferPrices.sql
- ./dependencies/queries/semantics/CarPayments.sql
- ./dependencies/queries/semantics/CarTransits.sql
- ./dependencies/queries/semantics/Dealers.sql

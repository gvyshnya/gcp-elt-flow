from airflow.operators import python_operator


def ga_get_and_push_admin_app_v1(
    start_date: str,
    end_date: str,
    ga_key_file_path: str,
    dataset: str,
    gcp_project_id: str,
):
    from datetime import datetime
    from google2pandas import GoogleAnalyticsQueryV4

    admin_app_viewId = "ga:210914832"
    dimensions = [
        {"name": "ga:date"},
        {"name": "ga:dimension3"},  # userId
        {"name": "ga:pagePath"},
    ]
    metrics = [{"expression": "ga:timeOnPage"}]
    filters = [
        {
            "dimensionName": "ga:pagePath",
            "operator": "REGEXP",
            "expressions": ["car/edit/"],
        }
    ]

    ga_query = {
        "reportRequests": [
            {
                "viewId": admin_app_viewId,
                "dateRanges": [{"startDate": start_date, "endDate": end_date}],
                "dimensions": dimensions,
                "metrics": metrics,
                "dimensionFilterClauses": [{"operator": "AND", "filters": filters}],
            }
        ]
    }

    ga_connection = GoogleAnalyticsQueryV4(secrets=ga_key_file_path)
    ga_data = ga_connection.execute_query(ga_query)

    ga_data["application_name"] = "AdminApp v1"
    ga_data.columns = [
        "action_date",
        "user_id",
        "page_path",
        "time_on_page_seconds",
        "application_name",
    ]
    ga_data = ga_data.astype({"time_on_page_seconds": "float"})
    ga_data["action_date"] = ga_data["action_date"].apply(
        lambda x: datetime.strptime(x, "%Y%m%d")
    )
    ga_data["car_id"] = ga_data["page_path"].apply(lambda x: x.split("/")[-2])
    table_name = "AdminAppV1CarEdits"
    exists_behavior = "append"
    ga_data.to_gbq(
        "{dataset}.{table}".format(dataset=dataset, table=table_name),
        project_id=gcp_project_id,
        if_exists=exists_behavior,
    )


def ga_reload_admin_app_v1(
    start_date: str,
    end_date: str,
    ga_key_file_path: str,
    dataset: str,
    gcp_project_id: str,
) -> python_operator.PythonVirtualenvOperator:
    return python_operator.PythonVirtualenvOperator(
        task_id="GA-AdminAppV1",
        python_callable=ga_get_and_push_admin_app_v1,
        requirements=["google2pandas==0.1.1", "oauth2client", "pandas_gbq"],
        python_version="3",
        op_args=[start_date, end_date, ga_key_file_path, dataset, gcp_project_id,],
    )

# TODO: The country specific data can be global and required as a parameter.
#  This in order to reuse the list of countries and not repeat it in the DAG.
# But remember that the function cannot contain references to external
# variables and we need to pass it as a parameter to the function.


def ga_get_and_push_by_country(
    country: str,
    start_date: str,
    end_date: str,
    ga_key_file_path: str,
    dataset: str,
    gcp_project_id: str,
):
    from datetime import datetime
    from google2pandas import GoogleAnalyticsQueryV4
    import numpy as np

    dimensions = [
        {"name": "ga:date"},
        {"name": "ga:campaign"},
        {"name": "ga:adwordsCampaignID"},
        {"name": "ga:deviceCategory"},
        # source medium
        # distribution network
        # {"name": "ga:channelGrouping"}
    ]

    common_metrics = [
        {"expression": "ga:sessions"},
        {"expression": "ga:users"},
        {"expression": "ga:newUsers"},
        {"expression": "ga:adCost"},
    ]
    # Send to config file
    countries_specific_data = {
        "AR": {
            "viewId": "ga:177723569",
            "metrics": [
                {"expression": "ga:goal4Completions"},
                {"expression": "ga:goal5Completions"},
                {"expression": "ga:goal6Completions"},
                {"expression": "ga:goal7Completions"},
            ],
        },
        "CL": {
            "viewId": "ga:158371001",
            "metrics": [
                {"expression": "ga:goal2Completions"},
                {"expression": "ga:goal1Completions"},
                {"expression": "ga:goal7Completions"},
                {"expression": "ga:goal6Completions"},
            ],
        },
        "CO": {
            "viewId": "ga:177753398",
            "metrics": [
                {"expression": "ga:goal5Completions"},
                {"expression": "ga:goal4Completions"},
                {"expression": "ga:goal7Completions"},
                {"expression": "ga:goal6Completions"},
            ],
        },
        "ID": {
            "viewId": "ga:146164864",
            "metrics": [
                {"expression": "ga:goal1Completions"},
                {"expression": "ga:goal2Completions"},
                {"expression": "ga:goal4Completions"},
                {"expression": "ga:goal5Completions"},
            ],
        },
        "IN": {
            "viewId": "ga:178670174",
            "metrics": [
                {"expression": "ga:goal2Completions"},
                {"expression": "ga:goal1Completions"},
                {"expression": "ga:goal3Completions"},
                {"expression": "ga:goal4Completions"},
            ],
        },
        "MX": {
            "viewId": "ga:138397785",
            "metrics": [
                {"expression": "ga:goal5Completions"},
                {"expression": "ga:goal1Completions"},
                {"expression": "ga:goal9Completions"},
                {"expression": "ga:goal8Completions"},
            ],
        },
        "NG": {
            "viewId": "ga:132153143",
            "metrics": [
                {"expression": "ga:goal4Completions"},
                {"expression": "ga:goal7Completions"},
                {"expression": "ga:goal5Completions"},
                {"expression": "ga:goal6Completions"},
            ],
        },
        "PK": {
            "viewId": "ga:132340715",
            "metrics": [
                {"expression": "ga:goal2Completions"},
                {"expression": "ga:goal4Completions"},
                {"expression": "ga:goal9Completions"},
                {"expression": "ga:goal10Completions"},
            ],
        },
        "PL": {
            "viewId": "ga:187725043",
            "metrics": [
                {"expression": "ga:goal2Completions"},
                {"expression": "ga:goal1Completions"},
                {"expression": "ga:goal3Completions"},
                {"expression": "ga:goal4Completions"},
            ],
        },
    }

    ga_query = {
        "reportRequests": [
            {
                "viewId": countries_specific_data[country]["viewId"],
                "dateRanges": [{"startDate": start_date, "endDate": end_date}],
                "dimensions": dimensions,
                "metrics": common_metrics + countries_specific_data[country]["metrics"],
            }
        ]
    }

    ga_connection = GoogleAnalyticsQueryV4(secrets=ga_key_file_path)
    ga_data = ga_connection.execute_query(ga_query)
    ga_data["application_name"] = "Website"
    ga_data["country_id"] = country
    ga_data.columns = [
        "visits_date",
        "campaign_name",
        "campaign_adwords_id",
        "device_type",
        # 'marketing_channel',
        "total_visits_number",
        "unique_visits_number",
        "new_visits_number",
        "ad_costs",
        "bookings_number",
        "quotes_number",
        "inspections_number",
        "purchases_number",
        "application_name",
        "country_id",
    ]
    ga_data = ga_data.astype(
        {
            "total_visits_number": np.int32,
            "unique_visits_number": np.int32,
            "new_visits_number": np.int32,
            "ad_costs": np.float32,
            "bookings_number": np.int32,
            "quotes_number": np.int32,
            "inspections_number": np.int32,
            "purchases_number": np.int32,
        }
    )
    ga_data["visits_date"] = ga_data["visits_date"].apply(
        lambda x: datetime.strptime(x, "%Y%m%d")
    )
    table_name = "Visits"
    exists_behavior = "append"
    ga_data.to_gbq(
        "{dataset}.{table}".format(dataset=dataset, table=table_name),
        project_id=gcp_project_id,
        if_exists=exists_behavior,
    )


def ga_reload_country(
    country: str,
    start_date: str,
    end_date: str,
    ga_key_file_path: str,
    dataset: str,
    gcp_project_id: str,
):
    from airflow.operators import python_operator

    return python_operator.PythonVirtualenvOperator(
        task_id="GA-{}".format(country),
        python_callable=ga_get_and_push_by_country,
        requirements=["google2pandas==0.1.1", "oauth2client", "pandas_gbq"],
        python_version="3",
        op_args=[
            country,
            start_date,
            end_date,
            ga_key_file_path,
            dataset,
            gcp_project_id,
        ],
    )

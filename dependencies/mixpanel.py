from typing import Dict

# Send to config file
COUNTRY_DATA = {
    "AR": {"api_secret": "202e43c90326e70779680a280fd25648"},
    "CL": {"api_secret": "154389a0fa1f4cada887f696abb3eebe"},
    "CO": {"api_secret": "a732691391ebc2551ba68c30953ad638"},
    "ID": {"api_secret": "1beda660608e9441bc7a4c4a58e07731"},
    "IN": {"api_secret": "39f550cb2c8a085a5a9861e0d8d6b33f"},
    "MX": {"api_secret": "ba7e5bea8e6086103402d9e3bff79488"},
    "NG": {"api_secret": "fb9090cb83daf8a3c48a3854876ba070"},
    "PK": {"api_secret": "c4e9bda0d49eb5e6a07ad42dff5b53e6"},
}


def mixpanel_to_bq_by_country(
    country: str,
    start_date: str,
    end_date: str,
    gcp_project_id: str,
    dataset: str,
    table_name: str,
    country_data,
):
    import json
    import requests
    import pandas as pd

    batch_size = 100000
    request_payload = {"from_date": start_date, "to_date": end_date}
    mixpanel_base_url = "https://data.mixpanel.com/api/2.0/export/"
    response = requests.get(
        mixpanel_base_url,
        params=request_payload,
        auth=(country_data[country]["api_secret"], ""),
        stream=True,
    )
    if response.status_code not in [200]:
        print(f"Code: {response.status_code} Message: {response.text}")
    else:
        print(f"Code: {response.status_code}")
    row_counter = 0
    rows_batch = list()
    for line in response.iter_lines():
        if line:
            decoded_line = line.decode("utf-8").replace("$", "mp_")
            dict_line = json.loads(decoded_line)
            event_record = {
                "country_id": country,
                "ts": dict_line["properties"]["time"],
                "event_type": dict_line["event"],
                "event_data": json.dumps(dict_line["properties"]),
            }
            rows_batch.append(event_record)
            row_counter += 1
            if (row_counter % batch_size) == 0:
                print(f"Sending {row_counter} events...")
                pd.DataFrame(rows_batch).to_gbq(
                    destination_table=f"{dataset}.{table_name}",
                    project_id=gcp_project_id,
                    if_exists="append",
                )
                rows_batch = list()
    if rows_batch:
        print(f"Preparing to send {row_counter} events")
        pd.DataFrame(rows_batch).to_gbq(
            destination_table=f"{dataset}.{table_name}",
            project_id=gcp_project_id,
            if_exists="append",
        )
    print("All events sent!")


def mixpanel_load_country(
    country: str,
    start_date: str,
    end_date: str,
    gcp_project_id: str,
    dataset: str,
    table_name: str,
):
    from airflow.operators import python_operator

    return python_operator.PythonVirtualenvOperator(
        task_id=f"MixPanel-{country}-Daily",
        python_callable=mixpanel_to_bq_by_country,
        requirements=["requests", "pandas", "pandas_gbq"],
        python_version="3",
        op_args=[country, start_date, end_date, gcp_project_id, dataset, table_name, COUNTRY_DATA],
    )

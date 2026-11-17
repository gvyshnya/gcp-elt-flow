import datetime


def oxr_get_and_push(
    start_date,
    end_date,
    open_exchange_rates_key: str,
    dataset: str,
    gcp_project_id: str,
    overwrite: bool = False,
):
    from datetime import timedelta, datetime
    from typing import List, Dict
    import itertools
    import openexchangerate as oxr
    import pandas as pd

    oxr_currency_bases = ["USD", "EUR", "SEK"]
    # Send to config file
    oxr_currency_symbols = [
        "ARS",
        "CLP",
        "COP",
        "DKK",
        "IDR",
        "INR",
        "MXN",
        "NGN",
        "PKR",
        "TRY",
        "PLN",
        "AED",
        "GHS",
        "KES",
        "PEN"
    ]
    table_name = "ExchangeRates"
    dates_list = [
        start_date + timedelta(days=day_idx)
        for day_idx in range(0, (end_date - start_date).days + 1)
    ]
    raw_data = []

    def oxr_rates_for_date(
        oxr_base: str, symbols: List[str], historical: Dict, oxr_date: datetime
    ) -> List[Dict]:
        return [
            dict(
                [
                    ("exchange_rate_date", oxr_date),
                    ("currency_symbol", symbol),
                    ("exchange_rate_to_{}".format(oxr_base), historical[symbol]),
                ]
            )
            for symbol in symbols
        ]

    for base in oxr_currency_bases:
        client = oxr.OpenExchangeRates(api_key=open_exchange_rates_key, base=base)
        raw_data += [
            oxr_rates_for_date(
                base,
                oxr_currency_symbols,
                client.historical(since_date=oxr_date).dict,
                oxr_date,
            )
            for oxr_date in dates_list
        ]

    oxr_raw_data = list(itertools.chain.from_iterable(raw_data))

    oxr_df = pd.DataFrame(oxr_raw_data).sort_values(
        by=["exchange_rate_date", "currency_symbol"]
    )
    oxr_df = (
        oxr_df.groupby(["exchange_rate_date", "currency_symbol"]).max().reset_index()
    )

    exists_behavior = "replace" if overwrite else "append"
    oxr_df.to_gbq(
        "{dataset}.{table}".format(dataset=dataset, table=table_name),
        project_id=gcp_project_id,
        if_exists=exists_behavior,
    )


def oxr_reload(
    start_date: datetime.datetime,
    end_date: datetime.datetime,
    open_exchange_rates_key: str,
    dataset: str,
    gcp_project_id: str,
    overwrite: bool = False,
):
    from airflow.operators import python_operator

    return python_operator.PythonVirtualenvOperator(
        task_id="ExchangeRates-{}".format("ALL"),
        python_callable=oxr_get_and_push,
        requirements=["openexchangerate", "pandas", "pandas_gbq"],
        python_version="3",
        op_args=[
            start_date,
            end_date,
            open_exchange_rates_key,
            dataset,
            gcp_project_id,
            overwrite,
        ],
    )

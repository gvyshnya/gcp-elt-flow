from pyspark.sql.functions import *
from pyspark.context import SparkContext
from pyspark.sql.session import SparkSession
import sys

YES_TOKEN = "Yes"

sc = SparkContext.getOrCreate()
spark = SparkSession(sc)

def export_a_bigquery_view (
    country_id,
    country_exponea_dataset,
    country_exponea_project_name,
    entity_name,
    gcs_output_bucket,
    materialization_gcp_project_id,
    materialization_dataset,
    output_parquet,
    is_partitioned,
    is_full_reload,
    since_date
):
    table = "".join(['gcloudltds.', country_exponea_dataset, '.', entity_name])

    if is_partitioned:
        filter_value = f"ingest_timestamp > '{since_date}'"
    else:
        # for non-particioned customer-related tables
        if entity_name == 'customers_properties':
            filter_value = f"internal_id <> ''" 
        else:
            filter_value = f"internal_customer_id <> ''" 
    
    df = spark.read.format("bigquery") \
        .option("viewsEnabled", True) \
        .option("mergeSchema", True) \
        .option("viewMaterializationProject", materialization_gcp_project_id) \
        .option("viewMaterializationDataset", materialization_dataset) \
        .option("filter", filter_value) \
        .load(table)
    
    spark_write_method = ""
    if is_full_reload:
        spark_write_method = "overwrite"
    else:
        # incremental update, doing append rather then overwrite
        spark_write_method = "append"
    
    if is_partitioned:
        # create a partition field
        df = df.withColumn("ingest_date", to_date(col('ingest_timestamp')))

        if output_parquet:
            # write down as a partitioned parquet file
            output_parquet_path = "".join(
                [
                    gcs_output_bucket,
                    '/', country_id, '/', country_exponea_project_name,
                    '/parquet/', entity_name, '/'
                ])
            df.write.partitionBy("ingest_date").mode(spark_write_method).parquet(output_parquet_path)
        else:
            # write down as a partitioned JSON file
            output_json_path = "".join(
                [
                    gcs_output_bucket,
                    '/', country_id, '/', country_exponea_project_name,
                    '/json/', entity_name, '/'
                ])
            df.write.partitionBy("ingest_date").mode(spark_write_method).json(output_json_path)
    else:
        # write down a non-partitioned table/view
        if output_parquet:
            # write down as a partitioned parquet file
            output_parquet_path = "".join(
                [
                    gcs_output_bucket,
                    '/', country_id, '/', country_exponea_project_name,
                    '/parquet/', entity_name, '/'
                ])
            df.write.mode(spark_write_method).parquet(output_parquet_path)
        else:
            # write down as a partitioned JSON file
            output_json_path = "".join(
                [
                    gcs_output_bucket,
                    '/', country_id, '/', country_exponea_project_name,
                    '/json/', entity_name, '/'
                ])
            df.write.mode(spark_write_method).json(output_json_path)

        
def main(argv):

    country_id = argv[0]
    country_exponea_dataset = argv[1]
    country_exponea_project_name = argv[2]
    entity_name = argv[3]
    gcs_output_bucket = argv[4]
    materialization_gcp_project_id = argv[5]
    materialization_dataset = argv[6]
    parquet_flag = argv[7]
    is_partitioned_flag = argv[8]
    is_full_reload_flag = argv[9]
    since_date = argv[10]

    output_parquet = False
    is_partitioned = False
    is_full_reload = False

    if parquet_flag == YES_TOKEN:
        output_parquet = True
    
    if is_partitioned_flag == YES_TOKEN:
        is_partitioned = True
    
    if is_full_reload_flag == YES_TOKEN:
        is_full_reload_flag = True
    
    export_a_bigquery_view (
        country_id,
        country_exponea_dataset,
        country_exponea_project_name,
        entity_name,
        gcs_output_bucket,
        materialization_gcp_project_id,
        materialization_dataset,
        output_parquet,
        is_partitioned,
        is_full_reload,
        since_date
    )


if __name__ == "__main__":
    main(sys.argv[1:])
    sc.stop()
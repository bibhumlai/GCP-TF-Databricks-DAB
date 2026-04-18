# MAGIC %python
from pyspark.sql import SparkSession

# Initialize SparkSession


# Setup pathing via Unity Catalog Volumes
# Format: /Volumes/<catalog>/<schema>/<volume_name>/<folder>
raw_volume_path = "/Volumes/nativo_prod/raw_test/raw_landing"
checkpoint_path = "/Volumes/nativo_prod/raw_test/final_delta/_checkpoints"

# 1. BRONZE: Incremental Ingestion using Autoloader
# Autoloader handles schema evolution automatically
df_bronze = (spark.readStream
  .format("cloudFiles")
  .option("cloudFiles.format", "json")
  .option("cloudFiles.inferColumnTypes", "true")
  .load(raw_volume_path))

# Write to Bronze Table
(df_bronze.writeStream
  .option("checkpointLocation", f"{checkpoint_path}/bronze")
  .toTable("nativo_prod.raw_test.bronze_events"))

# 2. SILVER: Quality filtering (The "Senior DE" move)
from pyspark.sql.functions import col

def process_silver(batch_df, batch_id):
    # Filter out zero amounts and duplicates
    clean_df = batch_df.filter(col("amt") > 0).dropDuplicates(["user_id", "ts"])
    clean_df.write.format("delta").mode("append").saveAsTable("nativo_prod.raw_test.silver_events")

# Trigger the silver transformation
(df_bronze.writeStream
  .foreachBatch(process_silver)
  .option("checkpointLocation", f"{checkpoint_path}/silver")
  .start())
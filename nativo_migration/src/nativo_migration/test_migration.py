import pytest
from pyspark.sql import SparkSession

@pytest.fixture(scope="session")
def spark():
    return SparkSession.builder.getOrCreate()

def test_data_filter(spark):
    # Mock data
    data = [({"amount": 100}), ({"amount": -50})]
    df = spark.createDataFrame(data)
    
    # Apply logic
    filtered_df = df.filter(df.amount > 0)
    
    # Assert
    assert filtered_df.count() == 1
    assert filtered_df.collect()[0]["amount"] == 100
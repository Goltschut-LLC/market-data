import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

DataSource0 = glueContext.create_dynamic_frame.from_catalog(database = "main-rds-glue-catalog-database", table_name = "us_stock_market_daily_ohlcv", transformation_ctx = "DataSource0")

Transform0 = ApplyMapping.apply(frame = DataSource0, mappings = [("volume", "int", "volume", "int"), ("timeframe", "string", "timeframe", "string"), ("symbol", "string", "symbol", "string"), ("start_time", "timestamp", "start_time", "timestamp"), ("close_price", "double", "close_price", "double"), ("high_price", "double", "high_price", "double"), ("open_price", "double", "open_price", "double"), ("low_price", "double", "low_price", "double")], transformation_ctx = "Transform0")

DataSink0 = glueContext.write_dynamic_frame.from_options(frame = Transform0, connection_type = "s3", format = "csv", connection_options = {"path": "s3://aws-glue-goltschut-market-data-${ENV}/exports/daily_ohlcv/", "partitionKeys": ["symbol"]}, transformation_ctx = "DataSink0")

job.commit()
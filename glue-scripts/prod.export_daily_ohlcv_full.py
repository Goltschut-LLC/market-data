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

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "main-rds-glue-catalog-database", table_name = "us_stock_market_daily_ohlcv", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("volume", "int", "volume", "int"), ("timeframe", "string", "timeframe", "string"), ("symbol", "string", "symbol", "string"), ("start_time", "timestamp", "start_time", "timestamp"), ("close_price", "double", "close_price", "double"), ("high_price", "double", "high_price", "double"), ("open_price", "double", "open_price", "double"), ("low_price", "double", "low_price", "double")], transformation_ctx = "applymapping1")
applymapping1.toDF().write.mode("overwrite").format("csv").partitionBy("symbol").save('s3://aws-glue-goltschut-market-data-prod/exports')
job.commit()
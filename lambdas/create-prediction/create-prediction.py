# Standard
from math import sqrt
import os

# Third Party
import boto3
from matplotlib import pyplot
import pandas as pd
from statsmodels.tsa.arima.model import ARIMA

BUCKET = os.getenv('BUCKET')
DAILY_EXPORTS_PREFIX = 'exports/daily_ohlcv/'


def lambda_handler(event, context):
    s3 = boto3.client("s3")

    target_file_key = s3.list_objects_v2(
        Bucket=BUCKET,
        Prefix=DAILY_EXPORTS_PREFIX,
        MaxKeys=1
    )['Contents'][0]['Key']

    return {'target_file_key': target_file_key}

# obj = s3.get_object(Bucket=BUCKET, Key=target_file_key)
# df = pd.read_csv(obj['Body'])

# df['mid_price'] = (df['low_price'] + df['high_price'])/2
# df['percent_change'] = (df['close_price'] - df['open_price'])/df['open_price']
# df['mid_price_volume_product'] = df['mid_price'] * df['volume']

# predictions = {}

# for symbol in df['symbol'].unique():
#     try:
#         symbol_data = df[df['symbol'] == symbol]
#         symbol_data = symbol_data.sort_values(by=['symbol', 'start_time'])
#         X = symbol_data['percent_change'].values
#         model = ARIMA(X, order=[5,1,0])
#         model_fit = model.fit()
#         predicted_percent_change = model_fit.forecast()[0]
#         predictions[symbol] = predicted_percent_change        
#     except Exception as e:
#       print('An exception occurred while generating prediction for symbol:', symbol, str(e))
    
# print(predictions)

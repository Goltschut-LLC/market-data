# Standard
import io
import json
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

    symbol = event['Input']

    s3 = boto3.resource('s3')
    bucket = s3.Bucket(BUCKET)

    prefix_objs = bucket.objects.filter(
        Prefix=DAILY_EXPORTS_PREFIX + 'symbol=' + symbol
    )

    df = []

    for obj in prefix_objs:
        key = obj.key
        body = obj.get()['Body'].read()
        temp = pd.read_csv(io.BytesIO(body), encoding='utf8')        
        df.append(temp)

    df = pd.concat(df)

    df['mid_price'] = (df['low_price'] + df['high_price'])/2
    df['percent_change'] = (df['close_price'] - df['open_price'])/df['open_price']
    df['mid_price_volume_product'] = df['mid_price'] * df['volume']

    try:
        symbol_data = df.sort_values(by=['start_time'])
        X = symbol_data['percent_change'].values
        model = ARIMA(X, order=[5,1,0])
        model_fit = model.fit()
        predicted_percent_change = model_fit.forecast()[0]
        print(str({ 'prediction': predicted_percent_change }))
        return { 'prediction': predicted_percent_change }  

    except Exception as e:
        print('An exception occurred while generating prediction for symbol:', symbol, str(e))

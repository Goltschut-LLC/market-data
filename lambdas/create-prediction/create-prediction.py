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

    try:
        
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
        df['date_string'] = df['start_time'].apply(lambda start_time: start_time[:10])

        symbol_data = df.sort_values(by=['start_time'])
        X = symbol_data['percent_change'].values
        model = ARIMA(X, order=[5,1,0])
        model_fit = model.fit()
        predicted_percent_change = model_fit.forecast()[0]

        fig = pyplot.figure()
        ax = fig.add_subplot()

        ax.plot_date(df.tail(7)['date_string'], df.tail(7)['mid_price'], ls='-', color='b')
        ax.plot_date(pd.concat([df.tail(1)['date_string'], pd.Series(['Target Price'])]), pd.concat([df.tail(1)['mid_price'], pd.Series([df.tail(1)['mid_price']*(1+predicted_percent_change)])]), ls='--', color='g')
        ax.set_ylabel('Unadjusted Price (USD)')
        ax.set_title('Forecasted Price for Ticker ' + symbol)

        for tick in ax.get_xticklabels():
            tick.set_rotation(45)

        for spine in ax.spines:
            ax.spines[spine].set_visible(False)

        fig.savefig('s3://' + BUCKET + '/nice.png', dpi=300, orientation='landscape', transparent=True, bbox_inches='tight')

        result = { 
            'prediction': predicted_percent_change,
            'symbol': symbol 
        }

        print(str(result))
        return result  

    except Exception as e:
        print('An exception occurred while generating prediction for symbol:', symbol, str(e))

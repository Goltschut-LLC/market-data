# Standard
from io import BytesIO, StringIO
import json
from math import sqrt
import os

# Third Party
import boto3
from matplotlib import pyplot
import pandas as pd
from statsmodels.tsa.arima.model import ARIMA

EXPORTS_BUCKET = os.getenv('EXPORTS_BUCKET')
DAILY_EXPORTS_PREFIX = 'exports/daily_ohlcv/'

PUBLIC_BUCKET = os.getenv('PUBLIC_BUCKET')
PUBLIC_PREDICTIONS_PREFIX = 'predictions/arima/'

def lambda_handler(event, context):

    symbol = event['Input']

    try:    

        s3 = boto3.resource('s3')
        exports_bucket = s3.Bucket(EXPORTS_BUCKET)

        prefix_objs = exports_bucket.objects.filter(
            Prefix=DAILY_EXPORTS_PREFIX + 'symbol=' + symbol + '/'
        )

        df = []

        for obj in prefix_objs:
            key = obj.key
            body = obj.get()['Body'].read()
            temp = pd.read_csv(BytesIO(body), encoding='utf8')        
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

        ax.plot_date(
            symbol_data.tail(7)['date_string'],
            symbol_data.tail(7)['mid_price'],
            ls='-',
            color='b'
        )
        ax.plot_date(
            pd.concat([
                symbol_data.tail(1)['date_string'],
                pd.Series(['Target Price'])
            ]), 
            pd.concat([
                symbol_data.tail(1)['mid_price'],
                pd.Series([symbol_data.tail(1)['mid_price']*(1+predicted_percent_change)])
            ]), ls='--', color='g')
        ax.set_ylabel('Unadjusted Price $USD')

        for tick in ax.get_xticklabels():
            tick.set_rotation(45)

        for spine in ax.spines:
            ax.spines[spine].set_visible(False)

        img_data = BytesIO()
        fig.savefig(
            img_data,
            dpi=300,
            orientation='landscape',
            transparent=True,
            bbox_inches='tight'
        )
        img_data.seek(0)

        public_bucket = s3.Bucket(PUBLIC_BUCKET)
        public_bucket.put_object(Body=img_data, ContentType='image/png', Key=PUBLIC_PREDICTIONS_PREFIX + 'symbol=' + symbol + '/prediction.png')

        json_df = symbol_data.tail(7)
        json_df['predicted_percent_change'] = predicted_percent_change
        json_buffer = StringIO()
        json_df.reset_index().to_json(json_buffer)
        public_bucket.put_object(Body=json_buffer.getvalue(), Key=PUBLIC_PREDICTIONS_PREFIX + 'symbol=' + symbol + '/prediction.json')

        result = { 
            'p': "%.3f" % predicted_percent_change,
            's': symbol 
        }

        print(str(result))
        return result  

    except Exception as e:
        print(
            'An exception occurred while generating prediction for symbol:', 
            symbol,
            str(e)
        )
        
        return { 'p': None, 's': symbol }

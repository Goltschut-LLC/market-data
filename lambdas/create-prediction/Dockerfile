FROM public.ecr.aws/lambda/python:3.8

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY create-prediction.py .

CMD [ "create-prediction.lambda_handler" ]

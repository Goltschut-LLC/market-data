#!/bin/sh
FUNCTION_NAME="ingest-daily-ohlcv"
npm i
rm ./dist/$FUNCTION_NAME.zip .
zip -r ./dist/$FUNCTION_NAME.zip .

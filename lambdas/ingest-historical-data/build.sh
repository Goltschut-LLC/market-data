#!/bin/sh
FUNCTION_NAME="ingest-historical-data"
rm ./dist/$FUNCTION_NAME.zip .
zip -r ./dist/$FUNCTION_NAME.zip .
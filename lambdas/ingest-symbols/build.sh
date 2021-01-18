#!/bin/sh
FUNCTION_NAME="ingest-symbols"
npm i
rm ./dist/$FUNCTION_NAME.zip .
zip -r ./dist/$FUNCTION_NAME.zip .

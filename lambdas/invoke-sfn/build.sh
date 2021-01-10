#!/bin/sh
FUNCTION_NAME="invoke-sfn"
npm i
rm ./dist/$FUNCTION_NAME.zip .
zip -r ./dist/$FUNCTION_NAME.zip .

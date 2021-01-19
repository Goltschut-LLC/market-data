#!/bin/sh
FUNCTION_NAME="get-initialize-symbol-payloads"
npm i
rm ./dist/$FUNCTION_NAME.zip .
zip -r ./dist/$FUNCTION_NAME.zip .

#!/bin/sh
FUNCTION_NAME="batch-symbols"
npm i
rm ./dist/$FUNCTION_NAME.zip .
zip -r ./dist/$FUNCTION_NAME.zip .

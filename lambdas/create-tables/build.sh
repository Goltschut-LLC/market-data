#!/bin/sh
FUNCTION_NAME="create-tables"
npm i
rm ./dist/$FUNCTION_NAME.zip .
zip -r ./dist/$FUNCTION_NAME.zip .

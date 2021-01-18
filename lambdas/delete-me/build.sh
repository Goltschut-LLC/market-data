#!/bin/sh
FUNCTION_NAME="delete-me"
npm i
rm ./dist/$FUNCTION_NAME.zip .
zip -r ./dist/$FUNCTION_NAME.zip .

#!/bin/sh
for lambda in ingest-historical-data create-tables delete-me
do 
    cd ./lambdas/$lambda

    npm run format
    bash build.sh
    cd -
done

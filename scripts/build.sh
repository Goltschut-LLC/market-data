#!/bin/sh
for lambda in create-tables ingest-symbols ingest-aggregate-observations delete-me
do 
    cd ./lambdas/$lambda

    npm run format
    bash build.sh
    cd -
done

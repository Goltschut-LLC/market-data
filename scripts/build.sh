#!/bin/sh
for lambda in create-tables ingest-symbols ingest-daily-ohlcv
do 
    cd ./lambdas/$lambda

    npm run format
    bash build.sh
    cd -
done

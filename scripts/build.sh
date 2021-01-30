#!/bin/sh
for lambda in batch-symbols create-tables get-initialize-symbol-payloads get-symbols get-update-symbol-payload ingest-daily-ohlcv ingest-symbols
do 
    cd ./lambdas/$lambda

    npm run format
    bash build.sh
    cd -
done

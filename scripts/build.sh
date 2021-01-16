#!/bin/sh
cd ./lambdas/ingest-historical-data

npm run format
bash build.sh
cd -
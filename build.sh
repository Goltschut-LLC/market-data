#!/bin/sh
workdir=$PWD

cd ./lambdas/ingest-historical-data
bash build.sh
cd $workdir

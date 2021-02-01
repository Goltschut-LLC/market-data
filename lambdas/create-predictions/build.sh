#!/bin/sh
mkdir lambda_layer
cd lambda_layer
cp -r ../venv/lib64/python3.8/dist-packages/* .
cd ..
zip -r lambda_data_science_layer_payload.zip lambda_layer

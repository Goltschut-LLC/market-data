#!/bin/sh

cd ./venv/lib/python3.8/site-packages
zip -r ../../../../create-prediction.zip .
cd ../../../../

zip -g create-prediction.zip create-prediction.py
zip create-prediction.zip ./*.py

rm -rf ./dist/*

mv create-prediction.zip ./dist

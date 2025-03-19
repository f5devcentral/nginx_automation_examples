#!/bin/bash

BUCKET="$1"
KEY="$2"
REGION="$3"
DYNAMODB_TABLE="$4"

sed -e "s/{{ .Bucket }}/$BUCKET/" \
    -e "s/{{ .Key }}/$KEY/" \
    -e "s/{{ .Region }}/$REGION/" \
    -e "s/{{ .DynamoDBTable }}/$DYNAMODB_TABLE/" \
    backend.tf.template > backend.tf
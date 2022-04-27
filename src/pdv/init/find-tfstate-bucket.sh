#!/bin/bash

## Find s3 bucket with tag value tfstate.
## Buckets with this tag are supposed to store terraform state file.

for BUCKET in $(aws s3api list-buckets --output json | jq .Buckets[].Name -r); do
    RESULT=$(aws s3api get-bucket-tagging --bucket $BUCKET --output json 2>&1)
    if [[ $RESULT == *"tfstate"* ]]; then
        echo $BUCKET
    fi
done
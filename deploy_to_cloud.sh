#!/bin/bash
set -e

aws cloudformation package --template-file template.yaml --output-template-file serverless-output.yaml --s3-bucket steve-mbta-proxy-deployment
aws cloudformation deploy --template-file serverless-output.yaml --stack-name mbta-proxy --capabilities CAPABILITY_IAM

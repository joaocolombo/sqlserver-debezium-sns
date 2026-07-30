#!/usr/bin/env bash
set -euo pipefail

awslocal sns create-topic --name sqlserver_cdc-dbo-pessoa

awslocal sqs create-queue --queue-name fila-dados-pessoa

awslocal sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:000000000000:sqlserver_cdc-dbo-pessoa \
    --protocol sqs \
    --notification-endpoint arn:aws:sqs:us-east-1:000000000000:fila-dados-pessoa
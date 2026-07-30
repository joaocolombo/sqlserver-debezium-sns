#!/usr/bin/env bash
set -euo pipefail

# Debezium destination (SNS topic) name:
# topic.prefix + topic.delimiter + database + delimiter + schema + delimiter + table
TOPIC_NAME="cdcserver-CadastroDB-dbo-pessoa"
QUEUE_NAME="fila-dados-pessoa"

awslocal sns create-topic --name "${TOPIC_NAME}" >/dev/null
awslocal sqs create-queue --queue-name "${QUEUE_NAME}" >/dev/null

# LocalStack default account id
TOPIC_ARN="arn:aws:sns:us-east-1:000000000000:${TOPIC_NAME}"
QUEUE_ARN="arn:aws:sqs:us-east-1:000000000000:${QUEUE_NAME}"

awslocal sns subscribe \
  --topic-arn "${TOPIC_ARN}" \
  --protocol sqs \
  --notification-endpoint "${QUEUE_ARN}" \
  --attributes RawMessageDelivery=true >/dev/null

TOPIC_NAME="cdcserver-CadastroDB-dbo-pessoa2"
QUEUE_NAME="fila-dados-pessoa2"

awslocal sns create-topic --name "${TOPIC_NAME}" >/dev/null
awslocal sqs create-queue --queue-name "${QUEUE_NAME}" >/dev/null

# LocalStack default account id
TOPIC_ARN="arn:aws:sns:us-east-1:000000000000:${TOPIC_NAME}"
QUEUE_ARN="arn:aws:sqs:us-east-1:000000000000:${QUEUE_NAME}"

awslocal sns subscribe \
  --topic-arn "${TOPIC_ARN}" \
  --protocol sqs \
  --notification-endpoint "${QUEUE_ARN}" \
  --attributes RawMessageDelivery=true >/dev/null

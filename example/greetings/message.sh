#!/bin/sh
set -e

export AWS_ACCESS_KEY_ID=$(cat /tmp/secrets/AWS_ACCESS_KEY_ID)
export AWS_SECRET_ACCESS_KEY=$(cat /tmp/secrets/AWS_SECRET_ACCESS_KEY)

echo "sending a message to queue $QUEUE_URL"
aws sqs send-message --queue-url $QUEUE_URL --message-body "hello world!" --message-group-id "greetings" --message-deduplication-id "world"

echo "reading a message from queue $QUEUE_URL"
aws sqs receive-message --queue-url $QUEUE_URL
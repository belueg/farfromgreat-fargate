#!/bin/sh

echo "Fetching S3 bucket and SSL certificate info from Parameter Store..."

S3_BUCKET=$(aws ssm get-parameter --name "/node-app/S3_BUCKET" --with-decryption --query "Parameter.Value" --output text)
SSL_CERT_FILE=$(aws ssm get-parameter --name "/node-app/SSL_CERT_FILE" --with-decryption --query "Parameter.Value" --output text)

echo "Downloading SSL certificate from S3..."
aws s3 cp "s3://$S3_BUCKET/$SSL_CERT_FILE" "/tmp/$SSL_CERT_FILE"

echo "SSL certificate downloaded. Starting app..."
exec node server.js

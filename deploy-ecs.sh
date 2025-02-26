#!/bin/bash

echo "Fetching environment variables from AWS Parameter Store..."

AWS_REGION=$(aws ssm get-parameter --name "/node-app/AWS_REGION" --with-decryption --query "Parameter.Value" --output text)
ECR_REPO=$(aws ssm get-parameter --name "/node-app/ECR_REPO" --with-decryption --query "Parameter.Value" --output text)
TASK_FAMILY=$(aws ssm get-parameter --name "/node-app/TASK_FAMILY" --with-decryption --query "Parameter.Value" --output text)
CLUSTER=$(aws ssm get-parameter --name "/node-app/CLUSTER" --with-decryption --query "Parameter.Value" --output text)
SERVICE=$(aws ssm get-parameter --name "/node-app/SERVICE" --with-decryption --query "Parameter.Value" --output text)

echo "✅ Loaded environment variables securely."

CPU="256"
MEMORY="1024"


echo "1) AWS ECR authentication"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO

echo "2) Building Docker image"
docker build --platform linux/amd64 -t node-app .

echo "3) Tagging image"
TAG=$(date +%Y%m%d-%H%M)
docker tag node-app:latest $ECR_REPO:$TAG
docker tag node-app:latest $ECR_REPO:latest

echo "4) Pushing to ECR"
docker push $ECR_REPO:$TAG
docker push $ECR_REPO:latest

echo "5) Waiting for image to be available in ECR..."
while ! aws ecr describe-images --repository-name node-app --image-ids imageTag=latest --region $AWS_REGION > /dev/null 2>&1; do
    echo "   ... waiting 5 seconds for the image to be available in ECR"
    sleep 5
done

echo "6) Registering new task definition with SSM Parameter Store secrets"
aws ecs register-task-definition \
    --family $TASK_FAMILY \
    --execution-role-arn $(aws ecs describe-task-definition --task-definition $TASK_FAMILY --query "taskDefinition.executionRoleArn" --output text) \
    --task-role-arn "arn:aws:iam::266735829867:role/ECSExecRole" \
    --network-mode awsvpc \
    --requires-compatibilities FARGATE \
    --cpu $CPU \
    --memory $MEMORY \
    --container-definitions "[
        {
            \"name\": \"node-app\",
            \"image\": \"$ECR_REPO:latest\",
            \"cpu\": $CPU,
            \"memory\": $MEMORY,
            \"memoryReservation\": 512,
            \"portMappings\": [
                {
                    \"containerPort\": 3000,
                    \"hostPort\": 3000,
                    \"protocol\": \"tcp\"
                }
            ],
            \"logConfiguration\": {
                \"logDriver\": \"awslogs\",
                \"options\": {
                    \"awslogs-group\": \"/ecs/$TASK_FAMILY\",
                    \"awslogs-region\": \"$AWS_REGION\",
                    \"awslogs-stream-prefix\": \"ecs\"
                }
            },
            \"secrets\": [
                {\"name\": \"PG_USER\", \"valueFrom\": \"/node-app/PG_USER\"},
                {\"name\": \"PG_HOST\", \"valueFrom\": \"/node-app/PG_HOST\"},
                {\"name\": \"PG_DATABASE\", \"valueFrom\": \"/node-app/PG_DATABASE\"},
                {\"name\": \"PG_PASSWORD\", \"valueFrom\": \"/node-app/PG_PASSWORD\"},
                {\"name\": \"PG_PORT\", \"valueFrom\": \"/node-app/PG_PORT\"},
                { \"name\": \"PG_SSL_CERT_PATH\", \"valueFrom\": \"/node-app/PG_SSL_CERT_PATH\" }

            ],
            \"essential\": true
        }
    ]"

echo "7) Updating service with new task definition"
NEW_TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --query "taskDefinition.taskDefinitionArn" --output text)
aws ecs update-service --cluster $CLUSTER --service $SERVICE --task-definition $NEW_TASK_DEF --force-new-deployment


echo "🚀 Deployment completed successfully!"

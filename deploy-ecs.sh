#!/bin/bash

AWS_REGION="us-east-1"
ECR_REPO="266735829867.dkr.ecr.$AWS_REGION.amazonaws.com/node-app"
TASK_FAMILY="node-app-task"
CLUSTER="bel-clust3r"
SERVICE="node-app-svc"

echo "1) AWS ECR authentication"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO

echo "2) Building Docker image"
docker build --platform linux/amd64 -t node-app .

echo "3) Tagging image"
docker tag node-app:latest $ECR_REPO:latest

echo "4) Pushing to ECR"
docker push $ECR_REPO:latest

echo "5) Waiting for image to be available in ECR..."
while ! aws ecr describe-images --repository-name node-app --image-ids imageTag=latest --region $AWS_REGION > /dev/null 2>&1; do
    echo "   ... waiting 10 seconds for image to be available in ECR"
    sleep 10
done

echo "6) Getting last Task Definition"
LATEST_TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --query "taskDefinition.taskDefinitionArn" --output text)

echo "7) Creating new revision of task definition"
aws ecs register-task-definition \
    --family $TASK_FAMILY \
    --execution-role-arn $(aws ecs describe-task-definition --task-definition $TASK_FAMILY --query "taskDefinition.executionRoleArn" --output text) \
    --container-definitions "$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --query "taskDefinition.containerDefinitions" --output json | sed "s|$LATEST_TASK_DEF|$ECR_REPO:latest|g")"

echo "8) Force new deployment"
aws ecs update-service --cluster $CLUSTER --service $SERVICE --force-new-deployment

echo " Deployment completed! ✅ 🚀"

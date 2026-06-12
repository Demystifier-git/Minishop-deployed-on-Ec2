#!/bin/bash
set -e

REGION="us-east-1"
VERSION_PARAM="/minishop/backend/version"
SECRET_NAME="prod/minishop/app"
ECR_REPO="387041334219.dkr.ecr.us-east-1.amazonaws.com/minishop-backend"

echo "===== USERDATA START ====="


# 1. GET VERSION FROM SSM

VERSION=$(aws ssm get-parameter \
  --name "$VERSION_PARAM" \
  --region "$REGION" \
  --query "Parameter.Value" \
  --output text)

echo "Backend version: $VERSION"


# 2. GET SECRETS FROM SECRETS MANAGER

echo "Fetching secrets..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --region "$REGION" \
  --query SecretString \
  --output text)

# Export DB variables
export DB_HOST=$(echo "$SECRET_JSON" | jq -r '.DB_HOST')
export DB_USER=$(echo "$SECRET_JSON" | jq -r '.DB_USER')
export DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.DB_PASSWORD')
export DB_NAME=$(echo "$SECRET_JSON" | jq -r '.DB_NAME')

# Export SMTP variables
export SMTP_HOST=$(echo "$SECRET_JSON" | jq -r '.SMTP_HOST')
export SMTP_USER=$(echo "$SECRET_JSON" | jq -r '.SMTP_USER')
export SMTP_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.SMTP_PASSWORD')
export SMTP_FROM=$(echo "$SECRET_JSON" | jq -r '.SMTP_FROM')

echo "Secrets exported"


# 3. ECR LOGIN

aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$ECR_REPO"


# 4. PULL IMAGE

docker pull "$ECR_REPO:$VERSION"


# 5. RESTART SYSTEMD STACK

systemctl restart minishop

echo "===== USERDATA COMPLETE ====="
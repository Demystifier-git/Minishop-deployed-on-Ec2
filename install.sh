#!/bin/bash
set -euo pipefail

AWS_REGION="us-east-1"
SECRET_NAME="prod/minishop/app"
APP_DIR="/root/Minishop-deployed-on-Ec2"

echo "Updating system..."
apt-get update -y

echo "Installing base tools..."
apt-get install -y curl unzip git jq ca-certificates gnupg lsb-release

echo "Installing Docker..."

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

echo "Installing AWS CLI v2..."
if ! command -v aws &> /dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
  unzip -q awscliv2.zip
  ./aws/install
  rm -rf aws awscliv2.zip
fi

echo "Verifying installations..."
docker --version
docker compose version
aws --version
git --version

echo "Cloning application repo..."
if [ ! -d "$APP_DIR" ]; then
  git clone https://github.com/Demystifier-git/Minishop-deployed-on-Ec2.git "$APP_DIR"
fi

cd "$APP_DIR"

echo "Fetching secrets from AWS Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$SECRET_NAME" \
  --query SecretString \
  --output text)

if [[ -z "$SECRET_JSON" || "$SECRET_JSON" == "None" ]]; then
  echo "Failed to fetch secrets"
  exit 1
fi

echo "Creating .env file from Secrets Manager..."

echo "$SECRET_JSON" | jq -r '
  to_entries |
  map("\(.key)=\(.value|tostring)") |
  .[]
' > .env

echo "Setting application version from SSM..."

VERSION=$(aws ssm get-parameter \
  --name "/minishop/backend/version" \
  --query "Parameter.Value" \
  --output text \
  --region "$AWS_REGION")

echo "VERSION=$VERSION" >> .env

echo "Logging into ECR..."

aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin 387041334219.dkr.ecr.us-east-1.amazonaws.com

echo "Deploying application..."

docker compose down || true
docker compose up -d --build

echo "Deployment complete"
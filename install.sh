#!/bin/bash
set -euo pipefail

AWS_REGION="us-east-1"
SECRET_NAME="prod/minishop/app"
APP_DIR="/root/app/Minishop-deployed-on-Ec2/"

echo "Updating system..."
sudo apt-get update -y

echo "Installing base tools..."
sudo apt-get install -y curl unzip git jq ca-certificates gnupg lsb-release

echo "Installing Docker..."

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

echo "Installing AWS CLI v2..."

if ! command -v aws &> /dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  sudo ./aws/install
  rm -rf aws awscliv2.zip
fi

echo "Verifying installations..."
docker --version
docker compose version
aws --version
git --version

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

echo "Creating runtime environment for Docker..."

# 🔥 FIX: convert secrets into environment variables safely
export $(echo "$SECRET_JSON" | jq -r 'to_entries | map("\(.key)=\(.value|tostring)") | .[]')

echo "Secrets injected successfully"

echo "Deploying application..."

cd "$APP_DIR"

docker compose down || true
docker compose up -d --build

echo "Deployment complete"
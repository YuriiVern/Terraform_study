#!/bin/bash

sudo apt-get update -y

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker ubuntu

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


sudo apt-get install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version >> /var/log/user-data.log 2>&1

SECRET_NAME="my-test-secret_v9"
REGION="us-east-1"
ENV_FILE="/home/ubuntu/.env"

SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query "SecretString" --output text --region "$REGION")

echo "$SECRET_VALUE" > "$ENV_FILE"
sudo chmod 777 "$ENV_FILE"

(sleep 30 && sudo reboot) &
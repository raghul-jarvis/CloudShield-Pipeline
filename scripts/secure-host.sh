#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting Host System Provisioning Cycle..."
export DEBIAN_FRONTEND=noninteractive

# Update system repositories
apt-get update -y && apt-get upgrade -y

# Install system dependencies required for Docker
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Configure official Docker cryptographic signing keys
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker engine upstream repository channels
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update repository records and pull down Docker runtimes
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable Docker daemon service routines
systemctl enable --now docker

# Establish firewall boundaries on the virtual host machine
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw --force enable

echo "==> Node configuration sequence executed successfully."
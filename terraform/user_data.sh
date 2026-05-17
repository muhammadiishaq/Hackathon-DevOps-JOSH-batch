#!/bin/bash

set -e

LOG_FILE="/var/log/devsecops-bootstrap.log"

exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "Starting DevSecOps Bootstrap..."

# Update system
apt update -y

# Install required packages
apt install -y \
    docker.io \
    curl \
    wget \
    git \
    unzip \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Enable Docker
systemctl enable docker
systemctl start docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

echo "Docker installed successfully"

# Install kubectl
curl -LO "https://dl.k8s.io/release/v1.33.1/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client

echo "kubectl installed successfully"

# Install k3s Kubernetes
curl -sfL https://get.k3s.io | sh -

sleep 30

systemctl status k3s

echo "k3s installed successfully"

# Configure kubeconfig
mkdir -p /home/ubuntu/.kube

cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config

chown -R ubuntu:ubuntu /home/ubuntu/.kube

export KUBECONFIG=/home/ubuntu/.kube/config

echo "Kubeconfig configured"

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm version

echo "Helm installed successfully"

# Install Docker Compose
apt install docker-compose-plugin -y

docker compose version

echo "Docker Compose installed"

# Install Trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -

echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main \
| tee /etc/apt/sources.list.d/trivy.list

apt update -y

apt install trivy -y

trivy --version

echo "Trivy installed successfully"

# Install htop
apt install htop -y

# Final verification
kubectl get nodes

echo "================================="
echo "DevSecOps Bootstrap Completed"
echo "================================="
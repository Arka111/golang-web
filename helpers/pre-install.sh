#! /bin/bash


# Exit immediately if a command exits with a non-zero status.
# Print commands and arguments as they are being executed.
set -xe

# Adds JetStack repository

helm repo add jetstack https://charts.jetstack.io

# Adds Bitnami repository

helm repo add bitnami https://charts.bitnami.com/bitnami

# Update Helm repository

helm repo update

# Check if cluster exits, if not exit with 0
# If the cluster exist, authenticate on it

# if [[ $(aws eks list-clusters --region $REGION --query 'clusters[*]' --output text) != $EKS_CLUSTER ]]
# then
#     echo "Cluster Does not exist"
#     exit 0
# else
#     aws eks --region $REGION  update-kubeconfig --name $EKS_CLUSTER
#     sleep 10

# fi
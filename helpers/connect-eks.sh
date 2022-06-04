#! /bin/bash


# Exit immediately if a command exits with a non-zero status.
# Print commands and arguments as they are being executed.
set -xe

if [[ $(aws eks list-clusters --region $REGION --query 'clusters[*]' --output text) != $EKS_CLUSTER ]]
then
    echo "Cluster Does not exist"
    exit 1
else
    aws eks --region $REGION  update-kubeconfig --name $EKS_CLUSTER
    sleep 10

fi
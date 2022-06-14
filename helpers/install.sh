#! /bin/bash


# Exit immediately if a command exits with a non-zero status.
# Print commands and arguments as they are being executed.
set -xe

# Install Metrics Server 

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Install Nginx ingress controller

helm upgrade --install  nginx bitnami/nginx-ingress-controller --namespace nginx-ingress --create-namespace --version 7.6.21 --set replicaCount=2 

# Install Cert-manager 

helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.5.3 --set installCRDs=true

# Install Cert-manager cluster-issuer prod and staging 

kubectl apply -f ./cm-issuers/prod_issuer.yaml

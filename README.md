# Golang - Docker - Helm 

This repo contains the application part. It is composed of the golang web application and the Helm chart to deploy the container.

## Project Objectives

1. Docker Image

Create a Golang container as small and as secure as possible.

Automate the build and upload of the container.


2. Automation

The whole process is fully automated. There are two pipelines. One is responsible for creating the container and pushing it to DockerHub, after this pipeline finishes it is gonna trigger a second pipeline which is responsible for deploying the Helm chart into the EKS cluster.
## Solution Explanation

Every time a change is made into any file inside the golang-app, the first pipeline is gonna trigger, build a container, tag it, and push it to DockerHub.

Once this pipeline finishes a second pipeline is gonna be trigged and it is gonna deploy the install/upgrade the Helm chart into the EKS cluster.

The Helm chart is gonna deploy the application, including the ingress resource with TLS support, and HPA. Also, every change made into the values.yaml file is gonna the
pipeline responsible for deploying the Helm chart, in case it is needed to change only configuration regarding the chart and not update the container image.

## List of folders/files and their descriptions

1. [golang-app](golang-app) Contains the application code and the Dockerfile.
2. [golang-web-chart](golang-web-chart) Contains the Helm chart responsible for deploying the Golang application.
3. [helpers](helpers) Contains scripts used by GitHub Actions.
   
## GitHub Actions Workflows

1. [terraform.yaml] (.github/workflows/terraform.yaml) Provision the infra on AWS (VPC, EKS-Master and EKS-Nodes)
2. [configure_eks.yaml] (.github/workflows/configure_eks.yaml) Install EKS Add-ons
1. [golang-build-push.yaml](.github/workflows/golang-build-push.yaml) Workflow responsible for building the container and pushing it to DockerHub.
2. [deploy-golang-chart.yaml](.github/workflows/configure-eks.yaml) Workflow responsible for deploying the Helm chart into the EKS cluster.

## Configuring GitHub Actions Workflows

The workflow needs below secrets in order to work:

- AWS_ACCESS_KEY_ID: Access key used by AWS CLI
- AWS_SECRET_ACCESS_KEY: Secret key used by AWS CLI
- DOCKER_HUB_USERNAME: DockerHub username
- DOCKER_HUB_ACCESS_TOKEN: DockerHub Access Token
- TF_API_TOKEN: Token used to connect to Terraform Cloud


## Considerations

1. The Container tagging strategy is not optimal for a production environment, since it does not use any tagging strategy and every build tags the image with latest.

2. The pipeline/deployment strategy is not optimal for a production environment.
   
3. To keep things simple, I did not configure "advanced" stuff such as Affinity and anti-affinity to improve pod scalability/resilience.

4. The Dockerfile was created to be as simple as possible.

# Golang - Docker - Helm - Terraform

This repo contains the end-toend pipeline. It is composed of the golang web application and the Helm chart to deploy the container, and the infra required to be created for this set-up with the use of Terraform.

## Project Objectives

1. Docker Image

Create a Golang container as small and as secure as possible.

Automate the build and upload of the container. Deploy it using Helm charts.

2. TLS Offloading and Load Balancer.

LoadBalancer type service creates a L4 load balancer. L4 load balancers are aware about source IP:port and destination IP:port, but they are not aware about anything on the application layer.

HTTP/HTTPS load balancers are on L7, therefor they are application aware.

So, basically you it is not possible to get  a HTTPS load balancer from a LoadBalancer type service. The achieve it, a Ingress controller is needed.

Nginx was the choice for this project. Since it is one of the most used by the community, and has a great support.

To manage certificates, Cert-Manager was the choice for this project. It is the most popular solution used in Kubernetes and has a great support from the community.

3. Automation

The whole process is fully automated. There are four pipelines. 
One is responsible for creating the whole infra on AWS, after this pipeline finishes it is gonna trigger a second pipeline which is responsible for configuring the following add-ons:

- Metrics Server
- Nginx Ingress Controller
- Cert-Manager
- Cert-Manager Issuers(Prod only)

Next ones are responsible for creating the container and pushing it to DockerHub, after this pipeline finishes it is gonna trigger another pipeline which is responsible for deploying the Helm chart into the EKS cluster.

## Solution Explanation

Cert-manager is a native Kubernetes certificate management controller. It can help with issuing certificates from a variety of sources, such as Let’s Encrypt, HashiCorp Vault, Venafi, a simple signing keypair, or self signed.

It will ensure certificates are valid and up to date, and attempt to renew certificates at a configured time before expiry.

The sub-component ingress-shim watches Ingress resources across the cluster. If it observes an Ingress with a supported annotation, it will ensure a Certificate resource with the name provided in the tls.secretName field and configured as described on the Ingress exists.

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    # add an annotation indicating the issuer to use.
    cert-manager.io/cluster-issuer: nameOfClusterIssuer
  name: myIngress
  namespace: myIngress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: myservice
            port:
              number: 80
  tls: # < placing a host in the TLS config will determine what ends up in the cert's subjectAltNames
  - hosts:
    - example.com
    secretName: myingress-cert # < cert-manager will store the created certificate in this secret.
```

Every time a change is made into any file inside the golang-app, the pipeline is gonna trigger, create the infra on AWS, and then the next pipeline will trigger to create the Add-ons. The 3rd pipeline build a container, tag it, and push it to DockerHub.

Once this pipeline finishes the next pipeline is gonna be trigged and it is gonna deploy the install/upgrade the Helm chart into the EKS cluster.

The Helm chart is gonna deploy the application, including the ingress resource with TLS support, and HPA. Also, every change made into the values.yaml file is gonna the
pipeline responsible for deploying the Helm chart, in case it is needed to change only configuration regarding the chart and not update the container image.



## List of folders/files and their descriptions

1. [main.tf](main.tf) File responsible for the modules composition. It is responsible for "calling" external Terraform modules to create VPC, EKS-MASTER and EKS-NODES
2. [backend.tf](variables.tf) File responsible for the backend configuration to connect to terraform cloud, where the state file is being kept.
3. [golang-app](golang-app) Contains the application code and the Dockerfile.
4. [golang-web-chart](golang-web-chart) Contains the Helm chart responsible for deploying the Golang application.
5. [helpers](helpers) Contains scripts used by GitHub Actions.
   
## Helpers

1. check-bin.sh: script that check if the binaries needed.
2. connect-eks.sh: script used to connect to EKS cluster API.
3. pre-install.sh: script used to add Helm repositories.
4. install.sh: script used to install EKS add-ons.

## GitHub Actions Workflows

1. [terraform.yaml](.github/workflows/terraform.yaml) Provision the infra on AWS (VPC, EKS-Master and EKS-Nodes)
2. [configure_eks.yaml](.github/workflows/configure_eks.yaml) Install EKS Add-ons
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

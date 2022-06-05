provider "aws" {

  region = "eu-west-1"

}

locals {
  cluster_name = "eks-cluster-golang-web"
  environment  = "task"
}

module "networking" {

  source              = "github.com/arka111/terraform-aws-networking"
  vpc_name            = "vpc-golang-web"
  environment         = local.environment
  azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_ip_on_launch = "true"
  vpc_cidr_block      = "192.168.0.0/16"
  public_subnets      = ["192.168.0.0/19", "192.168.32.0/19", "192.168.64.0/19"]
  private_subnets     = ["192.168.96.0/19", "192.168.128.0/19", "192.168.160.0/19"]
  enable_nat_gateway  = true

  tags = {

    "kubernetes.io/cluster/${local.cluster_name}-${local.environment}" = "shared"
    "kubernetes.io/role/elb"                                           = "1"
  }

}

module "eks_master" {

  source             = "github.com/arka111/terraform-aws-eks-master"
  environment        = local.environment
  cluster_name       = local.cluster_name
  master_subnets     = module.networking.public_subnets
  cluster_log_types  = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  create_cluster_iam = true

  tags = {
    "enviroment" = local.environment
  }

  depends_on = [module.networking]
}

module "eks_nodes_data" {
  source                    = "github.com/arka111/terraform-aws-eks-node"
  cluster_name              = module.eks_master.cluster_name
  node_group_name           = "node-group-01"
  subnet_ids                = module.networking.private_subnets
  instance_types            = ["t3.medium"]
  create_node_iam           = true
  create_cluster_autoscaler = true

  scaling_config = [{
    desired_size = 3
    max_size     = 6
    min_size     = 4
  }]

  

  depends_on = [module.networking, module.eks_master]
}

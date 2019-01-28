#
# Provider Configuration
#

# For purposes of this demo the aws provider will use the AWS-cli 
# config for creds In a pipeline you could uncomment the access_key 
# and secret_key lines in order to pass them in as cli-args
provider "aws" {
# access_key        = "${var.aws_access_key}"
# secret_key        = "${var.aws_secret_key}"
  region = "us-east-2"
}

#In a collaborative environment you would implement a terraform backend
#terraform {
#  backend "s3" {
#    bucket                = "states"
#    key                   = "tf/backend/timestamp-api"
#    region                = "us-west-2"
#  }
#}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

# Not required: currently used in conjuction with using
# icanhazip.com to determine local workstation external IP
# to open EC2 Security Group access to the Kubernetes cluster.
# See workstation-external-ip.tf for additional information.
provider "http" {}


module "vpc" {
  source = "./modules/vpc"
  cluster-name = "${var.cluster-name}"
}


module "workstation-external-ip" {
  source = "./modules/workstation-external-ip"
}


module "eks-cluster" {
  source                    = "./modules/eks-cluster"
  cluster-name              = "${var.cluster-name}"
  aws_sg_demo_node_id       = "${module.eks-worker-nodes.aws_sg_demo_node_id}"
  aws_vpc_demo_id           = "${module.vpc.aws_vpc_demo_id}"
  aws_subnet_demo           = "${module.vpc.aws_subnet_demo}"
  workstation-external-cidr = "${module.workstation-external-ip.workstation-external-cidr}"
}


module "eks-worker-nodes" {
  source                                = "./modules/eks-worker-nodes"
  cluster-name                          = "${var.cluster-name}"
  aws_vpc_demo_id                       = "${module.vpc.aws_vpc_demo_id}"
  aws_sg_demo_cluster_id                = "${module.eks-cluster.aws_sg_demo_cluster_id}"
  aws_subnet_demo                       = "${module.vpc.aws_subnet_demo}"
  aws_eks_cluster_demo_endpoint         = "${module.eks-cluster.aws_eks_cluster_demo_endpoint}"
  aws_eks_cluster_demo_cert_auth_0_data = "${module.eks-cluster.aws_eks_cluster_demo_cert_auth_0_data}"
}


module "eks-state" {
  source                                = "./modules/eks-state"
  cluster-name                          ="${var.cluster-name}"
  aws_iam_role_demo_node                = "${module.eks-worker-nodes.aws_iam_role_demo_node}"
  aws_eks_cluster_demo_endpoint         = "${module.eks-cluster.aws_eks_cluster_demo_endpoint}"
  aws_eks_cluster_demo_cert_auth_0_data = "${module.eks-cluster.aws_eks_cluster_demo_cert_auth_0_data}"
}

module "s3-react" {
  source = "./modules/s3-react"
}

module "r53" {
  source   = "./modules/r53"
  api_ep   = "${module.eks-state.api_ep}"
  web_fe   = "${module.s3-react.web_ep}"
  web_zone = "${module.s3-react.web_zone}"
}

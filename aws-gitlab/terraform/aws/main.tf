terraform {
  backend "s3" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key    = "terraform/aws/terraform.tfstate"

    region  = "<CLOUD_REGION>"
    encrypt = true
  }
}

required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = ">= 5.61.0"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      ClusterName   = "<CLUSTER_NAME>"
      ProvisionedBy = "kubefirst"
    }
  }
}

module "eks" {
  source = "./eks"
}

resource "aws_iam_role_policy_attachment" "vcluster_external_dns" {
  role       = module.eks.node_iam_role_name
  policy_arn = module.eks.external_dns_policy_arn
}

module "kms" {
  source = "./kms"
}

module "dynamodb" {
  source = "./dynamodb"
}

module "ecr_metaphor" {
  source = "./ecr"

  repository_name = "metaphor"
  use_ecr         = var.use_ecr
}

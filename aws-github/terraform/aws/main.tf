terraform {
  backend "s3" {
    bucket  = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key     = "terraform/aws/tfstate.tf"
    region  = "<AWS_DEFAULT_REGION>"
    encrypt = true
  }
}


provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      ClusterName = "<CLUSTER_NAME>"
    }
  }
}
module "eks" {
  source = "./eks"

  aws_account_id = var.aws_account_id
  cluster_name   = "<CLUSTER_NAME>"
  lifecycle_nodes = var.lifecycle_nodes
}

module "dynamodb" {
  source = "./dynamodb"
}

module "kms" {
  source = "./kms"
}

module "s3" {
  source = "./s3"
}

output "vault_unseal_kms_key" {
  value = module.kms.vault_unseal_kms_key
}

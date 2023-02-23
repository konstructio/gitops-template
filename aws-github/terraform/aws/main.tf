terraform {
  backend "s3" {
    bucket  = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key     = "terraform/base/tfstate.tf"
    region  = "<CLOUD_REGION>"
    encrypt = true
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

  aws_account_id  = var.aws_account_id
  cluster_name    = "<CLUSTER_NAME>"
  lifecycle_nodes = "<AWS_LIFECYCLE_NODES>"
  ami_type        = var.ami_type
  instance_type   = var.instance_type
}

module "kms" {
  source = "./kms"
}

module "dynamodb" {
  source = "./dynamodb"
}

output "vault_unseal_kms_key" {
  // todo https://github.com/terraform-aws-modules/terraform-aws-iam/tree/v4.0.0/examples/iam-assumable-role-with-oidcoutput "vault_unseal_kms_key" {
  value = module.kms.vault_unseal_kms_key
}

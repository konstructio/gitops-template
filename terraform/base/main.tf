terraform {
  backend "s3" {
    bucket  = "<TF_STATE_BUCKET>"
    key     = "terraform/base/tfstate.tf"
    region  = "<AWS_DEFAULT_REGION>"
    encrypt = true
  }
}


provider "aws" {

  region = var.aws_region
}
module "eks" {
  source = "./eks"

  aws_account_id = var.aws_account_id
  cluster_name   = "kubefirst"
}

module "kms" {
  aws_account_id = var.aws_account_id
  source = "./kms"
}

module "dynamodb" {
  source = "./dynamodb"
}

# TODO: decide the long term plan for these
# module "s3" {
#   source = "./s3"
# }

# TODO: think these can be destroyed
# module "security_groups" {
#   source = "./security-groups"

#   kubefirst_vpc_id = module.eks.kubefirst_vpc_id
# }

output "vault_unseal_kms_key" {
  value = module.kms.vault_unseal_kms_key
}

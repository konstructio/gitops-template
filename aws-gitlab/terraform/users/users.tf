terraform {
  backend "s3" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key    = "terraform/users/terraform.tfstate"

    region  = "<CLOUD_REGION>"
    encrypt = true
  }
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "15.8.0"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}

data "gitlab_group" "admins" {
  full_path = "<GITLAB_OWNER>/admins"
}

data "gitlab_group" "developers" {
  full_path = "<GITLAB_OWNER>/developers"
}


data "vault_auth_backend" "userpass" {
  path = "userpass"
}

data "vault_identity_group" "admins" {
  group_name = "admins"
}

variable "initial_password" {
  type    = string
  default = ""
}

data "vault_identity_group" "developers" {
  group_name = "developers"
}

module "admins" {
  source = "./admins"

  initial_password = var.initial_password # ignore or remove - this is only used to bootstrap the initial kbot password
}

module "developers" {
  source = "./developers"
}

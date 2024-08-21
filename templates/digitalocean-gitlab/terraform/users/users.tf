terraform {
  backend "s3" {
    endpoint = "nyc3.digitaloceanspaces.com"
    key      = "terraform/users/terraform.tfstate"
    bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    // Don't change this.
    region = "us-east-1"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
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

resource "vault_identity_group_member_entity_ids" "admins_membership" {
  member_entity_ids = module.admins.vault_identity_entity_ids

  group_id = data.vault_identity_group.admins.group_id
}

# # after you add your first developer to the platform be sure to 
# # uncomment everything below this comment to initialize the 
# # developers module

# data "vault_identity_group" "developers" {
#   group_name = "developers"
# }

# module "developers" {
#   source = "./developers"
# }

# resource "vault_identity_group_member_entity_ids" "developers_membership" {
#   member_entity_ids = module.developers.vault_identity_entity_ids
#   group_id = data.vault_identity_group.developers.group_id
# }

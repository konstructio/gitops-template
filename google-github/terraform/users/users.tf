terraform {
  backend "gcs" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    prefix = "terraform/users/terraform.tfstate"
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.17.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}

data "github_team" "admins" {
  slug = "<ADMIN_TEAM>"
}

data "github_team" "developers" {
  slug = "<DEVELOPER-TEAM>"
}

data "vault_auth_backend" "userpass" {
  path = "userpass"
}

data "vault_identity_group" "admins" {
  group_name = "<ADMIN_TEAM>"
}

variable "initial_password" {
  type    = string
  default = ""
}

module "admins" {
  source = "./admins"

  initial_password = var.initial_password
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

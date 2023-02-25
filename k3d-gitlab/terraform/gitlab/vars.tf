variable "kubefirst_bot_ssh_public_key" {
  type    = string
  default = ""
}

variable "kubefirst_bot_user_email" {
  type    = string
  default = ""
}

variable "owner_group_id" {
  description = "gitlab owner group id"
  type        = string
}

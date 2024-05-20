variable "list_servers_private_ips" {
  description = "List of k3s private addresses for servers like 192.168.1.20"
  type        = list(string)
}

variable "list_servers_public_ips" {
  description = "List of k3s public_ip addresses for servers like 91.10.10.200, eg: used on VM with public ip"
  type        = list(string)
}

variable "list_agents_ips" {
  description = "List of IP addresses for agents"
  type        = list(string)
  default     = []
}

variable "ssh_user" {
  description = "SSH user to use for remote connection on K3S nodes"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key to use for remote connection on K3S nodes"
  type        = string
}

variable "servers_args" {
  description = "Extra configuration to pass to K3S"
  type        = list(string)
}

# output "ipv4_address" {
#   # value = proxmox_virtual_environment_vm.this[0].ipv4_addresses[-1]
#   value = {
#     for vm in proxmox_virtual_environment_vm.this :
#     vm.name => flatten(vm.ipv4_addresses)[1]
#   }
# }

# locals {
#   ipv4 = [for v in proxmox_virtual_environment_vm.this : v.ipv4_addresses]
# }

# resource "local_file" "this" {
#   filename = "ipv4_addresses"
#   content  = "ip: ${join(", ", local.ipv4)}"
# }

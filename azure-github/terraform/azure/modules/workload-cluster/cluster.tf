resource "azurerm_log_analytics_workspace" "kubefirst" {
  location            = azurerm_resource_group.kubefirst.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.kubefirst.name
  retention_in_days   = 30
  sku                 = "PerGB2018"

  tags = local.tags
}

resource "azurerm_log_analytics_solution" "kubefirst" {
  location              = azurerm_resource_group.kubefirst.location
  resource_group_name   = azurerm_resource_group.kubefirst.name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.kubefirst.name
  workspace_resource_id = azurerm_log_analytics_workspace.kubefirst.id

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }

  tags = local.tags
}

resource "azurerm_kubernetes_cluster" "kubefirst" {
  name                = var.cluster_name
  location            = azurerm_resource_group.kubefirst.location
  resource_group_name = azurerm_resource_group.kubefirst.name
  dns_prefix          = var.cluster_name

  kubernetes_version      = data.azurerm_kubernetes_service_versions.current.latest_version
  node_os_upgrade_channel = "NodeImage"

  default_node_pool {
    name           = "kubefirst"
    node_count     = var.node_count
    vm_size        = var.node_type
    vnet_subnet_id = azurerm_subnet.kubefirst.id
  }

  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [0, 1, 2, 3]
    }
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    day_of_week = "Sunday"
    duration    = 4
    start_time  = "00:00"
    utc_offset  = "+00:00"
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.kubefirst.id
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].upgrade_settings
    ]
  }
}

// Grant permissions for the cluster to manage DNS
// zone records so external-dns can do it's thing
//
// @link https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md
data "azurerm_dns_zone" "external_dns" {
  count = local.use_dns_zone ? 1 : 0

  name                = local.dns_zone
  resource_group_name = local.dns_zone_rg
}

resource "azurerm_role_assignment" "external_dns" {
  count = local.use_dns_zone ? 1 : 0

  scope                = data.azurerm_dns_zone.external_dns[count.index].id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_kubernetes_cluster.kubefirst.kubelet_identity[0].object_id
}

resource "kubernetes_namespace_v1" "external_dns" {
  count = local.use_dns_zone ? 1 : 0

  metadata {
    name = "external-dns"
  }
}

# This must be created by Terraform as the userAssignedIdentityID is a generated value
resource "kubernetes_secret_v1" "external_dns" {
  count = local.use_dns_zone ? 1 : 0

  metadata {
    name      = "external-dns-secrets" # Used by the external-secrets component too
    namespace = kubernetes_namespace_v1.external_dns[count.index].metadata.0.name
  }
  data = {
    "azure.json" = jsonencode({
      tenantId                    = data.azurerm_client_config.current.tenant_id
      subscriptionId              = data.azurerm_client_config.current.subscription_id
      resourceGroup               = local.dns_zone_rg
      useManagedIdentityExtension = true
      userAssignedIdentityID      = azurerm_kubernetes_cluster.kubefirst.kubelet_identity[0].client_id
    })
  }
  type = "Opaque"
}

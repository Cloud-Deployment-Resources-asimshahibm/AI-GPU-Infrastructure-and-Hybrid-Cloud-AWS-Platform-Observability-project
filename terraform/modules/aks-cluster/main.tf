resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.name
  kubernetes_version        = var.kubernetes_version
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  private_cluster_enabled   = true

  default_node_pool {
    name                 = "system"
    vm_size              = "Standard_D4s_v5"
    auto_scaling_enabled = true
    min_count            = 3
    max_count            = 6
    zones                = ["1", "2", "3"]
    vnet_subnet_id       = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "cilium"
    network_data_plane = "cilium"
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "observability" {
  name                  = "obs"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_E8s_v5"
  auto_scaling_enabled  = true
  min_count             = 3
  max_count             = 9
  zones                 = ["1", "2", "3"]
  vnet_subnet_id        = var.subnet_id
  node_labels           = { dedicated = "observability" }
  node_taints           = ["dedicated=observability:NoSchedule"]
}

resource "azurerm_kubernetes_cluster_node_pool" "gpu" {
  name                  = "gpu"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.gpu_vm_size
  auto_scaling_enabled  = true
  min_count             = 0
  max_count             = var.gpu_max_count
  vnet_subnet_id        = var.subnet_id
  node_labels           = { workload = "ai" }
  node_taints           = ["nvidia.com/gpu=true:NoSchedule"]
}

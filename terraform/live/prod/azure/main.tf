resource "azurerm_resource_group" "obs" {
  name     = "${var.prefix}-observability-prod"
  location = var.location
}

resource "azurerm_virtual_network" "obs" {
  name                = "${var.prefix}-obs-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.obs.name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks"
  resource_group_name  = azurerm_resource_group.obs.name
  virtual_network_name = azurerm_virtual_network.obs.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 4, 0)]
}

module "aks" {
  source              = "../../../modules/aks-cluster"
  name                = "${var.prefix}-aks-prod"
  location            = var.location
  resource_group_name = azurerm_resource_group.obs.name
  subnet_id           = azurerm_subnet.aks.id
}

module "storage" {
  source              = "../../../modules/obs-storage-azure"
  prefix              = var.prefix
  env                 = "prod"
  location            = var.location
  resource_group_name = azurerm_resource_group.obs.name
  oidc_issuer_url     = module.aks.oidc_issuer_url
  service_accounts = {
    prometheus = "monitoring:kube-prometheus-stack-prometheus"
    azure-exporter = "observability:azure-metrics-exporter"
  }
}

output "identity_client_ids" {
  value = module.storage.identity_client_ids
}

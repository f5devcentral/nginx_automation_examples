resource "azurerm_virtual_network" "vnet_vms" {
  name                = "${var.project_prefix}-vnet-vms"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "subnet_vms" {
  name                 = "${var.project_prefix}-subnet-vms"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet_vms.name
  address_prefixes     = [var.subnet_prefix_vms]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.project_prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_virtual_network" "vnet_nginxaas" {
  name                = "${var.project_prefix}-vnet-nginxaas"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "subnet_nginxaas" {
  name                 = "${var.project_prefix}-subnet-nginxaas"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet_nginxaas.name
  address_prefixes     = [var.subnet_prefix_nginxaas]

  delegation {
    name = "nginx_delegation"
    service_delegation {
      name = "NGINX.NGINXPLUS/nginxDeployments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_virtual_network_peering" "vms_to_nginxaas" {
  name                          = "${var.project_prefix}-vms-to-nginxaas"
  resource_group_name           = azurerm_resource_group.main.name
  virtual_network_name          = azurerm_virtual_network.vnet_vms.name
  remote_virtual_network_id     = azurerm_virtual_network.vnet_nginxaas.id
  allow_forwarded_traffic       = true
  allow_virtual_network_access  = true
}

resource "azurerm_virtual_network_peering" "nginxaas_to_vms" {
  name                          = "${var.project_prefix}-nginxaas-to-vms"
  resource_group_name           = azurerm_resource_group.main.name
  virtual_network_name          = azurerm_virtual_network.vnet_nginxaas.name
  remote_virtual_network_id     = azurerm_virtual_network.vnet_vms.id
  allow_forwarded_traffic       = true
  allow_virtual_network_access  = true
}

### Inbound Rules for Admin IP ###

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.admin_ip}/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "allow-admin-ip-http" {
  name                        = "allow-admin-ip-http"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*" 
  destination_port_range      = "80"
  source_address_prefix       = "${var.admin_ip}/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "allow-admin-ip-https" {
  name                        = "allow-admin-ip-https"
  priority                    = 111
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "${var.admin_ip}/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "allow_nginxaas_http" {
  name                        = "allow-nginxaas-http"
  priority                    = 115
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = azurerm_public_ip.main.ip_address
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "allow_nginxaas_https" {
  name                        = "allow-nginxaas-https"
  priority                    = 116
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = azurerm_public_ip.main.ip_address
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}  

############################ Security Groups Association ############################

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_nginxaas" {
  subnet_id                 = azurerm_subnet.subnet_nginxaas.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_vm" {
  subnet_id                 = azurerm_subnet.subnet_vms.id
  network_security_group_id = azurerm_network_security_group.main.id
}

terraform {
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

#Creacion del grupo de recursos
resource "azurerm_resource_group" "rg" {
  #Puede cambiar el nombre del grupo de recursos
  name     = "myResourceGroup"
  location = var.location
}
# Virtual Machine Resources
  ## Red de la maquina
resource "azurerm_virtual_network" "rg" {
  name                = "rg-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

  ## Subred de la maquina
resource "azurerm_subnet" "rg" {
  name                 = "rg-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.rg.name
  address_prefixes     = ["10.0.4.0/24"]
}

  ## Interfaz de red
resource "azurerm_network_interface" "rg" {
  name                = "rg-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "rg-ip"
    subnet_id                     = azurerm_subnet.rg.id
    private_ip_address_allocation = "Dynamic"
  }
}

  ## IP publica de la maquina
resource "azurerm_public_ip" "rg" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku = "Basic"
  sku_tier = "Regional"
  allocation_method   = "Static"
}

  # Tamaño y demas caracteristicas de la maquina
resource "azurerm_windows_virtual_machine" "rg" {
  name                = "myTerraF-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ##Tamaño
  size                = "Standard_DS1_v2"
  ##Nombre de administador
  admin_username      = "adminuser"
  ##Contraseña de administador
  admin_password      = "P@ssw0rd1234!"

  network_interface_ids = [
    azurerm_network_interface.rg.id,
  ]
  #Disco
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  ##Imagen(Version)
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }

  patch_mode = "AutomaticByPlatform"
}
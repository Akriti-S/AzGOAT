## <https://www.terraform.io/docs/providers/azurerm/index.html>
provider "azurerm" {
  version = "=2.83.0"
  features {}
}

## <https://www.terraform.io/docs/providers/azurerm/r/resource_group.html> create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "Azgoat"
  location = "eastus"
   tags = {
        environment = "Azgoat"
    }
}


## <https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html> create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "AzgoatvNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

## <https://www.terraform.io/docs/providers/azurerm/r/subnet.html> create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "azgoatinternal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.2.0/24"
}
# Add a Public IP address
resource "azurerm_public_ip" "vmip" {
    count                  = 2
    name                   = "vm-ip-${count.index}"
    resource_group_name    =  azurerm_resource_group.rg.name
    allocation_method      = "Static"
    location               = azurerm_resource_group.rg.location
}
##create nsgs
# Create Network Security Group and rule
resource "azurerm_network_security_group" "azuregoatmnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "azgoat Demo"
    }
}

## <https://www.terraform.io/docs/providers/azurerm/r/network_interface.html>
resource "azurerm_network_interface" "example" {
  count		      =2
  name                = "azgoat-nic${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.vmip.*.id, count.index)
  }
}

## Connect the security group to the subnet
resource "azurerm_subnet_network_security_group_association" "example" {
    subnet_id                     = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.azuregoatmnsg.id
}

##create managed disk
 resource "azurerm_managed_disk" "test" {
   count                = 2
   name                 = "datadisk_existing_${count.index}"
   location             = azurerm_resource_group.rg.location
   resource_group_name  = azurerm_resource_group.rg.name
   storage_account_type = "Standard_LRS"
   create_option        = "Empty"
   disk_size_gb         = "1023"
 }
## <https://www.terraform.io/docs/providers/azurerm/r/windows_virtual_machine.html>
resource "azurerm_linux_virtual_machine" "example" {
  count		      =2	 
  name                = "AzgoatVM1${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  disable_password_authentication = false
  admin_username      = "azureuser"
  admin_password      = "P@$$w0rd1234!"
  computer_name  = "AzgoatVM1"
  ##availability_set_id = azurerm_availability_set.DemoAset.id
  network_interface_ids = [element(azurerm_network_interface.example.*.id, count.index)]  

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
  }
}
 
 ## creation of storage account public
resource "azurerm_storage_account" "storage" {
 
  name                = "sachall1"
  resource_group_name = azurerm_resource_group.rg.name

  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = "true"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  }

  tags = {
    environment = "Azgoat"
  }
}
resource "azurerm_storage_container" "container" {
  
  name                  = "content"
  storage_account_name  = azurerm_storage_account.storage.name
  
}

resource "azurerm_storage_blob" "blob" {
  name                   = "content.zip"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "content.zip"
}


 ## creation of storage account private
resource "azurerm_storage_account" "storage_pr" {
 
  name                = "sachall2"
  resource_group_name = azurerm_resource_group.rg.name

  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  }

  tags = {
    environment = "Azgoat"
  }
}
resource "azurerm_storage_container" "container" {
  
  name                  = "content"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob" {
  name                   = "flag.zip"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "flag.zip"
}
  
##create functions
resource "azurerm_storage_account" "azure_storage" {
  name                     = "functionsappsa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "azure_app_svc" {
  name                = "azure-functions-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "azure_function_app" {
  name                       = "test-azure-functions"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.azure_app_svc.id
  storage_account_name       = azurerm_storage_account.azure_storage.name
  storage_account_access_key = azurerm_storage_account.azure_storage.primary_access_key
}
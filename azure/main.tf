terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

#Create azure resource group
resource "azurerm_resource_group" "apache_terraform_rg" {
  name     = var.resource_group_name
  location = var.location

  lifecycle {
    prevent_destroy = false
  }
}

#Create virtual network for the VM
resource "azurerm_virtual_network" "apache_terraform_vnet" {
  name                = var.virtual_network_name
  location            = var.location
  address_space       = var.address_space
  resource_group_name = azurerm_resource_group.apache_terraform_rg.name
}

#Create subnet to the virtual network
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}_subnet"
  virtual_network_name = azurerm_virtual_network.apache_terraform_vnet.name
  resource_group_name  = azurerm_resource_group.apache_terraform_rg.name
  address_prefixes     = var.subnet_prefix
}

#Create public ip
resource "azurerm_public_ip" "apache_terraform_pip" {
  name                = "${var.prefix}-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.apache_terraform_rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = var.hostname
}

#Create Network security group
resource "azurerm_network_security_group" "apache_terraform_sg" {
  name                = "${var.prefix}-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.apache_terraform_rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Create Network interface
resource "azurerm_network_interface" "apache_terraform_nic" {
  name                = "${var.prefix}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.apache_terraform_rg.name

  ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.apache_terraform_pip.id
  }
}

#Create VM
resource "azurerm_virtual_machine" "apache_terraform_site" {
  name                = "${var.hostname}-apache"
  location            = var.location
  resource_group_name = azurerm_resource_group.apache_terraform_rg.name
  vm_size             = var.vm_size

  network_interface_ids         = ["${azurerm_network_interface.apache_terraform_nic.id}"]
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  storage_os_disk {
    name              = "${var.hostname}_osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.hostname}-apahce"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file("C:/Users/alanr/.ssh/id_rsa.pub")
    }
  }

  # This is to ensure SSH comes up before we run the local exec.
  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config",

      "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config",

      "sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config",

      "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config",

      "wget 'https://raw.githubusercontent.com/AlanRicardoS/scripts/main/lamp.sh'",
      "sudo sh lamp.sh",
    ]
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.apache_terraform_pip.fqdn
      user        = var.admin_username
      private_key = file("C:/Users/alanr/.ssh/id_rsa")
    }
  }
}

# ------------------------------------------------------------------
#Create azure resource group
resource "azurerm_resource_group" "jenkins_terraform_rg" {
  name     = "jenkin-terraform"
  location = var.location

  lifecycle {
    prevent_destroy = false
  }
}

#Create virtual network for the VM
resource "azurerm_virtual_network" "jenkins_terraform_vnet" {
  name                = "jenkins-terraform-vnet"
  location            = var.location
  address_space       = var.address_space
  resource_group_name = azurerm_resource_group.jenkins_terraform_rg.name
}

#Create subnet to the virtual network
resource "azurerm_subnet" "subnet-jenkins" {
  name                 = "jenkins-terraform-subnet"
  virtual_network_name = azurerm_virtual_network.jenkins_terraform_vnet.name
  resource_group_name  = azurerm_resource_group.jenkins_terraform_rg.name
  address_prefixes     = var.subnet_prefix
}

#Create public ip
resource "azurerm_public_ip" "jenkins_terraform_pip" {
  name                = "jenkins-terraform-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.jenkins_terraform_rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "jenkins-terraform-iaac-trabalho-01"
}

#Create Network security group
resource "azurerm_network_security_group" "jenkins_terraform_sg" {
  name                = "jenkins-terraform-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.jenkins_terraform_rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Create Network interface
resource "azurerm_network_interface" "jenkins_terraform_nic" {
  name                = "jenkins-terraform-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.jenkins_terraform_rg.name

  ip_configuration {
    name                          = "jenkins-terraform-ipconfig"
    subnet_id                     = azurerm_subnet.subnet-jenkins.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins_terraform_pip.id
  }
}


# #Create VM
resource "azurerm_virtual_machine" "jenkins_terraform_site" {
  name                = "jenkins-terraform"
  location            = var.location
  resource_group_name = azurerm_resource_group.jenkins_terraform_rg.name
  vm_size             = var.vm_size

  network_interface_ids         = ["${azurerm_network_interface.jenkins_terraform_nic.id}"]
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  storage_os_disk {
    name              = "jenkinsterraform_osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "jenkins-terraform"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file("C:/Users/alanr/.ssh/id_rsa.pub")
    }
  }

  # This is to ensure SSH comes up before we run the local exec.
  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config",

      "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config",

      "sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config",

      "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config",

      "wget 'https://raw.githubusercontent.com/AlanRicardoS/scripts/main/script-jenkins.sh'",
      "sh script-jenkins.sh",
    ]
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.jenkins_terraform_pip.fqdn
      user        = var.admin_username
      private_key = file("C:/Users/alanr/.ssh/id_rsa")
    }
  }
}

# _______________________ BLOB STORAGE _______________________
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  name                     = "examplestoracc"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "example" {
  name                   = "my-awesome-content.zip"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
  source                 = "some-local-file.zip"
}
##############################################################################
# Variables File
#
# Here is where we store the default values for all the variables used in our
# Terraform code.

variable "prefix" {
  description = "This prefix will be included in the name of some resources."
  default     = "apachetf"
}

variable "resource_group_name" {
  description = "The name of your Azure Resource Group."
  default     = "Apache-Terraform"
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "West Europe"
}

variable "virtual_network_name" {
  description = "The name for your virtual network."
  default     = "vnet"
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.2.0/24"]
}

variable "hostname" {
  description = "Virtual machine hostname. Used for local hostname, DNS, and storage-related names."
  default     = "iaac-trabalho-01"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_DS1_v2"
}

variable "image_publisher" {
  description = "Name of the publisher of the image (az vm image list)"
  default     = "Canonical"
}

variable "image_offer" {
  description = "Name of the offer (az vm image list)"
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "Image SKU to apply (az vm image list)"
  default     = "18.04-LTS"
}

variable "image_version" {
  description = "Version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "Administrator user name"
  default     = "adminuser"
}

variable "admin_password" {
  description = "Administrator password"
  default     = "AdminPa55w.rd123!"
}
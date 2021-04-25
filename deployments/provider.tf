

terraform {
  backend "azurerm" {
    resource_group_name  = "resource-group-demo-ops"
    storage_account_name = "storageops195906"
    container_name       = "az-terraform-state-195906"
    key                  = "terraform.tfstate"
  }
}



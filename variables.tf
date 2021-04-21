variable "email" {
  description = "Email to be used with ClusterIssuer for CertManager"
}
variable "az_client_id" {
  description = "Azure Kubernetes Service Cluster service principal"
}
variable "az_client_secret" {
  description = "Azure Kubernetes Service Cluster password"
}
variable "az_location" {
  description = "Azure resources location"
  default = "Germany West Central"
}
variable "az_resource_group_name_devs" {
  description = "Azure resources group for devs"
  default = "resource-group-demo-devs"
}
variable "az_resource_group_name_ops" {
  description = "Azure resources group for ops"
  default = "resource-group-demo-ops"
}
variable "az_storage_account_ops" {
}
variable "az_storage_tfstate" {
}
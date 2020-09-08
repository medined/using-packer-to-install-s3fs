variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}
variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default     = "10.1.0.0/24"
}
variable "environment_tag" {
  default     = "dev"
}
variable "key_private_file" {
  type        = string
}
variable "region"{
  description = "The region Terraform deploys your instance"
}
variable "ssh_user" {
  description = "account used for ssh"
}

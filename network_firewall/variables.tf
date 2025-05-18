variable "aws_regions" {
  description = "List of AWS regions for deploying resources"
  type        = list(string)
  default     = ["us-west-2", "us-east-1"]
}

variable "inspection_vpc_id" {
  description = "ID of the inspection VPC"
  type        = string
}

variable "firewall_subnet_ids" {
  description = "IDs of the Firewall subnets in the inspection VPC"
  type        = list(string)
}

variable "firewall_name" {
  description = "Name of the Network Firewall"
  type        = string
  default     = "central-network-firewall"
}

variable "delegated_account_id" {
  description = "AWS Account ID where resources will be created"
  type        = string
}
variable "aws_regions" {
  description = "List of AWS regions for deploying resources"
  type        = list(string)
  default     = ["us-west-2", "us-east-1"]
}

variable "tfg_test_account1_id" {
  description = "AWS Account ID for the test account where resources will be created"
  type        = string
}

variable "delegated_account_id" {
  description = "AWS Account ID for delegated account where IPAM is created"
  type        = string
}

variable "subnet_pool_id" {
  description = "ID of the subnet pool for VPC CIDR allocation"
  type        = string
}

variable "subnet_prefix" {
  description = "Prefix size for the VPC subnets"
  type        = number
  default     = 3  # For dividing a /24 VPC into /27 subnets
}

variable "vpc_cidr_netmask" {
  description = "Netmask for the VPC CIDR allocation"
  type        = number
  default     = 24
}

variable "firewall_endpoint_ids" {
  description = "List of Network Firewall endpoint IDs for each AZ"
  type        = list(string)
  default     = []
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
  default     = ""
}

variable "workload_cidr_blocks" {
  description = "List of CIDR blocks for workload VPCs"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.31.0.0/16"]
}

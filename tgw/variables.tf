variable "aws_regions" {
  description = "List of AWS regions for deploying resources"
  type        = list(string)
  default     = ["us-west-2", "us-east-1"]
}

variable "delegated_account_id" {
  description = "AWS Account ID where resources will be created"
  type        = string
}

variable "inspection_vpc_id" {
  description = "ID of the inspection VPC"
  type        = string
}

variable "inspection_subnet_ids" {
  description = "IDs of the TGW subnets in the inspection VPC"
  type        = list(string)
}

variable "amazon_side_asn" {
  description = "Private ASN for the transit gateway"
  type        = number
  default     = 64512
}

variable "inspection_vpc_cidr" {
  description = "CIDR block of the inspection VPC"
  type        = string
}

variable "tgw_route_table_ids" {
  description = "Map of inspection VPC TGW route table IDs"
  type = object({
    a = string
    b = string
  })
}


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

########################################################
variable "spoke_vpc_attachments" {
  description = "Map of spoke VPC names to their CIDR blocks and TGW attachment IDs"
  type = map(object({
    cidr_block    = string
    attachment_id = string
  }))
  default = {}
}

########################################################

variable "management_account_id" {
  description = "AWS Management Account ID to share TGW with"
  type        = string
  default     = ""
}

variable "tfg_test_account1_id" {
  description = "AWS Account ID for tfg-test-account1 to share TGW with"
  type        = string
  default     = ""
}

variable "spoke_account_ids" {
  description = "List of additional AWS account IDs to share TGW with"
  type        = list(string)
  default     = []
}

variable "organization_id" {
  description = "AWS Organization ID (kept for reference but not used for sharing)"
  type        = string
  default     = ""
}

########################################################

#Blackhole Variables

variable "prod_cidr_block" {
  description = "CIDR block for production environment"
  type        = string
  default     = "10.0.0.0/17"  # Based on your current configuration
}

variable "nonprod_cidr_block" {
  description = "CIDR block for non-production environment"
  type        = string
  default     = "10.0.128.0/17"  # Based on your current configuration
}
########################################################
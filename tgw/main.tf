# Data source to get current AWS caller identity
data "aws_caller_identity" "current" {
  provider = aws.delegated_account_us-west-2
}

# Create Transit Gateway
resource "aws_ec2_transit_gateway" "central_tgw" {
  provider                        = aws.delegated_account_us-west-2
  description                     = "Central Transit Gateway for VPC inspection"
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  
  tags = {
    Name        = "central-tgw"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Create Transit Gateway Route Tables
resource "aws_ec2_transit_gateway_route_table" "inspection_rt" {
  provider           = aws.delegated_account_us-west-2
  transit_gateway_id = aws_ec2_transit_gateway.central_tgw.id
  
  tags = {
    Name        = "central-tgw-inspection-rt"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

resource "aws_ec2_transit_gateway_route_table" "main_rt" {
  provider           = aws.delegated_account_us-west-2
  transit_gateway_id = aws_ec2_transit_gateway.central_tgw.id
  
  tags = {
    Name        = "central-tgw-main-rt"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}



#create Transit gateway route tables for nonprod_vpc
resource "aws_ec2_transit_gateway_route_table" "nonprod_tgw_rt" {
  provider           = aws.delegated_account_us-west-2
  transit_gateway_id = aws_ec2_transit_gateway.central_tgw.id

  tags = {
    Name        = "nonprod-transit-gateway-route-table"
    Environment = "nonprod"
    ManagedBy   = "terraform"
  }
}

# Add default route from nonprod route table to inspection VPC
resource "aws_ec2_transit_gateway_route" "nonprod_default_route" {
  provider                       = aws.delegated_account_us-west-2
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.nonprod_tgw_rt.id
}


# Create Transit gateway route tables for prod_vpc
resource "aws_ec2_transit_gateway_route_table" "prod_tgw_rt" {
  provider           = aws.delegated_account_us-west-2
  transit_gateway_id = aws_ec2_transit_gateway.central_tgw.id

  tags = {
    Name        = "prod-transit-gateway-route-table"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# Add default route from prod route table to inspection VPC
resource "aws_ec2_transit_gateway_route" "prod_default_route" {
  provider                       = aws.delegated_account_us-west-2
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_tgw_rt.id
}

############################################

# Add blackhole route from prod to nonprod CIDRs
resource "aws_ec2_transit_gateway_route" "prod_to_nonprod_blackhole" {
  provider                       = aws.delegated_account_us-west-2
  destination_cidr_block         = "10.0.128.0/17" 
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_tgw_rt.id
}

# Add blackhole route from nonprod to prod CIDRs
resource "aws_ec2_transit_gateway_route" "nonprod_to_prod_blackhole" {
  provider                       = aws.delegated_account_us-west-2
  destination_cidr_block         = "10.0.0.0/17"  
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.nonprod_tgw_rt.id
}

# Add a specific route for inspection VPC in both prod and nonprod route tables
# This ensures traffic to the inspection VPC is never blackholed
resource "aws_ec2_transit_gateway_route" "prod_to_inspection_vpc" {
  provider                       = aws.delegated_account_us-west-2
  destination_cidr_block         = var.inspection_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route" "nonprod_to_inspection_vpc" {
  provider                       = aws.delegated_account_us-west-2
  destination_cidr_block         = var.inspection_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.nonprod_tgw_rt.id
}

############################################


# Attach Inspection VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "inspection_attachment" {
  provider           = aws.delegated_account_us-west-2
  subnet_ids         = var.inspection_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.central_tgw.id
  vpc_id             = var.inspection_vpc_id
  
  appliance_mode_support                          = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  tags = {
    Name        = "central-tgw-inspection-attachment"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
  
  lifecycle {
    precondition {
      condition     = var.inspection_vpc_id != "vpc-placeholder" && length(var.inspection_subnet_ids) > 0 && var.inspection_subnet_ids[0] != "subnet-placeholder"
      error_message = "Invalid inspection VPC ID or subnet IDs provided."
    }
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "inspection_association" {
  provider           = aws.delegated_account_us-west-2
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt.id
}

resource "aws_ec2_transit_gateway_route" "main_default_route" {
  provider           = aws.delegated_account_us-west-2
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main_rt.id
}

resource "aws_ec2_transit_gateway_route" "inspection_default_route" {
  provider           = aws.delegated_account_us-west-2
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt.id
}

###########################################

# Create Global Network
resource "aws_networkmanager_global_network" "main" {
  provider    = aws.delegated_account_us-west-2
  description = "Global network for hub-and-spoke architecture"
  
  tags = {
    Name        = "hub-spoke-global-network"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Register Transit Gateway with Global Network
resource "aws_networkmanager_transit_gateway_registration" "main" {
  provider            = aws.delegated_account_us-west-2
  global_network_id   = aws_networkmanager_global_network.main.id
  transit_gateway_arn = aws_ec2_transit_gateway.central_tgw.arn
}



#############################################################################


# Share Transit Gateway with specific accounts
resource "aws_ram_resource_share" "tgw_share" {
  provider                  = aws.delegated_account_us-west-2
  name                      = "central-tgw-share"
  allow_external_principals = true
  
  tags = {
    Name        = "central-tgw-share"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Associate TGW with the resource share
resource "aws_ram_resource_association" "tgw_association" {
  provider           = aws.delegated_account_us-west-2
  resource_arn       = aws_ec2_transit_gateway.central_tgw.arn
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

# Share with management account
resource "aws_ram_principal_association" "tgw_management_account" {
  provider           = aws.delegated_account_us-west-2
  count              = var.management_account_id != "" ? 1 : 0
  principal          = var.management_account_id
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

# Share with test account
resource "aws_ram_principal_association" "tgw_test_account" {
  provider           = aws.delegated_account_us-west-2
  count              = var.tfg_test_account1_id != "" ? 1 : 0
  principal          = var.tfg_test_account1_id
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

# Share with additional spoke accounts (dynamic list)
resource "aws_ram_principal_association" "tgw_spoke_accounts" {
  provider           = aws.delegated_account_us-west-2
  for_each           = toset(var.spoke_account_ids)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}
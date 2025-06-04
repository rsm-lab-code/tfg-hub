
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


#############################################################3

# Add routes to inspection route table for all spoke VPCs
/*
resource "aws_ec2_transit_gateway_route" "inspection_rt_spoke_routes" {
  provider                       = aws.delegated_account_us-west-2
  for_each                      = var.spoke_vpc_attachments

  destination_cidr_block        = each.value.cidr_block
  transit_gateway_attachment_id = each.value.attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt.id
}
*/
# Add routes to main route table for all spoke VPCs
/*
resource "aws_ec2_transit_gateway_route" "main_rt_spoke_routes" {
  provider                       = aws.delegated_account_us-west-2
  for_each                      = var.spoke_vpc_attachments

  destination_cidr_block        = each.value.cidr_block
  transit_gateway_attachment_id = each.value.attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main_rt.id
}
*/

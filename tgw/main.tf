
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
  
  #lifecycle with precondition
  #lifecycle {
   # precondition {
    #  condition     = var.inspection_vpc_id != "vpc-placeholder" && length(var.inspection_subnet_ids) > 0 && var.inspection_subnet_ids[0] != "subnet-placeholder"
     # error_message = "Invalid inspection VPC ID or subnet IDs provided."
    #}
  #}
}
# Associate Inspection attachment with route tables
resource "aws_ec2_transit_gateway_route_table_association" "inspection_association" {
  provider           = aws.delegated_account_us-west-2
    
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt.id

    
  lifecycle {
    precondition {
      condition     = var.inspection_vpc_id != "vpc-placeholder" && length(var.inspection_subnet_ids) > 0 && var.inspection_subnet_ids[0] != "subnet-placeholder"
      error_message = "Invalid inspection VPC ID or subnet IDs provided."
    }
  }
}

# Add default route (0.0.0.0/0) in the TGW Main route table to send traffic to the inspection VPC
resource "aws_ec2_transit_gateway_route" "main_default_route" {
  provider           = aws.delegated_account_us-west-2
    
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main_rt.id

   
  lifecycle {
    precondition {
      condition     = var.inspection_vpc_id != "vpc-placeholder" && length(var.inspection_subnet_ids) > 0 && var.inspection_subnet_ids[0] != "subnet-placeholder"
      error_message = "Invalid inspection VPC ID or subnet IDs provided."
    }
  }
}

# Add default route (0.0.0.0/0) in the TGW Inspection route table to send traffic to the inspection VPC attachment
resource "aws_ec2_transit_gateway_route" "inspection_default_route" {
  provider           = aws.delegated_account_us-west-2
   
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt.id

    lifecycle {
    precondition {
      condition     = var.inspection_vpc_id != "vpc-placeholder" && length(var.inspection_subnet_ids) > 0 && var.inspection_subnet_ids[0] != "subnet-placeholder"
      error_message = "Invalid inspection VPC ID or subnet IDs provided."
    }
  }
}

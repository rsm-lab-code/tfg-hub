# Get IPAM pool allocation for inspection VPC
resource "aws_vpc_ipam_pool_cidr_allocation" "inspection_vpc_cidr" {
  provider    = aws.delegated_account_us-west-2
  ipam_pool_id   = var.subnet_pool_id
  netmask_length = var.vpc_cidr_netmask
  description    = "CIDR allocation for Inspection VPC"
}

# Create Inspection VPC
resource "aws_vpc" "inspection_vpc" {
  provider    = aws.delegated_account_us-west-2
  cidr_block           = aws_vpc_ipam_pool_cidr_allocation.inspection_vpc_cidr.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "inspection-vpc"
    Environment = "shared"
    ManagedBy = "terraform"
  }
}

# Create public subnet in us-west-2a
resource "aws_subnet" "inspection_public_subnet_a" {
  provider    = aws.delegated_account_us-west-2
  vpc_id            = aws_vpc.inspection_vpc.id
  availability_zone = "${var.aws_regions[0]}a"
  cidr_block        = cidrsubnet(aws_vpc.inspection_vpc.cidr_block, var.subnet_prefix, 0)

  tags = {
    Name = "inspection-vpc-public-a"
    Environment = "shared"
    Type = "public"
    ManagedBy = "terraform"
  }
}

# Create public subnet in us-west-2b
resource "aws_subnet" "inspection_public_subnet_b" {
  provider    = aws.delegated_account_us-west-2
  vpc_id            = aws_vpc.inspection_vpc.id
  availability_zone = "${var.aws_regions[0]}b"
  cidr_block        = cidrsubnet(aws_vpc.inspection_vpc.cidr_block, var.subnet_prefix, 1)

  tags = {
    Name = "inspection-vpc-public-b"
    Environment = "shared"
    Type = "public"
    ManagedBy = "terraform"
  }
}

# Create TGW subnet in us-west-2a
resource "aws_subnet" "inspection_tgw_subnet_a" {
  provider    = aws.delegated_account_us-west-2
  vpc_id            = aws_vpc.inspection_vpc.id
  availability_zone = "${var.aws_regions[0]}a"
  cidr_block        = cidrsubnet(aws_vpc.inspection_vpc.cidr_block, var.subnet_prefix, 2)

  tags = {
    Name = "inspection-vpc-tgw-a"
    Environment = "shared"
    Type = "tgw"
    ManagedBy = "terraform"
  }
}

# Create TGW subnet in us-west-2b
resource "aws_subnet" "inspection_tgw_subnet_b" {
  provider    = aws.delegated_account_us-west-2
  vpc_id            = aws_vpc.inspection_vpc.id
  availability_zone = "${var.aws_regions[0]}b"
  cidr_block        = cidrsubnet(aws_vpc.inspection_vpc.cidr_block, var.subnet_prefix, 3)

  tags = {
    Name = "inspection-vpc-tgw-b"
    Environment = "shared"
    Type = "tgw"
    ManagedBy = "terraform"
  }
}

# Create Firewall subnet in us-west-2a
resource "aws_subnet" "inspection_firewall_subnet_a" {
  provider    = aws.delegated_account_us-west-2
  vpc_id            = aws_vpc.inspection_vpc.id
  availability_zone = "${var.aws_regions[0]}a"
  cidr_block        = cidrsubnet(aws_vpc.inspection_vpc.cidr_block, var.subnet_prefix, 4)

  tags = {
    Name = "inspection-vpc-firewall-a"
    Environment = "shared"
    Type = "firewall"
    ManagedBy = "terraform"
  }
}

# Create Firewall subnet in us-west-2b
resource "aws_subnet" "inspection_firewall_subnet_b" {
  provider    = aws.delegated_account_us-west-2
  vpc_id            = aws_vpc.inspection_vpc.id
  availability_zone = "${var.aws_regions[0]}b"
  cidr_block        = cidrsubnet(aws_vpc.inspection_vpc.cidr_block, var.subnet_prefix, 5)

  tags = {
    Name = "inspection-vpc-firewall-b"
    Environment = "shared"
    Type = "firewall"
    ManagedBy = "terraform"
  }
}

# Create Internet Gateway for inspection VPC
resource "aws_internet_gateway" "inspection_igw" {
  provider    = aws.delegated_account_us-west-2
  vpc_id   = aws_vpc.inspection_vpc.id

  tags = {
    Name = "inspection-vpc-igw"
    Environment = "shared"
    ManagedBy = "terraform"
  }
}

# Create NAT Gateway for inspection VPC
resource "aws_eip" "nat_eip_a" {
 provider    = aws.delegated_account_us-west-2
  domain   = "vpc"

  tags = {
    Name = "inspection-vpc-nat-eip-a"
    Environment = "shared"
    ManagedBy = "terraform"
  }
}

resource "aws_eip" "nat_eip_b" {
 provider    = aws.delegated_account_us-west-2
  domain   = "vpc"

  tags = {
    Name = "inspection-vpc-nat-eip-b"
    Environment = "shared"
    ManagedBy = "terraform"
  }
}

resource "aws_nat_gateway" "inspection_nat_gw_a" {
  provider    = aws.delegated_account_us-west-2
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.inspection_public_subnet_a.id

  tags = {
    Name = "inspection-vpc-nat-gw-a"
    Environment = "shared"
    ManagedBy = "terraform"
  }
}

resource "aws_nat_gateway" "inspection_nat_gw_b" {
  provider    = aws.delegated_account_us-west-2
  allocation_id = aws_eip.nat_eip_b.id
  subnet_id     = aws_subnet.inspection_public_subnet_b.id

  tags = {
    Name = "inspection-vpc-nat-gw-b"
    Environment = "shared"
    ManagedBy = "terraform"
  }
}

# Create firewall route tables (a and b zones)
resource "aws_route_table" "inspection_firewall_rt_a" {
  provider    = aws.delegated_account_us-west-2
  vpc_id = aws_vpc.inspection_vpc.id
  tags = {
    Name        = "inspection-firewall-rt-usw2-a"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

resource "aws_route_table" "inspection_firewall_rt_b" {
  provider    = aws.delegated_account_us-west-2
  vpc_id = aws_vpc.inspection_vpc.id
  tags = {
    Name        = "inspection-firewall-rt-usw2-b"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Create public route tables (a and b zones)
resource "aws_route_table" "inspection_public_rt_a" {
  provider    = aws.delegated_account_us-west-2
  vpc_id = aws_vpc.inspection_vpc.id
  tags = {
    Name        = "inspection-public-rt-usw2-a"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

resource "aws_route_table" "inspection_public_rt_b" {
  provider    = aws.delegated_account_us-west-2
  vpc_id = aws_vpc.inspection_vpc.id
  tags = {
    Name        = "inspection-public-rt-usw2-b"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Create transit gateway route tables (a and b zones)
resource "aws_route_table" "inspection_tgw_rt_a" {
  provider    = aws.delegated_account_us-west-2
  vpc_id = aws_vpc.inspection_vpc.id
  tags = {
    Name        = "inspection-tgw-rt-usw2-a"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

resource "aws_route_table" "inspection_tgw_rt_b" {
  provider    = aws.delegated_account_us-west-2
  vpc_id = aws_vpc.inspection_vpc.id
  tags = {
    Name        = "inspection-tgw-rt-usw2-b"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Create public route to internet for zone A
resource "aws_route" "inspection_public_rt_a_to_igw" {
  provider    = aws.delegated_account_us-west-2
  route_table_id         = aws_route_table.inspection_public_rt_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inspection_igw.id
}


# DUMMY CODE (testing)
# Create public route to internet for zone A
resource "aws_route" "inspection_public_rt_a_to_dummy" {
  provider    = aws.delegated_account_us-west-2
  route_table_id         = aws_route_table.inspection_public_rt_a.id
  destination_cidr_block = "8.1.2.3/32"
  gateway_id             = var.firewall_endpoint_ids[0]
}


# Create public route to internet for zone B
resource "aws_route" "inspection_public_rt_b_to_igw" {
  provider    = aws.delegated_account_us-west-2
  route_table_id         = aws_route_table.inspection_public_rt_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inspection_igw.id
}

# Associate TGW subnets with TGW route tables
resource "aws_route_table_association" "inspection_tgw_rta_a" {
  provider    = aws.delegated_account_us-west-2
  subnet_id      = aws_subnet.inspection_tgw_subnet_a.id
  route_table_id = aws_route_table.inspection_tgw_rt_a.id
}

resource "aws_route_table_association" "inspection_tgw_rta_b" {
  provider    = aws.delegated_account_us-west-2
  subnet_id      = aws_subnet.inspection_tgw_subnet_b.id
  route_table_id = aws_route_table.inspection_tgw_rt_b.id
}

# Associate Firewall subnets with Firewall route tables
resource "aws_route_table_association" "inspection_firewall_rta_a" {
  provider    = aws.delegated_account_us-west-2
  subnet_id      = aws_subnet.inspection_firewall_subnet_a.id
  route_table_id = aws_route_table.inspection_firewall_rt_a.id
}

resource "aws_route_table_association" "inspection_firewall_rta_b" {
  provider    = aws.delegated_account_us-west-2
  subnet_id      = aws_subnet.inspection_firewall_subnet_b.id
  route_table_id = aws_route_table.inspection_firewall_rt_b.id
}

# Associate public subnets with public route tables
resource "aws_route_table_association" "inspection_public_rta_a" {
  provider    = aws.delegated_account_us-west-2
  subnet_id      = aws_subnet.inspection_public_subnet_a.id
  route_table_id = aws_route_table.inspection_public_rt_a.id
}

resource "aws_route_table_association" "inspection_public_rta_b" {
  provider    = aws.delegated_account_us-west-2
  subnet_id      = aws_subnet.inspection_public_subnet_b.id
  route_table_id = aws_route_table.inspection_public_rt_b.id
}

# Main association for public route table A
resource "aws_main_route_table_association" "main" {
  provider    = aws.delegated_account_us-west-2
  vpc_id         = aws_vpc.inspection_vpc.id
  route_table_id = aws_route_table.inspection_public_rt_a.id
}

# inspection-tgw-rt-usw2-a points to the us-west-2a firewall endpoint
resource "aws_route" "inspection_tgw_rt_a_to_firewall" {
  provider    = aws.delegated_account_us-west-2
  route_table_id         = aws_route_table.inspection_tgw_rt_a.id
  destination_cidr_block = "0.0.0.0/0"
 # vpc_endpoint_id        = local.effective_endpoints[0]  # us-west-2a endpoint
  vpc_endpoint_id        = var.firewall_endpoint_ids[0]  # us-west-2a endpoint
}

# inspection-tgw-rt-usw2-b points to the us-west-2b firewall endpoint
resource "aws_route" "inspection_tgw_rt_b_to_firewall" {
  provider    = aws.delegated_account_us-west-2
  route_table_id         = aws_route_table.inspection_tgw_rt_b.id
  destination_cidr_block = "0.0.0.0/0"
  #vpc_endpoint_id        = local.effective_endpoints[1]  # us-west-2b endpoint
  vpc_endpoint_id        = var.firewall_endpoint_ids[1]  # us-west-2b endpoint
}

# Create routes for internet access 
locals {
  # Flag to determine whether to use NAT gateways for firewall subnets
  use_nat_gateways = true
}

# Routes for Firewall subnets to Internet Gateway (for internet-bound traffic)
resource "aws_route" "inspection_firewall_rt_a_to_igw" {
  provider    = aws.delegated_account_us-west-2
  count                  = local.use_nat_gateways ? 0 : 1
  route_table_id         = aws_route_table.inspection_firewall_rt_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inspection_igw.id
}

resource "aws_route" "inspection_firewall_rt_b_to_igw" {
  provider    = aws.delegated_account_us-west-2
  count                  = local.use_nat_gateways ? 0 : 1
  route_table_id         = aws_route_table.inspection_firewall_rt_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inspection_igw.id
}

# Routes for Firewall subnets to NAT Gateways (for internet-bound traffic)
resource "aws_route" "inspection_firewall_rt_a_to_nat" {
  provider    = aws.delegated_account_us-west-2
  count                  = local.use_nat_gateways ? 1 : 0
  route_table_id         = aws_route_table.inspection_firewall_rt_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.inspection_nat_gw_a.id
}

resource "aws_route" "inspection_firewall_rt_b_to_nat" {
  provider    = aws.delegated_account_us-west-2
  count                  = local.use_nat_gateways ? 1 : 0
  route_table_id         = aws_route_table.inspection_firewall_rt_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.inspection_nat_gw_b.id
}

#Inspection VPC traffic to transit gateway for all VPC CIDR blocks
resource "aws_route" "inspection_firewall_rt_a_to_tgw" {
  provider               = aws.delegated_account_us-west-2
  route_table_id         = aws_route_table.inspection_firewall_rt_a.id
  destination_cidr_block = "10.0.0.0/16" 
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "inspection_firewall_rt_b_to_tgw" {
  provider               = aws.delegated_account_us-west-2
  route_table_id         = aws_route_table.inspection_firewall_rt_b.id
  destination_cidr_block = "10.0.0.0/16"  
  transit_gateway_id     = var.transit_gateway_id
}

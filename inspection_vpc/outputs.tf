output "vpc_id" {
  description = "ID of the Inspection VPC"
  value       = aws_vpc.inspection_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the Inspection VPC"
  value       = aws_vpc.inspection_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets in the Inspection VPC"
  value       = [aws_subnet.inspection_public_subnet_a.id, aws_subnet.inspection_public_subnet_b.id]
}

output "tgw_subnet_ids" {
  description = "IDs of the TGW subnets in the Inspection VPC"
  value       = [aws_subnet.inspection_tgw_subnet_a.id, aws_subnet.inspection_tgw_subnet_b.id]
}

output "firewall_subnet_ids" {
  description = "IDs of the Firewall subnets in the Inspection VPC"
  value       = [aws_subnet.inspection_firewall_subnet_a.id, aws_subnet.inspection_firewall_subnet_b.id]
}

output "public_route_table_ids" {
  description = "IDs of the public route tables"
  value       = [aws_route_table.inspection_public_rt_a.id, aws_route_table.inspection_public_rt_b.id]
}

output "tgw_route_table_ids" {
  description = "IDs of the TGW route tables"
  value       = [aws_route_table.inspection_tgw_rt_a.id, aws_route_table.inspection_tgw_rt_b.id]
}

output "firewall_route_table_ids" {
  description = "IDs of the firewall route tables"
  value       = [aws_route_table.inspection_firewall_rt_a.id, aws_route_table.inspection_firewall_rt_b.id]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.inspection_igw.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = {
    a = aws_nat_gateway.inspection_nat_gw_a.id
    b = aws_nat_gateway.inspection_nat_gw_b.id
  }
}

output "nat_eips" {
  description = "Elastic IP addresses for the NAT Gateways"
  value       = {
    a = aws_eip.nat_eip_a.public_ip
    b = aws_eip.nat_eip_b.public_ip
  }
}

output "region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_regions[0]
}

output "tgw_route_tables" {
  description = "Map of all TGW subnet route tables"
  value = {
    a = aws_route_table.inspection_tgw_rt_a.id
    b = aws_route_table.inspection_tgw_rt_b.id
  }
}


output "flow_logs_s3_bucket_arn" {
  description = "ARN of the S3 bucket for VPC Flow Logs"
  value       = aws_s3_bucket.vpc_flow_logs.arn
}

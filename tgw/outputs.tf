output "tgw_id" {
  description = "ID of the Central Transit Gateway"
  value       = aws_ec2_transit_gateway.central_tgw.id
}

output "inspection_rt_id" {
  description = "ID of the Inspection Transit Gateway route table"
  value       = aws_ec2_transit_gateway_route_table.inspection_rt.id
}

output "main_rt_id" {
  description = "ID of the Main Transit Gateway route table"
  value       = aws_ec2_transit_gateway_route_table.main_rt.id
}

output "route_table_ids" {
  description = "Map of all Transit Gateway route table IDs"
  value       = {
    inspection = aws_ec2_transit_gateway_route_table.inspection_rt.id
    main       = aws_ec2_transit_gateway_route_table.main_rt.id
    #    dev        = aws_ec2_transit_gateway_route_table.dev_tgw_rt.id
    nonprod    = aws_ec2_transit_gateway_route_table.nonprod_tgw_rt.id
    prod       = aws_ec2_transit_gateway_route_table.prod_tgw_rt.id
  }
}
output "inspection_attachment_id" {
  description = "ID of the Inspection VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
}


output "nonprod_tgw_rt_id" {
  description = "ID of the Non-Prod Transit Gateway route table"
  value       = aws_ec2_transit_gateway_route_table.nonprod_tgw_rt.id
}

output "prod_tgw_rt_id" {
  description = "ID of the Production Transit Gateway route table"
  value       = aws_ec2_transit_gateway_route_table.prod_tgw_rt.id
}

output "tgw_arn" {
  description = "ARN of the Central Transit Gateway"
  value       = aws_ec2_transit_gateway.central_tgw.arn
}

output "tgw_owner_id" {
  description = "Owner ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.central_tgw.owner_id
}


###################################################################

# Network Manager Outputs
output "global_network_id" {
  description = "ID of the Global Network"
  value       = aws_networkmanager_global_network.main.id
}

output "global_network_arn" {
  description = "ARN of the Global Network"
  value       = aws_networkmanager_global_network.main.arn
}

output "transit_gateway_registration_id" {
  description = "ID of the Transit Gateway registration"
  value       = aws_networkmanager_transit_gateway_registration.main.id
}

output "network_manager_console_url" {
  description = "URL to access Network Manager console"
  value       = "https://${var.aws_regions[0]}.console.aws.amazon.com/networkmanager/networks/${aws_networkmanager_global_network.main.id}/global-networks"
}

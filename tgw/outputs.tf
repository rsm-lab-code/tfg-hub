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

# Workload route table is not created in the module
output "workload_rt_id" {
  description = "ID of the Workload Transit Gateway route table"
  value       = "placeholder-workload-rt-id"
}

output "route_table_ids" {
  description = "Map of all Transit Gateway route table IDs"
  value       = {
    inspection = aws_ec2_transit_gateway_route_table.inspection_rt.id
    main       = aws_ec2_transit_gateway_route_table.main_rt.id
  }
}

output "inspection_attachment_id" {
  description = "ID of the Inspection VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.inspection_attachment.id
}
output "tgw_arn" {
  description = "ARN of the Central Transit Gateway"
  value       = aws_ec2_transit_gateway.central_tgw.arn
}

output "tgw_owner_id" {
  description = "Owner ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.central_tgw.owner_id
}
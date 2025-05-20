output "firewall_id" {
  description = "ID of the Network Firewall"
  value       = aws_networkfirewall_firewall.main-rsm.id
}

output "firewall_arn" {
  description = "ARN of the Network Firewall"
  value       = aws_networkfirewall_firewall.main-rsm.arn
}

output "firewall_status" {
  description = "Current status of the Network Firewall"
  value       = aws_networkfirewall_firewall.main-rsm.firewall_status
}

output "firewall_endpoint_ids" {
  description = "IDs of the Network Firewall endpoints"
  value       = [for state in aws_networkfirewall_firewall.main-rsm.firewall_status[0].sync_states : state.attachment[0].endpoint_id]
}

output "firewall_policy_id" {
  description = "ID of the Network Firewall policy"
  value       = aws_networkfirewall_firewall_policy.main-rsm.id
}

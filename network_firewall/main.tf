# Create the stateless rule group for ICMP
resource "aws_networkfirewall_rule_group" "allow_all_traffic-rsm" {
  provider    = aws.delegated_account_us-west-2
  capacity    = 100
  name        = "allow-all-traffic-rsm"
  type        = "STATELESS"
  description = "Allow ALL traffic for monitoring"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 10
          rule_definition {
            actions = ["aws:forward_to_sfe"]
            match_attributes {

              source {
                address_definition = "0.0.0.0/0"
              }

              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }

  tags = {
    Name        = "${var.firewall_name}-allow-all-traffic-rsm"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Create the stateful rule group with your custom rules
resource "aws_networkfirewall_rule_group" "custom_stateful_rules-rsm" {
  provider    = aws.delegated_account_us-west-2
  capacity    = 100
  name        = "custom-stateful-rules-rsm"
  type        = "STATEFUL"
  description = "Custom stateful rules for traffic inspection"

  rule_group {
    rules_source {
      rules_string = <<EOF
# Alert Traffic to Internet
alert ip 10.0.24.0/21 any -> any any (msg:"Alert traffic [10.0.24.0/21->0.0.0.0/0]"; sid:1000015; rev:1;)
# Block all ICMP traffic (North-South and East-West)
#drop icmp any any -> any any (msg:"Block all ICMP traffic"; sid:1000001; rev:1;)

# Allow all internal traffic between VPCs (East-West)
pass ip 10.0.0.0/8 any -> 10.0.0.0/8 any (msg:"Allow internal VPC traffic [10.0.0.0/8->10.0.0.0/8]"; sid:1000003; rev:1;)
pass ip 10.0.0.0/8 any -> 172.31.0.0/16 any (msg:"Allow internal VPC traffic [10.0.0.0/8->172.31.0.0/16]"; sid:1000004; rev:1;)
pass ip 172.31.0.0/16 any -> 172.31.0.0/16 any (msg:"Allow internal VPC traffic [172.31.0.0/16->10.0.0.0/8]"; sid:1000005; rev:1;)
pass ip 172.31.0.0/16 any -> 10.0.0.0/8 any (msg:"Allow internal VPC traffic [172.31.0.0/16->10.0.0.0/8]"; sid:1000006; rev:1;)
# Allow established connections
pass tcp any any <> any any (msg:"Allow established connections"; flow:established; sid:1000002; rev:1;)

# Allow DNS traffic
pass udp any any -> any 53 (msg:"Allow DNS UDP"; sid:1000007; rev:1;)
pass tcp any any -> any 53 (msg:"Allow DNS TCP"; sid:1000008; rev:1;)

# Allow HTTP/HTTPS traffic
pass tcp any any -> any 80 (msg:"Allow HTTP"; sid:1000009; rev:1;)
pass tcp any any -> any 443 (msg:"Allow HTTPS"; sid:1000010; rev:1;)

# Block common attack vectors
drop tcp any any -> any 22 (msg:"Block SSH from Internet"; sid:1000011; rev:1;)
drop tcp any any -> any 3389 (msg:"Block RDP from Internet"; sid:1000012; rev:1;)

# Specific East-West traffic rules (production to development)
pass tcp 10.0.0.0/17 any -> 10.0.64.0/18 any (msg:"Allow traffic from prod to dev [10.0.0.0/17->10.0.64.0/18]"; sid:1000013; rev:1;)
pass tcp 10.0.64.0/18 any -> 10.0.0.0/17 any (msg:"Allow traffic from dev to prod [10.0.64.0/18->10.0.0.0/17]"; sid:1000014; rev:1;)
EOF
    }
  }

  tags = {
    Name        = "${var.firewall_name}-custom-rules-rsm"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Create the domain filtering rule group
resource "aws_networkfirewall_rule_group" "block_domains-rsm" {
  provider    = aws.delegated_account_us-west-2
  capacity    = 100
  name        = "block-malicious-domains-rsm"
  type        = "STATEFUL"
  description = "Block known malicious domains"

  rule_group {
    rules_source {
      rules_string = <<EOF
      alert http any any -> any any (msg:"Blocked domain access attempt"; content:"malicious-example.com"; http_header; sid:10001; rev:1;)
      EOF
    }
  }

  tags = {
    Name        = "${var.firewall_name}-block-domains-rsm"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Create AWS Network Firewall Policy
resource "aws_networkfirewall_firewall_policy" "main-rsm" {
  provider    = aws.delegated_account_us-west-2
  name        = "${var.firewall_name}-policy-rsm"
  description = "Network Firewall policy for centralized inspection"

firewall_policy {
  stateless_default_actions          = ["aws:forward_to_sfe"]
  stateless_fragment_default_actions = ["aws:forward_to_sfe"]

  stateless_rule_group_reference {
    priority    = 10
    resource_arn = aws_networkfirewall_rule_group.allow_all_traffic-rsm.arn
  }

  stateful_rule_group_reference {
    resource_arn = aws_networkfirewall_rule_group.custom_stateful_rules-rsm.arn
  }

  stateful_rule_group_reference {
    resource_arn = aws_networkfirewall_rule_group.block_domains-rsm.arn
  }

  stateful_engine_options {
    rule_order = "DEFAULT_ACTION_ORDER"
  }

  #stateful_default_actions = ["aws:drop_established", "aws:alert_established"]
}

  tags = {
    Name        = "${var.firewall_name}-policy-rsm"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Create AWS Network Firewall
resource "aws_networkfirewall_firewall" "main-rsm" {
  provider    = aws.delegated_account_us-west-2
  name        = var.firewall_name
  description = "Central Network Firewall for VPC inspection"

  vpc_id                            = var.inspection_vpc_id
  firewall_policy_arn               = aws_networkfirewall_firewall_policy.main-rsm.arn
  delete_protection                 = false
  subnet_change_protection          = false
  firewall_policy_change_protection = false

  # Deploy firewall in each firewall subnet
  dynamic "subnet_mapping" {
    for_each = var.firewall_subnet_ids

    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = {
    Name        = var.firewall_name
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}
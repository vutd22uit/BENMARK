# CIS 4.1: Ensure no security groups allow ingress from 0.0.0.0/0 to port 22
# This policy denies security groups that allow SSH access from the internet

package terraform.security_groups

import future.keywords.contains
import future.keywords.if

# Deny security groups with SSH (port 22) open to 0.0.0.0/0
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    
    ingress := resource.change.after.ingress[_]
    
    # Check if port 22 is in the range
    is_ssh_port(ingress)
    
    # Check if open to the world
    is_open_to_world(ingress)
    
    msg := sprintf(
        "CIS 4.1 VIOLATION: Security group '%s' allows SSH (port 22) from 0.0.0.0/0. This violates CIS AWS Foundations Benchmark.",
        [resource.address]
    )
}

# Deny security groups with RDP (port 3389) open to 0.0.0.0/0
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    
    ingress := resource.change.after.ingress[_]
    
    # Check if port 3389 is in the range
    is_rdp_port(ingress)
    
    # Check if open to the world
    is_open_to_world(ingress)
    
    msg := sprintf(
        "CIS 4.2 VIOLATION: Security group '%s' allows RDP (port 3389) from 0.0.0.0/0. This violates CIS AWS Foundations Benchmark.",
        [resource.address]
    )
}

# Helper: Check if SSH port (22) is included
is_ssh_port(ingress) {
    ingress.from_port <= 22
    ingress.to_port >= 22
    ingress.protocol == "tcp"
}

is_ssh_port(ingress) {
    ingress.from_port <= 22
    ingress.to_port >= 22
    ingress.protocol == "-1"  # All protocols
}

# Helper: Check if RDP port (3389) is included
is_rdp_port(ingress) {
    ingress.from_port <= 3389
    ingress.to_port >= 3389
    ingress.protocol == "tcp"
}

is_rdp_port(ingress) {
    ingress.from_port <= 3389
    ingress.to_port >= 3389
    ingress.protocol == "-1"
}

# Helper: Check if rule allows access from 0.0.0.0/0
is_open_to_world(ingress) {
    cidr := ingress.cidr_blocks[_]
    cidr == "0.0.0.0/0"
}

is_open_to_world(ingress) {
    cidr := ingress.ipv6_cidr_blocks[_]
    cidr == "::/0"
}

# Warn about overly permissive security groups (all ports)
warn[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    
    ingress := resource.change.after.ingress[_]
    
    ingress.from_port == 0
    ingress.to_port == 65535
    is_open_to_world(ingress)
    
    msg := sprintf(
        "WARNING: Security group '%s' allows ALL ports from 0.0.0.0/0. Consider restricting access.",
        [resource.address]
    )
}

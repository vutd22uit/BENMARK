# CIS 4.1: Ensure no security groups allow ingress from 0.0.0.0/0 to port 22

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# COMPLIANT Security Group - SSH restricted to specific IP
resource "aws_security_group" "compliant_ssh" {
  name        = "${var.project_name}-compliant-ssh"
  description = "Compliant SSH access - restricted to specific IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from specific IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Private IP range only
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Compliant SSH Security Group"
    CIS_Control = "4.1"
  }
}

# COMPLIANT Security Group - HTTPS from anywhere (allowed)
resource "aws_security_group" "compliant_https" {
  name        = "${var.project_name}-compliant-https"
  description = "Compliant HTTPS access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Compliant HTTPS Security Group"
    CIS_Control = "4.1"
  }
}

# NON-COMPLIANT Security Group (for testing)
# Uncomment to test Checkov/OPA blocking
# resource "aws_security_group" "non_compliant_ssh" {
#   name        = "${var.project_name}-non-compliant-ssh"
#   description = "NON-COMPLIANT: SSH from anywhere"
#   vpc_id      = data.aws_vpc.default.id
#
#   ingress {
#     description = "SSH from anywhere - CIS 4.1 VIOLATION"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name        = "Non-Compliant SSH Security Group"
#     CIS_Control = "VIOLATION"
#   }
# }

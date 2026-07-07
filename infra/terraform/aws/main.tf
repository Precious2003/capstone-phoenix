// Terraform skeleton for AWS SOC homelab (EC2 + networking)
// NOTE: Fill in provider and variables before use
provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "lab" {
  cidr_block = var.vpc_cidr
  tags = { Name = "soc-lab-vpc" }
}

// Example: security group for management access
resource "aws_security_group" "mgmt" {
  name        = "soc-mgmt-sg"
  description = "Allow SSH and management"
  vpc_id      = aws_vpc.lab.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }
  egress { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
}

// Additional resources: subnets, internet gateway, route tables, EC2 instances for Security Onion, Zeek, Windows (use AMI mapping)

resource "aws_vpc" "secure_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "secure-vpc-jdev"
    Environment = "learning"
    Owner       = "Admin-jdev"
    project     = "devsecops-portfolio"
  }
}

output "vpc_id" {
  value = aws_vpc.secure_vpc.id
}

# Internet Gateway (for public internet access)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.secure_vpc.id

  tags = {
    Name = "secure-igw-jdev"
  }
}

# Public Subnet (one AZ for simplicity/free tier)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.secure_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"   # e.g. us-east-1a
  map_public_ip_on_launch = true               # Auto-assign public IPs to instances

  tags = {
    Name = "public-subnet-jdev"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.secure_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt-jdev"
  }
}

# Associate route table to public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group - Minimal: SSH only from your IP
resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh-only"
  description = "Allow SSH inbound from my IP"
  vpc_id      = aws_vpc.secure_vpc.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-ssh-only-jdev"
  }
}

# Temporarily disabled until account verification/payment method is added

# Enable GuardDuty (basic detector)
/*
resource "aws_guardduty_detector" "main" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
  }

  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = {
    Name = "guardduty-detector-jdev"
  }
}

# Enable Security Hub (account-level enablement)
resource "aws_securityhub_account" "main" {}

# Subscribe to key standards (after account enablement)
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/cis-aws-foundations-benchmark/v/1.4.0"
  depends_on    = [aws_securityhub_account.main]
}

resource "aws_securityhub_standards_subscription" "foundational" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.main]
}
*/
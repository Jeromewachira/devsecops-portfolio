resource "aws_vpc" "secure_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "secure-vpc-jdev"
    Environment = "learning"
    Owner       = "Admin-jdev"
  }
}

output "vpc_id" {
  value = aws_vpc.secure_vpc.id
}
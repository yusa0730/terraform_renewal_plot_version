locals {
  project_name = "terraform-renewal-version-test"
  env          = "dev"
  region       = "ap-northeast-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project_name}-${local.env}-vpc"
  }
}

# Subnet
resource "aws_subnet" "lambda_public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${local.region}a"

  tags = {
    Name = "${local.project_name}-${local.env}-lambda-subnet-public-a"
  }
}

resource "aws_subnet" "nat_public_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "${local.region}c"

  tags = {
    Name = "${local.project_name}-${local.env}-nat-subnet-public-c"
  }
}

resource "aws_subnet" "dynamodb_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.40.0/24"
  availability_zone = "${local.region}a"

  tags = {
    Name = "${local.project_name}-${local.env}-dynamodb-subnet-private-a"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "handson"
  }
}

# EIP
resource "aws_eip" "nat_1c" {
  vpc = true

  tags = {
    Name = "${local.project_name}-${local.env}-natgw-1c"
  }
}

# NAT
resource "aws_nat_gateway" "nat_1c" {
  subnet_id     = aws_subnet.nat_public_c.id
  allocation_id = aws_eip.nat_1c.id

  tags = {
    Name = "${local.project_name}-${local.env}-nat-1c"
  }
}

# route_table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.project_name}-${local.env}-public"
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.nat_public_c.id
  route_table_id = aws_route_table.public.id
}

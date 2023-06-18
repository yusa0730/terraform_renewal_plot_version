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
resource "aws_subnet" "lambda_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${local.region}a"

  tags = {
    Name = "${local.project_name}-${local.env}-lambda-subnet-private-a"
  }
}

resource "aws_subnet" "nat_public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "${local.region}a"

  tags = {
    Name = "${local.project_name}-${local.env}-nat-subnet-public-a"
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
resource "aws_eip" "nat_1a" {
  vpc = true

  tags = {
    Name = "${local.project_name}-${local.env}-natgw-1c"
  }
}

# NAT
resource "aws_nat_gateway" "nat_1a" {
  subnet_id     = aws_subnet.nat_public_a.id
  allocation_id = aws_eip.nat_1a.id

  tags = {
    Name = "${local.project_name}-${local.env}-nat-1a"
  }
}

# route_table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${local.project_name}-${local.env}-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.nat_public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.lambda_private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "from_api_gateway_to_lambda" {
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_endpoint" "from_api_gateway_to_lambda" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.lambda"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.lambda_private_a.id]
  security_group_ids  = [aws_security_group.from_api_gateway_to_lambda.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "from_lambda_to_dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.dynamodb"
  vpc_endpoint_type = "Gateway"
}

resource "aws_route" "route_to_dynamodb" {
  route_table_id             = aws_route_table.private.id
  destination_prefix_list_id = aws_vpc_endpoint.from_lambda_to_dynamodb.prefix_list_id
  vpc_endpoint_id            = aws_vpc_endpoint.from_lambda_to_dynamodb.id
}

resource "aws_vpc" "main" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-vpc"
  }
}

# Subnet
resource "aws_subnet" "lambda_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.0.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.env}-lambda-private-a-sbn"
  }
}

resource "aws_subnet" "lambda_private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name = "${var.env}-lambda-private-c-sbn"
  }
}

resource "aws_subnet" "nat_public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.8.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.env}-nat-public-a-sbn"
  }
}

resource "aws_subnet" "nat_public_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.9.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name = "${var.env}-nat-public-c-sbn"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-internet-gateway"
  }
}

# EIP
resource "aws_eip" "nat_1a" {
  vpc = true

  tags = {
    Name = "${var.env}-eip-natgw-1a"
  }
}

resource "aws_eip" "nat_1c" {
  vpc = true

  tags = {
    Name = "${var.env}-eip-natgw-1c"
  }
}

# NAT
resource "aws_nat_gateway" "nat_1a" {
  subnet_id     = aws_subnet.nat_public_a.id
  allocation_id = aws_eip.nat_1a.id

  tags = {
    Name = "${var.env}-natgw-1a"
  }
}

resource "aws_nat_gateway" "nat_1c" {
  subnet_id     = aws_subnet.nat_public_c.id
  allocation_id = aws_eip.nat_1c.id

  tags = {
    Name = "${var.env}-natgw-1c"
  }
}

# route_table
resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-nat-public-a-route-table"
  }
}

resource "aws_route_table" "public_c" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-nat-public-c-route-table"
  }
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }
  tags = {
    Name = "${var.env}-lambda-private-a-route-table"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1c.id
  }
  tags = {
    Name = "${var.env}-lambda-private-c-route-table"
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.nat_public_a.id
  route_table_id = aws_route_table.public_a.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.nat_public_c.id
  route_table_id = aws_route_table.public_c.id
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.lambda_private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.lambda_private_c.id
  route_table_id = aws_route_table.private_c.id
}

# security_group
resource "aws_security_group" "from_api_gateway_to_lambda_sg" {
  name        = "${var.env}-internal-lambda-sg"
  description = "${var.env}-internal-lambda-sg"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_endpoint" "from_api_gateway_to_lambda" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.lambda"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.lambda_private_a.id, aws_subnet.lambda_private_c.id]
  security_group_ids  = [aws_security_group.from_api_gateway_to_lambda_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.env}-endpoint-lambda"
  }
}

resource "aws_vpc_endpoint" "from_lambda_to_dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_a.id, aws_route_table.private_c.id]

  tags = {
    Name = "${var.env}-endpoint-dynamodb"
  }
}

resource "aws_vpc_endpoint_route_table_association" "from_lambda_a_to_dynamodb" {
  route_table_id  = aws_route_table.private_a.id
  vpc_endpoint_id = aws_vpc_endpoint.from_lambda_to_dynamodb.id
}

resource "aws_vpc_endpoint_route_table_association" "from_lambda_c_to_dynamodb" {
  route_table_id  = aws_route_table.private_c.id
  vpc_endpoint_id = aws_vpc_endpoint.from_lambda_to_dynamodb.id
}

resource "aws_vpc" "main" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-vpc"
  }
}

# Subnet
# resource "aws_subnet" "lambda_private_a" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.2.0.0/24"
#   availability_zone = "${var.region}a"

#   tags = {
#     Name = "${var.env}-lambda-private-a-sbn"
#   }
# }

resource "aws_subnet" "lambda_public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.0.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.env}-lambda-public-a-sbn"
  }
}

# resource "aws_subnet" "lambda_private_c" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.2.1.0/24"
#   availability_zone = "${var.region}c"

#   tags = {
#     Name = "${var.env}-lambda-private-c-sbn"
#   }
# }

# resource "aws_subnet" "lambda_public_c" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.2.1.0/24"
#   availability_zone = "${var.region}c"

#   tags = {
#     Name = "${var.env}-lambda-public-c-sbn"
#   }
# }

resource "aws_subnet" "nat_public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.8.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.env}-nat-public-a-sbn"
  }
}

# resource "aws_subnet" "nat_public_c" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.2.9.0/24"
#   availability_zone = "${var.region}c"

#   tags = {
#     Name = "${var.env}-nat-public-c-sbn"
#   }
# }

resource "aws_subnet" "aws_batch_public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.10.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.env}-batch-public-a-sbn"
  }
}

# resource "aws_subnet" "aws_batch_public_c" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.2.11.0/24"
#   availability_zone = "${var.region}c"

#   tags = {
#     Name = "${var.env}-batch-public-c-sbn"
#   }
# }

resource "aws_subnet" "aws_batch_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.20.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.env}-batch-private-a-sbn"
  }
}

# resource "aws_subnet" "aws_batch_private_c" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.2.21.0/24"
#   availability_zone = "${var.region}c"

#   tags = {
#     Name = "${var.env}-batch-private-c-sbn"
#   }
# }


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

# resource "aws_eip" "nat_1c" {
#   vpc = true

#   tags = {
#     Name = "${var.env}-eip-natgw-1c"
#   }
# }

# NAT
resource "aws_nat_gateway" "nat_1a" {
  subnet_id     = aws_subnet.nat_public_a.id
  allocation_id = aws_eip.nat_1a.id

  tags = {
    Name = "${var.env}-natgw-1a"
  }
}

# resource "aws_nat_gateway" "nat_1c" {
#   subnet_id     = aws_subnet.nat_public_c.id
#   allocation_id = aws_eip.nat_1c.id

#   tags = {
#     Name = "${var.env}-natgw-1c"
#   }
# }

# route_table
resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-public-a-route-table"
  }
}

# resource "aws_route_table" "public_c" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }
#   tags = {
#     Name = "${var.env}-public-c-route-table"
#   }
# }

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }
  tags = {
    Name = "${var.env}-private-a-route-table"
  }
}

# resource "aws_route_table" "private_c" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_1c.id
#   }
#   tags = {
#     Name = "${var.env}-private-c-route-table"
#   }
# }

resource "aws_route_table_association" "nat_public_1a" {
  subnet_id      = aws_subnet.nat_public_a.id
  route_table_id = aws_route_table.public_a.id
}

# resource "aws_route_table_association" "nat_public_1c" {
#   subnet_id      = aws_subnet.nat_public_c.id
#   route_table_id = aws_route_table.public_c.id
# }

resource "aws_route_table_association" "aws_batch_public_a" {
  subnet_id      = aws_subnet.aws_batch_public_a.id
  route_table_id = aws_route_table.public_a.id
}

# resource "aws_route_table_association" "aws_batch_public_c" {
#   subnet_id      = aws_subnet.aws_batch_public_c.id
#   route_table_id = aws_route_table.public_c.id
# }

# resource "aws_route_table_association" "lambda_private_1a" {
#   subnet_id      = aws_subnet.lambda_private_a.id
#   route_table_id = aws_route_table.private_a.id
# }
resource "aws_route_table_association" "lambda_public_1a" {
  subnet_id      = aws_subnet.lambda_public_a.id
  route_table_id = aws_route_table.public_a.id
}

# resource "aws_route_table_association" "lambda_private_1c" {
#   subnet_id      = aws_subnet.lambda_private_c.id
#   route_table_id = aws_route_table.private_c.id
# }

# resource "aws_route_table_association" "lambda_public_1c" {
#   subnet_id      = aws_subnet.lambda_public_c.id
#   route_table_id = aws_route_table.public_c.id
# }

resource "aws_route_table_association" "aws_batch_private_a" {
  subnet_id      = aws_subnet.aws_batch_private_a.id
  route_table_id = aws_route_table.private_a.id
}

# resource "aws_route_table_association" "aws_batch_private_c" {
#   subnet_id      = aws_subnet.aws_batch_private_c.id
#   route_table_id = aws_route_table.private_c.id
# }

# security_group
#=======privateサブネットにLambdaを設定する際に必要なSecurity Group=========
# resource "aws_security_group" "vpc_endpoint_of_interface_lambda_sg" {
#   name        = "${var.env}-vpce-interface-lambda-sg"
#   description = "${var.env}-vpce-interface-lambda-sg"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description = "HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     description = "HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "from_api_gateway_to_lambda_sg" {
#   name        = "${var.env}-internal-private-lambda-sg"
#   description = "${var.env}-internal-private-lambda-sg"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description     = "HTTPS"
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = ["${aws_security_group.vpc_endpoint_of_interface_lambda_sg.id}"]
#   }

#   egress {
#     description = ""
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#=======privateサブネットにLambdaを設定する際に必要なSecurity Group=========

resource "aws_security_group" "from_api_gateway_to_lambda_sg" {
  name        = "${var.env}-internal-public-lambda-sg"
  description = "${var.env}-internal-public-lambda-sg"
  vpc_id      = aws_vpc.main.id

  egress {
    description = ""
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "push_notification_aws_batch_sg" {
  name        = "${var.env}-push-notification-aws-batch-sg"
  description = "${var.env}-push-notification-aws-batch-sg"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_aws_batch_sg" {
  name        = "${var.env}-public-aws-batch-sg"
  description = "${var.env}-public-aws-batch-sg"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc_endpoint_ecr_sg" {
  name        = "${var.env}-vpc-endpoint-ecr-sg"
  description = "${var.env}-vpc-endpoint-ecr-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "from AWS Batch"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.push_notification_aws_batch_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc_endpoint_cloudwatch_logs_sg" {
  name        = "${var.env}-vpc-endpoint-cloudwatch-logs-sg"
  description = "${var.env}-vpc-endpoint-cloudwatch-logs-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "from push notification AWS Batch"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.push_notification_aws_batch_sg.id}"]
  }

  ingress {
    description     = "from public AWS Batch"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.public_aws_batch_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#=======privateサブネットにLambdaを設定する際に必要なVPC Endpoint=========
# resource "aws_vpc_endpoint" "from_api_gateway_to_lambda" {
#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.${var.region}.lambda"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = [aws_subnet.lambda_private_a.id]
#   # subnet_ids          = [aws_subnet.lambda_private_a.id, aws_subnet.lambda_private_c.id]
#   security_group_ids  = [aws_security_group.vpc_endpoint_of_interface_lambda_sg.id]
#   private_dns_enabled = true
#   tags = {
#     Name = "${var.env}-endpoint-lambda"
#   }
# }
#=======privateサブネットにLambdaを設定する際に必要なVPC Endpoint=========

# resource "aws_vpc_endpoint" "from_lambda_to_dynamodb" {
#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.${var.region}.dynamodb"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = [aws_route_table.private_a.id]
#   # route_table_ids   = [aws_route_table.private_a.id, aws_route_table.private_c.id]

#   tags = {
#     Name = "${var.env}-endpoint-dynamodb"
#   }
# }

resource "aws_vpc_endpoint" "from_lambda_to_dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public_a.id]
  # route_table_ids   = [aws_route_table.public_a.id, aws_route_table.public_c.id]

  tags = {
    Name = "${var.env}-endpoint-dynamodb"
  }
}

# resource "aws_vpc_endpoint_route_table_association" "from_lambda_a_to_dynamodb" {
#   route_table_id  = aws_route_table.private_a.id
#   vpc_endpoint_id = aws_vpc_endpoint.from_lambda_to_dynamodb.id
# }

resource "aws_vpc_endpoint_route_table_association" "from_lambda_a_to_dynamodb" {
  route_table_id  = aws_route_table.public_a.id
  vpc_endpoint_id = aws_vpc_endpoint.from_lambda_to_dynamodb.id
}

# resource "aws_vpc_endpoint_route_table_association" "from_lambda_c_to_dynamodb" {
#   route_table_id  = aws_route_table.private_c.id
#   vpc_endpoint_id = aws_vpc_endpoint.from_lambda_to_dynamodb.id
# }

# resource "aws_vpc_endpoint_route_table_association" "from_lambda_c_to_dynamodb" {
#   route_table_id  = aws_route_table.public_c.id
#   vpc_endpoint_id = aws_vpc_endpoint.from_lambda_to_dynamodb.id
# }

### ECRのVPC Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.aws_batch_private_a.id]
  # subnet_ids = [aws_subnet.aws_batch_private_a.id, aws_subnet.aws_batch_private_c.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_ecr_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.env}-endpoint-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.aws_batch_private_a.id]
  # subnet_ids = [aws_subnet.aws_batch_private_a.id, aws_subnet.aws_batch_private_c.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_ecr_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.env}-endpoint-ecr-api"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.aws_batch_private_a.id]
  # subnet_ids = [aws_subnet.aws_batch_private_a.id, aws_subnet.aws_batch_private_c.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_cloudwatch_logs_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.env}-endpoint-cloudwatch-logs"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_a.id]
  # route_table_ids   = [aws_route_table.private_a.id, aws_route_table.private_c.id]

  tags = {
    Name = "${var.env}-endpoint-s3"
  }
}

resource "aws_vpc_endpoint_route_table_association" "private_a_s3" {
  route_table_id  = aws_route_table.private_a.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

# resource "aws_vpc_endpoint_route_table_association" "private_c_s3" {
#   route_table_id  = aws_route_table.private_c.id
#   vpc_endpoint_id = aws_vpc_endpoint.s3.id
# }

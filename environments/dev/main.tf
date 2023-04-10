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

resource "aws_subnet" "lambda_public_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${local.region}a" 

  tags = {
    Name = "${local.project_name}-${local.env}-lambda-subnet-private-a"
  }
}

resource "aws_subnet" "nat_private_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.40.0/24"
  availability_zone = "${local.region}a"

  tags = {
    Name = "${local.project_name}-${local.env}-nat-subnet-private-a"
  }
}

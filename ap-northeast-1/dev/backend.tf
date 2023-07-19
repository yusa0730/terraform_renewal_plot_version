provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

provider "aws" {
  region = "ap-northeast-3"
  alias  = "osaka"
}

terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.4.0"
    }
  }
  backend "s3" {
    bucket = "infrastructure-renewal-lesson-bucket"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

resource "aws_ecr_repository" "push_notification_batch_ecr" {
  name                 = "${var.project_name}-${var.env}-push-notification-batch-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-push-notification-batch-ecr"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_ecr_repository" "public_batch_ecr" {
  name                 = "${var.project_name}-${var.env}-public-batch-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-public-batch-ecr"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_ecr_repository" "lambda_ecr" {
  name                 = "${var.project_name}-${var.env}-lambda-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-lambda-ecr"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

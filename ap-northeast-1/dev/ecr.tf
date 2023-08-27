resource "aws_ecr_repository" "push_notification_batch_ecr" {
  name                 = "push_notification_batch_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "public_batch_ecr" {
  name                 = "public_batch_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "lambda_ecr" {
  name                 = "lambda_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

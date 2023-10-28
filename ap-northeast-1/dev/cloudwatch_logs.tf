resource "aws_cloudwatch_log_group" "push_notification_batch" {
  name = "/aws-batch/${var.env}/push_notification/job"

  tags = {
    Name      = "${var.project_name}-${var.env}-cw-log-push-notification-job"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "public_batch" {
  name = "/aws-batch/${var.env}/public/job"

  tags = {
    Name      = "${var.project_name}-${var.env}-cw-log-public-job"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "redis_engine_logs" {
  name = "redis/${var.env}/engine-logs"

  tags = {
    Name      = "${var.project_name}-${var.env}-cw-log-redis-engine-logs"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "redis_slow_logs" {
  name = "redis/${var.env}/slow-logs"

  tags = {
    Name      = "${var.project_name}-${var.env}-cw-log-redis-slow-logs"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

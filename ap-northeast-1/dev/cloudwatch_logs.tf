resource "aws_cloudwatch_log_group" "push_notification_batch" {
  name = "/aws-batch/${var.env}/push_notification/job"
}

resource "aws_cloudwatch_log_group" "public_batch" {
  name = "/aws-batch/${var.env}/public/job"
}

resource "aws_cloudwatch_log_group" "redis_engine_logs" {
  name = "redis/${var.env}/engine-logs"
}

resource "aws_cloudwatch_log_group" "redis_slow_logs" {
  name = "redis/${var.env}/slow-logs"
}

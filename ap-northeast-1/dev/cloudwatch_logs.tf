resource "aws_cloudwatch_log_group" "push_notification_batch" {
  name = "/aws/batch/push_notification/job"
}

resource "aws_cloudwatch_log_group" "public_batch" {
  name = "/aws/batch/public/job"
}

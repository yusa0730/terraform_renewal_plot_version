# EventBridge Event Rule
resource "aws_cloudwatch_event_rule" "every_first_saturday" {
  name        = "every-first-saturday"
  description = "Fires every first Saturday of the month at 12:30"

  schedule_expression = "cron(30 12 ? * 6#1 *)"
}

resource "aws_cloudwatch_event_rule" "every_third_saturday" {
  name        = "every-third-saturday"
  description = "Fires every third Saturday of the month at 12:30"

  schedule_expression = "cron(30 12 ? * 6#3 *)"
}


### プッシュ通知用バッチ専用
# Target that links the Event Rule to the AWS Batch Job
resource "aws_cloudwatch_event_target" "first_push_notification_batch_target" {
  rule     = aws_cloudwatch_event_rule.every_first_saturday.name
  arn      = aws_batch_job_queue.push_notification_batch_queue.arn
  role_arn = aws_iam_role.event_role.arn # A role that EventBridge can assume to launch the Batch Job

  batch_target {
    job_name       = "first-saturday-push-notification-job"
    job_definition = aws_batch_job_definition.push_notification_batch_job_def.name
  }
}


# Target that links the Event Rule to the AWS Batch Job
resource "aws_cloudwatch_event_target" "third_push_notification_batch_target" {
  rule     = aws_cloudwatch_event_rule.every_third_saturday.name
  arn      = aws_batch_job_queue.push_notification_batch_queue.arn
  role_arn = aws_iam_role.event_role.arn # A role that EventBridge can assume to launch the Batch Job

  batch_target {
    job_name       = "third-saturday-push-notification-job"
    job_definition = aws_batch_job_definition.push_notification_batch_job_def.name
  }
}

### パブリックバッチ専用
# Target that links the Event Rule to the AWS Batch Job
# resource "aws_cloudwatch_event_target" "first_public_batch_target" {
#   rule     = aws_cloudwatch_event_rule.every_first_saturday.name
#   arn      = aws_batch_job_queue.public_batch_queue.arn
#   role_arn = aws_iam_role.event_role.arn # A role that EventBridge can assume to launch the Batch Job

#   batch_target {
#     job_name       = "first-saturday-public-batch-job"
#     job_definition = aws_batch_job_definition.public_batch_job_def.name
#   }
# }


# # Target that links the Event Rule to the AWS Batch Job
# resource "aws_cloudwatch_event_target" "third_public_batch_target" {
#   rule     = aws_cloudwatch_event_rule.every_third_saturday.name
#   arn      = aws_batch_job_queue.public_batch_queue.arn
#   role_arn = aws_iam_role.event_role.arn # A role that EventBridge can assume to launch the Batch Job

#   batch_target {
#     job_name       = "third-saturday-public-batch-job"
#     job_definition = aws_batch_job_definition.public_batch_job_def.name
#   }
# }

## privateサブネットに設定するプッシュ通知用のバッチ設定
resource "aws_batch_compute_environment" "push_notification_compute_environment" {
  compute_environment_name = "${var.env}_push_notification_compute_environment"
  compute_resources {
    type    = "Fargate"
    subnets = [aws_subnet.aws_batch_private_a.id]
    # subnets            = [
    #   aws_subnet.aws_batch_private_a.id,
    #   aws_subnet.aws_batch_private_c.id,
    # ]
    security_group_ids = [aws_security_group.push_notification_aws_batch_sg.id]
    max_vcpus          = 4
  }
  service_role = aws_iam_role.batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch]
}

resource "aws_batch_job_queue" "push_notification_batch_queue" {
  name                 = "${var.env}_push_notification_batch_queue"
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.push_notification_compute_environment.arn]
}

resource "aws_batch_job_definition" "push_notification_batch_job_def" {
  name                  = "${var.env}_push_notification_batch_job_def"
  type                  = "container"
  platform_capabilities = ["FARGATE"]

  container_properties = jsonencode({
    command = ["python", "test.py"],
    image   = "${aws_ecr_repository.push_notification_batch_ecr.repository_url}:latest",

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "${aws_cloudwatch_log_group.push_notification_batch.name}"
        "awslogs-region"        = "${var.region}"
        "awslogs-stream-prefix" = "push-notification-batch-job"
      }
    }

    resourceRequirements = [
      {
        type  = "VCPU"
        value = "1"
      },
      {
        type  = "MEMORY"
        value = "2048"
      }
    ]
    jobRoleArn = "${aws_iam_role.push_notification_batch_job_role.arn}"

    executionRoleArn = "${aws_iam_role.batch_task_execution_role.arn}"
  })
}

## publicサブネットに設定するバッチ設定
# resource "aws_batch_compute_environment" "public_compute_environment" {
#   compute_environment_name = "${var.env}_public_compute_environment"
#   compute_resources {
#     type = "Fargate"
#     subnets = [
#       aws_subnet.aws_batch_public_a.id
#     ]
#     # subnets            = [
#     #   aws_subnet.aws_batch_public_a.id,
#     #   aws_subnet.aws_batch_public_c.id,
#     # ]
#     security_group_ids = [aws_security_group.public_aws_batch_sg.id]
#     max_vcpus          = 4
#   }
#   service_role = aws_iam_role.batch_service_role.arn
#   type         = "MANAGED"
#   depends_on   = [aws_iam_role_policy_attachment.aws_batch]
# }

# resource "aws_batch_job_queue" "public_batch_queue" {
#   name                 = "${var.env}_public_batch_queue"
#   state                = "ENABLED"
#   priority             = 1
#   compute_environments = [aws_batch_compute_environment.public_compute_environment.arn]
# }

# resource "aws_batch_job_definition" "public_batch_job_def" {
#   name                  = "${var.env}_public_batch_job_def"
#   type                  = "container"
#   platform_capabilities = ["FARGATE"]

#   container_properties = jsonencode({
#     command = ["echo", "Hello, public AWS Batch on Fargate!"],
#     image   = "${aws_ecr_repository.public_batch_ecr.repository_url}:latest",

#     logConfiguration = {
#       logDriver = "awslogs"
#       options = {
#         "awslogs-group"         = "${aws_cloudwatch_log_group.public_batch.name}"
#         "awslogs-region"        = "${var.region}"
#         "awslogs-stream-prefix" = "public-batch-job"
#       }
#     }

#     resourceRequirements = [
#       {
#         type  = "VCPU"
#         value = "1"
#       },
#       {
#         type  = "MEMORY"
#         value = "2048"
#       }
#     ]
#     jobRoleArn = "${aws_iam_role.public_batch_job_role.arn}"

#     executionRoleArn = "${aws_iam_role.batch_task_execution_role.arn}"
#   })
# }

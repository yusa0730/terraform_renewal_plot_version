resource "aws_batch_compute_environment" "push_notification_compute_environment" {
  compute_environment_name = "${var.env}_push_notification_compute_environment"
  compute_resources {
    type               = "Fargate"
    subnets            = [aws_subnet.aws_batch_private_a.id]
    security_group_ids = [aws_security_group.aws_batch.id]
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
    command = ["echo", "Hello, AWS Batch on Fargate!"],
    image   = "busybox",

    resourceRequirements = [
      {
        type  = "VCPU"
        value = "0.25"
      },
      {
        type  = "MEMORY"
        value = "512"
      }
    ]
    jobRoleArn = "${aws_iam_role.batch_job_role.arn}"

    executionRoleArn = "${aws_iam_role.batch_task_execution_role.arn}"
  })
}


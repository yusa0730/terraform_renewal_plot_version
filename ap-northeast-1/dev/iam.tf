## Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.env}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attach_VPCAccessExecutionRole" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "${var.env}-lambda-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Scan",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [
          "${aws_dynamodb_table.main.arn}"
        ]
      }
    ]
  })
}

## AWS Backup
resource "aws_iam_role" "aws_backup_role" {
  name = "AWSBackupDefaultServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "backup.amazonaws.com",
        },
      },
    ],
  })
}

data "aws_iam_policy" "aws_backup_service_role_policy_for_backup" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

data "aws_iam_policy" "aws_backup_service_role_policy_for_restore" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_role_policy_attachment" "aws_backup" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = data.aws_iam_policy.aws_backup_service_role_policy_for_backup.arn
}

resource "aws_iam_role_policy_attachment" "aws_restore" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = data.aws_iam_policy.aws_backup_service_role_policy_for_restore.arn
}

## AWS Batch
resource "aws_iam_role" "batch_service_role" {
  name = "${var.env}-push-notification-batch-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "batch.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy" "aws_batch" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role_policy_attachment" "aws_batch" {
  role       = aws_iam_role.batch_service_role.name
  policy_arn = data.aws_iam_policy.aws_batch.arn
}

resource "aws_iam_role" "batch_task_execution_role" {
  name = "${var.env}-batch-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy" "batch_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "batch_task_execution" {
  role       = aws_iam_role.batch_task_execution_role.id
  policy_arn = data.aws_iam_policy.batch_task_execution.arn
}

resource "aws_iam_role" "batch_job_role" {
  name = "${var.env}-batch-job-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "batch_job" {
  name   = "${var.env}-batch-job-policy"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.batch_job_custom.json
}

data "aws_iam_policy_document" "batch_job_custom" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Scan",
      "dynamodb:GetItem",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "sns:Publish",
      "sns:CreatePlatformApplication",
      "sns:CreatePlatformEndpoint",
      "sns:CreateTopic",
      "sns:DeleteEndpoint",
      "sns:DeletePlatformApplication",
      "sns:DeleteTopic",
      "sns:GetEndpointAttributes",
      "sns:GetPlatformApplicationAttributes",
      "sns:ListPlatformApplications",
      "sns:SetEndpointAttributes",
      "sns:SetPlatformApplicationAttributes",
      "sns:Subscribe",
      "sns:Unsubscribe"
    ]
    resources = ["*"]
  }
}

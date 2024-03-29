## Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.env}-lambda-role"
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

  tags = {
    Name      = "${var.project_name}-${var.env}-lambda-role"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attach_VPCAccessExecutionRole" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Scan",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      aws_dynamodb_table.main.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage"
    ]
    resources = [
      aws_ecr_repository.lambda_ecr.arn
    ]
  }
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "${var.project_name}-${var.env}-lambda-role-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_role_policy.json
}

## AWS Backup
resource "aws_iam_role" "aws_backup_role" {
  name = "${var.project_name}-${var.env}-aws-backup-default-role"

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

  tags = {
    Name      = "${var.project_name}-${var.env}-aws-backup-default-role"
    Env       = var.env
    ManagedBy = "Terraform"
  }
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
  name = "${var.project_name}-${var.env}-batch-service-role"
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

  tags = {
    Name      = "${var.project_name}-${var.env}-batch-service-role"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

data "aws_iam_policy" "aws_batch" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role_policy_attachment" "aws_batch" {
  role       = aws_iam_role.batch_service_role.name
  policy_arn = data.aws_iam_policy.aws_batch.arn
}

resource "aws_iam_role" "batch_task_execution_role" {
  name = "${var.project_name}-${var.env}-batch-task-execution-role"
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

  tags = {
    Name      = "${var.project_name}-${var.env}-batch-task-execution-role"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

data "aws_iam_policy" "batch_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "batch_task_execution" {
  role       = aws_iam_role.batch_task_execution_role.id
  policy_arn = data.aws_iam_policy.batch_task_execution.arn
}

resource "aws_iam_role" "push_notification_batch_job_role" {
  name = "${var.project_name}-${var.env}-push-notification-batch-job-role"
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

  tags = {
    Name      = "${var.project_name}-${var.env}-push-notification-batch-job-role"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy" "push_notification_batch_job" {
  name   = "${var.env}-push-notification-batch-job-policy"
  role   = aws_iam_role.push_notification_batch_job_role.id
  policy = data.aws_iam_policy_document.push_notification_batch_job_custom.json
}

data "aws_iam_policy_document" "push_notification_batch_job_custom" {
  statement {
    effect = "Allow"
    actions = [
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

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.push_notification_batch.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage"
    ]
    resources = [
      aws_ecr_repository.push_notification_batch_ecr.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Scan",
      "dynamodb:GetItem"
    ]
    resources = [
      aws_dynamodb_table.main.arn
    ]
  }
}


## public用AWS BatchのIAM
resource "aws_iam_role" "public_batch_job_role" {
  name = "${var.project_name}-${var.env}-public-batch-job-role"
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

  tags = {
    Name      = "${var.project_name}-${var.env}-public-batch-job-role"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy" "public_batch_job" {
  name   = "${var.project_name}-${var.env}-public-batch-job-policy"
  role   = aws_iam_role.public_batch_job_role.id
  policy = data.aws_iam_policy_document.public_batch_job_custom.json
}

data "aws_iam_policy_document" "public_batch_job_custom" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.public_batch.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage"
    ]
    resources = [
      aws_ecr_repository.public_batch_ecr.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Scan",
      "dynamodb:GetItem"
    ]
    resources = [
      aws_dynamodb_table.main.arn
    ]
  }
}

# IAM Role that EventBridge assumes
resource "aws_iam_role" "event_role" {
  name = "${var.project_name}-${var.env}-event-bridge-batch-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-event-bridge-batch-execution-role"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

# Add the permissions necessary for the EventBridge role
resource "aws_iam_role_policy_attachment" "event_role_permissions" {
  role       = aws_iam_role.event_role.name
  policy_arn = aws_iam_policy.event_policy.arn
}

resource "aws_iam_policy" "event_policy" {
  name        = "${var.project_name}-${var.env}-event-bridge-batch-policy"
  description = "Policy to allow EventBridge to start AWS Batch Jobs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "batch:SubmitJob"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${var.env}-event-bridge-batch-policy"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

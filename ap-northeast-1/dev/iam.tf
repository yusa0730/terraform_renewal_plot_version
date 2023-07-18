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
  name = "${var.env}_lambda_policy"
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

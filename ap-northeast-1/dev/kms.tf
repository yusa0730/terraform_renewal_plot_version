data "aws_caller_identity" "current" {}

resource "aws_kms_key" "backup_vault" {
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Default key that protects my Backup data when no other key is defined"
  enable_key_rotation      = true
  is_enabled               = true
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = false
  policy = jsonencode(
    {
      Id = "auto-backup-1"
      Statement = [
        {
          Action = [
            "kms:CreateGrant",
            "kms:Decrypt",
            "kms:GenerateDataKey*",
          ]
          Condition = {
            StringEquals = {
              "kms:CallerAccount" = "${data.aws_caller_identity.current.account_id}"
              "kms:ViaService"    = "backup.ap-northeast-1.amazonaws.com"
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Resource = "*"
          Sid      = "Allow access through Backup for all principals in the account that are authorized to use Backup Storage"
        },
        {
          Action = [
            "kms:Describe*",
            "kms:Get*",
            "kms:List*",
            "kms:RevokeGrant",
          ]
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
          Resource = "*"
          Sid      = "Allow direct access to key metadata to the account"
        },
      ]
      Version = "2012-10-17"
    }
  )

  tags = {
    Name      = "${var.project_name}-${var.env}-backup-vault"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_kms_key" "destination_backup_vault" {
  provider                 = aws.osaka
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Default key that protects my Backup data when no other key is defined"
  enable_key_rotation      = true
  is_enabled               = true
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = false
  policy = jsonencode(
    {
      Id = "auto-backup-1"
      Statement = [
        {
          Action = [
            "kms:CreateGrant",
            "kms:Decrypt",
            "kms:GenerateDataKey*",
          ]
          Condition = {
            StringEquals = {
              "kms:CallerAccount" = "${data.aws_caller_identity.current.account_id}"
              "kms:ViaService"    = "backup.ap-northeast-3.amazonaws.com"
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Resource = "*"
          Sid      = "Allow access through Backup for all principals in the account that are authorized to use Backup Storage"
        },
        {
          Action = [
            "kms:Describe*",
            "kms:Get*",
            "kms:List*",
            "kms:RevokeGrant",
          ]
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
          Resource = "*"
          Sid      = "Allow direct access to key metadata to the account"
        },
      ]
      Version = "2012-10-17"
    }
  )

  tags = {
    Name      = "${var.project_name}-${var.env}-destination-backup-vault"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

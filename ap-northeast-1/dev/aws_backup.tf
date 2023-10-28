# resource "aws_backup_plan" "main" {
#   name = "${var.project_name}-${var.env}-backup-plan"

#   rule {
#     completion_window        = 120
#     enable_continuous_backup = true
#     recovery_point_tags      = {}
#     rule_name                = "${var.project_name}-${var.env}-backup-rule"
#     schedule                 = "cron(0 19 ? * * *)"
#     start_window             = 60
#     target_vault_name        = aws_backup_vault.main.name

#     copy_action {
#       destination_vault_arn = aws_backup_vault.destination.arn
#     }

#     lifecycle {
#       cold_storage_after = 0
#       delete_after       = 35
#     }
#   }

#   tags = {
#     Name      = "${var.project_name}-${var.env}-backup-plan"
#     Env       = var.env
#     ManagedBy = "Terraform"
#   }
# }

# resource "aws_backup_vault" "main" {
#   kms_key_arn = aws_kms_key.backup_vault.arn
#   name        = "${var.project_name}-${var.env}-backup-vault"

#   tags = {
#     Name      = "${var.project_name}-${var.env}-backup-vault"
#     Env       = var.env
#     ManagedBy = "Terraform"
#   }
# }

# resource "aws_backup_vault" "destination" {
#   provider    = aws.osaka
#   kms_key_arn = aws_kms_key.destination_backup_vault.arn
#   name        = "${var.project_name}-${var.env}-destination-backup-vault"

#   tags = {
#     Name      = "${var.project_name}-${var.env}-destination-backup-vault"
#     Env       = var.env
#     ManagedBy = "Terraform"
#   }
# }

# resource "aws_backup_selection" "main" {
#   iam_role_arn = aws_iam_role.aws_backup_role.arn
#   name         = "${var.project_name}-${var.env}-backup-selection"
#   plan_id      = aws_backup_plan.main.id

#   resources = ["arn:aws:dynamodb:*:*:table/*"]
# }

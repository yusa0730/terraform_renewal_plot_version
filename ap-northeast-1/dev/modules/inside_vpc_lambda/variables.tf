variable "lambda_count" {}
variable "image_url" {}
variable "iam_role_arn" {}
variable "api_root_id" {}
variable "rest_api_id" {}
variable "project_name" {}
variable "env" {}
variable "region" {}
variable "security_group_ids" {
  type = list(string)
}
variable "subnet_ids" {
  type = list(string)
}

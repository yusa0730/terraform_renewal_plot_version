variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "terraform-renewal-version-test"
}

variable "env" {
  description = "The environment (e.g. dev, prod)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "The AWS region."
  type        = string
  default     = "ap-northeast-1"
}

variable "rest_api_name" {
  description = "aws_api_gateway_rest_apiのnameの値です"
  type        = string
  default     = "test_api"
}

variable "rest_api_description" {
  description = "aws_api_gateway_rest_apiのdescriptionの値です"
  type        = string
  default     = ""
}

variable "rest_api_gateway_resource_path_part" {
  description = "rest_api_gateway_resourceのpath_partの値です"
  type        = string
  default     = "items"
}

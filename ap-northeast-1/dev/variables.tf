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
  description = "aws_api_gateway_rest_apiのnameの値"
  type        = string
  default     = "test_api"
}

variable "rest_api_description" {
  description = "aws_api_gateway_rest_apiのdescriptionの値"
  type        = string
  default     = ""
}

variable "rest_api_gateway_resource_path_part" {
  description = "aws_rest_api_gateway_resourceのpath_partの値"
  type        = string
  default     = "items"
}

variable "api_gateway_authorizer_name" {
  description = "aws_api_gateway_authorizerのnameの値"
  type        = string
  default     = "cognito"
}

variable "lambda_function_name" {
  description = "aws_lambda_functionのfunction_nameの値"
  type        = string
  default     = "example_lambda"
}

variable "cognito_user_pool_name" {
  description = "cognitoのuser_pool用のname値"
  type        = string
  default     = "user_pool_of_tcdx"
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "main" {
  count = var.lambda_count

  function_name = "${var.project_name}-${var.env}-api${count.index + 201}"
  role          = var.iam_role_arn
  image_uri     = var.image_url

  package_type = "Image"
}

resource "aws_api_gateway_resource" "main" {
  count = var.lambda_count

  parent_id   = var.api_root_id
  path_part   = "api${count.index + 201}"
  rest_api_id = var.rest_api_id
}

# resource "aws_api_gateway_method" "get" {
#   count = var.lambda_count

#   rest_api_id   = var.rest_api_id
#   resource_id   = aws_api_gateway_resource.main[count.index].id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_method" "options" {
#   count = var.lambda_count

#   api_key_required     = false
#   authorization        = "NONE"
#   authorization_scopes = []
#   http_method          = "OPTIONS"
#   request_models       = {}
#   request_parameters   = {}
#   resource_id          = aws_api_gateway_resource.main[count.index].id
#   rest_api_id          = var.rest_api_id
# }

# resource "aws_lambda_permission" "get" {
#   count = var.lambda_count

#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.main[count.index].arn
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.rest_api_id}/*/${aws_api_gateway_method.get[count.index].http_method}/api${count.index + 201}"
# }

# resource "aws_api_gateway_integration" "main" {
#   count = var.lambda_count

#   rest_api_id = var.rest_api_id
#   resource_id = aws_api_gateway_resource.main[count.index].id
#   http_method = aws_api_gateway_method.get[count.index].http_method

#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.main[count.index].invoke_arn
# }

# resource "aws_api_gateway_integration" "options" {
#   count = var.lambda_count

#   cache_key_parameters = []
#   cache_namespace      = aws_api_gateway_resource.main[count.index].id
#   connection_type      = "INTERNET"
#   http_method          = "OPTIONS"
#   passthrough_behavior = "WHEN_NO_MATCH"
#   request_parameters   = {}
#   request_templates = {
#     "application/json" = jsonencode(
#       {
#         statusCode = 200
#       }
#     )
#   }
#   resource_id          = aws_api_gateway_resource.main[count.index].id
#   rest_api_id          = var.rest_api_id
#   timeout_milliseconds = 29000
#   type                 = "MOCK"

#   depends_on = [
#     aws_api_gateway_resource.main,
#     aws_api_gateway_method.options
#   ]
# }

# resource "aws_api_gateway_deployment" "main" {
#   rest_api_id = var.rest_api_id

#   depends_on = [
#     aws_api_gateway_integration.main,
#     aws_api_gateway_integration.options,
#   ]
# }

# resource "aws_api_gateway_stage" "main" {
#   cache_cluster_enabled = false
#   deployment_id         = aws_api_gateway_deployment.main.id
#   rest_api_id           = var.rest_api_id
#   stage_name            = var.env
#   tags                  = {}
#   tags_all              = {}
#   variables             = {}
#   xray_tracing_enabled  = false
# }

data "aws_caller_identity" "current" {}

resource "aws_api_gateway_rest_api" "main" {
  api_key_source               = "HEADER"
  binary_media_types           = []
  description                  = var.rest_api_description
  disable_execute_api_endpoint = false
  name                         = var.rest_api_name
  put_rest_api_mode            = "overwrite"
  tags                         = {}
  tags_all                     = {}

  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }
}

resource "aws_api_gateway_resource" "items" {
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = var.rest_api_gateway_resource_path_part
  rest_api_id = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_resource" "items_id" {
  parent_id   = aws_api_gateway_resource.items.id
  path_part   = "{id}"
  rest_api_id = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_authorizer" "cognito" {
  authorizer_result_ttl_in_seconds = 300
  identity_source                  = "method.request.header.Authorization"
  name                             = var.api_gateway_authorizer_name
  provider_arns = [
    aws_cognito_user_pool.main.arn,
  ]
  rest_api_id = aws_api_gateway_rest_api.main.id
  type        = "COGNITO_USER_POOLS"
}

resource "aws_api_gateway_method" "get" {
  api_key_required     = false
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.cognito.id
  authorization_scopes = []
  http_method          = "GET"
  request_models       = {}
  request_parameters   = {}
  resource_id          = aws_api_gateway_resource.items.id
  rest_api_id          = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_method" "put" {
  api_key_required     = false
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.cognito.id
  authorization_scopes = []
  http_method          = "PUT"
  request_models       = {}
  request_parameters   = {}
  resource_id          = aws_api_gateway_resource.items.id
  rest_api_id          = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_method" "options" {
  api_key_required     = false
  authorization        = "NONE"
  authorization_scopes = []
  http_method          = "OPTIONS"
  request_models       = {}
  request_parameters   = {}
  resource_id          = aws_api_gateway_resource.items.id
  rest_api_id          = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_method" "get_id" {
  api_key_required     = false
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.cognito.id
  authorization_scopes = []
  http_method          = "GET"
  request_models       = {}
  request_parameters = {
    "method.request.path.id" = true
  }
  resource_id = aws_api_gateway_resource.items_id.id
  rest_api_id = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_method" "delete_id" {
  api_key_required     = false
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.cognito.id
  authorization_scopes = []
  http_method          = "DELETE"
  request_models       = {}
  request_parameters = {
    "method.request.path.id" = true
  }
  resource_id = aws_api_gateway_resource.items_id.id
  rest_api_id = aws_api_gateway_rest_api.main.id
}

resource "aws_lambda_permission" "get" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.get.http_method}/${var.rest_api_gateway_resource_path_part}"
}

resource "aws_lambda_permission" "put" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.put.http_method}/${var.rest_api_gateway_resource_path_part}"
}

resource "aws_lambda_permission" "get_id" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.get_id.http_method}/${var.rest_api_gateway_resource_path_part}/*"
}

resource "aws_lambda_permission" "delete_id" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.delete_id.http_method}/${var.rest_api_gateway_resource_path_part}/*"
}

resource "aws_api_gateway_integration" "get" {
  cache_key_parameters    = []
  cache_namespace         = aws_api_gateway_resource.items.id
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = "GET"
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters      = {}
  request_templates       = {}
  resource_id             = aws_api_gateway_resource.items.id
  rest_api_id             = aws_api_gateway_rest_api.main.id
  timeout_milliseconds    = 29000
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.main.invoke_arn
}

resource "aws_api_gateway_integration" "put" {
  cache_key_parameters    = []
  cache_namespace         = aws_api_gateway_resource.items.id
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = "PUT"
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters      = {}
  request_templates       = {}
  resource_id             = aws_api_gateway_resource.items.id
  rest_api_id             = aws_api_gateway_rest_api.main.id
  timeout_milliseconds    = 29000
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.main.invoke_arn
}

resource "aws_api_gateway_integration" "get_id" {
  cache_key_parameters    = []
  cache_namespace         = aws_api_gateway_resource.items_id.id
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = "GET"
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters      = {}
  request_templates       = {}
  resource_id             = aws_api_gateway_resource.items_id.id
  rest_api_id             = aws_api_gateway_rest_api.main.id
  timeout_milliseconds    = 29000
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.main.invoke_arn
}

resource "aws_api_gateway_integration" "delete_id" {
  cache_key_parameters    = []
  cache_namespace         = aws_api_gateway_resource.items_id.id
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = "DELETE"
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters      = {}
  request_templates       = {}
  resource_id             = aws_api_gateway_resource.items_id.id
  rest_api_id             = aws_api_gateway_rest_api.main.id
  timeout_milliseconds    = 29000
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.main.invoke_arn
}

resource "aws_api_gateway_integration" "options" {
  cache_key_parameters = []
  cache_namespace      = aws_api_gateway_resource.items.id
  connection_type      = "INTERNET"
  http_method          = "OPTIONS"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_parameters   = {}
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  resource_id          = aws_api_gateway_resource.items.id
  rest_api_id          = aws_api_gateway_rest_api.main.id
  timeout_milliseconds = 29000
  type                 = "MOCK"

  depends_on = [
    aws_api_gateway_resource.items,
    aws_api_gateway_method.options
  ]
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  depends_on = [
    aws_api_gateway_integration.get,
    aws_api_gateway_integration.put,
    aws_api_gateway_integration.get_id,
    aws_api_gateway_integration.delete_id,
    aws_api_gateway_integration.options,
  ]
}

resource "aws_api_gateway_stage" "main" {
  cache_cluster_enabled = false
  deployment_id         = aws_api_gateway_deployment.main.id
  rest_api_id           = aws_api_gateway_rest_api.main.id
  stage_name            = var.env
  tags                  = {}
  tags_all              = {}
  variables             = {}
  xray_tracing_enabled  = false
}

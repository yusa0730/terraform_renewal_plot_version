resource "aws_api_gateway_rest_api" "main" {
  name = "test_lambda_api"
}

resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = ""
}

resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_method" "get_users" {
  rest_api_id          = aws_api_gateway_rest_api.main.id
  resource_id          = aws_api_gateway_resource.users.id
  api_key_required     = false
  authorization        = "NONE"
  authorization_scopes = []
  http_method          = "GET"
  request_models       = {}
  request_parameters   = {}
}

resource "aws_api_gateway_integration" "get_users" {
  cache_key_parameters    = []
  cache_namespace         = aws_api_gateway_resource.users.id
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = aws_api_gateway_method.get_users.http_method
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters      = {}
  request_templates = {
    "application/json" = ""
  }
  resource_id          = aws_api_gateway_resource.users.id
  rest_api_id          = aws_api_gateway_rest_api.main.id
  timeout_milliseconds = 29000
  type                 = "AWS"
  uri                  = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${local.region}:218317313594:function:index2-users-function/invocations"
}

resource "aws_api_gateway_method" "create_users" {
  rest_api_id          = aws_api_gateway_rest_api.main.id
  resource_id          = aws_api_gateway_resource.users.id
  api_key_required     = false
  authorization        = "NONE"
  authorization_scopes = []
  http_method          = "POST"
  request_models       = {}
  request_parameters   = {}
}

resource "aws_api_gateway_integration" "create_users" {
  cache_key_parameters    = []
  cache_namespace         = aws_api_gateway_resource.users.id
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = aws_api_gateway_method.create_users.http_method
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  request_parameters      = {}
  request_templates = {
    "application/json" = <<-EOT
            {
              "id": $input.json('$.id'),
              "FirstName": $input.json('$.FirstName'),
              "LastName": $input.json('$.LastName')
            }
        EOT
  }
  resource_id          = aws_api_gateway_resource.users.id
  rest_api_id          = aws_api_gateway_rest_api.main.id
  timeout_milliseconds = 29000
  type                 = "AWS"
  uri                  = aws_lambda_function.create.invoke_arn
}

resource "aws_api_gateway_method" "option_users" {
  rest_api_id          = aws_api_gateway_rest_api.main.id
  resource_id          = aws_api_gateway_resource.users.id
  api_key_required     = false
  authorization        = "NONE"
  authorization_scopes = []
  http_method          = "OPTIONS"
  request_models       = {}
  request_parameters   = {}
}

resource "aws_api_gateway_integration" "option_users" {
  cache_key_parameters = []
  cache_namespace      = aws_api_gateway_resource.users.id
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
  resource_id          = aws_api_gateway_resource.users.id
  rest_api_id          = aws_api_gateway_rest_api.main.id
  timeout_milliseconds = 29000
  type                 = "MOCK"
}


resource "aws_api_gateway_method_response" "option_users" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.users.id
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  rest_api_id = aws_api_gateway_rest_api.main.id
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "option_users" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.users.id
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = {}
  rest_api_id        = aws_api_gateway_rest_api.main.id
  status_code        = "200"
}

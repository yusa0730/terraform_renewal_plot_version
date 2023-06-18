# resource "aws_lambda_function" "main" {
#   filename         = "./my-lambda-function.zip"
#   function_name    = "example_lambda20230618"
#   role             = aws_iam_role.lambda_role.arn
#   handler          = "index.handler"
#   runtime          = "nodejs14.x"
#   source_code_hash = filebase64sha256("./my-lambda-function.zip")
# }

# resource "aws_lambda_function" "create" {
#   filename         = "create-users-function.zip"
#   source_code_hash = filebase64sha256("./create-users-function")
#   architectures = [
#     "x86_64",
#   ]
#   function_name                  = "create-users-function"
#   handler                        = "index.handler"
#   layers                         = []
#   memory_size                    = 128
#   package_type                   = "Zip"
#   reserved_concurrent_executions = -1
#   role                           = aws_iam_role.lambda_role.arn
#   runtime                        = "nodejs18.x"
#   source_code_size               = 674
#   tags                           = {}
#   tags_all                       = {}
#   timeout                        = 3
#   version                        = "$LATEST"

#   ephemeral_storage {
#     size = 512
#   }

#   timeouts {}

#   tracing_config {
#     mode = "PassThrough"
#   }
# }

# lambda_functionディレクトリで以下のコマンドを実行してlambdaのコードを最新化する
# pip install -r requirements.txt -t .
# zip -r ../lambda_function_payload.zip .
# Lambda function
resource "aws_lambda_function" "main" {
  function_name = "example_lambda"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_role.arn
  filename      = "./lambda_function_payload.zip"
}

# resource "aws_lambda_permission" "apigw" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.main.function_name
#   principal     = "apigateway.amazonaws.com"

#   # The /* part allows invocation from any stage, method and resource path
#   # within API Gateway.
#   source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*"
# }

# lambda_functionディレクトリで以下のコマンドを実行してlambdaのコードを最新化する
# pip install -r requirements.txt -t .
# zip -r ../lambda_function_payload.zip .
# Lambda function
resource "aws_lambda_function" "main" {
  function_name = var.lambda_function_name
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.lambda_role.arn
  filename      = "./lambda_function_payload.zip"
}

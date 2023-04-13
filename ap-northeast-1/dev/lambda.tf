resource "aws_lambda_function" "main" {
  filename         = "./my-lambda-function.zip"
  function_name    = "my-lambda-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  source_code_hash = filebase64sha256("./my-lambda-function.zip")
}



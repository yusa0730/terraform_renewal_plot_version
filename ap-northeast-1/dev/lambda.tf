# lambda_functionディレクトリで以下のコマンドを実行してlambdaのコードを最新化する
# pip install -r requirements.txt -t .
# zip -r ../lambda_function_payload.zip .
# Lambda function
# resource "aws_lambda_function" "main" {
#   function_name = var.lambda_function_name
#   handler       = "lambda_function.lambda_handler"
#   runtime       = "python3.10"
#   role          = aws_iam_role.lambda_role.arn
#   filename      = "./lambda_function_payload.zip"

#   vpc_config {
#     security_group_ids = [
#       aws_security_group.from_api_gateway_to_lambda_sg.id
#     ]
#     subnet_ids = [
#       aws_subnet.lambda_private_a.id
#     ]
#   }
# }

resource "aws_api_gateway_rest_api" "main" {
  api_key_source               = "HEADER"
  binary_media_types           = []
  description                  = var.rest_api_description
  disable_execute_api_endpoint = false
  name                         = "${var.project_name}-${var.env}-rest-api"
  put_rest_api_mode            = "overwrite"
  tags                         = {}
  tags_all                     = {}

  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }
}

module "inside_lambda_and_api" {
  source = "./modules/inside_vpc_lambda"

  lambda_count = var.lambda_count
  image_url    = "${aws_ecr_repository.lambda_ecr.repository_url}:latest"
  iam_role_arn = aws_iam_role.lambda_role.arn
  api_root_id  = aws_api_gateway_rest_api.main.root_resource_id
  rest_api_id  = aws_api_gateway_rest_api.main.id
  env          = var.env
  project_name = var.project_name
  region       = var.region
  security_group_ids = [
    aws_security_group.from_api_gateway_to_lambda_sg.id
  ]
  subnet_ids = [
    aws_subnet.lambda_public_a.id
  ]
  # subnet_ids = [
  #   aws_subnet.lambda_public_a.id,
  #   aws_subnet.lambda_public_c.id
  # ]
}

module "outside_lambda_and_api" {
  source = "./modules/outside_vpc_lambda"

  lambda_count = var.lambda_count
  image_url    = "${aws_ecr_repository.lambda_ecr.repository_url}:latest"
  iam_role_arn = aws_iam_role.lambda_role.arn
  api_root_id  = aws_api_gateway_rest_api.main.root_resource_id
  rest_api_id  = aws_api_gateway_rest_api.main.id
  env          = var.env
  project_name = var.project_name
  region       = var.region
}


# resource "aws_api_gateway_deployment" "main" {
#   rest_api_id = aws_api_gateway_rest_api.main.id

#   depends_on = [
#     module.inside_lambda_and_api,
#     module.outside_lambda_and_api
#   ]
# }

# resource "aws_api_gateway_stage" "main" {
#   cache_cluster_enabled = false
#   deployment_id         = aws_api_gateway_deployment.main.id
#   rest_api_id           = aws_api_gateway_rest_api.main.id
#   stage_name            = var.env
#   tags                  = {}
#   tags_all              = {}
#   variables             = {}
#   xray_tracing_enabled  = false
# }

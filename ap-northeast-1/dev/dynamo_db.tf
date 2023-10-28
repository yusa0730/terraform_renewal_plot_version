resource "aws_dynamodb_table" "main" {
  name         = "${var.project_name}-${var.env}-dynamodb-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-dynamodb-table"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_dynamodb_table_item" "main" {
  table_name = aws_dynamodb_table.main.name
  hash_key   = "id"
  item = jsonencode({
    id = {
      S = "a00000110"
    },
    FirstName = {
      S = "Taro"
    },
    LastName = {
      S = "Jiro"
    }
  })
}

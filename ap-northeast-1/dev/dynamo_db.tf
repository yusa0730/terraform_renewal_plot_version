resource "aws_dynamodb_table" "main" {
  name         = "${local.env}-example-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
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

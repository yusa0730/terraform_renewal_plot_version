resource "aws_cognito_user_pool" "main" {
  auto_verified_attributes = [
    "email",
  ]
  deletion_protection = "ACTIVE"
  mfa_configuration   = "OFF"
  name                = var.cognito_user_pool_name
  tags                = {}
  tags_all            = {}
  username_attributes = [
    "email",
  ]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  email_configuration {
    # https://docs.aws.amazon.com/ja_jp/cognito/latest/developerguide/user-pool-email.html
    # ユーザー招待時などに使用するメールの設定。Cognito(デフォルト) or SES が使用できる。
    # デフォルトだと送信数などに制限があるため、本番で使用する場合は、SESを使用した方がよい。
    email_sending_account = "COGNITO_DEFAULT"
  }

  # 登録するユーザーのパスワードポリシー。
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  # カスタム属性。「schema」は登録するユーザーに求める属性。(メールアドレスや電話番号など)
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = [
      "email",
    ]
  }

  username_configuration {
    # ユーザー名(Email)で大文字小文字を区別しない。
    case_sensitive = false
  }

  # ユーザー登録時の招待メッセージの内容。
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}

resource "aws_cognito_user_pool_client" "public_client" {
  access_token_validity                         = 60
  allowed_oauth_flows                           = []
  allowed_oauth_flows_user_pool_client          = false
  allowed_oauth_scopes                          = []
  auth_session_validity                         = 3
  callback_urls                                 = []
  enable_propagate_additional_user_context_data = false
  enable_token_revocation                       = true
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  id_token_validity             = 60
  logout_urls                   = []
  name                          = "publicClient"
  prevent_user_existence_errors = "ENABLED"
  read_attributes = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
  refresh_token_validity       = 30
  supported_identity_providers = []
  user_pool_id                 = aws_cognito_user_pool.main.id
  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

## Auth API の Authorization Code Grant フローでの呼び出しを行う場合はこちらを利用する
# resource "aws_cognito_user_pool_client" "confidencial_client" {
#   access_token_validity = 60
#   allowed_oauth_flows = [
#     "code",
#   ]
#   allowed_oauth_flows_user_pool_client = true
#   allowed_oauth_scopes = [
#     "openid",
#   ]
#   auth_session_validity = 3
#   callback_urls = [
#     "https://localhost/",
#   ]
#   enable_propagate_additional_user_context_data = false
#   enable_token_revocation                       = true
#   explicit_auth_flows = [
#     "ALLOW_REFRESH_TOKEN_AUTH",
#   ]
#   id_token_validity             = 60
#   logout_urls                   = []
#   name                          = "ConfidentialClient"
#   prevent_user_existence_errors = "ENABLED"
#   read_attributes = [
#     "address",
#     "birthdate",
#     "email",
#     "email_verified",
#     "family_name",
#     "gender",
#     "given_name",
#     "locale",
#     "middle_name",
#     "name",
#     "nickname",
#     "phone_number",
#     "phone_number_verified",
#     "picture",
#     "preferred_username",
#     "profile",
#     "updated_at",
#     "website",
#     "zoneinfo",
#   ]
#   refresh_token_validity = 30
#   supported_identity_providers = [
#     "COGNITO",
#   ]
#   user_pool_id = aws_cognito_user_pool.main.id
#   write_attributes = [
#     "address",
#     "birthdate",
#     "email",
#     "family_name",
#     "gender",
#     "given_name",
#     "locale",
#     "middle_name",
#     "name",
#     "nickname",
#     "phone_number",
#     "picture",
#     "preferred_username",
#     "profile",
#     "updated_at",
#     "website",
#     "zoneinfo",
#   ]

#   token_validity_units {
#     access_token  = "minutes"
#     id_token      = "minutes"
#     refresh_token = "days"
#   }
# }

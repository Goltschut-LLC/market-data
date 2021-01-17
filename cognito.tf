resource "aws_cognito_user_pool" "main_user_pool" {
  name = "main-user-pool"
}

resource "aws_cognito_user_pool_client" "main_user_pool_client" {
  name                                 = "main-user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.main_user_pool.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid"]
  callback_urls                        = ["https://${aws_alb.main_alb.dns_name}/oauth2/idpresponse"]
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "main_user_pool_domain" {
  domain       = "main-user-pool-domain"
  user_pool_id = aws_cognito_user_pool.main_user_pool.id
}

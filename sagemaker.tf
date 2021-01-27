resource "aws_sagemaker_domain" "main" {
  domain_name             = "${var.project_name}-${var.env}-sagemaker"
  auth_mode               = "SSO"
  vpc_id                  = aws_vpc.main_vpc.id
  subnet_ids              = aws_subnet.private_subnets.*.id
  app_network_access_type = "VpcOnly"

  default_user_settings {
    execution_role  = aws_iam_role.sagemaker_role.arn
    security_groups = [aws_security_group.main_sg.id]
  }
}

resource "aws_sagemaker_user_profile" "admin" {
  domain_id                      = aws_sagemaker_domain.main.id
  user_profile_name              = "admin"
  single_sign_on_user_identifier = "UserName"
  single_sign_on_user_value      = var.sso_username

  user_settings {
    execution_role  = aws_iam_role.sagemaker_role.arn
    security_groups = [aws_security_group.main_sg.id]
  }
}

resource "aws_sagemaker_notebook_instance" "main" {
  count                  = var.env == "prod" ? 1 : 0
  name                   = "main"
  role_arn               = aws_iam_role.sagemaker_role.arn
  instance_type          = "ml.t2.medium"
  direct_internet_access = "Disabled"
  subnet_id              = aws_subnet.private_subnets[0].id
  security_groups        = [aws_security_group.main_sg.id]
}

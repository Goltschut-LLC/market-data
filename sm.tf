data "aws_secretsmanager_secret" "rds_secret" {
  name = var.rds_secret_name
}

data "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id = data.aws_secretsmanager_secret.rds_secret.id
}

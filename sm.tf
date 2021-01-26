resource "random_integer" "rds_secret_length" {
  min = 12
  max = 18
}

resource "random_password" "rds_password" {
  length  = random_integer.rds_secret_length.result
  number  = true
  upper   = true
  lower   = true
  special = false
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = var.rds_secret_name
  secret_string = jsonencode({
    "host"     = aws_rds_cluster.rds_cluster.endpoint,
    "user"     = var.rds_username,
    "password" = random_password.rds_password.result,
    "database" = var.rds_database_name
  })
}

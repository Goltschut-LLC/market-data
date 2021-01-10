resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "aurora-cluster"
  engine             = "aurora"
  availability_zones = [
    "${data.aws_region.current.name}a",
    "${data.aws_region.current.name}b",
    "${data.aws_region.current.name}c"
  ]
  db_subnet_group_name = aws_db_subnet_group.private_db_subnet_group.name
  database_name = "market"
  master_username = jsondecode(
    data.aws_secretsmanager_secret_version.rds_secret_value.secret_string
  )["user"]
  master_password = jsondecode(
    data.aws_secretsmanager_secret_version.rds_secret_value.secret_string
  )["password"]
  engine_mode = "serverless"
  scaling_configuration {
    min_capacity = var.rds_min_capacity
    max_capacity = var.rds_max_capacity
  }
  skip_final_snapshot  = true
}

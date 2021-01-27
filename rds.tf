resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "aurora-cluster"
  engine             = "aurora"

  # Max RDS AZ count of 3
  availability_zones     = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_security_group_ids = [aws_security_group.main_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.private_db_subnet_group.name
  database_name          = var.rds_database_name
  master_username        = var.rds_username
  master_password        = random_password.rds_password.result
  engine_mode            = "serverless"
  enable_http_endpoint   = true
  skip_final_snapshot = true
  
  scaling_configuration {
    min_capacity = var.rds_min_capacity
    max_capacity = var.rds_max_capacity
  }

}

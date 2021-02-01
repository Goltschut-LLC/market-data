resource "aws_glue_catalog_database" "glue_catalog_database" {
  name = "main-rds-glue-catalog-database"
}

resource "aws_glue_connection" "rds_glue_connection" {
  name = "main-rds-glue-connection"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://${aws_rds_cluster.rds_cluster.endpoint}:${var.rds_port}/${var.rds_database_name}"
    PASSWORD            = random_password.rds_password.result
    USERNAME            = var.rds_username
  }

  physical_connection_requirements {
    availability_zone      = aws_subnet.private_subnets[0].availability_zone
    security_group_id_list = [aws_security_group.main_sg.id]
    subnet_id              = aws_subnet.private_subnets[0].id
  }
}

resource "aws_glue_connection" "s3_glue_connection" {
  name            = "main-s3-glue-connection"
  connection_type = "NETWORK"

  connection_properties = {
    VPC             = aws_vpc.main_vpc.id
    SUBNET          = aws_subnet.private_subnets[0].id
    SECURITY_GROUPS = aws_security_group.main_sg.id
  }

  physical_connection_requirements {
    availability_zone      = aws_subnet.private_subnets[0].availability_zone
    security_group_id_list = [aws_security_group.main_sg.id]
    subnet_id              = aws_subnet.private_subnets[0].id
  }
}

resource "aws_glue_crawler" "glue_crawler" {
  database_name = aws_glue_catalog_database.glue_catalog_database.name
  name          = "main-rds-glue-crawler"
  role          = aws_iam_role.glue_role.arn

  jdbc_target {
    connection_name = aws_glue_connection.rds_glue_connection.name
    path            = "${var.rds_database_name}/%"
  }
}

resource "aws_s3_bucket_object" "export_daily_ohlcv_full" {
  bucket = aws_s3_bucket.glue.id
  key    = "glue-scripts/export_daily_ohlcv_full.py"
  content = templatefile("${path.module}/templates/export_daily_ohlcv_full.tpl", { ENV = var.env })
}


resource "aws_glue_job" "export_daily_ohlcv_full" {
  name     = "export-daily-ohlcv-full"
  role_arn = aws_iam_role.glue_role.arn
  glue_version = "2.0"
  max_retries = 3

  connections = [
    aws_glue_connection.rds_glue_connection.name,
    aws_glue_connection.s3_glue_connection.name
  ]

  command {
    script_location = "s3://${aws_s3_bucket.glue.bucket}/${aws_s3_bucket_object.export_daily_ohlcv_full.key}"
  }
}

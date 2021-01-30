resource "aws_glue_connection" "glue_connection" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://${aws_rds_cluster.rds_cluster.endpoint}/exampledatabase"
    PASSWORD            = random_password.rds_password.result
    USERNAME            = var.rds_username
  }

  name = "rds-main"

  physical_connection_requirements {
    availability_zone      = aws_subnet.private_subnets[0].availability_zone
    security_group_id_list = [aws_security_group.main_sg.id]
    subnet_id              = aws_subnet.private_subnets[0].id
  }
}

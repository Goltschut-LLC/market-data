resource "aws_lambda_function" "lambda_function" {
  filename = "./lambdas/ingest-historical-data/dist/ingest-historical-data.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/ingest-historical-data/dist/ingest-historical-data.zip"
  )
  function_name = "ingest-historical-data"
  handler       = "index.handler"
  role          = aws_iam_role.ingest_historical_data_lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 30

  environment {
    variables = {
      REGION             = data.aws_region.current.name
      ALPACA_SECRET_NAME = var.alpaca_secret_name
      RDS_SECRET_NAME    = var.rds_secret_name
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets.*.id
    security_group_ids = [aws_security_group.main_sg.id]
  }
}

resource "aws_lambda_function" "create_tables_lambda_function" {
  filename = "./lambdas/create-tables/dist/create-tables.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/create-tables/dist/create-tables.zip"
  )
  function_name = "create-tables"
  handler       = "index.handler"
  role          = aws_iam_role.rds_vpc_lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 30

  environment {
    variables = {
      REGION             = data.aws_region.current.name
      RDS_SECRET_NAME    = var.rds_secret_name
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets.*.id
    security_group_ids = [aws_security_group.main_sg.id]
  }
}

resource "aws_lambda_function" "ingest_symbols_lambda_function" {
  filename = "./lambdas/ingest-symbols/dist/ingest-symbols.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/ingest-symbols/dist/ingest-symbols.zip"
  )
  function_name = "ingest-symbols"
  handler       = "index.handler"
  role          = aws_iam_role.rds_vpc_lambda_role.arn
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

resource "aws_lambda_function" "ingest_aggregate_observations_lambda_function" {
  filename = "./lambdas/ingest-aggregate-observations/dist/ingest-aggregate-observations.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/ingest-aggregate-observations/dist/ingest-aggregate-observations.zip"
  )
  function_name = "ingest-aggregate-observations"
  handler       = "index.handler"
  role          = aws_iam_role.rds_vpc_lambda_role.arn
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

resource "aws_lambda_function" "get_symbols_lambda_function" {
  filename = "./lambdas/get-symbols/dist/get-symbols.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/get-symbols/dist/get-symbols.zip"
  )
  function_name = "get-symbols"
  handler       = "index.handler"
  role          = aws_iam_role.rds_vpc_lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 30

  environment {
    variables = {
      REGION             = data.aws_region.current.name
      RDS_SECRET_NAME    = var.rds_secret_name
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets.*.id
    security_group_ids = [aws_security_group.main_sg.id]
  }
}

resource "aws_lambda_function" "get_initialize_symbol_payloads_lambda_function" {
  filename = "./lambdas/get-initialize-symbol-payloads/dist/get-initialize-symbol-payloads.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/get-initialize-symbol-payloads/dist/get-initialize-symbol-payloads.zip"
  )
  function_name = "get-initialize-symbol-payloads"
  handler       = "index.handler"
  role          = aws_iam_role.rds_vpc_lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 30

  environment {
    variables = {
      REGION             = data.aws_region.current.name
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets.*.id
    security_group_ids = [aws_security_group.main_sg.id]
  }
}

# REALLY shouldn't have a passthrough query option
resource "aws_lambda_function" "delete_me_lambda_function" {
  filename = "./lambdas/delete-me/dist/delete-me.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/delete-me/dist/delete-me.zip"
  )
  function_name = "delete-me"
  handler       = "index.handler"
  role          = aws_iam_role.rds_vpc_lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 30

  environment {
    variables = {
      REGION             = data.aws_region.current.name
      RDS_SECRET_NAME    = var.rds_secret_name
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets.*.id
    security_group_ids = [aws_security_group.main_sg.id]
  }
}

resource "aws_lambda_function" "create_tables_lambda_function" {
  filename = "./lambdas/create-tables/dist/create-tables.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/create-tables/dist/create-tables.zip"
  )
  function_name = "create-tables"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 30

  environment {
    variables = {
      REGION          = data.aws_region.current.name
      RDS_SECRET_NAME = var.rds_secret_name
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
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 900

  environment {
    variables = {
      ENV                = var.env
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

resource "aws_lambda_function" "ingest_daily_ohlcv_lambda_function" {
  filename = "./lambdas/ingest-daily-ohlcv/dist/ingest-daily-ohlcv.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/ingest-daily-ohlcv/dist/ingest-daily-ohlcv.zip"
  )
  function_name = "ingest-daily-ohlcv"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 30

  environment {
    variables = {
      ENV                = var.env
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
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 30

  environment {
    variables = {
      ENV             = var.env
      REGION          = data.aws_region.current.name
      RDS_SECRET_NAME = var.rds_secret_name
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets.*.id
    security_group_ids = [aws_security_group.main_sg.id]
  }
}

resource "aws_lambda_function" "batch_symbols_lambda_function" {
  filename = "./lambdas/batch-symbols/dist/batch-symbols.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/batch-symbols/dist/batch-symbols.zip"
  )
  function_name = "batch-symbols"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 30

  environment {
    variables = {
      REGION = data.aws_region.current.name
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
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 30

  environment {
    variables = {
      REGION = data.aws_region.current.name
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets.*.id
    security_group_ids = [aws_security_group.main_sg.id]
  }
}

resource "aws_lambda_function" "get_update_symbol_payload_lambda_function" {
  filename = "./lambdas/get-update-symbol-payload/dist/get-update-symbol-payload.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/get-update-symbol-payload/dist/get-update-symbol-payload.zip"
  )
  function_name = "get-update-symbol-payload"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs12.x"
  timeout       = 30

  environment {
    variables = {
      REGION = data.aws_region.current.name
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets.*.id
    security_group_ids = [aws_security_group.main_sg.id]
  }
}

resource "aws_lambda_function" "create_prediction_lambda_function" {
  function_name = "create-prediction"
  package_type  = "Image"
  role          = aws_iam_role.lambda_role.arn
  image_uri     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/create-prediction:latest"

  timeout     = 900
  memory_size = 512
  environment {
    variables = {
      REGION         = data.aws_region.current.name
      EXPORTS_BUCKET = aws_s3_bucket.glue.bucket
      PUBLIC_BUCKET  = aws_s3_bucket.public.bucket
    }
  }
}

terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  region = var.region
}

#################################################################################################
# Consts
#   Calling special attention here due to hardcoded nature of values
#################################################################################################

locals {
  alpaca_secret_name = "alpaca"
  rds_secret_name    = "rds"
}

#################################################################################################
# AWS Defaults
#   Default resources behave differently than normal resources, in that Terraform 
#   does not create this resource, but instead "adopts" it into management
#################################################################################################

resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "default_az_a" {
  availability_zone = "${data.aws_region.current.name}a"
}

resource "aws_default_subnet" "default_az_b" {
  availability_zone = "${data.aws_region.current.name}b"
}

resource "aws_default_subnet" "default_az_c" {
  availability_zone = "${data.aws_region.current.name}c"
}

resource "aws_default_subnet" "default_az_d" {
  availability_zone = "${data.aws_region.current.name}d"
}

resource "aws_default_subnet" "default_az_e" {
  availability_zone = "${data.aws_region.current.name}e"
}

resource "aws_default_subnet" "default_az_f" {
  availability_zone = "${data.aws_region.current.name}f"
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_default_vpc.default_vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#################################################################################################
# Database
#################################################################################################

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "aurora-cluster"
  engine             = "aurora"
  availability_zones = [
    "${data.aws_region.current.name}a",
    "${data.aws_region.current.name}b",
    "${data.aws_region.current.name}c"
  ]
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
}

#################################################################################################
# Networking
#################################################################################################

resource "aws_vpc_endpoint" "secrets_manager_vpc_endpoint" {
  vpc_id = aws_default_vpc.default_vpc.id
  subnet_ids = [
    aws_default_subnet.default_az_a.id,
    aws_default_subnet.default_az_b.id,
    aws_default_subnet.default_az_c.id
  ]
  service_name      = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_default_security_group.default_sg.id,
  ]

  private_dns_enabled = true
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_default_subnet.default_az_d.id
}

resource "aws_route_table" "nat_gateway_route_table" {
  vpc_id = aws_default_vpc.default_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "route_association_a" {
  subnet_id      = aws_default_subnet.default_az_a.id
  route_table_id = aws_route_table.nat_gateway_route_table_a.id
}

resource "aws_route_table_association" "route_association_b" {
  subnet_id      = aws_default_subnet.default_az_b.id
  route_table_id = aws_route_table.nat_gateway_route_table_b.id
}

resource "aws_route_table_association" "route_association_c" {
  subnet_id      = aws_default_subnet.default_az_c.id
  route_table_id = aws_route_table.nat_gateway_route_table_c.id
}

#################################################################################################
# Lambda
#################################################################################################

resource "aws_iam_policy" "ingest_historical_data_lambda_iam_policy" {
  name   = "ingest-historical-data-lambda-policy"
  policy = data.aws_iam_policy_document.ingest_historical_data_lambda_iam_policy.json
}

resource "aws_iam_role" "ingest_historical_data_lambda_role" {
  name               = "ingest-historical-data-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_policy_attachment" "ingest_historical_data_lambda_iam_policy_role_attachment" {
  name       = "ingest-historical-data-lambda-policy-attachment"
  roles      = [aws_iam_role.ingest_historical_data_lambda_role.name]
  policy_arn = aws_iam_policy.ingest_historical_data_lambda_iam_policy.arn
}

resource "aws_lambda_function" "lambda_function" {
  filename = "./lambdas/ingest-historical-data/dist/ingest-historical-data.zip"
  source_code_hash = filebase64sha256(
    "./lambdas/ingest-historical-data/dist/ingest-historical-data.zip"
  )
  function_name = "ingest-historical-data"
  handler       = "index.handler"
  role          = aws_iam_role.ingest_historical_data_lambda_role.arn
  runtime       = "nodejs12.x"

  environment {
    variables = {
      REGION             = data.aws_region.current.name
      ALPACA_SECRET_NAME = local.alpaca_secret_name
      RDS_SECRET_NAME    = local.rds_secret_name
    }
  }

  vpc_config {
    subnet_ids = [
      aws_default_subnet.default_az_a.id,
      aws_default_subnet.default_az_b.id,
      aws_default_subnet.default_az_c.id
    ]
    security_group_ids = [aws_default_security_group.default_sg.id]
  }
}

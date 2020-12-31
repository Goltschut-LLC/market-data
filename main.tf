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
  region = "us-east-1"
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
  service_name      = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_default_security_group.default_sg.id,
  ]

  private_dns_enabled = true
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
  filename      = "./lambdas/ingest-historical-data/ingest-historical-data.zip"
  function_name = "ingest-historical-data"
  handler       = "index.handler"
  role          = aws_iam_role.ingest_historical_data_lambda_role.arn
  runtime       = "nodejs12.x"

  environment {
    variables = {
      test = "value"
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

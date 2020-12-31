##################################################################################
# General
##################################################################################

data "aws_region" "current" {}

##################################################################################
# Networking
##################################################################################

data "aws_vpc_endpoint_service" "secretsmanager" {
  service = "secretsmanager"
}

##################################################################################
# Secrets Manager
##################################################################################

data "aws_secretsmanager_secret" "rds_secret" {
  name = "rds"
}

data "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id = data.aws_secretsmanager_secret.rds_secret.id
}

##################################################################################
# Lambda IAM
##################################################################################

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ingest_historical_data_lambda_iam_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "logs:*",
      "rds:*",
      "ec2:*",
      "secretsmanager:*",
    ]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy" "AWSLambdaVPCAccessExecutionRole" {
  arn = "arn:aws:iam::aws:policy/AWSLambdaVPCAccessExecutionRole"
}

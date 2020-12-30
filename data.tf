##################################################################################
# General
##################################################################################

data "aws_region" "current" {}

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

data "aws_iam_policy_document" "lambda_iam_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "logs:*",
      "rds:*",
      "ec2:*",
    ]
    resources = [
      "*",
    ]
  }
}

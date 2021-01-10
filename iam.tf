##################################################################################
# Lambda
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

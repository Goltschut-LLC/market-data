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

data "aws_iam_policy_document" "rds_vpc_lambda_iam_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "logs:*",
      "rds:*",
      "ec2:*",
      "secretsmanager:*"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "rds_vpc_lambda_iam_policy" {
  name   = "rds-vpc-lambda-policy"
  policy = data.aws_iam_policy_document.rds_vpc_lambda_iam_policy.json
}

resource "aws_iam_role" "rds_vpc_lambda_role" {
  name               = "rds-vpc-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_policy_attachment" "rds_vpc_lambda_iam_policy_role_attachment" {
  name       = "rds-vpc-lambda-policy-attachment"
  roles      = [aws_iam_role.rds_vpc_lambda_role.name]
  policy_arn = aws_iam_policy.rds_vpc_lambda_iam_policy.arn
}

##################################################################################
# ECS
##################################################################################

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs_iam_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_iam_policy_role_attachment" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = data.aws_iam_policy.ecs_iam_policy.arn
}

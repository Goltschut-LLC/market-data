##################################################################################
# SFN
##################################################################################

data "aws_iam_policy_document" "sfn_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sfn_iam_policy" {
  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "lambda:InvokeFunction",
      "states:StartExecution",
      "states:DescribeExecution",
      "states:StopExecution",
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "sfn_iam_policy" {
  name   = "sfn-policy"
  policy = data.aws_iam_policy_document.sfn_iam_policy.json
}

resource "aws_iam_role" "sfn_role" {
  name               = "sfn-role"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "sfn_role_attachment" {
  role       = aws_iam_role.sfn_role.name
  policy_arn = aws_iam_policy.sfn_iam_policy.arn
}

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

data "aws_iam_policy_document" "lambda_iam_policy" {
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

resource "aws_iam_policy" "lambda_iam_policy" {
  name   = "lambda-policy"
  policy = data.aws_iam_policy_document.lambda_iam_policy.json
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_policy_attachment" "lambda_iam_policy_role_attachment" {
  name       = "lambda-policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
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

##################################################################################
# CW
##################################################################################

data "aws_iam_policy_document" "cw_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cw_iam_policy" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "cw_iam_policy" {
  name   = "cw-iam-policy"
  policy = data.aws_iam_policy_document.cw_iam_policy.json
}

resource "aws_iam_role" "cw_role" {
  name               = "cw-role"
  assume_role_policy = data.aws_iam_policy_document.cw_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "cw_iam_policy_role_attachment" {
  role       = aws_iam_role.cw_role.name
  policy_arn = aws_iam_policy.cw_iam_policy.arn
}

##################################################################################
# Sagemaker
##################################################################################

data "aws_iam_policy_document" "sagemaker_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "sagemaker_managed_iam_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

data "aws_iam_policy_document" "sagemaker_iam_policy" {
  statement {
    effect= "Allow"
    actions= [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "sagemaker_iam_policy" {
  name   = "sagemaker-iam-policy"
  policy = data.aws_iam_policy_document.sagemaker_iam_policy.json
}

resource "aws_iam_role" "sagemaker_role" {
  name               = "sagemaker-role"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "sagemaker_managed_iam_policy_role_attachment" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = data.aws_iam_policy.sagemaker_managed_iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_iam_policy_role_attachment" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = aws_iam_policy.sagemaker_iam_policy.arn
}

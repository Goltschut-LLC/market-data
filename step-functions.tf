resource "aws_sfn_state_machine" "initialize_environment_sfn" {
  name     = "initialize-environment"
  role_arn = aws_iam_role.lambda_xray_sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/initialize-environment.tpl",
    { 
      RETRY_INTERVAL_SECONDS = 2, 
      MAX_ATTEMPTS = 2,
      BACKOFF_RATE = 2
    }
  )
}

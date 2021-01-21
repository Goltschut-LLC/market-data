resource "aws_sfn_state_machine" "initialize_environment_sfn" {
  name     = "initialize-environment"
  role_arn = aws_iam_role.lambda_xray_sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/initialize-environment.tpl",
    {
      RETRY_INTERVAL_SECONDS = 2,
      MAX_ATTEMPTS           = 2,
      BACKOFF_RATE           = 2,
      HANDLE_JOB_BATCH_SFN_ARN = aws_sfn_state_machine.handle_job_batch_sfn.arn
    }
  )
}

resource "aws_sfn_state_machine" "handle_job_batch_sfn" {
  name     = "handle-job-batch"
  role_arn = aws_iam_role.lambda_xray_sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/handle-job-batch.tpl",
    {
      RETRY_INTERVAL_SECONDS = 5,
      MAX_ATTEMPTS           = 2,
      BACKOFF_RATE           = 2,
      INITIALIZE_SYMBOL_SFN_ARN = aws_sfn_state_machine.initialize_symbol_sfn.arn
    }
  )
}

resource "aws_sfn_state_machine" "initialize_symbol_sfn" {
  name     = "initialize-symbol"
  role_arn = aws_iam_role.lambda_xray_sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/initialize-symbol.tpl",
    {
      RETRY_INTERVAL_SECONDS = 5,
      MAX_ATTEMPTS           = 2,
      BACKOFF_RATE           = 2
    }
  )
}

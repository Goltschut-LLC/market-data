resource "aws_sfn_state_machine" "initialize_environment_sfn" {
  name     = "initialize-environment"
  role_arn = aws_iam_role.sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/initialize-environment.tpl",
    {
      RETRY_INTERVAL_SECONDS   = 2,
      MAX_ATTEMPTS             = 2,
      BACKOFF_RATE             = 2,
      INITIALIZE_BATCH_SFN_ARN = aws_sfn_state_machine.initialize_batch_sfn.arn
    }
  )
}

resource "aws_sfn_state_machine" "backfill_inactive_symbols_sfn" {
  name     = "backfill-inactive-symbols"
  role_arn = aws_iam_role.sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/backfill-inactive-symbols.tpl",
    {
      RETRY_INTERVAL_SECONDS   = 2,
      MAX_ATTEMPTS             = 2,
      BACKOFF_RATE             = 2,
      INITIALIZE_BATCH_SFN_ARN = aws_sfn_state_machine.initialize_batch_sfn.arn
    }
  )
}

resource "aws_sfn_state_machine" "initialize_batch_sfn" {
  name     = "initialize-batch"
  role_arn = aws_iam_role.sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/initialize-batch.tpl",
    {
      RETRY_INTERVAL_SECONDS    = 5,
      MAX_ATTEMPTS              = 2,
      BACKOFF_RATE              = 2,
      INITIALIZE_SYMBOL_SFN_ARN = aws_sfn_state_machine.initialize_symbol_sfn.arn
    }
  )
}

resource "aws_sfn_state_machine" "initialize_symbol_sfn" {
  name     = "initialize-symbol"
  role_arn = aws_iam_role.sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/initialize-symbol.tpl",
    {
      RETRY_INTERVAL_SECONDS = 5,
      MAX_ATTEMPTS           = 2,
      BACKOFF_RATE           = 2
    }
  )
}

resource "aws_sfn_state_machine" "update_environment_sfn" {
  name     = "update-environment"
  role_arn = aws_iam_role.sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/update-environment.tpl",
    {
      RETRY_INTERVAL_SECONDS           = 10,
      MAX_ATTEMPTS                     = 6,
      BACKOFF_RATE                     = 1,
      UPDATE_BATCH_SFN_ARN             = aws_sfn_state_machine.update_batch_sfn.arn
      EXPORT_DAILY_OHLCV_GLUE_JOB_NAME = aws_glue_job.export_daily_ohlcv_full.id
      BATCH_CREATE_PREDICTIONS_SFN_ARN = aws_sfn_state_machine.batch_create_predictions_sfn.arn
    }
  )
}

resource "aws_sfn_state_machine" "update_batch_sfn" {
  name     = "update-batch"
  role_arn = aws_iam_role.sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/update-batch.tpl",
    {
      RETRY_INTERVAL_SECONDS = 5,
      MAX_ATTEMPTS           = 2,
      BACKOFF_RATE           = 2,
      UPDATE_SYMBOL_SFN_ARN  = aws_sfn_state_machine.update_symbol_sfn.arn
    }
  )
}

resource "aws_sfn_state_machine" "update_symbol_sfn" {
  name     = "update-symbol"
  role_arn = aws_iam_role.sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/update-symbol.tpl",
    {
      RETRY_INTERVAL_SECONDS = 5,
      MAX_ATTEMPTS           = 2,
      BACKOFF_RATE           = 2
    }
  )
}

resource "aws_sfn_state_machine" "create_predictions_sfn" {
  name     = "create-predictions"
  role_arn = aws_iam_role.sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/create-predictions.tpl",
    {
      RETRY_INTERVAL_SECONDS = 3,
      MAX_ATTEMPTS           = 3,
      BACKOFF_RATE           = 2
    }
  )
}

resource "aws_sfn_state_machine" "batch_create_predictions_sfn" {
  name     = "batch-create-predictions"
  role_arn = aws_iam_role.sfn_role.arn

  definition = templatefile(
    "${path.module}/templates/batch-create-predictions.tpl",
    {
      RETRY_INTERVAL_SECONDS     = 5,
      MAX_ATTEMPTS               = 2,
      BACKOFF_RATE               = 2,
      CREATE_PREDICTIONS_SFN_ARN = aws_sfn_state_machine.create_predictions_sfn.arn
    }
  )
}

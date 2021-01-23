resource "aws_cloudwatch_log_group" "main_ecs_cw_log_group" {
  name = "/ecs/main"
}

resource "aws_cloudwatch_event_rule" "weekday_night_trigger" {
  name = "weekday-night-trigger"
  # 23:00 UTC (two hours after market close), Monday through Friday.
  schedule_expression = "cron(0 23 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "update_environment_sfn_target" {
  count = var.env == "prod" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.weekday_night_trigger.name
  target_id = "update-environment-sfn"
  arn       = aws_sfn_state_machine.update_environment_sfn.arn
  role_arn = aws_iam_role.sfn_cw_role.arn
}

{
  "StartAt": "Get Update Symbol Payload",
    "States": {
      "Get Update Symbol Payload": {
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": "get-update-symbol-payload:$LATEST",
          "Payload": {
            "Input.$": "$.symbol"
          }
        },
        "Retry": [
          {
            "Comment": "Retry function after an error occurs.",
            "ErrorEquals": [
              "States.ALL"
            ],
            "IntervalSeconds": ${RETRY_INTERVAL_SECONDS},
            "MaxAttempts": ${MAX_ATTEMPTS},
            "BackoffRate": ${BACKOFF_RATE}
          }
        ],
        "Next": "Update Symbol"
      },
      "Update Symbol": {
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": "ingest-daily-ohlcv:$LATEST",
          "Payload": {
            "Input.$": "$.Payload"
          }
        },
        "Retry": [
          {
            "Comment": "Retry function after an error occurs.",
            "ErrorEquals": [
              "States.ALL"
            ],
            "IntervalSeconds": ${RETRY_INTERVAL_SECONDS},
            "MaxAttempts": ${MAX_ATTEMPTS},
            "BackoffRate": ${BACKOFF_RATE}
          }
        ],
        "Next": "Wait One Minute"
      },
      "Wait One Minute": {
        "Type": "Wait",
        "Seconds": 60,
        "End": true
      }
    }
}
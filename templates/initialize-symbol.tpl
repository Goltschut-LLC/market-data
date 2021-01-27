{
  "StartAt": "Get Initialize Symbol Payloads",
    "States": {
      "Get Initialize Symbol Payloads": {
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": "get-initialize-symbol-payloads:$LATEST",
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
        "Next": "Initialize Symbol"
      },
      "Initialize Symbol": {
        "Type": "Map",
        "InputPath": "$.Payload",
        "ItemsPath": "$.payloads",
        "MaxConcurrency": 0,
        "Iterator": {
          "StartAt": "Ingest Historical Data",
          "States": {
            "Ingest Historical Data": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "ingest-daily-ohlcv:$LATEST",
                "Payload": {
                  "Input.$": "$"
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
              "End": true
            }
          }
        },
        "Next": "Wait One Minute"
      },
      "Wait One Minute": {
        "Type": "Wait",
        "Seconds": 60,
        "End": true
      }
    }
}
{
  "StartAt": "Ingest Symbols",
  "States": {
    "Ingest Symbols": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "ingest-symbols:$LATEST",
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
      "Catch": [
        {
          "Comment": "Catch errors and revert to fallback states.",
          "ResultPath": "$.error-info",
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Fallback"
        }
      ],
      "Next": "Get Inactive NYSE and NASDAQ Symbols"
    },
    "Get Inactive NYSE and NASDAQ Symbols": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "get-symbols:$LATEST",
        "Payload": {
          "statuses": ["inactive"]
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
      "Catch": [
        {
          "Comment": "Catch errors and revert to fallback states.",
          "ResultPath": "$.error-info",
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Fallback"
        }
      ],
      "Next": "Batch Symbols"
    },
    "Batch Symbols": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "batch-symbols:$LATEST",
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
      "Catch": [
        {
          "Comment": "Catch errors and revert to fallback states.",
          "ResultPath": "$.error-info",
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Fallback"
        }
      ],
      "Next": "Initialize Batches"
    },
    "Initialize Batches": {
      "Type": "Map",
      "InputPath": "$.Payload",
      "ItemsPath": "$.batches",
      "MaxConcurrency": 0,
      "Iterator": {
        "StartAt": "Initialize Batch",
        "States": {
          "Initialize Batch": {
            "Type": "Task",
            "Resource": "arn:aws:states:::states:startExecution.sync",
            "Parameters": {
              "StateMachineArn": "${INITIALIZE_BATCH_SFN_ARN}",
              "Input": {
                "symbols.$": "$"
              }
            },
            "End": true
          }
        }
      },
      "End": true
    },
    "Fallback": {
      "Type": "Fail",
      "Cause": "Environment initialization did not succeed."
    }
  }
}
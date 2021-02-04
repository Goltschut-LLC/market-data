{
  "StartAt": "Get Active NYSE and NASDAQ Symbols",
  "States": {
    "Get Active NYSE and NASDAQ Symbols": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "get-symbols:$LATEST",
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
      "Next": "Create Predictions for Batches"
    },
    "Create Predictions for Batches": {
      "Type": "Map",
      "InputPath": "$.Payload",
      "ItemsPath": "$.batches",
      "MaxConcurrency": 0,
      "Iterator": {
        "StartAt": "Create Predictions for Batch",
        "States": {
          "Create Predictions for Batch": {
            "Type": "Task",
            "Resource": "arn:aws:states:::states:startExecution.sync",
            "Parameters": {
              "StateMachineArn": "${CREATE_PREDICTIONS_SFN_ARN}",
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
      "Cause": "Create predictions did not succeed."
    }
  }
}
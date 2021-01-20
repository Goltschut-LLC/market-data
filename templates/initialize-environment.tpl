{
  "StartAt": "Create Tables",
  "States": {
    "Create Tables": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "create-tables:$LATEST",
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
      "Next": "Ingest Symbols"
    },
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
      "Next": "Get Active NYSE and NASDAQ Symbols"
    },
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
      "Next": "Initialize Symbols"
    },
    "Initialize Symbols": {
      "Type": "Map",
      "InputPath": "$.Payload",
      "ItemsPath": "$.symbols",
      "MaxConcurrency": 10,
      "Iterator": {
        "StartAt": "Initialize Symbol",
        "States": {
            "Initialize Symbol": {
              "Type": "Task",
              "Resource": "arn:aws:states:::states:startExecution.sync",
              "Parameters": {
                "StateMachineArn": "${INITIALIZE_SYMBOL_SFN_ARN}",
                "Input": {
                  "symbol.$": "$"
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
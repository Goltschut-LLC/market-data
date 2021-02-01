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
      "Next": "Create Predictions"
    },
    "Create Predictions": {
      "Type": "Map",
      "InputPath": "$.Payload",
      "ItemsPath": "$.symbols",
      "MaxConcurrency": 0,
      "Iterator": {
        "StartAt": "Create Prediction",
        "States": {
          "Create Prediction": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "create-prediction:$LATEST",
                "Payload": {
                  "Input.$": "$"
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
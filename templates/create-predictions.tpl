{
  "StartAt": "Create Predictions",
    "States": {
      "Create Predictions": {
        "Type": "Map",
        "ItemsPath": "$.symbols",
        "MaxConcurrency": 100,
        "ResultPath": "$",
        "Iterator": {
          "StartAt": "Create Prediction",
          "States": {
            "Create Prediction": {
                "Type": "Task",
                "Resource": "arn:aws:states:::lambda:invoke",
                "ResultSelector": {
                  "prediction.$": "$.Payload.prediction",
                  "symbol.$": "$.Payload.symbol"
                },
                "Parameters": {
                  "FunctionName": "create-prediction:$LATEST",
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
        "End": true
      }
    }
}
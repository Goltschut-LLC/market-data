{
  "Comment": "Create tables, and ingest all available historical U.S. stock market data.",
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
        "StartAt": "Get Initialize Symbol Payloads",
        "States": {
          "Get Initialize Symbol Payloads": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "Parameters": {
              "FunctionName": "get-initialize-symbol-payloads:$LATEST",
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
                    "FunctionName": "ingest-aggregate-observations:$LATEST",
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
      },
      "End": true
    },
    "Fallback": {
      "Type": "Fail",
      "Cause": "Environment initialization did not succeed."
    }
  }
}
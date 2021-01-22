{
  "StartAt": "Initialize Symbols",
    "States": {
      "Initialize Symbols": {
        "Type": "Map",
        "ItemsPath": "$.symbols",
        "ResultPath": null,
        "MaxConcurrency": 1,
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
      }
    }
}
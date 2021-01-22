{
  "StartAt": "Update Symbols",
    "States": {
      "Update Symbols": {
        "Type": "Map",
        "ItemsPath": "$.symbols",
        "ResultPath": null,
        "MaxConcurrency": 5,
        "Iterator": {
          "StartAt": "Update Symbol",
          "States": {
            "Update Symbol": {
              "Type": "Task",
              "Resource": "arn:aws:states:::states:startExecution.sync",
              "Parameters": {
                "StateMachineArn": "${UPDATE_SYMBOL_SFN_ARN}",
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
resource "aws_sfn_state_machine" "handle_image_valuation_request_state_machine" {
  name     = "handle-image-valuation-request"
  role_arn = aws_iam_role.handle_valuation_request_role.arn

  definition = <<EOF
{
  "Comment": "Responsible for facilitating the valuation process",
  "StartAt": "GV Request",
  "States": {
    "GV Request": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "gv-request:$LATEST",
        "Payload": {
          "Input.$": "$"
        }
      },
      "Retry": [
        {
          "Comment": "Retry function after an error occurs.",
          "ErrorEquals": [
            "Lambda.Unknown",
            "Lambda.ServiceException",
            "Lambda.TooManyRequestsException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Catch": [
        {
          "Comment": "Catch errors and revert to fallback states.",
          "ResultPath": "$.error-info",
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Fallback State 1 - Update Request Stage - FAILED"
        }
      ],
      "Next": "Handle GV Result"
    },
    "Handle GV Result": {
      "Type": "Parallel",
      "End": true,
      "Branches": [
        {
          "StartAt": "Save GV Result",
          "States": {
            "Save GV Result": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "save-gv-result:$LATEST",
                "Payload": {
                  "Input.$": "$"
                }
              },
              "Retry": [
                {
                  "Comment": "Retry function after an error occurs.",
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.TooManyRequestsException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "End": true
            }
          }
        },
        {
          "StartAt": "Parse GV Result",
          "States": {
            "Parse GV Result": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "parse-gv-result:$LATEST",
                "Payload": {
                  "Input.$": "$"
                }
              },
              "Retry": [
                {
                  "Comment": "Retry function after an error occurs.",
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.TooManyRequestsException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "Catch": [
                {
                  "Comment": "Catch errors and revert to fallback states.",
                  "ResultPath": "$.error-info",
                  "ErrorEquals": [
                    "States.ALL"
                  ],
                  "Next": "Fallback State 2 - Update Request Stage - FAILED"
                }
              ],
              "Next": "Ebay Search"
            },
            "Ebay Search": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "ebay-search:$LATEST",
                "Payload": {
                  "Input.$": "$"
                }
              },
              "Retry": [
                {
                  "Comment": "Retry function after an error occurs.",
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.TooManyRequestsException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "Catch": [
                {
                  "Comment": "Catch errors and revert to fallback states.",
                  "ResultPath": "$.error-info",
                  "ErrorEquals": [
                    "States.ALL"
                  ],
                  "Next": "Fallback State 2 - Update Request Stage - FAILED"
                }
              ],
              "Next": "Handle Ebay Result"
            },
            "Handle Ebay Result": {
              "Type": "Parallel",
              "End": true,
              "Branches": [
                {
                  "StartAt": "Save Ebay Result",
                  "States": {
                    "Save Ebay Result": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::lambda:invoke",
                      "Parameters": {
                        "FunctionName": "save-ebay-result:$LATEST",
                        "Payload": {
                          "Input.$": "$"
                        }
                      },
                      "Retry": [
                        {
                          "Comment": "Retry function after an error occurs.",
                          "ErrorEquals": [
                            "Lambda.ServiceException",
                            "Lambda.TooManyRequestsException",
                            "Lambda.AWSLambdaException",
                            "Lambda.SdkClientException"
                          ],
                          "IntervalSeconds": 2,
                          "MaxAttempts": 6,
                          "BackoffRate": 2
                        }
                      ],
                      "End": true
                    }
                  }
                },
                {
                  "StartAt": "Parse Ebay Result",
                  "States": {
                    "Parse Ebay Result": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::lambda:invoke",
                      "Parameters": {
                        "FunctionName": "parse-ebay-result:$LATEST",
                        "Payload": {
                          "Input.$": "$"
                        }
                      },
                      "Retry": [
                        {
                          "Comment": "Retry function after an error occurs.",
                          "ErrorEquals": [
                            "Lambda.ServiceException",
                            "Lambda.TooManyRequestsException",
                            "Lambda.AWSLambdaException",
                            "Lambda.SdkClientException"
                          ],
                          "IntervalSeconds": 2,
                          "MaxAttempts": 6,
                          "BackoffRate": 2
                        }
                      ],
                      "Catch": [
                        {
                          "Comment": "Catch errors and revert to fallback states.",
                          "ResultPath": "$.error-info",
                          "ErrorEquals": [
                            "States.ALL"
                          ],
                          "Next": "Fallback State 3 - Update Request Stage - FAILED"
                        }
                      ],
                      "Next": "Save Listings"
                    },
                    "Save Listings": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::lambda:invoke",
                      "Parameters": {
                        "FunctionName": "save-listings:$LATEST",
                        "Payload": {
                          "Input.$": "$"
                        }
                      },
                      "Retry": [
                        {
                          "Comment": "Retry function after an error occurs.",
                          "ErrorEquals": [
                            "Lambda.ServiceException",
                            "Lambda.TooManyRequestsException",
                            "Lambda.AWSLambdaException",
                            "Lambda.SdkClientException"
                          ],
                          "IntervalSeconds": 2,
                          "MaxAttempts": 6,
                          "BackoffRate": 2
                        }
                      ],
                      "Catch": [
                        {
                          "Comment": "Catch errors and revert to fallback states.",
                          "ResultPath": "$.error-info",
                          "ErrorEquals": [
                            "States.ALL"
                          ],
                          "Next": "Fallback State 3 - Update Request Stage - FAILED"
                        }
                      ],
                      "Next": "Update Request Stage - SUCCEEDED"
                    },
                    "Update Request Stage - SUCCEEDED": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::lambda:invoke",
                      "Parameters": {
                        "FunctionName": "update-request-stage:$LATEST",
                        "Payload": {
                          "Input.$": "$",
                          "NewStage": "SUCCEEDED"
                        }
                      },
                      "Retry": [
                        {
                          "Comment": "Retry function after an error occurs.",
                          "ErrorEquals": [
                            "Lambda.ServiceException",
                            "Lambda.TooManyRequestsException",
                            "Lambda.AWSLambdaException",
                            "Lambda.SdkClientException"
                          ],
                          "IntervalSeconds": 2,
                          "MaxAttempts": 6,
                          "BackoffRate": 2
                        }
                      ],
                      "Catch": [
                        {
                          "Comment": "Catch errors and revert to fallback states.",
                          "ResultPath": "$.error-info",
                          "ErrorEquals": [
                            "States.ALL"
                          ],
                          "Next": "Fallback State 3 - Update Request Stage - FAILED"
                        }
                      ],
                      "End": true
                    },
                    "Fallback State 3 - Update Request Stage - FAILED": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::lambda:invoke",
                      "Parameters": {
                        "FunctionName": "update-request-stage:$LATEST",
                        "Payload": {
                          "Input.$": "$",
                          "NewStage": "FAILED"
                        }
                      },
                      "Retry": [
                        {
                          "Comment": "Retry function after an error occurs.",
                          "ErrorEquals": [
                            "Lambda.ServiceException",
                            "Lambda.TooManyRequestsException",
                            "Lambda.AWSLambdaException",
                            "Lambda.SdkClientException"
                          ],
                          "IntervalSeconds": 2,
                          "MaxAttempts": 6,
                          "BackoffRate": 2
                        }
                      ],
                      "End": true
                    }
                  }
                }
              ]
            },
            "Fallback State 2 - Update Request Stage - FAILED": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "update-request-stage:$LATEST",
                "Payload": {
                  "Input.$": "$",
                  "NewStage": "FAILED"
                }
              },
              "Retry": [
                {
                  "Comment": "Retry function after an error occurs.",
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.TooManyRequestsException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "End": true
            }
          }
        }
      ]
    },
    "Fallback State 1 - Update Request Stage - FAILED": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "update-request-stage:$LATEST",
        "Payload": {
          "Input.$": "$",
          "NewStage": "FAILED"
        }
      },
      "Retry": [
        {
          "Comment": "Retry function after an error occurs.",
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.TooManyRequestsException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "End": true
    }
  }
}
EOF
}

resource "aws_sfn_state_machine" "handle_text_valuation_request_state_machine" {
  name     = "handle-text-valuation-request"
  role_arn = aws_iam_role.handle_valuation_request_role.arn

  definition = <<EOF
{
  "Comment": "Responsible for facilitating the valuation process",
  "StartAt": "Ebay Search",
  "States": {
    "Ebay Search": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "ebay-search:$LATEST",
        "Payload": {
          "Input.$": "$"
        }
      },
      "Retry": [
        {
          "Comment": "Retry function after an error occurs.",
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.TooManyRequestsException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Catch": [
        {
          "Comment": "Catch errors and revert to fallback states.",
          "ResultPath": "$.error-info",
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Fallback State 1 - Update Request Stage - FAILED"
        }
      ],
      "Next": "Handle Ebay Result"
    },
    "Handle Ebay Result": {
      "Type": "Parallel",
      "End": true,
      "Branches": [
        {
          "StartAt": "Save Ebay Result",
          "States": {
            "Save Ebay Result": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "save-ebay-result:$LATEST",
                "Payload": {
                  "Input.$": "$"
                }
              },
              "Retry": [
                {
                  "Comment": "Retry function after an error occurs.",
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.TooManyRequestsException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "End": true
            }
          }
        },
        {
          "StartAt": "Parse Ebay Result",
          "States": {
            "Parse Ebay Result": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "parse-ebay-result:$LATEST",
                "Payload": {
                  "Input.$": "$"
                }
              },
              "Retry": [
                {
                  "Comment": "Retry function after an error occurs.",
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.TooManyRequestsException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "Catch": [
                {
                  "Comment": "Catch errors and revert to fallback states.",
                  "ResultPath": "$.error-info",
                  "ErrorEquals": [
                    "States.ALL"
                  ],
                  "Next": "Fallback State 2 - Update Request Stage - FAILED"
                }
              ],
              "Next": "Save Listings"
            },
            "Save Listings": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "save-listings:$LATEST",
                "Payload": {
                  "Input.$": "$"
                }
              },
              "Retry": [
                {
                  "Comment": "Retry function after an error occurs.",
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.TooManyRequestsException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "Catch": [
                {
                  "Comment": "Catch errors and revert to fallback states.",
                  "ResultPath": "$.error-info",
                  "ErrorEquals": [
                    "States.ALL"
                  ],
                  "Next": "Fallback State 2 - Update Request Stage - FAILED"
                }
              ],
              "Next": "Update Request Stage - SUCCEEDED"
            },
            "Update Request Stage - SUCCEEDED": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "update-request-stage:$LATEST",
                "Payload": {
                  "Input.$": "$",
                  "NewStage": "SUCCEEDED"
                }
              },
              "Retry": [
                {
                  "Comment": "Retry function after an error occurs.",
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.TooManyRequestsException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "Catch": [
                {
                  "Comment": "Catch errors and revert to fallback states.",
                  "ResultPath": "$.error-info",
                  "ErrorEquals": [
                    "States.ALL"
                  ],
                  "Next": "Fallback State 2 - Update Request Stage - FAILED"
                }
              ],
              "End": true
            },
            "Fallback State 2 - Update Request Stage - FAILED": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "update-request-stage:$LATEST",
                "Payload": {
                  "Input.$": "$",
                  "NewStage": "FAILED"
                }
              },
              "Retry": [
                {
                  "Comment": "Retry function after an error occurs.",
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.TooManyRequestsException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "End": true
            }
          }
        }
      ]
    },            
    "Fallback State 1 - Update Request Stage - FAILED": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "update-request-stage:$LATEST",
        "Payload": {
          "Input.$": "$",
          "NewStage": "FAILED"
        }
      },
      "Retry": [
        {
          "Comment": "Retry function after an error occurs.",
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.TooManyRequestsException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "End": true
    }
  }
}
EOF
}





const sfn = require("./sfn");

const HANDLE_IMAGE_REQUEST_SFN_ARN = process.env.HANDLE_IMAGE_REQUEST_SFN_ARN;
const HANDLE_TEXT_REQUEST_SFN_ARN = process.env.HANDLE_TEXT_REQUEST_SFN_ARN;

exports.handler = (event, context, callback) => {
  event.Records.forEach((record) => {
    if (record.eventName == "INSERT") {
      // Only startExecution if newly-submitted
      if (((record.dynamodb.NewImage || {}).stage || {}).S == "SUBMITTED") {
        var requestId = record.dynamodb.NewImage.id.S;
        var requestType = record.dynamodb.NewImage.requestType.S;

        if (requestType === "image") {
          var imageS3Key = record.dynamodb.NewImage.image.S;
          var params = {
            stateMachineArn: HANDLE_IMAGE_REQUEST_SFN_ARN,
            input: JSON.stringify({
              requestId,
              imageS3Key,
            }),
          };
        } else if (requestType === "text") {
          var searchQuery = record.dynamodb.NewImage.searchQuery.S;
          var params = {
            stateMachineArn: HANDLE_TEXT_REQUEST_SFN_ARN,
            input: JSON.stringify({
              Payload: {
                requestId,
                keywordString: searchQuery,
              },
            }),
          };
        }

        sfn.startExecution(params);
      }
    }
  });
  callback(null, `Successfully processed ${event.Records.length} records.`);
};

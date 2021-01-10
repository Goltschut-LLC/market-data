const AWS = require("aws-sdk");
const sfn = new AWS.StepFunctions({apiVersion: '2016-11-23'});

const startExecution = (params) => {
    sfn.startExecution(params, function(err, data) {
        if (err) {
            throw new Error(`Unable to start SFN execution: ${JSON.stringify(err, null, 2)}`)
        } else {
            console.log("SFN execution started: ", JSON.stringify(data, null, 2));
        }
    });
};

module.exports = { startExecution };

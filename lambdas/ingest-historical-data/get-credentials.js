const AWS = require("aws-sdk");
const { region } = require("./config");

const get = async (secretName) => {
  try {
    console.log("Get credentials called with:", { secretName });

    const client = new AWS.SecretsManager({
      region,
    });

    const secret = await client
      .getSecretValue({ SecretId: secretName })
      .promise();

    return JSON.parse(secret.SecretString);
  } catch (error) {
    console.log("Error encountered during get credentials:", error.message);
    console.log(error.stack);
    throw error;
  }
};

module.exports = { get };

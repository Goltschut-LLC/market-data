const AWS = require("aws-sdk");
const { region } = require("./config");

const get = async (secretName) => {
  const client = new AWS.SecretsManager({
    region
  });

  const secret = await client
    .getSecretValue({ SecretId: secretName })
    .promise();

  return JSON.parse(secret.SecretString);
};

module.exports = { get };

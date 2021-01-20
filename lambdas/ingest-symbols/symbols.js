// Read more at:
// https://alpaca.markets/docs/api-documentation/api-v2/market-data/bars/

const Alpaca = require("@alpacahq/alpaca-trade-api");
const { alpacaSecretName, env } = require("./config");
const Credentials = require("./get-credentials");

const get = async (event) => {
  try {
    const { API_KEY_ID, SECRET_KEY } = await Credentials.get(alpacaSecretName);

    const alpaca = new Alpaca({
      keyId: API_KEY_ID,
      secretKey: SECRET_KEY,
      paper: env !== 'prod',
      usePolygon: false,
    });

    const assets = await alpaca.getAssets();

    return assets;
  } catch (error) {
    console.log("Error encountered during get symbols:", error.message);
    console.log(error.stack);
    throw error;
  }
};

module.exports = { get };

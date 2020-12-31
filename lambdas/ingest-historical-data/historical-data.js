// Read more at:
// https://alpaca.markets/docs/api-documentation/api-v2/market-data/bars/

const Alpaca = require("@alpacahq/alpaca-trade-api");
const { alpacaSecretName } = require("./config");
const Credentials = require("./get-credentials");

const get = async ({ timeframe, symbols, limit, start, end }) => {
  try {
    console.log("Get historical data called with:", {
      timeframe,
      symbols,
      limit,
      start,
      end,
    });

    const { API_KEY_ID, SECRET_KEY } = await Credentials.get(alpacaSecretName);

    const alpaca = new Alpaca({
      keyId: API_KEY_ID,
      secretKey: SECRET_KEY,
      paper: true,
      usePolygon: false,
    });

    console.log("Attempting to get historical data with newly obtained credentials.");
    const barset = await alpaca.getBars(timeframe, symbols.join(","), {
      limit,
      start,
      end,
    });

    console.log("Attempt to get historical data completed successfully.");
    return { timeframe, start, end, symbols: barset };
  } catch (error) {
    console.log("Error encountered during get historical data:", error.message);
    console.log(error.stack);
    throw error;
  }
};

module.exports = { get };

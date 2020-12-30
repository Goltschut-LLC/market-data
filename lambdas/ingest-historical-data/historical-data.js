// Read more at:
// https://alpaca.markets/docs/api-documentation/api-v2/market-data/bars/

const Alpaca = require("@alpacahq/alpaca-trade-api");
const { alpacaSecretName } = require("./config");
const Credentials = require("./get-credentials");

const get = async ({ timeframe, symbols, limit, start, end }) => {
  
  console.log("get historical-data called with: ", {
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

  const barset = await alpaca.getBars(timeframe, symbols.join(","), {
    limit,
    start,
    end,
  });

  return { timeframe, start, end, symbols: barset };
};

module.exports = { get };

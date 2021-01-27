const { rdsSecretName } = require("./config");
const HistoricalData = require("./historical-data");
const mysql = require("mysql2/promise");
const Credentials = require("./get-credentials");

exports.handler = async (event) => {
  const { Input } = event;

  console.log("Handler called with event:", JSON.stringify(event));
  const { timeframe, symbols, limit, start, end } = Input;

  console.log("Getting historical data");
  const barset = await HistoricalData.get({
    timeframe,
    symbols,
    limit,
    start,
    end,
  });

  if (!(Object.keys(barset.symbols).length > 0)) {
    console.log("No historical data found");
    return;
  }

  console.log("Parsing historical data values");
  let values = [];
  Object.keys(barset.symbols).forEach((symbol) => {
    const bars = barset.symbols[symbol];
    values.push(
      ...bars.map((bar) => [
        timeframe,
        symbol,
        new Date(bar.startEpochTime * 1000).toISOString(),
        bar.openPrice,
        bar.highPrice,
        bar.lowPrice,
        bar.closePrice,
        bar.volume,
      ])
    );
  });

  console.log("Getting RDS credentials");
  const { host, user, password, database } = await Credentials.get(
    rdsSecretName
  );

  console.log("Connecting to RDS cluster");
  const conn = await mysql.createConnection({
    host,
    user,
    password,
    database,
    connectTimeout: 30 * 1000,
  });

  if (values.length > 0) {
    console.log("Loading historical data values");
    try {
      await conn.query(
        [
          "REPLACE INTO daily_ohlcv (",
          "  timeframe,",
          "  symbol,",
          "  start_time,",
          "  open_price,",
          "  high_price,",
          "  low_price,",
          "  close_price,",
          "  volume",
          ") VALUES ?",
        ].join(""),
        [values]
      );
    } catch (error) {
      console.log("Error encountered during RDS data load:", error.message);
      console.log(error.stack);
      await conn.end();
      throw error;
    }
  }

  console.log("Closing RDS connection");
  await conn.end();
};

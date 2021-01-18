const { rdsSecretName } = require("./config");
const HistoricalData = require("./historical-data");
const mysql = require("mysql2/promise");
const Credentials = require("./get-credentials");

exports.handler = async (event) => {
  const { timeframe, symbols, limit, start, end } = event;

  console.log("Handler called with event:", event);

  console.log("Getting historical data");
  const barset = await HistoricalData.get({
    timeframe,
    symbols,
    limit,
    start,
    end,
  });

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

  console.log("Loading historical data values");
  await conn.query(
    [
      "REPLACE INTO aggregate_observations (",
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

  console.log("Closing RDS connection");
  await conn.end();
};

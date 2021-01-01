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

  console.log("Getting RDS credentials");
  const {
    host,
    user,
    password,
    dbClusterIdentifier: database,
  } = await Credentials.get(rdsSecretName);

  console.log("Connecting to RDS cluster");
  const conn = await mysql.createConnection({
    host,
    user,
    password,
    database,
    connectTimeout: 30 * 1000,
  });

  console.log("Performing query execution");
  await conn.execute(
    [
      `CREATE TABLE IF NOT EXISTS market.us_bars (`,
      "  timeframe VARCHAR(10),",
      "  symbol VARCHAR(20),",
      "  start_time DATETIME,",
      "  openPrice float(9,2),",
      "  highPrice float(9,2),",
      "  lowPrice float(9,2),",
      "  closePrice float(9,2),",
      "  volume INT,",
      "  primary key (timeframe, symbol, start_time)",
      ");",
    ].join("")
  );

  const [rows, fields] = await conn.execute("SELECT * FROM market.us_bars;");

  console.log("Results:", JSON.stringify({ rows, fields }));

  await conn.end();
};

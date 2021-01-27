const { rdsSecretName } = require("./config");
const mysql = require("mysql2/promise");
const Credentials = require("./get-credentials");

exports.handler = async (event) => {

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

  console.log("Creating daily_ohlcv table if not exists");
  await conn.execute(
    [
      "CREATE TABLE IF NOT EXISTS daily_ohlcv (",
      "  timeframe VARCHAR(10),",
      "  symbol VARCHAR(20),",
      "  start_time DATETIME,",
      "  open_price float(9,2),",
      "  high_price float(9,2),",
      "  low_price float(9,2),",
      "  close_price float(9,2),",
      "  volume INT,",
      "  primary key (timeframe, symbol, start_time)",
      ");",
    ].join("")
  );

  console.log("Creating symbols table if not exists");
  await conn.execute(
    [
      "CREATE TABLE IF NOT EXISTS symbols (",
      "  symbol VARCHAR(20),",
      "  exchange VARCHAR(20),",
      "  status VARCHAR(20),",
      "  primary key (symbol, exchange)",
      ");",
    ].join("")
  );

  console.log("Closing RDS connection");
  await conn.end();
};

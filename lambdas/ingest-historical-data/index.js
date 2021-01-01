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
    connectTimeout: 30 * 1000
  });
  
  console.log("Executing query");
  const [rows, fields] = await conn.execute(
    "SHOW DATABASES;"
  );
  console.log("Results:", JSON.stringify(rows, fields));
  
  await conn.end();
};

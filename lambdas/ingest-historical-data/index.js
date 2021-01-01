const HistoricalData = require("./historical-data");
const { Client } = require("pg");
const { rdsSecretName } = require("./config");
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
    username: user,
    password,
    dbClusterIdentifier: database,
  } = await Credentials.get(rdsSecretName);
  
  const client = new Client({
    host,
    user,
    password,
    database,
  });
  
  console.log("Connecting to RDS cluster");
  await client.connect();
  
  const text = "SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema'; ";
  
  console.log("Executing query");
  const res = await client.query(text);
  console.log("DB response:", res);

};

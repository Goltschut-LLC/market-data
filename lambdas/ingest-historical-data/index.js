const HistoricalData = require("./historical-data");
const { Client } = require("pg");
const { rdsSecretName } = require("./config");
const Credentials = require("./get-credentials");

exports.handler = async (event) => {
  const { timeframe, symbols, limit, start, end } = event;

  console.log("Handler called with event:", event);

  const barset = await HistoricalData.get({
    timeframe,
    symbols,
    limit,
    start,
    end,
  });

  // const {
  //   host,
  //   username: user,
  //   password,
  //   dbClusterIdentifier: database,
  // } = await Credentials.get(rdsSecretName);

  console.log(
    JSON.stringify(
      {
        barset,
        // host,
        // user,
        // password,
        // database,
      },
      false,
      2
    )
  );

  // const client = new Client({
  //   host,
  //   user,
  //   password,
  //   database,
  // });

  // await client.connect();

  // const text = "SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema'; ";

  // try {
  //   const res = await client.query(text);
  //   console.log(res);
  // } catch (err) {
  //   console.log(err.stack);
  // }
};

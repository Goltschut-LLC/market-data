const { rdsSecretName } = require("./config");
const Symbols = require("./symbols");
const mysql = require("mysql2/promise");
const Credentials = require("./get-credentials");

exports.handler = async (event) => {

  console.log("Getting symbols");
  const symbols = await Symbols.get();

  console.log("Parsing symbol data");
  let values = [];
  symbols.forEach((symbol) => {
    values.push(
      [ symbol.symbol, symbol.exchange, symbol.status ]
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

  console.log("Loading symbol records");
  await conn.query(
    [
      "REPLACE INTO symbols (",
      "  symbol,",
      "  exchange,",
      "  status",
      ") VALUES ?",
    ].join(""),
    [values]
  );

  console.log("Closing RDS connection");
  await conn.end();
};

const { rdsSecretName } = require("./config");
const mysql = require("mysql2/promise");
const Credentials = require("./get-credentials");

const DEFAULT_STATUSES = ["active"];
const DEFAULT_EXCHANGES = ["NYSE", "NASDAQ"];

exports.handler = async (event) => {
  console.log("Handler called with event:", event);

  const { exchanges, statuses } = event.Input.Payload || {};

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

  console.log("Executing query");

  const query = [
    "select * from symbols",
    ` where status in ('${(statuses || DEFAULT_STATUSES).join("','")}')`,
    ` and exchange in ('${(exchanges || DEFAULT_EXCHANGES).join("','")}');`,
  ].join("");

  const [rows, fields] = await conn.execute(query);

  console.log("Closing RDS connection");
  await conn.end();

  const symbols = rows.map((row) => row.symbol);

  return { symbols };
};

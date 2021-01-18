const { rdsSecretName } = require("./config");
const mysql = require("mysql2/promise");
const Credentials = require("./get-credentials");

exports.handler = async (event) => {
  const { query } = event;

  console.log("Handler called with event:", event);

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
  const [rows, fields] = await conn.execute( query );

  console.log("Query result rows:", rows)

  console.log("Closing RDS connection");
  await conn.end();
};

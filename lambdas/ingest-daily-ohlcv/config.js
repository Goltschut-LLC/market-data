const { ENV, REGION, ALPACA_SECRET_NAME, RDS_SECRET_NAME } = process.env;

module.exports = {
  env: ENV,
  region: REGION,
  alpacaSecretName: ALPACA_SECRET_NAME,
  rdsSecretName: RDS_SECRET_NAME,
};

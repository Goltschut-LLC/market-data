const { ENV, REGION, RDS_SECRET_NAME } = process.env;

module.exports = {
  env: ENV,
  region: REGION,
  rdsSecretName: RDS_SECRET_NAME,
};

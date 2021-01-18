const { REGION, RDS_SECRET_NAME } = process.env;

module.exports = {
  region: REGION,
  rdsSecretName: RDS_SECRET_NAME
};

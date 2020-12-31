const { REGION, ALPACA_SECRET_NAME, RDS_SECRET_NAME } = process.env;

module.exports = {
    region: REGION,
    alpacaSecretName: ALPACA_SECRET_NAME,
    rdsSecretName: RDS_SECRET_NAME
};

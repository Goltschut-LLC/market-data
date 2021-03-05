![Site Screenshot]("https://github.com/Goltschut-LLC/market-data/blob/main/site-screenshot.png")

# Getting started

1. Create S3 bucket for storing TF state
2. Update scripts/deploy.sh with S3 state bucket
3. Create variables/env-name.tfvars file
4. Manually create Alpaca and RDS secrets manager secret (plaintext type with default settings)
```json
// Example RDS secret
// NOTE - only a placeholder is needed here. TF will update values.
{
    "database": "DATABASE",
    "host": "HOST",
    "password": "PASSWORD",
    "user": "USER"
}

// Example Alpaca secret
// Actual key and secret values are required, and TF will not update values.
{
  "API_KEY_ID": "API_KEY_ID_GOES_HERE",
  "SECRET_KEY": "SECRET_KEY_GOES_HERE"
}
```
5. Export AWS credentials
6. Run the following:
```sh
bash scripts/build.sh
bash scripts/deploy.sh dev
```
7. Initial TF apply will fail with CertificateNotFound error. Visit [AWS ACM console](https://console.aws.amazon.com/acm/) to validate certificate.
8. After certificate is issued, run the following one more time:
```sh
bash scripts/deploy.sh dev
```
9. Deploy ECR image for create-prediction Lambda

# Cleanup
```
bash scripts/destroy.sh dev
```

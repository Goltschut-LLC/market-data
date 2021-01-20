#!/bin/sh
die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"
echo $1 | grep -E -q '^[aA-zZ]+$' || die "Alpha string argument required (for ENV), $1 provided"

ENV=$1
TFSTATE_BUCKET=goltschut-market-data-${ENV}
echo $TFSTATE_BUCKET
TFSTATE_KEY=goltschut-market-data.tfstate
TFSTATE_REGION=us-east-1

terraform init -reconfigure \
    -backend-config="bucket=${TFSTATE_BUCKET}" \
    -backend-config="key=${TFSTATE_KEY}" \
    -backend-config="region=${TFSTATE_REGION}"

terraform apply -var-file="./variables/${ENV}.tfvars"

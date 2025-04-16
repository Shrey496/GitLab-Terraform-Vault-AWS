#!/bin/bash
set -e

# Login to Vault using AppRole (get Vault token)
VAULT_TOKEN=$(curl --silent --request POST \
  --data "{\"role_id\":\"$VAULT_ROLE_ID\", \"secret_id\":\"$VAULT_SECRET_ID\"}" \
  "$VAULT_ADDR/v1/auth/approle/login" | jq -r '.auth.client_token')

# Fetch the AWS credentials from Vault
VAULT_RESPONSE=$(curl --silent \
  --header "X-Vault-Token: $VAULT_TOKEN" \
  "$VAULT_ADDR/v1/gitlab/data/ci-app")

# Export the credentials as environment variables
export AWS_ACCESS_KEY_ID=$(echo "$VAULT_RESPONSE" | jq -r '.data.data.AWS_ACCESS_KEY_ID')
export AWS_SECRET_ACCESS_KEY=$(echo "$VAULT_RESPONSE" | jq -r '.data.data.AWS_SECRET_ACCESS_KEY')
export AWS_REGION=$(echo "$VAULT_RESPONSE" | jq -r '.data.data.AWS_REGION')

# Debugging: Ensure AWS credentials are set
echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
echo "AWS_REGION: $AWS_REGION"

# Execute the Terraform command passed in (e.g., terraform plan)
exec "$@"
#!/bin/bash
set -e

# Login to Vault using AppRole (get Vault token)
echo "Attempting to authenticate to Vault..."
VAULT_TOKEN=$(curl --silent --request POST \
  --data "{\"role_id\":\"$VAULT_ROLE_ID\", \"secret_id\":\"$VAULT_SECRET_ID\"}" \
  "$VAULT_ADDR/v1/auth/approle/login" | jq -r '.auth.client_token')

# Check if we got a token
if [ -z "$VAULT_TOKEN" ]; then
  echo "Vault token retrieval failed"
  exit 1
fi
echo "Vault token retrieved successfully"

# Fetch the AWS credentials from Vault
echo "Fetching AWS credentials from Vault..."
VAULT_RESPONSE=$(curl --silent \
  --header "X-Vault-Token: $VAULT_TOKEN" \
  "$VAULT_ADDR/v1/gitlab/data/ci-app")

# Check if we received a valid response
if [ -z "$VAULT_RESPONSE" ]; then
  echo "Vault response is empty"
  exit 1
fi

echo "AWS credentials fetched from Vault"

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
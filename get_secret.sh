#!/bin/bash
VAULT_NAME="key-shelter"
SECRET_DB="db-password"
SECRET_FLASK="flask-secret"
ENV_FILE="/opt/app/.env"

az login --identity>>/dev/null

DB_SECRET=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "$SECRET_DB" --query "value" -o tsv)
FLASK_SECRET=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "$SECRET_FLASK" --query "value" -o tsv)
sed -i "s#^DB_PASSWORD=.*#DB_PASSWORD=$DB_SECRET#" "$ENV_FILE"
sed -i "s#^FLASK_SECRET_KEY=.*#FLASK_SECRET_KEY=$FLASK_SECRET#" "$ENV_FILE"

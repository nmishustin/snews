#!/bin/bash
set -e

ENV_FILE=".env"

echo "🔐 Generating and updating secrets in $ENV_FILE..."
echo ""

# Check if .env exists, if not create from example
if [ ! -f "$ENV_FILE" ]; then
    if [ -f ".env.example" ]; then
        echo "Creating .env from .env.example..."
        cp .env.example "$ENV_FILE"
    else
        echo "ERROR: .env.example not found!"
        exit 1
    fi
fi

# Function to update or add variable in .env
update_env_var() {
    local key=$1
    local value=$2
    
    # Escape special characters in value for sed
    local escaped_value=$(echo "$value" | sed 's/[\/&]/\\&/g')
    
    if grep -q "^${key}=" "$ENV_FILE"; then
        # Update existing variable
        sed -i.bak "s|^${key}=.*|${key}=${escaped_value}|" "$ENV_FILE"
    elif grep -q "^#${key}=" "$ENV_FILE"; then
        # Uncomment and update
        sed -i.bak "s|^#${key}=.*|${key}=${escaped_value}|" "$ENV_FILE"
    else
        # Add new variable
        echo "${key}=${value}" >> "$ENV_FILE"
    fi
}

echo "Generating Fernet Key..."
FERNET_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")
update_env_var "AIRFLOW_FERNET_KEY" "$FERNET_KEY"
echo "✅ Fernet Key generated"

echo "Generating Secret Key..."
SECRET_KEY=$(openssl rand -hex 32)
update_env_var "AIRFLOW_SECRET_KEY" "$SECRET_KEY"
echo "✅ Secret Key generated"

echo "Generating MySQL Root Password..."
MYSQL_ROOT_PASS=$(openssl rand -base64 24)
update_env_var "MYSQL_ROOT_PASSWORD" "$MYSQL_ROOT_PASS"
echo "✅ MySQL Root Password generated"

echo "Generating MySQL Airflow Password..."
MYSQL_AIRFLOW_PASS=$(openssl rand -base64 24)
update_env_var "MYSQL_PASSWORD" "$MYSQL_AIRFLOW_PASS"
update_env_var "APP_MYSQL_PASSWORD" "$MYSQL_AIRFLOW_PASS"
echo "✅ MySQL Airflow Password generated"

echo "Generating Airflow Admin Password..."
ADMIN_PASS=$(openssl rand -base64 16)
update_env_var "AIRFLOW_ADMIN_PASSWORD" "$ADMIN_PASS"
echo "✅ Airflow Admin Password: $ADMIN_PASS"

# Clean up backup file
rm -f "${ENV_FILE}.bak"

echo ""
echo "================================================"
echo "✅ All secrets generated and saved to $ENV_FILE"
echo ""
echo "Airflow Admin Credentials:"
echo "  Username: admin (or check AIRFLOW_ADMIN_USERNAME in .env)"
echo "  Password: $ADMIN_PASS"
echo ""
echo "⚠️  IMPORTANT:"
echo "  - .env file contains sensitive data!"
echo "  - NEVER commit .env to git!"
echo "  - Save admin password somewhere safe"
echo "================================================"


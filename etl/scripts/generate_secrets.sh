#!/bin/bash

echo "🔐 Generating Airflow secrets..."
echo ""

echo "# Generated secrets for Airflow" > secrets.txt
echo "# $(date)" >> secrets.txt
echo "" >> secrets.txt

echo "Generating Fernet Key..."
FERNET_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")
echo "AIRFLOW_FERNET_KEY=$FERNET_KEY" >> secrets.txt
echo "✅ Fernet Key: $FERNET_KEY"
echo ""

echo "Generating Secret Key..."
SECRET_KEY=$(openssl rand -hex 32)
echo "AIRFLOW_SECRET_KEY=$SECRET_KEY" >> secrets.txt
echo "✅ Secret Key: $SECRET_KEY"
echo ""

echo "Generating MySQL Root Password..."
MYSQL_ROOT_PASS=$(openssl rand -base64 24)
echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASS" >> secrets.txt
echo "✅ MySQL Root Password: $MYSQL_ROOT_PASS"
echo ""

echo "Generating MySQL Airflow Password..."
MYSQL_AIRFLOW_PASS=$(openssl rand -base64 24)
echo "MYSQL_PASSWORD=$MYSQL_AIRFLOW_PASS" >> secrets.txt
echo "APP_MYSQL_PASSWORD=$MYSQL_AIRFLOW_PASS" >> secrets.txt
echo "✅ MySQL Airflow Password: $MYSQL_AIRFLOW_PASS"
echo ""

echo "Generating Airflow Admin Password..."
ADMIN_PASS=$(openssl rand -base64 16)
echo "AIRFLOW_ADMIN_PASSWORD=$ADMIN_PASS" >> secrets.txt
echo "✅ Airflow Admin Password: $ADMIN_PASS"
echo ""

echo "================================================"
echo "✅ All secrets generated and saved to secrets.txt"
echo ""
echo "⚠️  IMPORTANT:"
echo "1. Copy these values to your .env file"
echo "2. Delete secrets.txt after copying (it contains sensitive data!)"
echo "3. NEVER commit .env to git!"
echo "================================================"


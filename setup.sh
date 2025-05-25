#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Snipe-IT Docker Automated Setup${NC}"

# Create persistent directories
[ -d mysql ] || mkdir -p mysql
[ -d snipeit ] || mkdir -p snipeit

SHOW_CREDENTIALS=0

# Generate .env if it doesn't exist
if [ ! -f .env ]; then
    APP_KEY="base64:$(openssl rand -base64 32)"
    MYSQL_ROOT_PASSWORD=$(openssl rand -hex 16)
    MYSQL_DATABASE="snipeit"
    MYSQL_USER="snipeit"
    MYSQL_PASSWORD=$(openssl rand -hex 16)
    APP_URL="http://localhost:8080"
    MAIL_FROM_ADDR="boni.akijgroup@gmail.com"
    MAIL_FROM_NAME="Snipe-IT Admin"

    cat <<EOF > .env
# Snipe-IT Environment
APP_ENV=production
APP_DEBUG=false
APP_KEY=${APP_KEY}
APP_URL=${APP_URL}

# DB Settings
DB_CONNECTION=mysql
DB_HOST=mysql
DB_DATABASE=${MYSQL_DATABASE}
DB_USERNAME=${MYSQL_USER}
DB_PASSWORD=${MYSQL_PASSWORD}
DB_PORT=3306

# MySQL Container Env
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
MYSQL_DATABASE=${MYSQL_DATABASE}
MYSQL_USER=${MYSQL_USER}
MYSQL_PASSWORD=${MYSQL_PASSWORD}

# Mail (configure as needed)
MAIL_DRIVER=log
MAIL_PORT=1025
MAIL_HOST=localhost
MAIL_FROM_ADDR=${MAIL_FROM_ADDR}
MAIL_FROM_NAME=${MAIL_FROM_NAME}
EOF

    echo -e "${GREEN}.env file created with your mail as sender.${NC}"
    SHOW_CREDENTIALS=1
else
    echo ".env file already exists, skipping creation."
fi

docker-compose up -d

echo -e "${GREEN}Snipe-IT is starting...${NC}"
echo -e "${GREEN}Access it at: http://localhost:8080${NC}"

# Show credentials if this is a fresh setup
if [ "$SHOW_CREDENTIALS" -eq 1 ]; then
    echo -e "\n${YELLOW}=============================="
    echo "   GENERATED CREDENTIALS"
    echo "=============================="
    echo "Snipe-IT APP_KEY:       $APP_KEY"
    echo "MySQL ROOT PASSWORD:    $MYSQL_ROOT_PASSWORD"
    echo "MySQL Database:         $MYSQL_DATABASE"
    echo "MySQL Username:         $MYSQL_USER"
    echo "MySQL User Password:    $MYSQL_PASSWORD"
    echo "Sender Email:           $MAIL_FROM_ADDR"
    echo "==============================${NC}"
    echo -e "${YELLOW}Please save these credentials securely!${NC}"
else
    echo -e "${YELLOW}To view your credentials, check the .env file.${NC}"
fi
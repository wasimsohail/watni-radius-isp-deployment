#!/bin/bash

# WATNI RADIUS ISP SYSTEM - FRESH INSTALLATION 
# Based on analysis of working system

set -e

echo "========================================================================"
echo "🚀 WATNI RADIUS ISP SYSTEM - FRESH DEPLOYMENT"
echo "========================================================================"

# Update system
echo "🔄 Updating system..."
sudo apt-get update

# Install MariaDB (not MySQL!)
echo "💾 Installing MariaDB..."
sudo apt-get install -y mariadb-server mariadb-client

# Install FreeRADIUS
echo "📡 Installing FreeRADIUS..."
sudo apt-get install -y freeradius freeradius-mysql freeradius-utils

# Install Nginx
echo "🌐 Installing Nginx..."
sudo apt-get install -y nginx

# Start MariaDB
echo "🔐 Starting MariaDB..."
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB
echo "🗄️ Securing MariaDB..."
# MariaDB on Ubuntu 24.04 uses auth_socket by default, need to use sudo mysql initially
sudo mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('RootPassword123!');" 2>/dev/null || \
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootPassword123!';" 2>/dev/null || \
sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('RootPassword123!') WHERE User = 'root';" 2>/dev/null
sudo mysql -e "FLUSH PRIVILEGES;" 2>/dev/null

# Create RADIUS database
echo "🗄️ Creating database..."
# Try with password first, fallback to sudo mysql if password doesn't work
mysql -u root -pRootPassword123! -e "CREATE DATABASE IF NOT EXISTS radius;" 2>/dev/null || \
sudo mysql -e "CREATE DATABASE IF NOT EXISTS radius;"

mysql -u root -pRootPassword123! -e "CREATE USER IF NOT EXISTS 'radius'@'localhost' IDENTIFIED BY 'RadiusPassword123!';" 2>/dev/null || \
sudo mysql -e "CREATE USER IF NOT EXISTS 'radius'@'localhost' IDENTIFIED BY 'RadiusPassword123!';"

mysql -u root -pRootPassword123! -e "GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'localhost';" 2>/dev/null || \
sudo mysql -e "GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'localhost';"

mysql -u root -pRootPassword123! -e "FLUSH PRIVILEGES;" 2>/dev/null || \
sudo mysql -e "FLUSH PRIVILEGES;"

echo "✅ Basic installation complete!"
echo "Run setup.sh next to configure FreeRADIUS and create schema"

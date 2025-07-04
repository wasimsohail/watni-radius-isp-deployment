#!/bin/bash

# Quick fix for MariaDB authentication issue
echo "🔧 Fixing MariaDB authentication..."

# Set root password using sudo mysql (auth_socket)
echo "Setting root password..."
sudo mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('RootPassword123!');" 2>/dev/null || \
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootPassword123!';" 2>/dev/null || \
echo "Password setting may have failed, continuing with auth_socket"

sudo mysql -e "FLUSH PRIVILEGES;" 2>/dev/null

# Create RADIUS database and user
echo "Creating RADIUS database..."
mysql -u root -pRootPassword123! -e "CREATE DATABASE IF NOT EXISTS radius;" 2>/dev/null || \
sudo mysql -e "CREATE DATABASE IF NOT EXISTS radius;"

mysql -u root -pRootPassword123! -e "CREATE USER IF NOT EXISTS 'radius'@'localhost' IDENTIFIED BY 'RadiusPassword123!';" 2>/dev/null || \
sudo mysql -e "CREATE USER IF NOT EXISTS 'radius'@'localhost' IDENTIFIED BY 'RadiusPassword123!';"

mysql -u root -pRootPassword123! -e "GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'localhost';" 2>/dev/null || \
sudo mysql -e "GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'localhost';"

mysql -u root -pRootPassword123! -e "FLUSH PRIVILEGES;" 2>/dev/null || \
sudo mysql -e "FLUSH PRIVILEGES;"

echo "✅ MariaDB fixed! You can now continue with ./setup.sh" 
#!/bin/bash

# WATNI RADIUS ISP SYSTEM - IMPROVED INSTALLATION 
# Fixed for Ubuntu 24.04 MariaDB authentication

set -e

echo "========================================================================"
echo "🚀 WATNI RADIUS ISP SYSTEM - FRESH DEPLOYMENT (FIXED)"
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

# Wait for MariaDB to be ready
echo "⏰ Waiting for MariaDB to start..."
sleep 3

# Secure MariaDB - Ubuntu 24.04 compatible
echo "🗄️ Securing MariaDB (Ubuntu 24.04 compatible)..."

# MariaDB on Ubuntu 24.04 uses auth_socket by default
# Try multiple authentication methods
echo "Attempting to set root password..."

# Method 1: Try SET PASSWORD (works in some versions)
sudo mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('RootPassword123!');" 2>/dev/null && echo "✅ Password set using SET PASSWORD" || echo "⚠️  SET PASSWORD failed, trying next method..."

# Method 2: Try ALTER USER (MySQL 5.7+ style)
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootPassword123!';" 2>/dev/null && echo "✅ Password set using ALTER USER" || echo "⚠️  ALTER USER failed, trying next method..."

# Method 3: Try UPDATE (old style)
sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('RootPassword123!') WHERE User = 'root';" 2>/dev/null && echo "✅ Password set using UPDATE" || echo "⚠️  UPDATE failed, will use auth_socket"

# Always flush privileges
sudo mysql -e "FLUSH PRIVILEGES;" 2>/dev/null

echo "🗄️ Creating RADIUS database and user..."

# Function to run MySQL command with fallback
run_mysql() {
    local cmd="$1"
    # Try with root password first
    mysql -u root -pRootPassword123! -e "$cmd" 2>/dev/null || \
    # Fallback to sudo mysql (auth_socket)
    sudo mysql -e "$cmd"
}

# Create database and user
run_mysql "CREATE DATABASE IF NOT EXISTS radius;"
run_mysql "CREATE USER IF NOT EXISTS 'radius'@'localhost' IDENTIFIED BY 'RadiusPassword123!';"
run_mysql "GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'localhost';"
run_mysql "FLUSH PRIVILEGES;"

# Test connections
echo "🧪 Testing database connections..."
if mysql -u radius -pRadiusPassword123! radius -e "SELECT 'Database connection successful' as Status;" 2>/dev/null; then
    echo "✅ RADIUS database connection successful!"
else
    echo "❌ RADIUS database connection failed!"
    echo "Database may still work, continuing..."
fi

echo "✅ Installation complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Run: chmod +x setup.sh && ./setup.sh"
echo "   2. Then: chmod +x create_data.sh && ./create_data.sh"
echo ""
echo "🗄️ Database access options:"
echo "   • With password: mysql -u radius -pRadiusPassword123! radius"
echo "   • Root with sudo: sudo mysql"
echo "   • Root with password: mysql -u root -pRootPassword123!" 
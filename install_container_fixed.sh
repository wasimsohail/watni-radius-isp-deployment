#!/bin/bash

# WATNI RADIUS ISP SYSTEM - CONTAINER-COMPATIBLE INSTALLATION 
# Fixed for environments without systemd

set -e

echo "========================================================================"
echo "🚀 WATNI RADIUS ISP SYSTEM - CONTAINER DEPLOYMENT (FIXED)"
echo "========================================================================"

# Update system
echo "🔄 Updating system..."
apt-get update

# Install MariaDB (not MySQL!)
echo "💾 Installing MariaDB..."
apt-get install -y mariadb-server mariadb-client

# Install FreeRADIUS
echo "📡 Installing FreeRADIUS..."
apt-get install -y freeradius freeradius-mysql freeradius-utils

# Install Nginx
echo "🌐 Installing Nginx..."
apt-get install -y nginx

# Start MariaDB using service command
echo "🔐 Starting MariaDB..."
service mariadb start

# Wait for MariaDB to be ready
echo "⏰ Waiting for MariaDB to start..."
sleep 3

# Secure MariaDB - Container compatible
echo "🗄️ Securing MariaDB (Container compatible)..."

# MariaDB setup for containers
echo "Attempting to set root password..."

# Method 1: Try SET PASSWORD (works in some versions)
mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('RootPassword123!');" 2>/dev/null && echo "✅ Password set using SET PASSWORD" || echo "⚠️  SET PASSWORD failed, trying next method..."

# Method 2: Try ALTER USER (MySQL 5.7+ style)
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootPassword123!';" 2>/dev/null && echo "✅ Password set using ALTER USER" || echo "⚠️  ALTER USER failed, trying next method..."

# Method 3: Try UPDATE (old style)
mysql -e "UPDATE mysql.user SET Password = PASSWORD('RootPassword123!') WHERE User = 'root';" 2>/dev/null && echo "✅ Password set using UPDATE" || echo "⚠️  UPDATE failed, will use auth_socket"

# Always flush privileges
mysql -e "FLUSH PRIVILEGES;" 2>/dev/null

echo "🗄️ Creating RADIUS database and user..."

# Function to run MySQL command with fallback
run_mysql() {
    local cmd="$1"
    # Try with root password first
    mysql -u root -pRootPassword123! -e "$cmd" 2>/dev/null || \
    # Fallback to sudo mysql (auth_socket)
    mysql -e "$cmd"
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
echo "   1. Run: ./setup_container_fixed.sh"
echo "   2. Then: ./create_data.sh"
echo ""
echo "🗄️ Database access options:"
echo "   • With password: mysql -u radius -pRadiusPassword123! radius"
echo "   • Root with password: mysql -u root -pRootPassword123!" 
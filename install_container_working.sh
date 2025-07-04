#!/bin/bash

# WATNI RADIUS ISP SYSTEM - WORKING CONTAINER INSTALLATION 
# Fixed for environments with existing MariaDB setups

set -e

echo "========================================================================"
echo "🚀 WATNI RADIUS ISP SYSTEM - WORKING CONTAINER DEPLOYMENT"
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

# Test if root password is already set
echo "🗄️ Testing MariaDB connection..."
if mysql -u root -pRootPassword123! -e "SELECT 1;" 2>/dev/null; then
    echo "✅ Root password already configured!"
    USE_PASSWORD=true
elif mysql -e "SELECT 1;" 2>/dev/null; then
    echo "🔧 Setting up root password..."
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootPassword123!';" 2>/dev/null && USE_PASSWORD=true || USE_PASSWORD=false
    mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true
else
    echo "❌ Cannot connect to MariaDB!"
    exit 1
fi

echo "🗄️ Creating RADIUS database and user..."

if [ "$USE_PASSWORD" = true ]; then
    echo "Using password authentication..."
    mysql -u root -pRootPassword123! -e "CREATE DATABASE IF NOT EXISTS radius;"
    mysql -u root -pRootPassword123! -e "CREATE USER IF NOT EXISTS 'radius'@'localhost' IDENTIFIED BY 'RadiusPassword123!';"
    mysql -u root -pRootPassword123! -e "GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'localhost';"
    mysql -u root -pRootPassword123! -e "FLUSH PRIVILEGES;"
else
    echo "Using socket authentication..."
    mysql -e "CREATE DATABASE IF NOT EXISTS radius;"
    mysql -e "CREATE USER IF NOT EXISTS 'radius'@'localhost' IDENTIFIED BY 'RadiusPassword123!';"
    mysql -e "GRANT ALL PRIVILEGES ON radius.* TO 'radius'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
fi

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
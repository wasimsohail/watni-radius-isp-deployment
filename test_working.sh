#!/bin/bash

# Working Test Script for WATNI RADIUS ISP System
set -e

echo "========================================================================"
echo "🚀 WORKING TEST - WATNI RADIUS ISP SYSTEM"
echo "========================================================================"

# Check if we're running as root or with sudo access
if [ "$EUID" -ne 0 ] && ! sudo -n true 2>/dev/null; then
    echo "❌ This script needs to be run with sudo access"
    echo "   Please run: sudo ./test_working.sh"
    exit 1
fi

# Make scripts executable
chmod +x install_container_working.sh setup_container_fixed.sh create_data.sh

echo "🧪 Running working install script..."
if ./install_container_working.sh; then
    echo "✅ install_container_working.sh completed successfully!"
else
    echo "❌ install_container_working.sh failed!"
    exit 1
fi

echo "🔧 Running setup script..."
if ./setup_container_fixed.sh; then
    echo "✅ setup_container_fixed.sh completed successfully!"
else
    echo "❌ setup_container_fixed.sh failed!"
    exit 1
fi

echo "📊 Running data creation script..."
if ./create_data.sh; then
    echo "✅ create_data.sh completed successfully!"
else
    echo "❌ create_data.sh failed!"
    exit 1
fi

echo "🧪 Testing RADIUS authentication..."
if radtest testuser1 password123 localhost 0 testing123; then
    echo "✅ RADIUS authentication test passed!"
else
    echo "❌ RADIUS authentication test failed!"
    echo "📋 Debugging - checking users in database:"
    mysql -u radius -pRadiusPassword123! radius -e 'SELECT * FROM radcheck LIMIT 5;' 2>/dev/null || echo "Database query failed"
fi

echo "🗄️ Testing database connection..."
if mysql -u radius -pRadiusPassword123! radius -e 'SELECT COUNT(*) as user_count FROM wr_users;'; then
    echo "✅ Database connection test passed!"
else
    echo "❌ Database connection test failed!"
fi

echo "📊 Testing service plans query..."
if mysql -u radius -pRadiusPassword123! radius -e 'SELECT plan_name, download_speed, upload_speed, monthly_price FROM wr_service_plans;'; then
    echo "✅ Service plans query successful!"
else
    echo "❌ Service plans query failed!"
fi

echo "📊 Showing service status..."
echo "🔍 MariaDB status:"
service mariadb status || true
echo ""
echo "🔍 FreeRADIUS status:"
service freeradius status || true
echo ""
echo "🔍 Nginx status:"
service nginx status || true

echo ""
echo "========================================================================"
echo "🎉 WORKING TEST COMPLETED!"
echo "========================================================================"
echo ""
echo "🧪 Final Test Commands:"
echo "   • Test RADIUS: radtest testuser1 password123 localhost 0 testing123"
echo "   • Check database: mysql -u radius -pRadiusPassword123! radius"
echo "   • View service plans: mysql -u radius -pRadiusPassword123! radius -e 'SELECT * FROM wr_service_plans;'"
echo "   • View test users: mysql -u radius -pRadiusPassword123! radius -e 'SELECT * FROM wr_users;'"
echo ""
echo "🎯 System Summary:"
echo "   • MariaDB: Running with radius database"
echo "   • FreeRADIUS: Configured with MySQL integration"  
echo "   • Test Users: testuser1-4 (password123), adminuser (admin123)"
echo "   • Service Plans: 4 ISP plans from 5M to 50M speeds"
echo "   • Web Server: Nginx running on port 80"
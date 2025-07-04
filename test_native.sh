#!/bin/bash

# Native Test Script for WATNI RADIUS ISP System
set -e

echo "========================================================================"
echo "🚀 NATIVE TEST - WATNI RADIUS ISP SYSTEM"
echo "========================================================================"

# Check if we're running as root or with sudo access
if [ "$EUID" -ne 0 ] && ! sudo -n true 2>/dev/null; then
    echo "❌ This script needs to be run with sudo access"
    echo "   Please run: sudo ./test_native.sh"
    exit 1
fi

echo "🧪 Running install_fixed.sh..."
if ./install_fixed.sh; then
    echo "✅ install_fixed.sh completed successfully!"
else
    echo "❌ install_fixed.sh failed!"
    exit 1
fi

echo "🔧 Running setup.sh..."
if ./setup.sh; then
    echo "✅ setup.sh completed successfully!"
else
    echo "❌ setup.sh failed!"
    exit 1
fi

echo "📊 Running create_data.sh..."
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
    mysql -u radius -pRadiusPassword123! radius -e 'SELECT * FROM radcheck LIMIT 5;'
fi

echo "🗄️ Testing database connection..."
if mysql -u radius -pRadiusPassword123! radius -e 'SELECT COUNT(*) as user_count FROM wr_users;'; then
    echo "✅ Database connection test passed!"
else
    echo "❌ Database connection test failed!"
fi

echo "📊 Showing service status..."
if command -v systemctl >/dev/null 2>&1; then
    systemctl status mariadb freeradius nginx --no-pager -l || true
else
    service mariadb status || true
    service freeradius status || true
    service nginx status || true
fi

echo ""
echo "========================================================================"
echo "🎉 NATIVE TEST COMPLETED!"
echo "========================================================================"
echo ""
echo "🧪 Test Commands:"
echo "   • Test RADIUS: radtest testuser1 password123 localhost 0 testing123"
echo "   • Check database: mysql -u radius -pRadiusPassword123! radius"
echo "   • View FreeRADIUS logs: sudo tail -f /var/log/freeradius/radius.log"
echo "   • View auth logs: sudo tail -f /var/log/auth.log"
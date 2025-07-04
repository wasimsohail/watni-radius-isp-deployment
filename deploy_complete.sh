#!/bin/bash

# WATNI RADIUS COMPLETE DEPLOYMENT SCRIPT
# Runs all installation steps in sequence

set -e

echo "========================================================================"
echo "🚀 WATNI RADIUS COMPLETE DEPLOYMENT"
echo "========================================================================"
echo "This will install a complete RADIUS ISP system with:"
echo "  • MariaDB Database Server"
echo "  • FreeRADIUS with MySQL integration" 
echo "  • ISP management schema"
echo "  • Log analysis system"
echo "  • Test users and service plans"
echo ""
echo "Ready to proceed? (y/N)"
read -r confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 1
fi

echo ""
echo "🔧 Step 1: Basic installation..."
chmod +x install.sh
./install.sh

echo ""
echo "🔧 Step 2: FreeRADIUS setup..."
chmod +x setup.sh
./setup.sh

echo ""
echo "🔧 Step 3: Creating ISP data..."
chmod +x create_data.sh
./create_data.sh

echo ""
echo "🔧 Step 4: Installing log analysis..."
chmod +x scripts/radius_logs_auto_import.sh
chmod +x scripts/view_radius_logs.sh

# Create radius-isp-system directory
mkdir -p ~/radius-isp-system/scripts
cp scripts/* ~/radius-isp-system/scripts/

# Set up cron job for log import
echo "⏰ Setting up automatic log import..."
(crontab -l 2>/dev/null; echo "* * * * * $HOME/radius-isp-system/scripts/radius_logs_auto_import.sh") | crontab -

echo ""
echo "🧪 Step 5: Testing system..."
echo "Testing authentication..."
if radtest testuser1 password123 localhost 0 testing123 | grep -q "Access-Accept"; then
    echo "✅ Authentication test PASSED!"
else
    echo "⚠️  Authentication test may need configuration"
fi

echo ""
echo "========================================================================"
echo "🎉 DEPLOYMENT COMPLETE!"
echo "========================================================================"
echo "✅ System Status:"
echo "   • MariaDB: $(systemctl is-active mariadb)"
echo "   • FreeRADIUS: $(systemctl is-active freeradius)" 
echo "   • Nginx: $(systemctl is-active nginx)"
echo ""
echo "🔐 Test Users Created:"
echo "   • testuser1 / password123 (5M plan)"
echo "   • testuser2 / password123 (10M plan)"
echo "   • testuser3 / password123 (25M plan)"
echo "   • testuser4 / password123 (50M plan)"
echo "   • adminuser / admin123 (50M plan)"
echo ""
echo "🗄️ Database Access:"
echo "   • mysql -u radius -pRadiusPassword123! radius"
echo ""
echo "📊 Log Analysis:"
echo "   • View logs: ~/radius-isp-system/scripts/view_radius_logs.sh"
echo "   • Manual import: ~/radius-isp-system/scripts/radius_logs_auto_import.sh"
echo "   • Automatic import runs every minute via cron"
echo ""
echo "🧪 Test Commands:"
echo "   • radtest testuser1 password123 localhost 0 testing123"
echo "   • mysql -u radius -pRadiusPassword123! radius -e 'SELECT * FROM wr_users;'"
echo ""
echo "========================================================================"

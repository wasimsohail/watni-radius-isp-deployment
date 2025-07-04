# Watni RADIUS ISP System - Fresh Deployment Package

This package contains everything needed to deploy a complete RADIUS ISP system on a fresh Ubuntu installation.

## What's Included

### 🚀 Complete ISP RADIUS System
- **MariaDB Database Server** (not MySQL - critical difference!)
- **FreeRADIUS with MySQL Integration**
- **Custom ISP Management Schema**
- **Automatic Log Analysis System**
- **Test Users and Service Plans**
- **Web Server (Nginx)**

### 📁 Package Contents
```
watni-radius-fresh-deployment/
├── deploy_complete.sh     # One-click complete deployment
├── install.sh            # Basic package installation
├── setup.sh              # FreeRADIUS configuration
├── create_data.sh         # ISP schema and test data
├── scripts/
│   ├── radius_logs_auto_import.sh  # Automatic log import
│   └── view_radius_logs.sh         # Log analysis viewer
└── README.md             # This file
```

## 🚀 Quick Start (Recommended)

For a complete one-click installation:

```bash
# Make executable and run complete deployment
chmod +x deploy_complete.sh
./deploy_complete.sh
```

This will:
1. Install all required packages (MariaDB, FreeRADIUS, Nginx)
2. Configure database with secure passwords
3. Set up FreeRADIUS with ISP integration
4. Create ISP schema and test users
5. Install log analysis system
6. Set up automatic log processing
7. Test the system

## 📋 Manual Step-by-Step Installation

If you prefer to run each step manually:

### Step 1: Basic Installation
```bash
chmod +x install.sh
./install.sh
```

### Step 2: FreeRADIUS Setup
```bash
chmod +x setup.sh
./setup.sh
```

### Step 3: Create ISP Data
```bash
chmod +x create_data.sh
./create_data.sh
```

### Step 4: Install Log Analysis
```bash
chmod +x scripts/*.sh
mkdir -p ~/radius-isp-system/scripts
cp scripts/* ~/radius-isp-system/scripts/
# Set up cron job
(crontab -l 2>/dev/null; echo "* * * * * $HOME/radius-isp-system/scripts/radius_logs_auto_import.sh") | crontab -
```

## 🧪 Testing Your Installation

### Test Authentication
```bash
radtest testuser1 password123 localhost 0 testing123
# Should return: Access-Accept
```

### Test Database
```bash
mysql -u radius -pRadiusPassword123! radius -e "SELECT * FROM wr_users;"
```

### View Service Plans
```bash
mysql -u radius -pRadiusPassword123! radius -e "SELECT * FROM wr_service_plans;"
```

### Test Log Analysis
```bash
~/radius-isp-system/scripts/view_radius_logs.sh
```

## 🔐 Default Credentials

### Database Access
- **Root User**: `mysql -u root -pRootPassword123!`
- **RADIUS User**: `mysql -u radius -pRadiusPassword123! radius`

### Test Users
- **testuser1** / password123 (5M plan)
- **testuser2** / password123 (10M plan)  
- **testuser3** / password123 (25M plan)
- **testuser4** / password123 (50M plan)
- **adminuser** / admin123 (50M plan)

## 📊 ISP Management Features

### Service Plans
The system includes 4 pre-configured service plans:
- **WL Basic 5M**: 5Mbps/5Mbps - $25/month
- **WL Silver 10M**: 10Mbps/10Mbps - $45/month
- **WL Gold 25M**: 25Mbps/25Mbps - $75/month
- **WL Platinum 50M**: 50Mbps/50Mbps - $120/month

### Database Schema
- `wr_users` - Customer accounts
- `wr_service_plans` - Service plan definitions
- `wr_service_plan_attributes` - RADIUS attributes per plan
- `radius_logs` - Comprehensive usage logging

### Log Analysis Features
- **Real-time Log Import**: Automatic every minute
- **Usage Analytics**: Data consumption by user
- **Session Tracking**: Active sessions and duration
- **NAS Monitoring**: Equipment performance stats
- **Billing Data**: Ready for billing integration

## 🔧 System Architecture

### Key Differences from Standard RADIUS
1. **MariaDB vs MySQL**: Uses MariaDB for better compatibility
2. **Hybrid Authentication**: Validates against both radcheck and wr_users
3. **Dynamic Attributes**: Service plan attributes served directly from database
4. **ISP-Grade Logging**: Comprehensive log analysis for billing
5. **Fixed Permissions**: Proper log file access for analysis

### Working System Analysis
This deployment is based on analysis of a working production system:
- **Production Server**: 192.168.2.79
- **Database**: MariaDB 10.11.13 (not MySQL 8.0)
- **Authentication**: mysql_native_password
- **Web Server**: Nginx included
- **Log System**: Automatic import every minute

## 🚨 Security Notes

### Before Production Use
1. **Change Default Passwords**:
   ```bash
   # Change database passwords
   mysql -u root -pRootPassword123! -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'YourNewRootPassword';"
   mysql -u root -pYourNewRootPassword -e "ALTER USER 'radius'@'localhost' IDENTIFIED BY 'YourNewRadiusPassword';"
   ```

2. **Configure Firewall**:
   ```bash
   sudo ufw enable
   sudo ufw allow 1812/udp  # RADIUS auth
   sudo ufw allow 1813/udp  # RADIUS acct
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 80/tcp    # HTTP
   ```

3. **Secure Database**:
   - Remove test users in production
   - Use SSL connections
   - Limit database user privileges

## 🛠️ Troubleshooting

### Common Issues

#### Authentication Failures
```bash
# Check FreeRADIUS status
sudo systemctl status freeradius

# Test in debug mode
sudo freeradius -X

# Check user exists
mysql -u radius -pRadiusPassword123! radius -e "SELECT * FROM radcheck WHERE username='testuser1';"
```

#### Database Connection Issues
```bash
# Check MariaDB status
sudo systemctl status mariadb

# Test connection
mysql -u radius -pRadiusPassword123! radius -e "SELECT NOW();"
```

#### Log Import Not Working
```bash
# Check log directory permissions
ls -la /var/log/freeradius/radacct/

# Check if user is in freerad group
groups $(whoami)

# Manual log import test
~/radius-isp-system/scripts/radius_logs_auto_import.sh
```

### Service Status Commands
```bash
# Check all services
sudo systemctl status mariadb freeradius nginx

# View logs
sudo journalctl -u freeradius -f
sudo journalctl -u mariadb -f
```

## 📞 Support

### Generated by Analysis
This deployment package was created by analyzing a working production RADIUS system and includes all the fixes and configurations needed for a successful deployment.

### Key Fixes Included
- MariaDB instead of MySQL 8.0
- Proper authentication methods
- Fixed log file permissions
- Working SQL queries
- Complete ISP schema
- Automatic log processing

For issues, check the troubleshooting section above or verify against the working system configuration.

---

**🎉 Your Watni RADIUS ISP system should now be ready for production use!**

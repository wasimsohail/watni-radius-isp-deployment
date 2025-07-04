#!/bin/bash

# WATNI RADIUS SETUP - Configure FreeRADIUS and Database Schema

set -e

echo "🔧 Configuring FreeRADIUS..."
sudo systemctl stop freeradius

# Enable SQL module
sudo ln -sf /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/sql

# Fix log permissions
sudo sed -i 's/permissions = 0600/permissions = 0640/' /etc/freeradius/3.0/mods-available/detail
sudo usermod -a -G freerad $(whoami)

# Configure SQL connection
sudo cp /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-available/sql.backup
sudo tee /etc/freeradius/3.0/mods-available/sql > /dev/null << 'SQLEOF'
sql {
    driver = "rlm_sql_mysql"
    dialect = "mysql"
    server = "localhost"
    port = 3306
    login = "radius"
    password = "RadiusPassword123!"
    radius_db = "radius"
    
    acct_table1 = "radacct"
    acct_table2 = "radacct"
    postauth_table = "radpostauth"
    authcheck_table = "radcheck"
    groupcheck_table = "radgroupcheck"
    authreply_table = "radreply"
    groupreply_table = "radgroupreply"
    usergroup_table = "radusergroup"
    
    read_groups = yes
    read_profiles = yes
    read_clients = yes
    delete_stale_sessions = yes
    
    pool {
        start = 5
        min = 4
        max = 32
        spare = 3
        uses = 0
        retry_delay = 30
        lifetime = 0
        idle_timeout = 60
    }
    
    $INCLUDE ${modconfdir}/sql/main/${dialect}/queries.conf
}
SQLEOF

# Enable SQL in sites
sudo sed -i 's/#.*-sql/\t\tsql/g' /etc/freeradius/3.0/sites-available/default
sudo sed -i 's/#.*sql/\t\tsql/g' /etc/freeradius/3.0/sites-available/inner-tunnel

echo "📊 Creating database schema..."
# Copy schema file to accessible location first
sudo cp /etc/freeradius/3.0/mods-config/sql/main/mysql/schema.sql /tmp/schema.sql
sudo chmod 644 /tmp/schema.sql

# Import schema with proper authentication
mysql -u radius -pRadiusPassword123! radius < /tmp/schema.sql 2>/dev/null || \
sudo mysql radius < /tmp/schema.sql

# Clean up temp file
rm -f /tmp/schema.sql

echo "🚀 Starting FreeRADIUS..."
sudo systemctl start freeradius
sudo systemctl enable freeradius

echo "✅ Setup complete! Run create_data.sh to create ISP schema and test data"

#!/bin/bash

# WATNI RADIUS - Create ISP Schema and Test Data

echo "📊 Creating Watni ISP schema and test data..."

mysql -u radius -pRadiusPassword123! radius << 'DATAEOF'
-- Watni ISP System Tables
CREATE TABLE IF NOT EXISTS wr_users (
    user_id int AUTO_INCREMENT PRIMARY KEY,
    username varchar(64) NOT NULL UNIQUE,
    password_hash varchar(128) NOT NULL,
    email varchar(128),
    service_plan_id int NOT NULL,
    is_enabled tinyint(1) DEFAULT 1,
    account_status enum('active','suspended','terminated') DEFAULT 'active',
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at datetime NULL,
    use_mac_auth tinyint(1) DEFAULT 0,
    mac_address varchar(17) NULL,
    INDEX idx_username (username),
    INDEX idx_service_plan (service_plan_id)
);

CREATE TABLE IF NOT EXISTS wr_service_plans (
    plan_id int AUTO_INCREMENT PRIMARY KEY,
    plan_name varchar(64) NOT NULL,
    plan_description text,
    download_speed varchar(16),
    upload_speed varchar(16),
    download_burst varchar(16),
    upload_burst varchar(16),
    monthly_price decimal(10,2),
    setup_fee decimal(10,2) DEFAULT 0.00,
    billing_cycle enum('monthly','quarterly','yearly') DEFAULT 'monthly',
    is_active tinyint(1) DEFAULT 1,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS wr_service_plan_attributes (
    attribute_id int AUTO_INCREMENT PRIMARY KEY,
    plan_id int NOT NULL,
    attribute_name varchar(64) NOT NULL,
    attribute_value varchar(128) NOT NULL,
    operator_type enum('=',':=','==','+=','!=','+=','<=','>=') DEFAULT '=',
    is_active tinyint(1) DEFAULT 1,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_id) REFERENCES wr_service_plans(plan_id),
    INDEX idx_plan_id (plan_id)
);

-- RADIUS log analysis table
CREATE TABLE IF NOT EXISTS radius_logs (
    id bigint NOT NULL AUTO_INCREMENT,
    timestamp datetime NOT NULL,
    nas_ip_address varchar(45) DEFAULT NULL,
    nas_identifier varchar(64) DEFAULT NULL,
    user_name varchar(64) DEFAULT NULL,
    acct_session_id varchar(64) DEFAULT NULL,
    acct_unique_session_id varchar(64) DEFAULT NULL,
    acct_status_type varchar(32) DEFAULT NULL,
    acct_authentic varchar(32) DEFAULT NULL,
    acct_session_time int DEFAULT 0,
    acct_input_octets bigint DEFAULT 0,
    acct_input_gigawords int DEFAULT 0,
    acct_input_packets bigint DEFAULT 0,
    acct_output_octets bigint DEFAULT 0,
    acct_output_gigawords int DEFAULT 0,
    acct_output_packets bigint DEFAULT 0,
    acct_delay_time int DEFAULT 0,
    acct_terminate_cause varchar(32) DEFAULT NULL,
    acct_multi_session_id varchar(64) DEFAULT NULL,
    acct_link_count int DEFAULT 1,
    framed_ip_address varchar(45) DEFAULT NULL,
    framed_protocol varchar(32) DEFAULT NULL,
    service_type varchar(32) DEFAULT NULL,
    nas_port int DEFAULT NULL,
    nas_port_type varchar(32) DEFAULT NULL,
    nas_port_id varchar(64) DEFAULT NULL,
    calling_station_id varchar(64) DEFAULT NULL,
    called_station_id varchar(64) DEFAULT NULL,
    event_timestamp datetime DEFAULT NULL,
    idle_timeout int DEFAULT 0,
    session_timeout int DEFAULT 0,
    raw_data text DEFAULT NULL,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_timestamp (timestamp),
    KEY idx_nas_ip (nas_ip_address),
    KEY idx_user_name (user_name),
    KEY idx_session_id (acct_session_id),
    KEY idx_status_type (acct_status_type),
    UNIQUE KEY idx_unique_record (timestamp, nas_ip_address, acct_session_id, acct_status_type, nas_port, user_name)
);

-- Insert sample service plans
INSERT INTO wr_service_plans (plan_name, plan_description, download_speed, upload_speed, download_burst, upload_burst, monthly_price) VALUES
('WL Basic 5M', 'Basic Wireless Plan - 5Mbps', '5M', '5M', '8M', '8M', 25.00),
('WL Silver 10M', 'Silver Wireless Plan - 10Mbps', '10M', '10M', '15M', '15M', 45.00),
('WL Gold 25M', 'Gold Wireless Plan - 25Mbps', '25M', '25M', '35M', '35M', 75.00),
('WL Platinum 50M', 'Platinum Wireless Plan - 50Mbps', '50M', '50M', '75M', '75M', 120.00);

-- Insert service plan attributes for MikroTik
INSERT INTO wr_service_plan_attributes (plan_id, attribute_name, attribute_value) VALUES
(1, 'Mikrotik-Rate-Limit', '5M/5M 8M/8M 4M/4M 8 8'),
(2, 'Mikrotik-Rate-Limit', '10M/10M 15M/15M 8M/8M 8 8'),
(3, 'Mikrotik-Rate-Limit', '25M/25M 35M/35M 20M/20M 8 8'),
(4, 'Mikrotik-Rate-Limit', '50M/50M 75M/75M 40M/40M 8 8');

-- Insert test users 
INSERT INTO wr_users (username, password_hash, email, service_plan_id, is_enabled, account_status) VALUES
('testuser1', 'hashed_password_placeholder', 'test1@example.com', 1, 1, 'active'),
('testuser2', 'hashed_password_placeholder', 'test2@example.com', 2, 1, 'active'),
('testuser3', 'hashed_password_placeholder', 'test3@example.com', 3, 1, 'active'),
('testuser4', 'hashed_password_placeholder', 'test4@example.com', 4, 1, 'active'),
('adminuser', 'hashed_password_placeholder', 'admin@example.com', 4, 1, 'active');

-- Insert into radcheck for authentication
INSERT INTO radcheck (username, attribute, op, value) VALUES
('testuser1', 'Cleartext-Password', ':=', 'password123'),
('testuser2', 'Cleartext-Password', ':=', 'password123'),
('testuser3', 'Cleartext-Password', ':=', 'password123'),
('testuser4', 'Cleartext-Password', ':=', 'password123'),
('adminuser', 'Cleartext-Password', ':=', 'admin123');
DATAEOF

echo "✅ ISP schema and test data created!"
echo "Test authentication: radtest testuser1 password123 localhost 0 testing123"

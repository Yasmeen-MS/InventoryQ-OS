-- ResQ OS Database Schema - PRODUCTION READY VERSION
-- Multi-tenant database schema for Hospitals, PDS, and NGOs
-- Copy and paste this entire file into Snowflake worksheet and run

-- Step 1: Create Database and Schema
CREATE DATABASE IF NOT EXISTS RESQ_OS;
USE DATABASE RESQ_OS;
CREATE SCHEMA IF NOT EXISTS SUPPLY_CHAIN;
USE SCHEMA SUPPLY_CHAIN;

-- Step 2: Core inventory table supporting all sectors
CREATE OR REPLACE TABLE inventory_master (
    inventory_id VARCHAR(50) PRIMARY KEY,
    organization_id VARCHAR(50) NOT NULL,
    sector_type VARCHAR(20) NOT NULL,
    item_type VARCHAR(50) NOT NULL,
    current_stock NUMBER(10,2) NOT NULL,
    daily_consumption_rate NUMBER(10,2) NOT NULL,
    reorder_point NUMBER(10,2) NOT NULL,
    critical_threshold NUMBER(10,2) NOT NULL,
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    location_city VARCHAR(50),
    location_state VARCHAR(50),
    location_country VARCHAR(50),
    location_latitude NUMBER(10,6),
    location_longitude NUMBER(10,6),
    supplier_info VARCHAR(500),
    batch_number VARCHAR(100),
    expiry_date DATE,
    unit_cost NUMBER(10,2),
    storage_conditions VARCHAR(200),
    quality_grade VARCHAR(20),
    compliance_status VARCHAR(50),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Step 3: Sector-specific configurations
CREATE OR REPLACE TABLE sector_config (
    sector_type VARCHAR(20) PRIMARY KEY,
    criticality_multiplier NUMBER(5,2) NOT NULL,
    default_reorder_days INTEGER NOT NULL,
    priority_level INTEGER NOT NULL,
    emergency_contact VARCHAR(200),
    regulatory_requirements VARCHAR(500),
    default_supplier VARCHAR(200),
    max_storage_days INTEGER,
    temperature_range VARCHAR(50),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Step 4: Purchase orders table for tracking automated orders
CREATE OR REPLACE TABLE purchase_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    inventory_id VARCHAR(50) NOT NULL,
    quantity NUMBER(10,2) NOT NULL,
    urgency_level VARCHAR(20) NOT NULL,
    estimated_delivery TIMESTAMP_NTZ,
    actual_delivery TIMESTAMP_NTZ,
    supplier_name VARCHAR(200),
    supplier_contact VARCHAR(200),
    unit_price NUMBER(10,2),
    total_amount NUMBER(12,2),
    order_status VARCHAR(50) DEFAULT 'PENDING',
    auto_generated BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    created_by VARCHAR(100),
    approved_at TIMESTAMP_NTZ,
    approved_by VARCHAR(100),
    reasoning VARCHAR(500),
    delivery_address VARCHAR(500),
    special_instructions VARCHAR(500)
);

-- Step 5: Audit log for tracking all automated actions
CREATE OR REPLACE TABLE audit_log (
    log_id VARCHAR(50) PRIMARY KEY,
    action_type VARCHAR(50) NOT NULL,
    inventory_id VARCHAR(50),
    organization_id VARCHAR(50),
    user_id VARCHAR(100),
    old_values VARCHAR(1000),
    new_values VARCHAR(1000),
    timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    reasoning VARCHAR(500),
    ip_address VARCHAR(50),
    session_id VARCHAR(100),
    severity_level VARCHAR(20) DEFAULT 'INFO'
);

-- Step 6: Vendor management table
CREATE OR REPLACE TABLE vendors (
    vendor_id VARCHAR(50) PRIMARY KEY,
    vendor_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    address VARCHAR(500),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    vendor_type VARCHAR(50),
    reliability_score NUMBER(3,2) DEFAULT 0.0,
    average_delivery_time INTEGER,
    quality_rating NUMBER(3,2) DEFAULT 0.0,
    payment_terms VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_order_date TIMESTAMP_NTZ
);

-- Step 7: Notifications table for alerts and communications
CREATE OR REPLACE TABLE notifications (
    notification_id VARCHAR(50) PRIMARY KEY,
    recipient_type VARCHAR(50) NOT NULL,
    recipient_id VARCHAR(100) NOT NULL,
    message_type VARCHAR(50) NOT NULL,
    subject VARCHAR(200),
    message_body VARCHAR(1000),
    priority_level VARCHAR(20) DEFAULT 'MEDIUM',
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    read_at TIMESTAMP_NTZ,
    related_inventory_id VARCHAR(50),
    related_order_id VARCHAR(50),
    delivery_method VARCHAR(50) DEFAULT 'EMAIL'
);

-- Step 8: System configuration table
CREATE OR REPLACE TABLE system_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value VARCHAR(500),
    config_description VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_by VARCHAR(100)
);

-- Step 9: Insert default sector configurations
INSERT INTO sector_config (
    sector_type, criticality_multiplier, default_reorder_days, priority_level,
    emergency_contact, regulatory_requirements, default_supplier, max_storage_days, temperature_range
) VALUES 
    ('HOSPITAL', 2.0, 3, 1, 'emergency@hospital.com', 'FDA Medical Device Regulations', 'MedSupply Corp', 30, '2-8°C'),
    ('PDS', 1.5, 7, 2, 'admin@pds.gov.in', 'Food Safety Standards Authority', 'GrainDistributors Ltd', 180, '15-25°C'),
    ('NGO', 1.8, 5, 1, 'emergency@ngo.org', 'Humanitarian Standards Partnership', 'ReliefSupplies Inc', 365, '10-30°C');

-- Step 10: Insert default vendors
INSERT INTO vendors (
    vendor_id, vendor_name, contact_person, phone, email, address, city, state, country,
    vendor_type, reliability_score, average_delivery_time, quality_rating, payment_terms
) VALUES 
    ('VENDOR_001', 'MedSupply Corp', 'Dr. Rajesh Kumar', '+91-80-12345678', 'orders@medsupply.com', 
     '123 Medical District', 'Bangalore', 'Karnataka', 'India', 'MEDICAL', 0.95, 24, 4.8, 'Net 30'),
    ('VENDOR_002', 'GrainDistributors Ltd', 'Amit Sharma', '+91-11-87654321', 'supply@graindist.com',
     '456 Agriculture Hub', 'Delhi', 'Delhi', 'India', 'FOOD', 0.88, 72, 4.5, 'Net 15'),
    ('VENDOR_003', 'ReliefSupplies Inc', 'Priya Patel', '+91-22-11223344', 'emergency@reliefsupplies.com',
     '789 Relief Center', 'Mumbai', 'Maharashtra', 'India', 'EMERGENCY', 0.92, 48, 4.7, 'Net 7');

-- Step 11: Insert system configuration
INSERT INTO system_config (config_key, config_value, config_description) VALUES
    ('CRITICAL_THRESHOLD_HOURS', '72', 'Hours before stock becomes critical'),
    ('AUTO_ORDER_ENABLED', 'true', 'Enable automatic purchase order generation'),
    ('EMAIL_NOTIFICATIONS', 'true', 'Send email notifications for critical events'),
    ('SIMULATION_MODE', 'true', 'Use high-fidelity simulation data'),
    ('MAX_ORDER_AMOUNT', '100000', 'Maximum amount for auto-generated orders'),
    ('WEATHER_API_ENABLED', 'false', 'Use real weather API (false = simulation)'),
    ('VENDOR_API_ENABLED', 'false', 'Use real vendor APIs (false = simulation)');

-- Step 12: Insert comprehensive sample data

-- Hospital test data with full details
INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_city, location_state, location_country, location_latitude, location_longitude,
    supplier_info, batch_number, expiry_date, unit_cost, storage_conditions, quality_grade,
    compliance_status, created_by
) VALUES 
    ('HOSP_001', 'ORG_HOSPITAL_001', 'HOSPITAL', 'OXYGEN',
     100.0, 10.0, 30.0, 3.0,
     'Bangalore', 'Karnataka', 'India', 12.9716, 77.5946,
     'MedSupply Corp - Premium Grade', 'OXY2024001', '2025-12-31', 150.00, 'Pressurized tanks, 2-8°C', 'Medical Grade',
     'FDA Approved', 'system_admin'),
    ('HOSP_002', 'ORG_HOSPITAL_001', 'HOSPITAL', 'MEDICAL_SUPPLIES',
     50.0, 5.0, 15.0, 2.0,
     'Bangalore', 'Karnataka', 'India', 12.9716, 77.5946,
     'MedSupply Corp - Surgical Kit', 'MED2024001', '2025-06-30', 75.00, 'Sterile environment, room temperature', 'Surgical Grade',
     'ISO Certified', 'system_admin');

-- PDS test data with full details
INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_city, location_state, location_country, location_latitude, location_longitude,
    supplier_info, batch_number, expiry_date, unit_cost, storage_conditions, quality_grade,
    compliance_status, created_by
) VALUES 
    ('PDS_001', 'ORG_PDS_001', 'PDS', 'RICE',
     500.0, 25.0, 100.0, 7.0,
     'Delhi', 'Delhi', 'India', 28.7041, 77.1025,
     'GrainDistributors Ltd - Basmati Premium', 'RICE2024001', '2025-03-31', 45.00, 'Dry storage, pest control', 'Grade A',
     'FSSAI Approved', 'pds_manager'),
    ('PDS_002', 'ORG_PDS_001', 'PDS', 'WHEAT',
     300.0, 15.0, 60.0, 5.0,
     'Delhi', 'Delhi', 'India', 28.7041, 77.1025,
     'GrainDistributors Ltd - Whole Wheat', 'WHT2024001', '2025-02-28', 35.00, 'Dry storage, temperature controlled', 'Grade A',
     'FSSAI Approved', 'pds_manager');

-- NGO test data with full details
INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_city, location_state, location_country, location_latitude, location_longitude,
    supplier_info, batch_number, expiry_date, unit_cost, storage_conditions, quality_grade,
    compliance_status, created_by
) VALUES 
    ('NGO_001', 'ORG_NGO_001', 'NGO', 'EMERGENCY_KIT',
     50.0, 5.0, 15.0, 5.0,
     'Mumbai', 'Maharashtra', 'India', 19.0760, 72.8777,
     'ReliefSupplies Inc - Disaster Kit', 'EMG2024001', '2026-12-31', 200.00, 'Waterproof storage, ambient temperature', 'Emergency Grade',
     'UN Standards', 'ngo_coordinator'),
    ('NGO_002', 'ORG_NGO_001', 'NGO', 'BLANKETS',
     75.0, 8.0, 20.0, 3.0,
     'Mumbai', 'Maharashtra', 'India', 19.0760, 72.8777,
     'ReliefSupplies Inc - Thermal Blankets', 'BLK2024001', '2027-12-31', 25.00, 'Dry storage, pest control', 'Relief Grade',
     'Red Cross Certified', 'ngo_coordinator');

-- Step 13: Create comprehensive views

-- Enhanced unified inventory view
CREATE OR REPLACE VIEW unified_inventory_view AS
SELECT 
    i.*,
    CASE 
        WHEN i.daily_consumption_rate <= 0 THEN 999999.0
        ELSE i.current_stock / i.daily_consumption_rate
    END as days_remaining,
    CASE 
        WHEN (i.current_stock / NULLIF(i.daily_consumption_rate, 0)) <= i.critical_threshold THEN 'CRITICAL'
        WHEN (i.current_stock / NULLIF(i.daily_consumption_rate, 0)) <= i.reorder_point THEN 'WARNING'
        ELSE 'NORMAL'
    END as status,
    sc.criticality_multiplier,
    sc.priority_level,
    sc.emergency_contact,
    sc.default_supplier,
    CASE 
        WHEN i.expiry_date IS NOT NULL AND i.expiry_date <= DATEADD(day, 30, CURRENT_DATE()) THEN 'EXPIRING_SOON'
        WHEN i.expiry_date IS NOT NULL AND i.expiry_date <= CURRENT_DATE() THEN 'EXPIRED'
        ELSE 'VALID'
    END as expiry_status,
    DATEDIFF(day, CURRENT_DATE(), i.expiry_date) as days_to_expiry
FROM inventory_master i
JOIN sector_config sc ON i.sector_type = sc.sector_type;

-- Critical items view with enhanced details
CREATE OR REPLACE VIEW critical_items_view AS
SELECT 
    *,
    CASE 
        WHEN days_remaining <= 1 THEN 'IMMEDIATE'
        WHEN days_remaining <= 3 THEN 'URGENT'
        ELSE 'STANDARD'
    END as action_required
FROM unified_inventory_view
WHERE status = 'CRITICAL'
ORDER BY priority_level ASC, days_remaining ASC;

-- Comprehensive sector summary view
CREATE OR REPLACE VIEW sector_summary_view AS
SELECT 
    sector_type,
    COUNT(*) as total_items,
    SUM(CASE WHEN status = 'CRITICAL' THEN 1 ELSE 0 END) as critical_items,
    SUM(CASE WHEN status = 'WARNING' THEN 1 ELSE 0 END) as warning_items,
    SUM(CASE WHEN status = 'NORMAL' THEN 1 ELSE 0 END) as normal_items,
    SUM(CASE WHEN expiry_status = 'EXPIRED' THEN 1 ELSE 0 END) as expired_items,
    SUM(CASE WHEN expiry_status = 'EXPIRING_SOON' THEN 1 ELSE 0 END) as expiring_soon_items,
    AVG(days_remaining) as avg_days_remaining,
    SUM(current_stock * unit_cost) as total_inventory_value,
    MAX(criticality_multiplier) as sector_criticality
FROM unified_inventory_view
GROUP BY sector_type;

-- Purchase order summary view
CREATE OR REPLACE VIEW purchase_order_summary AS
SELECT 
    po.*,
    i.sector_type,
    i.item_type,
    i.location_city,
    v.vendor_name,
    v.reliability_score,
    v.average_delivery_time
FROM purchase_orders po
LEFT JOIN inventory_master i ON po.inventory_id = i.inventory_id
LEFT JOIN vendors v ON po.supplier_name = v.vendor_name;

-- Step 14: Test queries to verify comprehensive setup

-- Test 1: View all inventory with full details
SELECT 'Test 1: Complete Inventory Overview' as test_description;
SELECT * FROM unified_inventory_view ORDER BY sector_type, days_remaining ASC;

-- Test 2: Critical items requiring immediate attention
SELECT 'Test 2: Critical Items Analysis' as test_description;
SELECT * FROM critical_items_view;

-- Test 3: Comprehensive sector analysis
SELECT 'Test 3: Sector Performance Dashboard' as test_description;
SELECT * FROM sector_summary_view;

-- Test 4: Vendor performance overview
SELECT 'Test 4: Vendor Management' as test_description;
SELECT * FROM vendors ORDER BY reliability_score DESC;

-- Test 5: System configuration status
SELECT 'Test 5: System Configuration' as test_description;
SELECT * FROM system_config WHERE is_active = TRUE;

-- Test 6: Multi-tenant verification with enhanced metrics
SELECT 'Test 6: Multi-tenant Analytics' as test_description;
SELECT 
    sector_type,
    COUNT(DISTINCT organization_id) as unique_organizations,
    COUNT(*) as total_items,
    AVG(current_stock) as avg_stock_level,
    SUM(current_stock * unit_cost) as total_value
FROM inventory_master 
GROUP BY sector_type;

-- Success message with system status
SELECT 
    'ResQ OS Production Database Setup Complete!' as status,
    'Database: RESQ_OS, Schema: SUPPLY_CHAIN' as location,
    'Full production features enabled' as features,
    COUNT(*) as total_inventory_items
FROM inventory_master;
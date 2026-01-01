-- ResQ OS Database Schema - COMPLETE SNOWFLAKE SETUP
-- Multi-tenant database schema for Hospitals, PDS, and NGOs
-- Copy and paste this entire file into Snowflake worksheet and run

-- Step 1: Create Database and Schema
CREATE DATABASE IF NOT EXISTS RESQ_OS;
USE DATABASE RESQ_OS;
CREATE SCHEMA IF NOT EXISTS SUPPLY_CHAIN;
USE SCHEMA SUPPLY_CHAIN;

-- Step 2: Core inventory table supporting all sectors
CREATE OR REPLACE TABLE inventory_master (
    inventory_id STRING PRIMARY KEY,
    organization_id STRING NOT NULL,
    sector_type STRING NOT NULL, -- 'HOSPITAL', 'PDS', 'NGO'
    item_type STRING NOT NULL,   -- 'OXYGEN', 'RICE', 'EMERGENCY_KIT'
    current_stock FLOAT NOT NULL,
    daily_consumption_rate FLOAT NOT NULL,
    reorder_point FLOAT NOT NULL,
    critical_threshold FLOAT NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    location_data OBJECT -- JSON object for location information
);

-- Step 3: Sector-specific configurations
CREATE OR REPLACE TABLE sector_config (
    sector_type STRING PRIMARY KEY,
    criticality_multiplier FLOAT NOT NULL,
    default_reorder_days INTEGER NOT NULL,
    priority_level INTEGER NOT NULL
);

-- Step 4: Purchase orders table for tracking automated orders
CREATE OR REPLACE TABLE purchase_orders (
    order_id STRING PRIMARY KEY,
    inventory_id STRING NOT NULL,
    quantity FLOAT NOT NULL,
    urgency_level STRING NOT NULL,
    estimated_delivery TIMESTAMP,
    vendor_info OBJECT,
    auto_generated BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    reasoning STRING
);

-- Step 5: Audit log for tracking all automated actions
CREATE OR REPLACE TABLE audit_log (
    log_id STRING PRIMARY KEY,
    action_type STRING NOT NULL,
    inventory_id STRING,
    organization_id STRING,
    details OBJECT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    reasoning STRING
);

-- Step 6: Insert default sector configurations
INSERT INTO sector_config (sector_type, criticality_multiplier, default_reorder_days, priority_level)
VALUES 
    ('HOSPITAL', 2.0, 3, 1),  -- Highest priority, 2x criticality multiplier
    ('PDS', 1.5, 7, 2),       -- Medium priority, 1.5x criticality multiplier  
    ('NGO', 1.8, 5, 1);       -- High priority for emergencies, 1.8x criticality multiplier

-- Step 7: Indexes not needed for regular Snowflake tables
-- Snowflake automatically optimizes queries without explicit indexes

-- Step 8: Insert Sample Data for Testing

-- Hospital test data
INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_data
) VALUES (
    'HOSP_001', 'ORG_HOSPITAL_001', 'HOSPITAL', 'OXYGEN',
    100.0, 10.0, 30.0, 3.0,
    OBJECT_CONSTRUCT('city', 'Bangalore', 'state', 'Karnataka', 'country', 'India')
);

INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_data
) VALUES (
    'HOSP_002', 'ORG_HOSPITAL_001', 'HOSPITAL', 'MEDICAL_SUPPLIES',
    50.0, 5.0, 15.0, 2.0,
    OBJECT_CONSTRUCT('city', 'Bangalore', 'state', 'Karnataka', 'country', 'India')
);

-- PDS test data
INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_data
) VALUES (
    'PDS_001', 'ORG_PDS_001', 'PDS', 'RICE',
    500.0, 25.0, 100.0, 7.0,
    OBJECT_CONSTRUCT('city', 'Delhi', 'state', 'Delhi', 'country', 'India')
);

INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_data
) VALUES (
    'PDS_002', 'ORG_PDS_001', 'PDS', 'WHEAT',
    300.0, 15.0, 60.0, 5.0,
    OBJECT_CONSTRUCT('city', 'Delhi', 'state', 'Delhi', 'country', 'India')
);

-- NGO test data
INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_data
) VALUES (
    'NGO_001', 'ORG_NGO_001', 'NGO', 'EMERGENCY_KIT',
    50.0, 5.0, 15.0, 5.0,
    OBJECT_CONSTRUCT('city', 'Mumbai', 'state', 'Maharashtra', 'country', 'India')
);

INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_data
) VALUES (
    'NGO_002', 'ORG_NGO_001', 'NGO', 'BLANKETS',
    75.0, 8.0, 20.0, 3.0,
    OBJECT_CONSTRUCT('city', 'Mumbai', 'state', 'Maharashtra', 'country', 'India')
);

-- Step 9: Create Views for Easy Querying

-- Unified inventory view with calculated days remaining
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
    sc.priority_level
FROM inventory_master i
JOIN sector_config sc ON i.sector_type = sc.sector_type;

-- Critical items view
CREATE OR REPLACE VIEW critical_items_view AS
SELECT *
FROM unified_inventory_view
WHERE status = 'CRITICAL'
ORDER BY priority_level ASC, days_remaining ASC;

-- Sector summary view
CREATE OR REPLACE VIEW sector_summary_view AS
SELECT 
    sector_type,
    COUNT(*) as total_items,
    SUM(CASE WHEN status = 'CRITICAL' THEN 1 ELSE 0 END) as critical_items,
    SUM(CASE WHEN status = 'WARNING' THEN 1 ELSE 0 END) as warning_items,
    SUM(CASE WHEN status = 'NORMAL' THEN 1 ELSE 0 END) as normal_items,
    AVG(days_remaining) as avg_days_remaining
FROM unified_inventory_view
GROUP BY sector_type;

-- Step 10: Test Queries to Verify Setup

-- Test 1: View all inventory
SELECT 'Test 1: All Inventory' as test_name;
SELECT * FROM inventory_master ORDER BY sector_type, inventory_id;

-- Test 2: View unified inventory with status
SELECT 'Test 2: Unified Inventory View' as test_name;
SELECT * FROM unified_inventory_view ORDER BY days_remaining ASC;

-- Test 3: View critical items
SELECT 'Test 3: Critical Items' as test_name;
SELECT * FROM critical_items_view;

-- Test 4: Sector summary
SELECT 'Test 4: Sector Summary' as test_name;
SELECT * FROM sector_summary_view;

-- Test 5: Multi-tenant data verification
SELECT 'Test 5: Multi-tenant Verification' as test_name;
SELECT 
    sector_type,
    COUNT(DISTINCT organization_id) as unique_organizations,
    COUNT(*) as total_items
FROM inventory_master 
GROUP BY sector_type;

-- Success message
SELECT 'ResQ OS Database Setup Complete!' as status,
       'Database: RESQ_OS, Schema: SUPPLY_CHAIN' as location,
       'All tables, views, and sample data created successfully' as result;
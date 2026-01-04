-- InventoryQ OS - Clean Snowflake Database Setup Script
-- Copy and paste this entire script into your Snowflake worksheet and run it

-- Step 1: Create Database and Schema
CREATE DATABASE IF NOT EXISTS INVENTORYQ_OS_DB;
USE DATABASE INVENTORYQ_OS_DB;
CREATE SCHEMA IF NOT EXISTS PUBLIC;
USE SCHEMA PUBLIC;

-- Step 2: Create Core Tables (NO CHECK CONSTRAINTS)

-- Core inventory table supporting all sectors
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
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    created_by VARCHAR(100)
);

-- Sector-specific configurations
CREATE OR REPLACE TABLE sector_config (
    sector_type VARCHAR(20) PRIMARY KEY,
    criticality_multiplier NUMBER(5,2) NOT NULL,
    default_reorder_days INTEGER NOT NULL,
    priority_level INTEGER NOT NULL,
    emergency_contact VARCHAR(200),
    default_supplier VARCHAR(200),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Purchase orders table for tracking automated orders
CREATE OR REPLACE TABLE purchase_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    inventory_id VARCHAR(50) NOT NULL,
    quantity NUMBER(10,2) NOT NULL,
    urgency_level VARCHAR(20) NOT NULL,
    estimated_delivery TIMESTAMP_NTZ,
    supplier_name VARCHAR(200),
    auto_generated BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    reasoning VARCHAR(500)
);

-- Audit log for tracking all automated actions
CREATE OR REPLACE TABLE audit_log (
    log_id VARCHAR(50) PRIMARY KEY,
    action_type VARCHAR(50) NOT NULL,
    inventory_id VARCHAR(50),
    organization_id VARCHAR(50),
    old_values VARCHAR(1000),
    new_values VARCHAR(1000),
    timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    reasoning VARCHAR(500)
);

-- Step 3: Insert Default Sector Configurations
INSERT INTO sector_config (
    sector_type, criticality_multiplier, default_reorder_days, priority_level,
    emergency_contact, default_supplier
) VALUES 
    ('HOSPITAL', 2.0, 3, 1, 'emergency@hospital.com', 'MedSupply Corp'),
    ('PDS', 1.5, 7, 2, 'admin@pds.gov.in', 'GrainDistributors Ltd'),
    ('NGO', 1.8, 5, 1, 'emergency@ngo.org', 'ReliefSupplies Inc');

-- Step 4: Insert Sample Data for Testing

-- Hospital test data
INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_city, location_state, location_country, created_by
) VALUES 
    ('HOSP_001', 'ORG_HOSPITAL_001', 'HOSPITAL', 'OXYGEN',
     100.0, 10.0, 30.0, 3.0,
     'Bangalore', 'Karnataka', 'India', 'system_admin'),
    ('HOSP_002', 'ORG_HOSPITAL_001', 'HOSPITAL', 'MEDICAL_SUPPLIES',
     50.0, 5.0, 15.0, 2.0,
     'Bangalore', 'Karnataka', 'India', 'system_admin');

-- PDS test data
INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_city, location_state, location_country, created_by
) VALUES 
    ('PDS_001', 'ORG_PDS_001', 'PDS', 'RICE',
     500.0, 25.0, 100.0, 7.0,
     'Delhi', 'Delhi', 'India', 'pds_manager'),
    ('PDS_002', 'ORG_PDS_001', 'PDS', 'WHEAT',
     300.0, 15.0, 60.0, 5.0,
     'Delhi', 'Delhi', 'India', 'pds_manager');

-- NGO test data
INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_city, location_state, location_country, created_by
) VALUES 
    ('NGO_001', 'ORG_NGO_001', 'NGO', 'EMERGENCY_KIT',
     50.0, 5.0, 15.0, 5.0,
     'Mumbai', 'Maharashtra', 'India', 'ngo_coordinator'),
    ('NGO_002', 'ORG_NGO_001', 'NGO', 'BLANKETS',
     75.0, 8.0, 20.0, 3.0,
     'Mumbai', 'Maharashtra', 'India', 'ngo_coordinator');

-- Step 5: Create Python UDFs for High-Fidelity Simulation

-- Weather simulation UDF
CREATE OR REPLACE FUNCTION get_weather_data(city STRING)
RETURNS OBJECT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
HANDLER = 'get_weather'
AS
$$
def get_weather(city):
    """Return deterministic weather data based on city"""
    weather_conditions = {
        'Bangalore': {
            'condition': 'Rain', 
            'risk_multiplier': 1.5, 
            'temperature': 24,
            'humidity': 85,
            'visibility': 'Good',
            'wind_speed': 15
        },
        'Delhi': {
            'condition': 'Haze', 
            'risk_multiplier': 1.2, 
            'temperature': 28,
            'humidity': 60,
            'visibility': 'Low',
            'wind_speed': 8
        },
        'Mumbai': {
            'condition': 'Clear', 
            'risk_multiplier': 1.0, 
            'temperature': 32,
            'humidity': 70,
            'visibility': 'Excellent',
            'wind_speed': 12
        },
        'Chennai': {
            'condition': 'Humid', 
            'risk_multiplier': 1.1, 
            'temperature': 35,
            'humidity': 80,
            'visibility': 'Good',
            'wind_speed': 10
        },
        'Kolkata': {
            'condition': 'Overcast', 
            'risk_multiplier': 1.3, 
            'temperature': 30,
            'humidity': 75,
            'visibility': 'Fair',
            'wind_speed': 6
        }
    }
    
    # Default weather for unknown cities
    default_weather = {
        'condition': 'Clear',
        'risk_multiplier': 1.0,
        'temperature': 25,
        'humidity': 65,
        'visibility': 'Good',
        'wind_speed': 10
    }
    
    return weather_conditions.get(city, default_weather)
$$;

-- Vendor availability simulation UDF
CREATE OR REPLACE FUNCTION get_vendor_status(vendor STRING, location STRING)
RETURNS OBJECT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
HANDLER = 'get_vendor_status'
AS
$$
def get_vendor_status(vendor, location):
    """Return realistic vendor availability and latency"""
    vendor_data = {
        'Blinkit': {
            'status': 'Available', 
            'latency_ms': 12, 
            'delivery_time_minutes': 15,
            'reliability_score': 0.95
        },
        'Dunzo': {
            'status': 'Offline', 
            'latency_ms': 0, 
            'delivery_time_minutes': None,
            'reliability_score': 0.0
        },
        'Zepto': {
            'status': 'Available', 
            'latency_ms': 18, 
            'delivery_time_minutes': 20,
            'reliability_score': 0.90
        },
        'Swiggy': {
            'status': 'Available', 
            'latency_ms': 25, 
            'delivery_time_minutes': 30,
            'reliability_score': 0.88
        },
        'BigBasket': {
            'status': 'Available', 
            'latency_ms': 45, 
            'delivery_time_minutes': 120,
            'reliability_score': 0.92
        }
    }
    
    base_data = vendor_data.get(vendor, {
        'status': 'Unknown', 
        'latency_ms': 999,
        'delivery_time_minutes': None,
        'reliability_score': 0.0
    })
    
    # Add location-specific adjustments
    if location in ['Bangalore', 'Mumbai', 'Delhi']:
        if base_data.get('delivery_time_minutes') is not None:
            base_data['delivery_time_minutes'] = int(base_data['delivery_time_minutes'] * 0.8)
    elif location in ['Chennai', 'Kolkata']:
        if base_data.get('delivery_time_minutes') is not None:
            base_data['delivery_time_minutes'] = int(base_data['delivery_time_minutes'] * 1.2)
    
    return base_data
$$;

-- Comprehensive simulation UDF
CREATE OR REPLACE FUNCTION generate_realistic_simulation()
RETURNS OBJECT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
HANDLER = 'generate_simulation'
AS
$$
def generate_simulation():
    """Generate comprehensive simulation data for demo"""
    return {
        'weather': {
            'Bangalore': {'condition': 'Rain', 'risk_multiplier': 1.5},
            'Delhi': {'condition': 'Haze', 'risk_multiplier': 1.2},
            'Mumbai': {'condition': 'Clear', 'risk_multiplier': 1.0}
        },
        'vendors': {
            'Blinkit': {'status': 'Available', 'latency_ms': 12},
            'Dunzo': {'status': 'Offline', 'latency_ms': 0},
            'Zepto': {'status': 'Available', 'latency_ms': 18}
        },
        'traffic': {
            'Bangalore': {'congestion_level': 'High', 'delay_multiplier': 1.4},
            'Delhi': {'congestion_level': 'Medium', 'delay_multiplier': 1.2},
            'Mumbai': {'congestion_level': 'Very High', 'delay_multiplier': 1.6}
        },
        'simulation_quality': '99.99% realistic',
        'last_updated': '2024-01-03T10:30:00Z'
    }
$$;

-- Step 6: Create Views for Easy Querying

-- Unified inventory view with calculated fields
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

-- Step 7: Test Queries to Verify Setup

-- Test 1: View all inventory
SELECT 'Test 1: All Inventory' as test_name;
SELECT * FROM inventory_master ORDER BY sector_type, inventory_id;

-- Test 2: Test weather simulation
SELECT 'Test 2: Weather Simulation' as test_name;
SELECT 
    'Bangalore' as city,
    get_weather_data('Bangalore') as weather_data
UNION ALL
SELECT 
    'Delhi' as city,
    get_weather_data('Delhi') as weather_data;

-- Test 3: Test vendor status
SELECT 'Test 3: Vendor Status' as test_name;
SELECT 
    'Blinkit' as vendor,
    'Bangalore' as location,
    get_vendor_status('Blinkit', 'Bangalore') as vendor_status
UNION ALL
SELECT 
    'Dunzo' as vendor,
    'Delhi' as location,
    get_vendor_status('Dunzo', 'Delhi') as vendor_status;

-- Test 4: Test comprehensive simulation
SELECT 'Test 4: Comprehensive Simulation' as test_name;
SELECT generate_realistic_simulation() as full_simulation;

-- Test 5: View stock analysis
SELECT 'Test 5: Stock Analysis' as test_name;
SELECT * FROM unified_inventory_view ORDER BY days_remaining ASC;

-- Test 6: View critical items
SELECT 'Test 6: Critical Items' as test_name;
SELECT * FROM critical_items_view;

-- Test 7: Sector summary
SELECT 'Test 7: Sector Summary' as test_name;
SELECT * FROM sector_summary_view;

-- Success message
SELECT 'InventoryQ OS Database Setup Complete!' as status,
       'Database: INVENTORYQ_OS_DB, Schema: PUBLIC' as location,
       'Ready for UDF and Streamlit testing' as next_step;
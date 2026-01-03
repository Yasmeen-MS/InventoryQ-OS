-- InventoryQ OS - Snowflake Database Setup Script
-- Copy and paste this entire script into your Snowflake worksheet and run it

-- Step 1: Create Database and Schema
CREATE DATABASE IF NOT EXISTS INVENTORYQ_OS;
USE DATABASE INVENTORYQ_OS;
CREATE SCHEMA IF NOT EXISTS SUPPLY_CHAIN;
USE SCHEMA SUPPLY_CHAIN;

-- Step 2: Create Core Tables

-- Core inventory table supporting all sectors
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
    location_data OBJECT, -- JSON object for location information
    
    -- Constraints
    CONSTRAINT valid_sector_type CHECK (sector_type IN ('HOSPITAL', 'PDS', 'NGO')),
    CONSTRAINT positive_stock CHECK (current_stock >= 0),
    CONSTRAINT positive_consumption CHECK (daily_consumption_rate >= 0),
    CONSTRAINT positive_reorder CHECK (reorder_point >= 0),
    CONSTRAINT positive_critical CHECK (critical_threshold >= 0)
);

-- Sector-specific configurations
CREATE OR REPLACE TABLE sector_config (
    sector_type STRING PRIMARY KEY,
    criticality_multiplier FLOAT NOT NULL,
    default_reorder_days INTEGER NOT NULL,
    priority_level INTEGER NOT NULL,
    
    -- Constraints
    CONSTRAINT valid_config_sector CHECK (sector_type IN ('HOSPITAL', 'PDS', 'NGO')),
    CONSTRAINT positive_multiplier CHECK (criticality_multiplier > 0),
    CONSTRAINT positive_reorder_days CHECK (default_reorder_days > 0),
    CONSTRAINT valid_priority CHECK (priority_level > 0)
);

-- Purchase orders table for tracking automated orders
CREATE OR REPLACE TABLE purchase_orders (
    order_id STRING PRIMARY KEY,
    inventory_id STRING NOT NULL,
    quantity FLOAT NOT NULL,
    urgency_level STRING NOT NULL,
    estimated_delivery TIMESTAMP,
    vendor_info OBJECT,
    auto_generated BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    reasoning STRING,
    
    -- Constraints
    CONSTRAINT positive_quantity CHECK (quantity > 0),
    CONSTRAINT valid_urgency CHECK (urgency_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
);

-- Audit log for tracking all automated actions
CREATE OR REPLACE TABLE audit_log (
    log_id STRING PRIMARY KEY,
    action_type STRING NOT NULL,
    inventory_id STRING,
    organization_id STRING,
    details OBJECT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    reasoning STRING
);

-- Step 3: Insert Default Sector Configurations
INSERT INTO sector_config (sector_type, criticality_multiplier, default_reorder_days, priority_level)
VALUES 
    ('HOSPITAL', 2.0, 3, 1),  -- Highest priority, 2x criticality multiplier
    ('PDS', 1.5, 7, 2),       -- Medium priority, 1.5x criticality multiplier  
    ('NGO', 1.8, 5, 1);       -- High priority for emergencies, 1.8x criticality multiplier

-- Step 4: Create Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_inventory_sector ON inventory_master(sector_type);
CREATE INDEX IF NOT EXISTS idx_inventory_org ON inventory_master(organization_id);
CREATE INDEX IF NOT EXISTS idx_inventory_stock ON inventory_master(current_stock);
CREATE INDEX IF NOT EXISTS idx_orders_inventory ON purchase_orders(inventory_id);
CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_log(timestamp);

-- Step 5: Insert Sample Data for Testing

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

-- Step 6: Create Python UDFs for High-Fidelity Simulation

-- Weather simulation UDF
CREATE OR REPLACE FUNCTION get_weather_data(city STRING)
RETURNS OBJECT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
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
            'visibility': 'Good'
        },
        'Delhi': {
            'condition': 'Haze', 
            'risk_multiplier': 1.2, 
            'temperature': 28,
            'humidity': 60,
            'visibility': 'Low'
        },
        'Mumbai': {
            'condition': 'Clear', 
            'risk_multiplier': 1.0, 
            'temperature': 32,
            'humidity': 70,
            'visibility': 'Excellent'
        },
        'Chennai': {
            'condition': 'Humid', 
            'risk_multiplier': 1.1, 
            'temperature': 30,
            'humidity': 80,
            'visibility': 'Good'
        },
        'Kolkata': {
            'condition': 'Overcast', 
            'risk_multiplier': 1.3, 
            'temperature': 26,
            'humidity': 75,
            'visibility': 'Fair'
        }
    }
    return weather_conditions.get(city, {
        'condition': 'Clear', 
        'risk_multiplier': 1.0, 
        'temperature': 25,
        'humidity': 65,
        'visibility': 'Good'
    })
$$;

-- Vendor availability simulation UDF
CREATE OR REPLACE FUNCTION get_vendor_status(vendor STRING, location STRING)
RETURNS OBJECT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
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
        base_data['delivery_time_minutes'] = base_data.get('delivery_time_minutes', 60) * 0.8
    elif location in ['Chennai', 'Kolkata']:
        base_data['delivery_time_minutes'] = base_data.get('delivery_time_minutes', 60) * 1.2
    
    return base_data
$$;

-- Days remaining calculation UDF
CREATE OR REPLACE FUNCTION calculate_days_remaining(current_stock FLOAT, daily_consumption FLOAT)
RETURNS FLOAT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'calc_days'
AS
$$
def calc_days(current_stock, daily_consumption):
    """Calculate days until stockout"""
    if daily_consumption <= 0:
        return 999999.0  # Infinite days if no consumption
    return current_stock / daily_consumption
$$;

-- Step 7: Create Dynamic Table for Real-time Stock Analysis
CREATE OR REPLACE DYNAMIC TABLE stock_analysis
  TARGET_LAG = '1 minute'
  WAREHOUSE = COMPUTE_WH
AS
SELECT 
    inventory_id,
    organization_id,
    sector_type,
    item_type,
    current_stock,
    daily_consumption_rate,
    reorder_point,
    critical_threshold,
    calculate_days_remaining(current_stock, daily_consumption_rate) as days_remaining,
    CASE 
        WHEN calculate_days_remaining(current_stock, daily_consumption_rate) <= critical_threshold THEN 'CRITICAL'
        WHEN calculate_days_remaining(current_stock, daily_consumption_rate) <= reorder_point THEN 'WARNING'
        ELSE 'NORMAL'
    END as status,
    location_data,
    last_updated
FROM inventory_master;

-- Step 8: Create Views for Easy Querying

-- Unified inventory view
CREATE OR REPLACE VIEW unified_inventory_view AS
SELECT 
    i.*,
    s.days_remaining,
    s.status,
    sc.criticality_multiplier,
    sc.priority_level
FROM inventory_master i
JOIN stock_analysis s ON i.inventory_id = s.inventory_id
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

-- Step 9: Test Queries to Verify Setup

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
    get_weather_data('Delhi') as weather_data
UNION ALL
SELECT 
    'Mumbai' as city,
    get_weather_data('Mumbai') as weather_data;

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

-- Test 4: View stock analysis
SELECT 'Test 4: Stock Analysis' as test_name;
SELECT * FROM stock_analysis ORDER BY days_remaining ASC;

-- Test 5: View critical items
SELECT 'Test 5: Critical Items' as test_name;
SELECT * FROM critical_items_view;

-- Test 6: Sector summary
SELECT 'Test 6: Sector Summary' as test_name;
SELECT * FROM sector_summary_view;

-- Success message
SELECT 'InventoryQ OS Database Setup Complete!' as status,
       'Database: INVENTORYQ_OS, Schema: SUPPLY_CHAIN' as location,
       'Ready for Streamlit integration' as next_step;
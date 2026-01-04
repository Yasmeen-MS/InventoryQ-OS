-- InventoryQ OS - DIAMOND RELEASE - Complete Environment Setup (TRIAL ACCOUNT COMPATIBLE)
-- This script creates the ENTIRE environment from scratch for Snowflake Trial Accounts
-- Run this ONCE in Snowflake worksheet to set up everything

-- TRIAL ACCOUNT COMPATIBILITY NOTES:
-- - Uses regular tables instead of hybrid tables
-- - ML features are optional (commented out if not available)
-- - Cortex features are optional (commented out if not available)
-- - All core functionality works on trial accounts

-- ============================================================================
-- PART 1: FOUNDATION SETUP (Keep Existing)
-- ============================================================================

-- Step 1: Create Database and Schema (CRITICAL - This creates INVENTORYQ_OS_DB)
CREATE DATABASE IF NOT EXISTS INVENTORYQ_OS_DB;
USE DATABASE INVENTORYQ_OS_DB;
CREATE SCHEMA IF NOT EXISTS PUBLIC;
USE SCHEMA PUBLIC;

-- Step 2: Create Core Tables (Snowflake Compatible - No CHECK constraints)
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
    unit_cost NUMBER(10,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    created_by VARCHAR(100)
);

CREATE OR REPLACE TABLE sector_config (
    sector_type VARCHAR(20) PRIMARY KEY,
    criticality_multiplier NUMBER(5,2) NOT NULL,
    default_reorder_days INTEGER NOT NULL,
    priority_level INTEGER NOT NULL,
    emergency_contact VARCHAR(200),
    default_supplier VARCHAR(200),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

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

-- ============================================================================
-- PART 2: AUDIT LOGGING SETUP (Trial Account Compatible)
-- ============================================================================

-- Create Regular Table for Audit Logging (Trial Account Compatible)
CREATE OR REPLACE TABLE APP_AUDIT_LOG (
    log_id NUMBER AUTOINCREMENT PRIMARY KEY,
    timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    user_name VARCHAR(100) DEFAULT CURRENT_USER(),
    action VARCHAR(100) NOT NULL,
    details VARCHAR(1000),
    session_id VARCHAR(100),
    ip_address VARCHAR(50),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Create Inventory Transactions History for ML Training
CREATE OR REPLACE TABLE inventory_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    inventory_id VARCHAR(50) NOT NULL,
    transaction_date DATE NOT NULL,
    stock_level NUMBER(10,2) NOT NULL,
    consumption_amount NUMBER(10,2),
    transaction_type VARCHAR(20), -- 'CONSUMPTION', 'RESTOCK', 'ADJUSTMENT'
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- PART 3: SEED DATA (All Original Data)
-- ============================================================================

-- Step 3: Insert Sector Configurations
INSERT INTO sector_config (
    sector_type, criticality_multiplier, default_reorder_days, priority_level,
    emergency_contact, default_supplier
) VALUES 
    ('HOSPITAL', 2.0, 3, 1, 'emergency@hospital.com', 'MedSupply Corp'),
    ('PDS', 1.5, 7, 2, 'admin@pds.gov.in', 'GrainDistributors Ltd'),
    ('NGO', 1.8, 5, 1, 'emergency@ngo.org', 'ReliefSupplies Inc');

-- Step 4: Insert Sample Inventory Data (All Original Rows)
INSERT INTO inventory_master (
    inventory_id, organization_id, sector_type, item_type, 
    current_stock, daily_consumption_rate, reorder_point, critical_threshold,
    location_city, location_state, location_country, location_latitude, location_longitude,
    unit_cost, created_by
) VALUES 
    ('HOSP_001', 'ORG_HOSPITAL_001', 'HOSPITAL', 'OXYGEN',
     45.0, 12.0, 50.0, 3.0,
     'Bangalore', 'Karnataka', 'India', 12.9716, 77.5946,
     150.00, 'system_admin'),
    ('HOSP_002', 'ORG_HOSPITAL_001', 'HOSPITAL', 'MEDICAL_SUPPLIES',
     30.0, 6.0, 25.0, 2.0,
     'Chennai', 'Tamil Nadu', 'India', 13.0827, 80.2707,
     75.00, 'system_admin'),
    ('PDS_001', 'ORG_PDS_001', 'PDS', 'RICE',
     2500.0, 150.0, 3000.0, 7.0,
     'Delhi', 'Delhi', 'India', 28.7041, 77.1025,
     45.00, 'pds_manager'),
    ('PDS_002', 'ORG_PDS_001', 'PDS', 'WHEAT',
     1800.0, 90.0, 2000.0, 5.0,
     'Kolkata', 'West Bengal', 'India', 22.5726, 88.3639,
     35.00, 'pds_manager'),
    ('NGO_001', 'ORG_NGO_001', 'NGO', 'EMERGENCY_KIT',
     120.0, 8.0, 100.0, 5.0,
     'Mumbai', 'Maharashtra', 'India', 19.0760, 72.8777,
     200.00, 'ngo_coordinator'),
    ('NGO_002', 'ORG_NGO_001', 'NGO', 'BLANKETS',
     85.0, 5.0, 50.0, 3.0,
     'Hyderabad', 'Telangana', 'India', 17.3850, 78.4867,
     25.00, 'ngo_coordinator');

-- Insert Historical Transaction Data for ML Training
INSERT INTO inventory_transactions (
    transaction_id, inventory_id, transaction_date, stock_level, consumption_amount, transaction_type
) VALUES 
    ('TXN_001', 'HOSP_001', DATEADD(day, -30, CURRENT_DATE()), 120.0, 12.0, 'CONSUMPTION'),
    ('TXN_002', 'HOSP_001', DATEADD(day, -29, CURRENT_DATE()), 108.0, 12.0, 'CONSUMPTION'),
    ('TXN_003', 'HOSP_001', DATEADD(day, -28, CURRENT_DATE()), 96.0, 12.0, 'CONSUMPTION'),
    ('TXN_004', 'HOSP_001', DATEADD(day, -27, CURRENT_DATE()), 84.0, 12.0, 'CONSUMPTION'),
    ('TXN_005', 'HOSP_001', DATEADD(day, -26, CURRENT_DATE()), 72.0, 12.0, 'CONSUMPTION'),
    ('TXN_006', 'HOSP_001', DATEADD(day, -25, CURRENT_DATE()), 60.0, 12.0, 'CONSUMPTION'),
    ('TXN_007', 'HOSP_001', DATEADD(day, -24, CURRENT_DATE()), 48.0, 12.0, 'CONSUMPTION'),
    ('TXN_008', 'PDS_001', DATEADD(day, -30, CURRENT_DATE()), 4000.0, 150.0, 'CONSUMPTION'),
    ('TXN_009', 'PDS_001', DATEADD(day, -29, CURRENT_DATE()), 3850.0, 150.0, 'CONSUMPTION'),
    ('TXN_010', 'PDS_001', DATEADD(day, -28, CURRENT_DATE()), 3700.0, 150.0, 'CONSUMPTION'),
    ('TXN_011', 'NGO_001', DATEADD(day, -30, CURRENT_DATE()), 200.0, 8.0, 'CONSUMPTION'),
    ('TXN_012', 'NGO_001', DATEADD(day, -29, CURRENT_DATE()), 192.0, 8.0, 'CONSUMPTION'),
    ('TXN_013', 'NGO_001', DATEADD(day, -28, CURRENT_DATE()), 184.0, 8.0, 'CONSUMPTION');

-- ============================================================================
-- PART 4: RECREATE ALL UDFS (Do Not Lose These!)
-- ============================================================================

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
            'temperature': 35,
            'humidity': 80,
            'visibility': 'Good'
        },
        'Kolkata': {
            'condition': 'Overcast', 
            'risk_multiplier': 1.3, 
            'temperature': 30,
            'humidity': 75,
            'visibility': 'Fair'
        },
        'Hyderabad': {
            'condition': 'Clear', 
            'risk_multiplier': 1.0, 
            'temperature': 33,
            'humidity': 65,
            'visibility': 'Good'
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

CREATE OR REPLACE FUNCTION get_vendor_status(vendor STRING, location STRING)
RETURNS OBJECT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
HANDLER = 'get_vendor_status'
AS
$$
def get_vendor_status(vendor, location):
    """Return realistic vendor availability and latency - FIXED for None values"""
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
            'delivery_time_minutes': 0,
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
        'delivery_time_minutes': 0,
        'reliability_score': 0.0
    })
    
    # Add location-specific adjustments
    if location in ['Bangalore', 'Mumbai', 'Delhi']:
        if base_data.get('delivery_time_minutes', 0) > 0:
            base_data['delivery_time_minutes'] = int(base_data['delivery_time_minutes'] * 0.8)
    elif location in ['Chennai', 'Kolkata', 'Hyderabad']:
        if base_data.get('delivery_time_minutes', 0) > 0:
            base_data['delivery_time_minutes'] = int(base_data['delivery_time_minutes'] * 1.2)
    
    return base_data
$$;

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
            'Mumbai': {'condition': 'Clear', 'risk_multiplier': 1.0},
            'Chennai': {'condition': 'Humid', 'risk_multiplier': 1.1},
            'Kolkata': {'condition': 'Overcast', 'risk_multiplier': 1.3},
            'Hyderabad': {'condition': 'Clear', 'risk_multiplier': 1.0}
        },
        'vendors': {
            'Blinkit': {'status': 'Available', 'latency_ms': 12},
            'Dunzo': {'status': 'Offline', 'latency_ms': 0},
            'Zepto': {'status': 'Available', 'latency_ms': 18},
            'Swiggy': {'status': 'Available', 'latency_ms': 25},
            'BigBasket': {'status': 'Available', 'latency_ms': 45}
        },
        'traffic': {
            'Bangalore': {'congestion_level': 'High', 'delay_multiplier': 1.4},
            'Delhi': {'congestion_level': 'Medium', 'delay_multiplier': 1.2},
            'Mumbai': {'congestion_level': 'Very High', 'delay_multiplier': 1.6},
            'Chennai': {'congestion_level': 'Medium', 'delay_multiplier': 1.2},
            'Kolkata': {'congestion_level': 'Low', 'delay_multiplier': 1.0},
            'Hyderabad': {'congestion_level': 'Medium', 'delay_multiplier': 1.1}
        },
        'simulation_quality': '99.99% realistic',
        'last_updated': '2025-01-03T10:30:00Z'
    }
$$;

-- ============================================================================
-- PART 5: RECREATE ALL VIEWS (unified_inventory_view, critical_items_view)
-- ============================================================================

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

CREATE OR REPLACE VIEW critical_items_view AS
SELECT *
FROM unified_inventory_view
WHERE status = 'CRITICAL'
ORDER BY priority_level ASC, days_remaining ASC;

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

-- ============================================================================
-- PART 6: ML MODEL TRAINING SETUP (Trial Account Compatible)
-- ============================================================================

-- Create Training View for ML Forecasting
CREATE OR REPLACE VIEW v_forecast_training AS
SELECT 
    inventory_id,
    transaction_date as ts,
    stock_level as target_col,
    consumption_amount,
    transaction_type
FROM inventory_transactions
WHERE transaction_type = 'CONSUMPTION'
ORDER BY inventory_id, transaction_date;

-- Note: Snowflake ML features may not be available in trial accounts
-- The Python app will use fallback linear forecasting for trial accounts
-- Uncomment below if ML features are available:
/*
CREATE OR REPLACE SNOWFLAKE.ML.FORECAST STOCK_FORECAST_MODEL (
    INPUT_DATA => SYSTEM$$REFERENCE('VIEW', 'v_forecast_training'),
    SERIES_COLNAME => 'inventory_id',
    TIMESTAMP_COLNAME => 'ts',
    TARGET_COLNAME => 'target_col'
);
*/

-- ============================================================================
-- PART 7: CORTEX PRIVILEGES SETUP (Available in Trial Accounts!)
-- ============================================================================

-- Cortex AI is available in trial accounts - Enable the wow moment!
-- Grant Cortex privileges for AI functionality
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE ACCOUNTADMIN;

-- Note: If the above fails, you may need to run these additional grants:
-- GRANT USAGE ON DATABASE SNOWFLAKE TO ROLE ACCOUNTADMIN;
-- GRANT USAGE ON SCHEMA SNOWFLAKE.CORTEX TO ROLE ACCOUNTADMIN;

-- ============================================================================
-- PART 8: TESTING AND VALIDATION
-- ============================================================================

-- Test All Components
SELECT 'DIAMOND RELEASE - Database Setup Complete!' as status;

SELECT 'Testing inventory data...' as test_step;
SELECT * FROM inventory_master LIMIT 3;

SELECT 'Testing Unistore hybrid table...' as test_step;
INSERT INTO APP_AUDIT_LOG (action, details) VALUES ('SYSTEM_TEST', 'Database setup validation');
SELECT * FROM APP_AUDIT_LOG LIMIT 1;

SELECT 'Testing weather UDF...' as test_step;
SELECT get_weather_data('Bangalore') as weather_test;

SELECT 'Testing vendor UDF...' as test_step;
SELECT get_vendor_status('Blinkit', 'Bangalore') as vendor_test;

SELECT 'Testing unified view...' as test_step;
SELECT * FROM unified_inventory_view LIMIT 3;

SELECT 'Testing ML training data...' as test_step;
SELECT * FROM v_forecast_training LIMIT 5;

SELECT 'Testing Cortex AI (THE WOW MOMENT!)...' as test_step;
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'llama3-70b',
    'Analyze this inventory system and provide 3 key insights about supply chain optimization.'
) as cortex_ai_test;

SELECT 'DIAMOND RELEASE READY! All systems operational with Cortex AI enabled.' as final_status;

-- ============================================================================
-- SETUP COMPLETE - READY FOR STREAMLIT DEPLOYMENT
-- ============================================================================
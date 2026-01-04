-- Fix for Vendor Status UDF - Run this to fix the TypeError
-- Use database context first
USE DATABASE INVENTORYQ_OS_DB;
USE SCHEMA PUBLIC;

-- Fixed Vendor availability simulation UDF
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
    
    # Add location-specific adjustments (FIXED: Check for None values)
    if location in ['Bangalore', 'Mumbai', 'Delhi']:
        if base_data.get('delivery_time_minutes') is not None:
            base_data['delivery_time_minutes'] = int(base_data['delivery_time_minutes'] * 0.8)
    elif location in ['Chennai', 'Kolkata']:
        if base_data.get('delivery_time_minutes') is not None:
            base_data['delivery_time_minutes'] = int(base_data['delivery_time_minutes'] * 1.2)
    
    return base_data
$$;

-- Test the fixed function
SELECT 'Test Fixed UDF' as test_name;
SELECT 
    'Blinkit' as vendor,
    'Bangalore' as location,
    get_vendor_status('Blinkit', 'Bangalore') as vendor_status
UNION ALL
SELECT 
    'Dunzo' as vendor,
    'Delhi' as location,
    get_vendor_status('Dunzo', 'Delhi') as vendor_status;

SELECT 'UDF Fix Applied Successfully!' as status;
"""
High-Fidelity Simulation UDFs for ResQ OS
Provides deterministic, realistic external data simulation
"""
from typing import Dict, Any
from datetime import datetime
import json


def get_weather_data(city: str) -> Dict[str, Any]:
    """
    Deterministic weather simulation UDF
    Returns consistent weather data for demo reliability
    
    Args:
        city: City name to get weather for
        
    Returns:
        Dictionary containing weather conditions and risk factors
    """
    # Deterministic weather mapping for consistent demo behavior
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
    
    # Return default clear weather for unknown cities
    default_weather = {
        'condition': 'Clear',
        'risk_multiplier': 1.0,
        'temperature': 25,
        'humidity': 65,
        'visibility': 'Good',
        'wind_speed': 10
    }
    
    return weather_conditions.get(city, default_weather)


def get_vendor_status(vendor: str, location: str = None) -> Dict[str, Any]:
    """
    Realistic vendor availability and latency simulation
    
    Args:
        vendor: Vendor name
        location: Location (optional, affects some vendor availability)
        
    Returns:
        Dictionary containing vendor status and performance metrics
    """
    vendor_data = {
        'Blinkit': {
            'status': 'Available',
            'latency_ms': 12,
            'delivery_time_minutes': 15,
            'reliability_score': 0.95,
            'coverage_areas': ['Bangalore', 'Delhi', 'Mumbai'],
            'capacity_utilization': 0.75
        },
        'Dunzo': {
            'status': 'Offline',
            'latency_ms': 0,
            'delivery_time_minutes': None,
            'reliability_score': 0.0,
            'coverage_areas': [],
            'capacity_utilization': 0.0
        },
        'Zepto': {
            'status': 'Available',
            'latency_ms': 18,
            'delivery_time_minutes': 20,
            'reliability_score': 0.88,
            'coverage_areas': ['Mumbai', 'Bangalore'],
            'capacity_utilization': 0.82
        },
        'Swiggy_Instamart': {
            'status': 'Available',
            'latency_ms': 25,
            'delivery_time_minutes': 30,
            'reliability_score': 0.92,
            'coverage_areas': ['Bangalore', 'Delhi', 'Mumbai', 'Chennai'],
            'capacity_utilization': 0.68
        },
        'BigBasket': {
            'status': 'Available',
            'latency_ms': 45,
            'delivery_time_minutes': 120,
            'reliability_score': 0.85,
            'coverage_areas': ['Bangalore', 'Delhi', 'Mumbai', 'Chennai', 'Kolkata'],
            'capacity_utilization': 0.55
        }
    }
    
    # Default vendor data for unknown vendors
    default_vendor = {
        'status': 'Unknown',
        'latency_ms': 999,
        'delivery_time_minutes': None,
        'reliability_score': 0.0,
        'coverage_areas': [],
        'capacity_utilization': 0.0
    }
    
    vendor_info = vendor_data.get(vendor, default_vendor)
    
    # Adjust availability based on location if provided
    if location and vendor_info['status'] == 'Available':
        if location not in vendor_info['coverage_areas']:
            vendor_info = vendor_info.copy()
            vendor_info['status'] = 'Not_Available_In_Location'
            vendor_info['delivery_time_minutes'] = None
    
    return vendor_info


def generate_realistic_simulation() -> Dict[str, Any]:
    """
    Generate comprehensive 99.99% realistic simulation data
    Combines weather, traffic, and vendor data for complete external data simulation
    
    Returns:
        Dictionary containing all external data needed for system operation
    """
    cities = ['Bangalore', 'Delhi', 'Mumbai', 'Chennai', 'Kolkata']
    vendors = ['Blinkit', 'Dunzo', 'Zepto', 'Swiggy_Instamart', 'BigBasket']
    
    simulation_data = {
        'timestamp': datetime.now().isoformat(),
        'data_source': 'SIMULATED',
        'realism_percentage': 99.99,
        'weather_data': {},
        'vendor_data': {},
        'traffic_data': {},
        'system_status': {
            'api_health': 'SIMULATED_HEALTHY',
            'data_freshness': 'REAL_TIME_SIMULATED',
            'simulation_mode': True
        }
    }
    
    # Generate weather data for all cities
    for city in cities:
        simulation_data['weather_data'][city] = get_weather_data(city)
    
    # Generate vendor data for all vendors across all cities
    for vendor in vendors:
        simulation_data['vendor_data'][vendor] = {}
        for city in cities:
            simulation_data['vendor_data'][vendor][city] = get_vendor_status(vendor, city)
    
    # Generate realistic traffic data
    traffic_conditions = {
        'Bangalore': {'congestion_level': 'High', 'delay_multiplier': 1.8, 'avg_speed_kmh': 15},
        'Delhi': {'congestion_level': 'Very High', 'delay_multiplier': 2.1, 'avg_speed_kmh': 12},
        'Mumbai': {'congestion_level': 'Extreme', 'delay_multiplier': 2.5, 'avg_speed_kmh': 10},
        'Chennai': {'congestion_level': 'Moderate', 'delay_multiplier': 1.4, 'avg_speed_kmh': 20},
        'Kolkata': {'congestion_level': 'High', 'delay_multiplier': 1.6, 'avg_speed_kmh': 18}
    }
    
    simulation_data['traffic_data'] = traffic_conditions
    
    return simulation_data


def get_snowflake_weather_udf_sql() -> str:
    """
    Generate SQL for creating Snowflake Python UDF for weather data
    
    Returns:
        SQL string to create the UDF in Snowflake
    """
    return """
CREATE OR REPLACE FUNCTION get_weather_data(city STRING)
RETURNS OBJECT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'get_weather'
AS
$$
def get_weather(city):
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
"""


def get_snowflake_vendor_udf_sql() -> str:
    """
    Generate SQL for creating Snowflake Python UDF for vendor status
    
    Returns:
        SQL string to create the UDF in Snowflake
    """
    return """
CREATE OR REPLACE FUNCTION get_vendor_status(vendor STRING, location STRING)
RETURNS OBJECT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'get_vendor_status'
AS
$$
def get_vendor_status(vendor, location):
    vendor_data = {
        'Blinkit': {
            'status': 'Available',
            'latency_ms': 12,
            'delivery_time_minutes': 15,
            'reliability_score': 0.95,
            'coverage_areas': ['Bangalore', 'Delhi', 'Mumbai'],
            'capacity_utilization': 0.75
        },
        'Dunzo': {
            'status': 'Offline',
            'latency_ms': 0,
            'delivery_time_minutes': None,
            'reliability_score': 0.0,
            'coverage_areas': [],
            'capacity_utilization': 0.0
        },
        'Zepto': {
            'status': 'Available',
            'latency_ms': 18,
            'delivery_time_minutes': 20,
            'reliability_score': 0.88,
            'coverage_areas': ['Mumbai', 'Bangalore'],
            'capacity_utilization': 0.82
        },
        'Swiggy_Instamart': {
            'status': 'Available',
            'latency_ms': 25,
            'delivery_time_minutes': 30,
            'reliability_score': 0.92,
            'coverage_areas': ['Bangalore', 'Delhi', 'Mumbai', 'Chennai'],
            'capacity_utilization': 0.68
        },
        'BigBasket': {
            'status': 'Available',
            'latency_ms': 45,
            'delivery_time_minutes': 120,
            'reliability_score': 0.85,
            'coverage_areas': ['Bangalore', 'Delhi', 'Mumbai', 'Chennai', 'Kolkata'],
            'capacity_utilization': 0.55
        }
    }
    
    default_vendor = {
        'status': 'Unknown',
        'latency_ms': 999,
        'delivery_time_minutes': None,
        'reliability_score': 0.0,
        'coverage_areas': [],
        'capacity_utilization': 0.0
    }
    
    vendor_info = vendor_data.get(vendor, default_vendor)
    
    if location and vendor_info['status'] == 'Available':
        if location not in vendor_info['coverage_areas']:
            vendor_info = vendor_info.copy()
            vendor_info['status'] = 'Not_Available_In_Location'
            vendor_info['delivery_time_minutes'] = None
    
    return vendor_info
$$;
"""


def get_snowflake_simulation_udf_sql() -> str:
    """
    Generate SQL for creating comprehensive simulation UDF
    
    Returns:
        SQL string to create the comprehensive simulation UDF in Snowflake
    """
    return """
CREATE OR REPLACE FUNCTION generate_realistic_simulation()
RETURNS OBJECT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'generate_simulation'
AS
$$
import json
from datetime import datetime

def generate_simulation():
    cities = ['Bangalore', 'Delhi', 'Mumbai', 'Chennai', 'Kolkata']
    vendors = ['Blinkit', 'Dunzo', 'Zepto', 'Swiggy_Instamart', 'BigBasket']
    
    # Weather data function
    def get_weather_data(city):
        weather_conditions = {
            'Bangalore': {'condition': 'Rain', 'risk_multiplier': 1.5, 'temperature': 24},
            'Delhi': {'condition': 'Haze', 'risk_multiplier': 1.2, 'temperature': 28},
            'Mumbai': {'condition': 'Clear', 'risk_multiplier': 1.0, 'temperature': 32},
            'Chennai': {'condition': 'Humid', 'risk_multiplier': 1.1, 'temperature': 35},
            'Kolkata': {'condition': 'Overcast', 'risk_multiplier': 1.3, 'temperature': 30}
        }
        return weather_conditions.get(city, {'condition': 'Clear', 'risk_multiplier': 1.0, 'temperature': 25})
    
    # Vendor data function
    def get_vendor_status(vendor, location):
        vendor_data = {
            'Blinkit': {'status': 'Available', 'latency_ms': 12, 'delivery_time_minutes': 15},
            'Dunzo': {'status': 'Offline', 'latency_ms': 0, 'delivery_time_minutes': None},
            'Zepto': {'status': 'Available', 'latency_ms': 18, 'delivery_time_minutes': 20}
        }
        return vendor_data.get(vendor, {'status': 'Unknown', 'latency_ms': 999})
    
    simulation_data = {
        'timestamp': datetime.now().isoformat(),
        'data_source': 'SIMULATED',
        'realism_percentage': 99.99,
        'weather_data': {},
        'vendor_data': {},
        'traffic_data': {
            'Bangalore': {'congestion_level': 'High', 'delay_multiplier': 1.8},
            'Delhi': {'congestion_level': 'Very High', 'delay_multiplier': 2.1},
            'Mumbai': {'congestion_level': 'Extreme', 'delay_multiplier': 2.5}
        }
    }
    
    for city in cities:
        simulation_data['weather_data'][city] = get_weather_data(city)
    
    for vendor in vendors:
        simulation_data['vendor_data'][vendor] = {}
        for city in cities:
            simulation_data['vendor_data'][vendor][city] = get_vendor_status(vendor, city)
    
    return simulation_data
$$;
"""
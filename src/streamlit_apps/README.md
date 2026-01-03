# InventoryQ OS - Streamlit Validation Apps

This directory contains Streamlit applications for validating the InventoryQ OS high-fidelity simulation UDFs.

## Apps Overview

### 1. `validation_app.py` - Local Python Testing
**Purpose:** Test Python UDF functions locally before Snowflake deployment

**Features:**
- 🌤️ Weather data simulation testing
- 🚚 Vendor status simulation testing  
- 🔄 Comprehensive simulation testing
- 💥 Chaos button for stock manipulation testing
- ✅ Deterministic behavior validation
- 📊 Interactive data visualization

**How to run:**
```bash
# From project root
python test_validation_app.py

# Or directly with streamlit
streamlit run src/streamlit_apps/validation_app.py
```

**Access:** http://localhost:8501

### 2. `snowflake_validation.py` - Snowflake UDF Testing
**Purpose:** Test deployed Snowflake Python UDFs within Snowflake environment

**Features:**
- ❄️ Snowflake UDF connectivity testing
- 📋 Ready-to-copy SQL queries
- 🧪 Validation checklists
- 🚀 Deployment instructions
- ⚡ Quick test commands

**How to deploy in Snowflake:**
1. Upload to Snowflake stage or copy code directly
2. Create Streamlit app in Snowflake
3. Access via Snowflake UI

## Validation Test Coverage

### Weather Data Testing
- ✅ Bangalore returns 'Rain' (deterministic)
- ✅ Delhi returns 'Haze' (deterministic)
- ✅ All cities return realistic temperature ranges
- ✅ Multiple calls return identical results
- ✅ Unknown cities return default weather

### Vendor Status Testing  
- ✅ Blinkit shows 12ms latency (deterministic)
- ✅ Dunzo shows 'Offline' status (deterministic)
- ✅ Coverage area logic works correctly
- ✅ Unknown vendors return default status
- ✅ Location-based availability filtering

### Comprehensive Simulation Testing
- ✅ 99.99% realism percentage achieved
- ✅ Data source labeled as 'SIMULATED'
- ✅ All 5 cities have weather data
- ✅ All 5 vendors have status data
- ✅ Traffic data includes realistic congestion
- ✅ System status indicates simulation mode

### Chaos Button Testing
- ✅ Stock manipulation simulation
- ✅ Emergency purchase order generation
- ✅ Critical stock level detection
- ✅ Automated response testing

## Expected Test Results

### Weather UDF Results
```json
// Bangalore
{
  "condition": "Rain",
  "risk_multiplier": 1.5,
  "temperature": 24,
  "humidity": 85,
  "visibility": "Good",
  "wind_speed": 15
}

// Delhi  
{
  "condition": "Haze",
  "risk_multiplier": 1.2,
  "temperature": 28,
  "humidity": 60,
  "visibility": "Low", 
  "wind_speed": 8
}
```

### Vendor UDF Results
```json
// Blinkit in Bangalore
{
  "status": "Available",
  "latency_ms": 12,
  "delivery_time_minutes": 15,
  "reliability_score": 0.95,
  "coverage_areas": ["Bangalore", "Delhi", "Mumbai"],
  "capacity_utilization": 0.75
}

// Dunzo (any location)
{
  "status": "Offline",
  "latency_ms": 0,
  "delivery_time_minutes": null,
  "reliability_score": 0.0,
  "coverage_areas": [],
  "capacity_utilization": 0.0
}
```

## Troubleshooting

### Local App Issues
- **Import errors:** Ensure you're running from project root
- **Module not found:** Check that `src/udfs/simulation_udfs.py` exists
- **Streamlit not found:** Install with `pip install streamlit`

### Snowflake App Issues
- **Function not found:** Ensure UDFs are deployed with correct names
- **Wrong database:** Use `USE DATABASE INVENTORYQ_OS_DB; USE SCHEMA PUBLIC;`
- **Permission errors:** Ensure proper warehouse and database access

## Quick Test Commands

### For Snowflake Testing
```sql
-- Set context
USE DATABASE INVENTORYQ_OS_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE COMPUTE_WH;

-- Test weather
SELECT INVENTORYQ_OS_DB.PUBLIC.get_weather_data('Bangalore') as bangalore_weather;
SELECT INVENTORYQ_OS_DB.PUBLIC.get_weather_data('Delhi') as delhi_weather;

-- Test vendors
SELECT INVENTORYQ_OS_DB.PUBLIC.get_vendor_status('Blinkit', 'Bangalore') as blinkit_status;
SELECT INVENTORYQ_OS_DB.PUBLIC.get_vendor_status('Dunzo', 'Mumbai') as dunzo_status;

-- Test comprehensive simulation
SELECT INVENTORYQ_OS_DB.PUBLIC.generate_realistic_simulation() as full_simulation;
```

## Property-Based Test Integration

The validation apps are backed by comprehensive property-based tests:

- **Property 3:** Deterministic simulation reliability ✅
- **Property 8:** Validation view completeness ✅  
- **Property 10:** Simulated data realism ✅

Run tests with:
```bash
python -m pytest tests/test_simulation_properties.py::TestValidationViewProperties -v
```

## Next Steps

After validation testing is complete:
1. ✅ Verify all UDFs work in Snowflake
2. ✅ Confirm deterministic behavior
3. ✅ Validate realistic data ranges
4. ⏭️ Proceed to Task 4: Checkpoint verification
5. ⏭️ Continue with self-healing engine implementation

---

**InventoryQ OS - Autonomous AI Inventory Operating System**  
Validation Interface Documentation v1.0
# ResQ OS - Self-Healing Supply Chain

## Overview

ResQ OS is a Snowflake-native application that implements a zero-touch logistics system for critical supply chain management across three sectors: Hospitals (Oxygen), Public Distribution Systems (Rice), and NGOs (Emergency Kits).

## Project Structure

```
├── src/
│   ├── models/
│   │   └── data_models.py          # Core data models and enums
│   ├── database/
│   │   ├── schema.sql              # Snowflake database schema
│   │   └── db_operations.py        # Database operations class
│   ├── udfs/                       # Python UDFs for Snowflake
│   └── streamlit_apps/             # Streamlit applications
├── tests/
│   └── test_multi_tenant_properties.py  # Property-based tests
├── requirements.txt                # Python dependencies
└── README.md
```

## Task 1 Implementation Status ✅

### Completed Components:

1. **Project Directory Structure** - Created organized folder structure for Python UDFs and Streamlit apps
2. **Multi-Tenant Database Schema** - Implemented schema supporting Hospital, PDS, and NGO sectors
3. **SQL Scripts** - Created table creation scripts with proper constraints and indexes
4. **Python Data Models** - Implemented comprehensive data models with validation
5. **Property-Based Tests** - Created and fixed tests for multi-tenant functionality

### Key Features Implemented:

- **Multi-tenant inventory management** with sector-specific configurations
- **Data isolation** ensuring organizations can only access their own data
- **Comprehensive data models** for all three sectors (Hospital, PDS, NGO)
- **Property-based testing** using Hypothesis library for robust validation
- **Database operations** with proper error handling and validation

### Property Tests Status:

✅ **Property 1: Multi-tenant data unification** - PASSED
- Validates that all three sectors can be stored and queried from unified table structure

✅ **Property 2: Organization data isolation** - PASSED  
- Validates that organizations can only access their own data, never other organizations' data

## Next Steps

The foundation is now ready for implementing:
- High-fidelity simulation UDFs
- Self-healing automation engine
- Streamlit validation interfaces
- Real-time monitoring and alerting

## Running Tests

```bash
# Install dependencies
pip install -r requirements.txt

# Run property-based tests
python -m pytest tests/test_multi_tenant_properties.py -v
```

## Dependencies

- Python 3.8+
- pytest (testing framework)
- hypothesis (property-based testing)
- snowflake-connector-python (Snowflake integration)
- streamlit (web applications)
- pandas (data manipulation)
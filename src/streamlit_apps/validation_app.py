"""
Streamlit Validation App for ResQ OS Simulation UDFs
Tests connectivity and functionality of high-fidelity simulation components
"""
import streamlit as st
import json
import pandas as pd
from datetime import datetime
import sys
import os

# Add src to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from udfs.simulation_udfs import (
    get_weather_data, 
    get_vendor_status, 
    generate_realistic_simulation
)

# Page configuration
st.set_page_config(
    page_title="ResQ OS - Simulation Validation",
    page_icon="🌦️",
    layout="wide"
)

st.title("🌦️ ResQ OS - High-Fidelity Simulation Validation")
st.markdown("**Test interface for validating simulation UDF connectivity and functionality**")

# Sidebar for navigation
st.sidebar.title("Validation Tests")
test_section = st.sidebar.selectbox(
    "Choose Test Section:",
    ["Weather Data Testing", "Vendor Status Testing", "Comprehensive Simulation", "Chaos Button Testing"]
)

# Weather Data Testing Section
if test_section == "Weather Data Testing":
    st.header("🌤️ Weather Data Simulation Testing")
    st.markdown("Test deterministic weather simulation for consistent demo behavior")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("City Weather Testing")
        
        # City selection
        cities = ['Bangalore', 'Delhi', 'Mumbai', 'Chennai', 'Kolkata', 'UnknownCity']
        selected_city = st.selectbox("Select City:", cities)
        
        if st.button("Get Weather Data", key="weather_btn"):
            try:
                weather_data = get_weather_data(selected_city)
                
                st.success(f"✅ Weather data retrieved for {selected_city}")
                
                # Display weather data in a nice format
                st.json(weather_data)
                
                # Validation checks
                st.subheader("Validation Results:")
                
                # Check for Bangalore = Rain
                if selected_city == 'Bangalore':
                    if weather_data.get('condition') == 'Rain':
                        st.success("✅ Bangalore correctly returns 'Rain'")
                    else:
                        st.error(f"❌ Bangalore should return 'Rain', got '{weather_data.get('condition')}'")
                
                # Check for Delhi = Haze
                elif selected_city == 'Delhi':
                    if weather_data.get('condition') == 'Haze':
                        st.success("✅ Delhi correctly returns 'Haze'")
                    else:
                        st.error(f"❌ Delhi should return 'Haze', got '{weather_data.get('condition')}'")
                
                # Check required fields
                required_fields = ['condition', 'risk_multiplier', 'temperature', 'humidity', 'visibility', 'wind_speed']
                missing_fields = [field for field in required_fields if field not in weather_data]
                
                if not missing_fields:
                    st.success("✅ All required fields present")
                else:
                    st.error(f"❌ Missing fields: {missing_fields}")
                
                # Check realistic ranges
                temp = weather_data.get('temperature', 0)
                if 5 <= temp <= 50:
                    st.success(f"✅ Temperature {temp}°C is realistic")
                else:
                    st.warning(f"⚠️ Temperature {temp}°C might be outside realistic range")
                
            except Exception as e:
                st.error(f"❌ Error getting weather data: {str(e)}")
    
    with col2:
        st.subheader("Deterministic Testing")
        st.markdown("Verify that multiple calls return identical results")
        
        if st.button("Test Deterministic Behavior", key="deterministic_btn"):
            try:
                test_city = 'Bangalore'
                
                # Make multiple calls
                call1 = get_weather_data(test_city)
                call2 = get_weather_data(test_city)
                call3 = get_weather_data(test_city)
                
                # Check if all calls are identical
                if call1 == call2 == call3:
                    st.success("✅ Deterministic behavior confirmed - all calls return identical data")
                    st.json(call1)
                else:
                    st.error("❌ Non-deterministic behavior detected!")
                    st.write("Call 1:", call1)
                    st.write("Call 2:", call2)
                    st.write("Call 3:", call3)
                
            except Exception as e:
                st.error(f"❌ Error testing deterministic behavior: {str(e)}")

# Vendor Status Testing Section
elif test_section == "Vendor Status Testing":
    st.header("🚚 Vendor Status Simulation Testing")
    st.markdown("Test realistic vendor availability and latency simulation")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Vendor Status Testing")
        
        vendors = ['Blinkit', 'Dunzo', 'Zepto', 'Swiggy_Instamart', 'BigBasket', 'UnknownVendor']
        locations = ['Bangalore', 'Delhi', 'Mumbai', 'Chennai', 'Kolkata', 'UnknownLocation']
        
        selected_vendor = st.selectbox("Select Vendor:", vendors)
        selected_location = st.selectbox("Select Location:", locations)
        
        if st.button("Get Vendor Status", key="vendor_btn"):
            try:
                vendor_data = get_vendor_status(selected_vendor, selected_location)
                
                st.success(f"✅ Vendor status retrieved for {selected_vendor} in {selected_location}")
                st.json(vendor_data)
                
                # Validation checks
                st.subheader("Validation Results:")
                
                # Check for Blinkit = 12ms latency
                if selected_vendor == 'Blinkit':
                    if vendor_data.get('latency_ms') == 12:
                        st.success("✅ Blinkit correctly returns 12ms latency")
                    else:
                        st.error(f"❌ Blinkit should return 12ms, got {vendor_data.get('latency_ms')}ms")
                
                # Check for Dunzo = Offline
                elif selected_vendor == 'Dunzo':
                    if vendor_data.get('status') == 'Offline':
                        st.success("✅ Dunzo correctly returns 'Offline' status")
                    else:
                        st.error(f"❌ Dunzo should return 'Offline', got '{vendor_data.get('status')}'")
                
                # Check required fields
                required_fields = ['status', 'latency_ms', 'delivery_time_minutes', 'reliability_score', 'coverage_areas']
                missing_fields = [field for field in required_fields if field not in vendor_data]
                
                if not missing_fields:
                    st.success("✅ All required fields present")
                else:
                    st.error(f"❌ Missing fields: {missing_fields}")
                
            except Exception as e:
                st.error(f"❌ Error getting vendor status: {str(e)}")
    
    with col2:
        st.subheader("Coverage Area Testing")
        st.markdown("Test location-based vendor availability")
        
        if st.button("Test Coverage Logic", key="coverage_btn"):
            try:
                # Test Zepto in Mumbai (should be available)
                zepto_mumbai = get_vendor_status('Zepto', 'Mumbai')
                
                # Test Zepto in Delhi (should be not available in location)
                zepto_delhi = get_vendor_status('Zepto', 'Delhi')
                
                st.write("**Zepto in Mumbai (covered area):**")
                st.json(zepto_mumbai)
                
                st.write("**Zepto in Delhi (not covered):**")
                st.json(zepto_delhi)
                
                # Validation
                if zepto_mumbai.get('status') == 'Available':
                    st.success("✅ Zepto available in Mumbai (covered area)")
                else:
                    st.error("❌ Zepto should be available in Mumbai")
                
                if zepto_delhi.get('status') == 'Not_Available_In_Location':
                    st.success("✅ Zepto correctly unavailable in Delhi (not covered)")
                else:
                    st.warning(f"⚠️ Zepto status in Delhi: {zepto_delhi.get('status')}")
                
            except Exception as e:
                st.error(f"❌ Error testing coverage logic: {str(e)}")

# Comprehensive Simulation Testing
elif test_section == "Comprehensive Simulation":
    st.header("🔄 Comprehensive Simulation Testing")
    st.markdown("Test the complete 99.99% realistic simulation data generation")
    
    if st.button("Generate Full Simulation", key="full_sim_btn"):
        try:
            with st.spinner("Generating comprehensive simulation data..."):
                simulation_data = generate_realistic_simulation()
            
            st.success("✅ Comprehensive simulation data generated successfully!")
            
            # Display key metrics
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                st.metric("Data Source", simulation_data.get('data_source', 'Unknown'))
            
            with col2:
                st.metric("Realism %", f"{simulation_data.get('realism_percentage', 0)}%")
            
            with col3:
                cities_count = len(simulation_data.get('weather_data', {}))
                st.metric("Cities Covered", cities_count)
            
            with col4:
                vendors_count = len(simulation_data.get('vendor_data', {}))
                st.metric("Vendors Tracked", vendors_count)
            
            # Expandable sections for detailed data
            with st.expander("Weather Data"):
                weather_df = pd.DataFrame(simulation_data.get('weather_data', {})).T
                st.dataframe(weather_df)
            
            with st.expander("Traffic Data"):
                traffic_df = pd.DataFrame(simulation_data.get('traffic_data', {})).T
                st.dataframe(traffic_df)
            
            with st.expander("System Status"):
                st.json(simulation_data.get('system_status', {}))
            
            with st.expander("Raw Simulation Data"):
                st.json(simulation_data)
            
            # Validation checks
            st.subheader("Validation Results:")
            
            # Check realism percentage
            realism = simulation_data.get('realism_percentage', 0)
            if realism >= 99.0:
                st.success(f"✅ High realism achieved: {realism}%")
            else:
                st.warning(f"⚠️ Realism below target: {realism}%")
            
            # Check simulation mode indicator
            if simulation_data.get('system_status', {}).get('simulation_mode'):
                st.success("✅ Simulation mode properly indicated")
            else:
                st.error("❌ Simulation mode not indicated")
            
            # Check data source labeling
            if simulation_data.get('data_source') == 'SIMULATED':
                st.success("✅ Data source properly labeled as SIMULATED")
            else:
                st.error("❌ Data source not properly labeled")
            
        except Exception as e:
            st.error(f"❌ Error generating simulation: {str(e)}")

# Chaos Button Testing
elif test_section == "Chaos Button Testing":
    st.header("💥 Chaos Button Testing")
    st.markdown("Test interface for stock manipulation and emergency scenarios")
    
    st.warning("⚠️ **Chaos Mode** - This will simulate critical stock scenarios for testing")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Stock Manipulation")
        
        # Mock inventory data for testing
        if 'inventory_data' not in st.session_state:
            st.session_state.inventory_data = {
                'HOSP_OXY_001': {'item': 'Oxygen', 'current_stock': 100, 'sector': 'Hospital'},
                'PDS_RICE_001': {'item': 'Rice', 'current_stock': 500, 'sector': 'PDS'},
                'NGO_KIT_001': {'item': 'Emergency Kit', 'current_stock': 50, 'sector': 'NGO'}
            }
        
        # Display current inventory
        st.write("**Current Inventory:**")
        for item_id, data in st.session_state.inventory_data.items():
            st.write(f"- {item_id}: {data['current_stock']} units ({data['item']} - {data['sector']})")
        
        st.markdown("---")
        
        # Chaos Button
        if st.button("🔥 ACTIVATE CHAOS MODE", key="chaos_btn", type="primary"):
            st.balloons()
            
            # Simulate dropping all stock to critical levels
            for item_id in st.session_state.inventory_data:
                st.session_state.inventory_data[item_id]['current_stock'] = 0
            
            st.error("💥 **CHAOS ACTIVATED!** All stock levels dropped to 0!")
            
            # Generate mock purchase orders
            purchase_orders = []
            for item_id, data in st.session_state.inventory_data.items():
                order = {
                    'order_id': f"PO_{item_id}_{datetime.now().strftime('%H%M%S')}",
                    'item_id': item_id,
                    'item_name': data['item'],
                    'sector': data['sector'],
                    'quantity': 100 if data['sector'] == 'Hospital' else 200,
                    'urgency': 'CRITICAL',
                    'auto_generated': True,
                    'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                }
                purchase_orders.append(order)
            
            st.session_state.purchase_orders = purchase_orders
            
            st.success("✅ Automated purchase orders generated!")
    
    with col2:
        st.subheader("Generated Purchase Orders")
        
        if 'purchase_orders' in st.session_state:
            st.write("**Emergency Purchase Orders:**")
            
            for order in st.session_state.purchase_orders:
                with st.container():
                    st.markdown(f"""
                    **Order ID:** {order['order_id']}  
                    **Item:** {order['item_name']} ({order['sector']})  
                    **Quantity:** {order['quantity']} units  
                    **Urgency:** {order['urgency']}  
                    **Auto-Generated:** {order['auto_generated']}  
                    **Time:** {order['timestamp']}
                    """)
                    st.markdown("---")
            
            # Reset button
            if st.button("🔄 Reset Inventory", key="reset_btn"):
                st.session_state.inventory_data = {
                    'HOSP_OXY_001': {'item': 'Oxygen', 'current_stock': 100, 'sector': 'Hospital'},
                    'PDS_RICE_001': {'item': 'Rice', 'current_stock': 500, 'sector': 'PDS'},
                    'NGO_KIT_001': {'item': 'Emergency Kit', 'current_stock': 50, 'sector': 'NGO'}
                }
                if 'purchase_orders' in st.session_state:
                    del st.session_state.purchase_orders
                st.success("✅ Inventory reset to normal levels")
                st.rerun()
        else:
            st.info("Click the Chaos Button to generate emergency purchase orders")

# Footer
st.markdown("---")
st.markdown("**ResQ OS - Self-Healing Supply Chain** | Validation Interface v1.0")
st.markdown("🔗 Testing high-fidelity simulation UDFs for consistent demo behavior")
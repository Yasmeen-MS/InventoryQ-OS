"""
InventoryQ OS - Main Streamlit Application
Autonomous AI Inventory Operating System for Hospitals & NGOs
"""

import streamlit as st
import pandas as pd
from datetime import datetime, timedelta

# Page configuration
st.set_page_config(
    page_title="InventoryQ: Zero-Touch Inventory",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        font-size: 3rem;
        font-weight: bold;
        text-align: center;
        margin-bottom: 2rem;
        background: linear-gradient(90deg, #2E86AB, #A23B72);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }
    .metric-card {
        background: #f0f2f6;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #2E86AB;
    }
    .alert-critical {
        background: #ffebee;
        border-left: 4px solid #f44336;
        padding: 1rem;
        border-radius: 0.5rem;
    }
    .alert-warning {
        background: #fff3e0;
        border-left: 4px solid #ff9800;
        padding: 1rem;
        border-radius: 0.5rem;
    }
    .alert-good {
        background: #e8f5e8;
        border-left: 4px solid #4caf50;
        padding: 1rem;
        border-radius: 0.5rem;
    }
</style>
""", unsafe_allow_html=True)

# Sidebar
st.sidebar.title("InventoryQ OS // v11.0")
st.sidebar.markdown("**Inventory Command Center**")

# Organization selector
org_type = st.sidebar.selectbox(
    "Select Organization Type",
    ["Hospital", "NGO", "PDS System"],
    help="Choose your organization type to view relevant inventory data"
)

# Location selector
if org_type == "Hospital":
    locations = ["Apollo Hospital - Bangalore", "AIIMS - Delhi", "Fortis - Mumbai"]
    critical_item = "Oxygen Cylinders"
    unit = "cylinders"
elif org_type == "NGO":
    locations = ["Red Cross - Chennai", "Oxfam - Kolkata", "Care India - Hyderabad"]
    critical_item = "Emergency Kits"
    unit = "kits"
else:  # PDS System
    locations = ["PDS Center - Bangalore", "Fair Price Shop - Delhi", "Ration Store - Mumbai"]
    critical_item = "Rice Stock"
    unit = "kg"

location = st.sidebar.selectbox("Select Location", locations)

# Main header
st.markdown('<h1 class="main-header">🏥 InventoryQ OS</h1>', unsafe_allow_html=True)
st.markdown('<p style="text-align: center; font-size: 1.2rem; color: #666;">Autonomous Inventory Health & Stockout Prevention System</p>', unsafe_allow_html=True)

# Current status overview
col1, col2, col3, col4 = st.columns(4)

# Sample data based on organization type
if org_type == "Hospital":
    current_stock = 45
    critical_threshold = 50
    daily_consumption = 12
    days_remaining = current_stock / daily_consumption
    status = "CRITICAL" if current_stock <= critical_threshold else "GOOD"
elif org_type == "NGO":
    current_stock = 120
    critical_threshold = 100
    daily_consumption = 8
    days_remaining = current_stock / daily_consumption
    status = "GOOD"
else:  # PDS
    current_stock = 2500
    critical_threshold = 3000
    daily_consumption = 150
    days_remaining = current_stock / daily_consumption
    status = "WARNING" if current_stock <= critical_threshold else "GOOD"

with col1:
    st.metric(
        label=f"Current {critical_item}",
        value=f"{current_stock:,} {unit}",
        delta=f"-{daily_consumption} {unit}/day"
    )

with col2:
    st.metric(
        label="Days Remaining",
        value=f"{days_remaining:.1f} days",
        delta="Critical" if days_remaining <= 3 else "Stable"
    )

with col3:
    st.metric(
        label="Auto-Orders Generated",
        value="3 today",
        delta="+2 from yesterday"
    )

with col4:
    st.metric(
        label="Stockout Prevention",
        value="100%",
        delta="Zero stockouts this month"
    )

# Status alert
if status == "CRITICAL":
    st.markdown(f"""
    <div class="alert-critical">
        <h3>🚨 CRITICAL INVENTORY ALERT</h3>
        <p><strong>{critical_item}</strong> at <strong>{location}</strong> is below critical threshold!</p>
        <p>Current: {current_stock} {unit} | Threshold: {critical_threshold} {unit}</p>
        <p>🤖 <strong>Auto-Action:</strong> Emergency purchase order generated automatically</p>
    </div>
    """, unsafe_allow_html=True)
elif status == "WARNING":
    st.markdown(f"""
    <div class="alert-warning">
        <h3>⚠️ INVENTORY WARNING</h3>
        <p><strong>{critical_item}</strong> at <strong>{location}</strong> is approaching critical levels</p>
        <p>Current: {current_stock} {unit} | Threshold: {critical_threshold} {unit}</p>
        <p>🤖 <strong>Auto-Action:</strong> Procurement order scheduled for tomorrow</p>
    </div>
    """, unsafe_allow_html=True)
else:
    st.markdown(f"""
    <div class="alert-good">
        <h3>✅ INVENTORY HEALTHY</h3>
        <p><strong>{critical_item}</strong> at <strong>{location}</strong> is well-stocked</p>
        <p>Current: {current_stock} {unit} | Days remaining: {days_remaining:.1f}</p>
        <p>🤖 <strong>Status:</strong> Autonomous monitoring active</p>
    </div>
    """, unsafe_allow_html=True)

# Tabs for different views
tab1, tab2, tab3, tab4 = st.tabs(["📊 Inventory Dashboard", "🔮 Predictions", "🛒 Auto-Orders", "🧪 Chaos Testing"])

with tab1:
    st.subheader("📊 Real-Time Inventory Tracking")
    
    # Sample inventory data
    dates = [datetime.now() - timedelta(days=x) for x in range(30, 0, -1)]
    if org_type == "Hospital":
        stock_levels = [65, 62, 58, 55, 52, 48, 45, 42, 38, 35, 32, 28, 25, 22, 18, 15, 12, 8, 5, 2, 85, 82, 78, 75, 72, 68, 65, 62, 58, 55]
    elif org_type == "NGO":
        stock_levels = [150, 145, 140, 135, 130, 125, 120, 115, 110, 105, 100, 95, 90, 85, 80, 75, 70, 65, 60, 55, 180, 175, 170, 165, 160, 155, 150, 145, 140, 135]
    else:
        stock_levels = [3500, 3400, 3300, 3200, 3100, 3000, 2900, 2800, 2700, 2600, 2500, 2400, 2300, 2200, 2100, 2000, 1900, 1800, 1700, 1600, 4000, 3900, 3800, 3700, 3600, 3500, 3400, 3300, 3200, 3100]
    
    df = pd.DataFrame({
        'Date': dates,
        'Stock Level': stock_levels,
        'Critical Threshold': [critical_threshold] * 30
    })
    
    st.line_chart(df.set_index('Date'))
    
    col1, col2 = st.columns(2)
    with col1:
        st.subheader("🌦️ Weather Impact")
        st.info("Bangalore: Rain detected - 1.5x delivery delay expected")
        st.success("Delhi: Clear weather - Normal delivery times")
        
    with col2:
        st.subheader("🚚 Vendor Status")
        st.success("Blinkit: Online - 12ms response time")
        st.error("Dunzo: Offline - Backup vendor activated")

with tab2:
    st.subheader("🔮 AI-Powered Stockout Predictions")
    
    st.markdown("**Next 7 Days Forecast:**")
    
    # Prediction data
    future_dates = [datetime.now() + timedelta(days=x) for x in range(1, 8)]
    predicted_stock = [current_stock - (daily_consumption * x) for x in range(1, 8)]
    
    prediction_df = pd.DataFrame({
        'Date': future_dates,
        'Predicted Stock': predicted_stock,
        'Critical Threshold': [critical_threshold] * 7
    })
    
    st.line_chart(prediction_df.set_index('Date'))
    
    # Stockout prediction
    stockout_day = None
    for i, stock in enumerate(predicted_stock):
        if stock <= 0:
            stockout_day = i + 1
            break
    
    if stockout_day:
        st.error(f"⚠️ **STOCKOUT PREDICTED:** Day {stockout_day} ({future_dates[stockout_day-1].strftime('%Y-%m-%d')})")
        st.info("🤖 **Auto-Action:** Emergency procurement order will be generated 3 days before predicted stockout")
    else:
        st.success("✅ **NO STOCKOUT PREDICTED** in the next 7 days")

with tab3:
    st.subheader("🛒 Autonomous Purchase Orders")
    
    # Sample purchase orders
    orders_data = {
        'Order ID': ['PO-2024-001', 'PO-2024-002', 'PO-2024-003'],
        'Item': [critical_item, critical_item, critical_item],
        'Quantity': [f"100 {unit}", f"150 {unit}", f"200 {unit}"],
        'Vendor': ['Primary Supplier', 'Backup Supplier', 'Emergency Supplier'],
        'Status': ['✅ Delivered', '🚚 In Transit', '📋 Generated'],
        'Auto-Generated': ['Yes', 'Yes', 'Yes']
    }
    
    st.dataframe(pd.DataFrame(orders_data), use_container_width=True)
    
    st.info("🤖 **Autonomous Procurement:** All orders are generated automatically based on AI predictions")

with tab4:
    st.subheader("💥 Chaos Testing - Simulate Crisis Scenarios")
    
    st.warning("⚠️ **Testing Environment Only** - These buttons simulate crisis scenarios for demonstration")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("🚨 Simulate Stockout Crisis", type="primary"):
            st.error("**CRISIS SIMULATED:** Stock dropped to 0!")
            st.info("🤖 **Auto-Response:** Emergency procurement activated")
            st.success("📞 **Alert Sent:** Notifications sent to all stakeholders")
    
    with col2:
        if st.button("🌧️ Simulate Weather Disruption"):
            st.warning("**WEATHER ALERT:** Heavy rain in Bangalore")
            st.info("🤖 **Auto-Adjustment:** Delivery times increased by 1.5x")
            st.info("📦 **Backup Plan:** Alternative suppliers activated")
    
    with col3:
        if st.button("🚚 Simulate Vendor Failure"):
            st.error("**VENDOR DOWN:** Primary supplier offline")
            st.success("🤖 **Auto-Failover:** Switched to backup vendor")
            st.info("📊 **Impact:** Zero service disruption")

# Footer
st.markdown("---")
st.markdown("**InventoryQ OS - Autonomous AI Inventory Operating System** | v11.0")
st.markdown("🏥 Preventing stockouts through intelligent automation | 🤖 Zero-touch inventory management")
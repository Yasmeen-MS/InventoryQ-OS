# Professional Dashboard UI Demo - Light Purple Gradient Theme
# Demonstrating the two rectangular header layout you requested

import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go
import plotly.express as px
from datetime import datetime, timedelta

# Page configuration
st.set_page_config(
    page_title="Professional Dashboard Demo",
    page_icon="⚡",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Professional Theme with Light Purple Gradient
st.markdown("""
<style>
    /* Import Professional Fonts */
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
    
    /* Professional Purple & White Color Palette */
    :root {
        --primary-bg: #faf7ff;
        --secondary-bg: #f3f0ff;
        --tertiary-bg: #e9e5ff;
        --card-bg: #ffffff;
        --border-color: #d4d4d8;
        --text-primary: #1f2937;
        --text-secondary: #6b7280;
        --text-muted: #9ca3af;
        --accent-purple: #8b5cf6;
        --accent-purple-light: #a78bfa;
        --accent-purple-dark: #7c3aed;
        --purple-gradient: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 50%, #c4b5fd 100%);
    }
    
    /* Global Styles - Force Purple Gradient Background */
    .stApp {
        background: var(--primary-bg) !important;
        color: var(--text-primary);
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    }
    
    .stApp > .main {
        background: linear-gradient(135deg, #faf7ff 0%, #f3f0ff 50%, #e9e5ff 100%) !important;
        min-height: 100vh;
    }
    
    .main .block-container {
        padding-top: 2rem;
        padding-bottom: 2rem;
        max-width: 100%;
        background: transparent !important;
    }
    
    /* Force background on main content area */
    .stApp [data-testid="stAppViewContainer"] {
        background: linear-gradient(135deg, #faf7ff 0%, #f3f0ff 50%, #e9e5ff 100%) !important;
    }
    
    .stApp [data-testid="stAppViewContainer"] > .main {
        background: transparent !important;
    }
    
    /* Professional Header */
    .dashboard-header {
        background: var(--purple-gradient);
        border: 1px solid var(--accent-purple-light);
        border-radius: 20px;
        padding: 2.5rem;
        margin-bottom: 2rem;
        text-align: center;
        position: relative;
        overflow: hidden;
        box-shadow: 0 10px 25px rgba(139, 92, 246, 0.2);
    }
    
    .main-title {
        font-size: 2.8rem;
        font-weight: 800;
        color: white;
        margin-bottom: 0.5rem;
        text-shadow: 0 2px 4px rgba(0,0,0,0.2);
        letter-spacing: -0.02em;
    }
    
    .subtitle {
        font-size: 1.3rem;
        color: rgba(255, 255, 255, 0.9);
        margin-bottom: 0.5rem;
        font-weight: 500;
    }
    
    /* Professional Chart Section with Light Purple Gradient */
    .professional-chart-section {
        margin-bottom: 2rem;
        background: linear-gradient(135deg, #faf7ff 0%, #f3f0ff 50%, #e9e5ff 100%);
        border-radius: 24px;
        padding: 2rem;
        box-shadow: 0 8px 32px rgba(139, 92, 246, 0.1);
        border: 1px solid rgba(139, 92, 246, 0.2);
    }
    
    .chart-header-container {
        background: rgba(255, 255, 255, 0.9);
        border: 2px solid rgba(139, 92, 246, 0.2);
        border-radius: 16px;
        margin-bottom: 1.5rem;
        overflow: hidden;
        transition: all 0.3s ease;
        backdrop-filter: blur(10px);
        box-shadow: 0 4px 16px rgba(139, 92, 246, 0.1);
    }
    
    .chart-header-container:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 32px rgba(139, 92, 246, 0.2);
        border-color: rgba(139, 92, 246, 0.4);
    }
    
    .chart-header-container.highlighted {
        border: 3px solid #8b5cf6;
        box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.1), 0 8px 32px rgba(139, 92, 246, 0.2);
        background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(248, 247, 255, 0.95) 100%);
    }
    
    .chart-header-title {
        background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 50%, #c4b5fd 100%);
        color: white;
        padding: 1.2rem 2rem;
        font-size: 1.3rem;
        font-weight: 700;
        display: flex;
        align-items: center;
        gap: 0.8rem;
        text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        letter-spacing: -0.01em;
    }
    
    .chart-header-container.highlighted .chart-header-title {
        background: linear-gradient(135deg, #7c3aed 0%, #8b5cf6 50%, #a78bfa 100%);
        box-shadow: 0 2px 8px rgba(139, 92, 246, 0.3);
    }
    
    .chart-icon {
        font-size: 1.4rem;
        filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.1));
    }
    
    .chart-text {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
        font-weight: 700;
    }
    
    .chart-content-area {
        padding: 2rem;
        min-height: 300px;
        background: rgba(255, 255, 255, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--text-secondary);
        font-weight: 600;
        font-size: 1.1rem;
    }
    
    .chart-header-container.highlighted .chart-content-area {
        background: rgba(248, 247, 255, 0.7);
        border-top: 1px solid rgba(139, 92, 246, 0.1);
    }
    
    /* Professional KPI Cards */
    .kpi-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 1.5rem;
        margin-bottom: 2rem;
    }
    
    .kpi-card {
        background: var(--card-bg);
        border: 2px solid var(--border-color);
        border-radius: 16px;
        padding: 1.8rem;
        position: relative;
        transition: all 0.3s ease;
        overflow: hidden;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
    }
    
    .kpi-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: var(--accent-purple);
    }
    
    .kpi-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 12px 25px rgba(139, 92, 246, 0.15);
        border-color: var(--accent-purple);
    }
    
    .kpi-title {
        font-size: 0.9rem;
        color: var(--text-secondary);
        font-weight: 600;
        margin-bottom: 0.8rem;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    
    .kpi-value {
        font-size: 2.2rem;
        font-weight: 800;
        color: var(--text-primary);
        margin-bottom: 0.5rem;
        line-height: 1.1;
    }
    
    .kpi-change {
        font-size: 0.8rem;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 0.3rem;
        color: var(--accent-purple);
    }
</style>
""", unsafe_allow_html=True)

# Generate sample data
@st.cache_data
def generate_sample_data():
    """Generate sample inventory data for demonstration"""
    np.random.seed(42)
    
    cities = ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata', 'Hyderabad', 'Pune', 'Ahmedabad']
    item_types = ['Medical Supplies', 'Surgical Equipment', 'Pharmaceuticals', 'PPE Kits', 'Oxygen Cylinders', 'Ventilators']
    statuses = ['CRITICAL', 'WARNING', 'NORMAL']
    
    data = []
    for i in range(50):
        current_stock = np.random.randint(10, 500)
        consumption_rate = np.random.uniform(5, 25)
        days_remaining = current_stock / consumption_rate
        
        if days_remaining <= 3:
            status = 'CRITICAL'
        elif days_remaining <= 7:
            status = 'WARNING'
        else:
            status = 'NORMAL'
        
        data.append({
            'INVENTORY_ID': f'INV{1000+i}',
            'ITEM_TYPE': np.random.choice(item_types),
            'LOCATION_CITY': np.random.choice(cities),
            'CURRENT_STOCK': current_stock,
            'DAILY_CONSUMPTION_RATE': consumption_rate,
            'DAYS_REMAINING': days_remaining,
            'STATUS': status,
            'REORDER_POINT': np.random.randint(20, 100),
            'CRITICAL_THRESHOLD': np.random.randint(5, 20)
        })
    
    return pd.DataFrame(data)

def main():
    """Professional Dashboard Demo"""
    
    # Professional Header
    st.markdown("""
    <div class="dashboard-header">
        <h1 class="main-title">Professional Dashboard UI</h1>
        <p class="subtitle">Light Purple Gradient Theme Demo</p>
    </div>
    """, unsafe_allow_html=True)
    
    # Load sample data
    df_inventory = generate_sample_data()
    
    # Professional KPI Cards
    if not df_inventory.empty:
        total_items = len(df_inventory)
        critical_items = len(df_inventory[df_inventory['STATUS'] == 'CRITICAL'])
        warning_items = len(df_inventory[df_inventory['STATUS'] == 'WARNING'])
        normal_items = len(df_inventory[df_inventory['STATUS'] == 'NORMAL'])
        avg_days = df_inventory['DAYS_REMAINING'].mean()
        total_value = df_inventory['CURRENT_STOCK'].sum() * 50
        
        st.markdown(f"""
        <div class="kpi-container">
            <div class="kpi-card">
                <div class="kpi-title">Total Items</div>
                <div class="kpi-value">{total_items:,}</div>
                <div class="kpi-change">Active Monitoring</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-title">Critical Alerts</div>
                <div class="kpi-value">{critical_items}</div>
                <div class="kpi-change">⚠ Action Required</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-title">Warning Items</div>
                <div class="kpi-value">{warning_items}</div>
                <div class="kpi-change">⚠ Monitor</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-title">Normal Status</div>
                <div class="kpi-value">{normal_items}</div>
                <div class="kpi-change">✓ Healthy Stock</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-title">Avg Days Remaining</div>
                <div class="kpi-value">{avg_days:.1f}</div>
                <div class="kpi-change">◐ Monitor</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-title">Total Value</div>
                <div class="kpi-value">₹{total_value:,.0f}</div>
                <div class="kpi-change">Live Data</div>
            </div>
        </div>
        """, unsafe_allow_html=True)
        
        # Professional Charts Section with Light Purple Gradient Theme
        st.markdown("""
        <div class="professional-chart-section">
            <div class="chart-header-container highlighted">
                <div class="chart-header-title">
                    <span class="chart-icon">📊</span>
                    <span class="chart-text">Inventory Status Distribution</span>
                </div>
                <div class="chart-content-area" id="status-chart-container">
                </div>
            </div>
            
            <div class="chart-header-container">
                <div class="chart-header-title">
                    <span class="chart-icon">📈</span>
                    <span class="chart-text">Stock Levels by Location</span>
                </div>
                <div class="chart-content-area" id="location-chart-container">
                </div>
            </div>
        </div>
        """, unsafe_allow_html=True)
        
        # Create the charts
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("### Status Distribution Chart")
            # Status Distribution Donut Chart
            status_counts = df_inventory['STATUS'].value_counts()
            colors = ['#ef4444', '#f59e0b', '#22c55e']  # Red, Yellow, Green
            
            fig_status = go.Figure(data=[go.Pie(
                labels=status_counts.index,
                values=status_counts.values,
                hole=0.6,
                marker=dict(colors=colors, line=dict(color='#ffffff', width=2)),
                textfont=dict(color='white', size=14),
                hovertemplate='<b>%{label}</b><br>Count: %{value}<br>Percentage: %{percent}<extra></extra>'
            )])
            
            fig_status.update_layout(
                paper_bgcolor='rgba(255,255,255,0)',
                plot_bgcolor='rgba(255,255,255,0)',
                font=dict(color='#1f2937', family='Inter'),
                height=280,
                margin=dict(l=20, r=20, t=20, b=20),
                legend=dict(
                    orientation="h",
                    yanchor="bottom",
                    y=-0.2,
                    xanchor="center",
                    x=0.5,
                    font=dict(color='#6b7280')
                )
            )
            
            st.plotly_chart(fig_status, width='stretch')
        
        with col2:
            st.markdown("### Location Distribution Chart")
            # Location Analysis Bar Chart
            location_data = df_inventory.groupby('LOCATION_CITY')['CURRENT_STOCK'].sum().sort_values(ascending=True)
            
            fig_location = go.Figure(data=[go.Bar(
                y=location_data.index,
                x=location_data.values,
                orientation='h',
                marker=dict(
                    color='#8b5cf6',
                    line=dict(color='#ffffff', width=1)
                ),
                hovertemplate='<b>%{y}</b><br>Total Stock: %{x:,.0f}<extra></extra>'
            )])
            
            fig_location.update_layout(
                paper_bgcolor='rgba(255,255,255,0)',
                plot_bgcolor='rgba(255,255,255,0)',
                font=dict(color='#1f2937', family='Inter'),
                height=280,
                margin=dict(l=20, r=20, t=20, b=20),
                xaxis=dict(
                    title="Total Stock Units",
                    gridcolor='rgba(139,92,246,0.1)',
                    color='#6b7280'
                ),
                yaxis=dict(
                    title="Location",
                    gridcolor='rgba(139,92,246,0.1)',
                    color='#6b7280'
                )
            )
            
            st.plotly_chart(fig_location, width='stretch')
        
        # Additional Information
        st.markdown("---")
        st.markdown("### Key Features Demonstrated:")
        
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.markdown("""
            **🎨 Light Purple Gradient Theme**
            - Soft purple gradient background
            - Professional color palette
            - Clean typography with Inter font
            """)
        
        with col2:
            st.markdown("""
            **📊 Two Rectangular Headers**
            - First container highlighted with stronger border
            - Second container with standard styling
            - Both with gradient header bars
            """)
        
        with col3:
            st.markdown("""
            **✨ Professional Design**
            - Hover effects and transitions
            - Consistent spacing and borders
            - Modern card-based layout
            """)

if __name__ == "__main__":
    main()
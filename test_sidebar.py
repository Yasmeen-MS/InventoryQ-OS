import streamlit as st

# Page configuration
st.set_page_config(
    page_title="Sidebar Test",
    page_icon="🔧",
    layout="wide",
    initial_sidebar_state="expanded"
)

# CSS for sidebar visibility
st.markdown("""
<style>
    /* Enhanced Sidebar Toggle - Ensure Visibility */
    .stApp [data-testid="collapsedControl"] {
        background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%) !important;
        border-radius: 8px !important;
        box-shadow: 0 2px 8px rgba(139, 92, 246, 0.4) !important;
        border: 1px solid rgba(255, 255, 255, 0.3) !important;
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
        z-index: 999999 !important;
        position: fixed !important;
        top: 1rem !important;
        left: 1rem !important;
    }
    
    .stApp [data-testid="collapsedControl"] button {
        color: white !important;
        font-weight: 700 !important;
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
    }
    
    /* Force Sidebar Visibility */
    .stApp [data-testid="stSidebar"] {
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
        width: 300px !important;
        min-width: 300px !important;
        max-width: 300px !important;
    }
    
    /* Ensure Sidebar Content is Visible */
    .stApp [data-testid="stSidebar"] > div {
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
    }
</style>
""", unsafe_allow_html=True)

def main():
    # Force sidebar to be visible - Emergency Fix
    st.sidebar.markdown("🔧 **Sidebar Status: ACTIVE**")
    st.sidebar.markdown("---")
    
    # Test sidebar content
    st.sidebar.markdown("### Navigation Test")
    
    if st.sidebar.button("🏠 Dashboard", use_container_width=True):
        st.sidebar.success("Dashboard clicked!")
    
    if st.sidebar.button("📦 Inventory", use_container_width=True):
        st.sidebar.success("Inventory clicked!")
    
    if st.sidebar.button("📊 Analytics", use_container_width=True):
        st.sidebar.success("Analytics clicked!")
    
    # Main content
    st.title("🔧 Sidebar Visibility Test")
    st.markdown("## Testing sidebar visibility and functionality")
    
    if st.button("Test Main Button"):
        st.success("Main button works!")
    
    st.markdown("""
    ### Instructions:
    1. Check if the sidebar is visible on the left
    2. Try clicking the sidebar buttons
    3. If sidebar is collapsed, look for the toggle button (should be purple)
    4. Click the toggle button to expand the sidebar
    """)

if __name__ == "__main__":
    main()
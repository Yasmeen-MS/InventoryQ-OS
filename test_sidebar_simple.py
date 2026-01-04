import streamlit as st

# Page configuration
st.set_page_config(
    page_title="Sidebar Test - Simple",
    page_icon="🔧",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Simple CSS for sidebar visibility
st.markdown("""
<style>
    .stApp [data-testid="collapsedControl"] {
        background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%) !important;
        border-radius: 8px !important;
        box-shadow: 0 2px 8px rgba(139, 92, 246, 0.4) !important;
        border: 1px solid rgba(255, 255, 255, 0.3) !important;
        z-index: 999 !important;
    }
    
    .stApp [data-testid="collapsedControl"] button {
        color: white !important;
        font-weight: 700 !important;
    }
</style>
""", unsafe_allow_html=True)

def main():
    # Force sidebar to be visible
    st.sidebar.title("🔧 Navigation")
    st.sidebar.markdown("**Sidebar is working!**")
    st.sidebar.markdown("---")
    
    # Simple navigation
    st.sidebar.markdown("### 🧭 Navigation")
    
    if st.sidebar.button("🏠 Dashboard", use_container_width=True):
        st.sidebar.success("Dashboard clicked!")
    
    if st.sidebar.button("📦 Inventory", use_container_width=True):
        st.sidebar.success("Inventory clicked!")
    
    if st.sidebar.button("📊 Analytics", use_container_width=True):
        st.sidebar.success("Analytics clicked!")
    
    st.sidebar.markdown("---")
    st.sidebar.markdown("### ⚡ Status")
    st.sidebar.success("✅ Sidebar is visible and working!")
    
    # Main content
    st.title("🔧 Sidebar Test - Simple Version")
    st.markdown("## ✅ Sidebar Visibility Test")
    
    st.markdown("""
    ### Test Results:
    - ✅ Page configuration set to `initial_sidebar_state="expanded"`
    - ✅ Simple sidebar content added
    - ✅ CSS styling for toggle button
    - ✅ Navigation buttons working
    
    ### Instructions:
    1. **Check the left side** - You should see the sidebar with navigation
    2. **If sidebar is collapsed**, look for a **purple toggle button** in the top-left
    3. **Click the toggle button** to expand the sidebar
    4. **Test the navigation buttons** in the sidebar
    """)
    
    if st.button("🔄 Refresh Page"):
        st.rerun()

if __name__ == "__main__":
    main()
import streamlit as st

# Page configuration - FORCE SIDEBAR OPEN
st.set_page_config(
    page_title="EMERGENCY SIDEBAR TEST",
    page_icon="🚨",
    layout="wide",
    initial_sidebar_state="expanded"
)

# AGGRESSIVE CSS TO FORCE SIDEBAR VISIBILITY
st.markdown("""
<style>
    /* FORCE SIDEBAR VISIBILITY - AGGRESSIVE FIX */
    .stApp [data-testid="stSidebar"] {
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
        position: relative !important;
        width: 300px !important;
        min-width: 300px !important;
        max-width: 300px !important;
        left: 0 !important;
        transform: translateX(0) !important;
        z-index: 1000 !important;
    }
    
    /* FORCE SIDEBAR CONTENT VISIBILITY */
    .stApp [data-testid="stSidebar"] > div {
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
    }
    
    /* FORCE SIDEBAR TO ALWAYS BE EXPANDED */
    .stApp [data-testid="stSidebar"][aria-expanded="false"] {
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
        width: 300px !important;
        transform: translateX(0) !important;
    }
    
    /* Enhanced Toggle Button */
    .stApp [data-testid="collapsedControl"] {
        background: #ef4444 !important;
        border-radius: 8px !important;
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.5) !important;
        border: 2px solid white !important;
        z-index: 999999 !important;
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
        position: fixed !important;
        top: 1rem !important;
        left: 1rem !important;
        width: 50px !important;
        height: 50px !important;
    }
    
    .stApp [data-testid="collapsedControl"] button {
        color: white !important;
        font-weight: 900 !important;
        font-size: 1.2rem !important;
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
    }
</style>

<script>
// EMERGENCY JAVASCRIPT FIX
document.addEventListener('DOMContentLoaded', function() {
    function emergencyForceSidebar() {
        const sidebar = document.querySelector('[data-testid="stSidebar"]');
        const toggleButton = document.querySelector('[data-testid="collapsedControl"]');
        
        if (sidebar) {
            sidebar.style.display = 'block';
            sidebar.style.visibility = 'visible';
            sidebar.style.opacity = '1';
            sidebar.style.width = '300px';
            sidebar.style.minWidth = '300px';
            sidebar.style.maxWidth = '300px';
            sidebar.style.transform = 'translateX(0)';
            sidebar.style.position = 'relative';
            sidebar.style.left = '0';
            sidebar.setAttribute('aria-expanded', 'true');
            console.log('✅ Sidebar forced visible');
        } else {
            console.log('❌ Sidebar element not found');
        }
        
        if (toggleButton) {
            toggleButton.style.display = 'block';
            toggleButton.style.visibility = 'visible';
            toggleButton.style.opacity = '1';
            toggleButton.style.background = '#ef4444';
            console.log('✅ Toggle button styled');
        } else {
            console.log('❌ Toggle button not found');
        }
    }
    
    // Force immediately
    emergencyForceSidebar();
    
    // Keep forcing every 50ms for 10 seconds
    let attempts = 0;
    const forceInterval = setInterval(() => {
        emergencyForceSidebar();
        attempts++;
        if (attempts > 200) {
            clearInterval(forceInterval);
            console.log('🔄 Stopped forcing after 200 attempts');
        }
    }, 50);
});
</script>
""", unsafe_allow_html=True)

def main():
    # EMERGENCY SIDEBAR CONTENT
    st.sidebar.markdown("# 🚨 EMERGENCY SIDEBAR")
    st.sidebar.markdown("## ✅ SUCCESS!")
    st.sidebar.markdown("**The sidebar is now visible!**")
    st.sidebar.markdown("---")
    
    st.sidebar.markdown("### 🧭 Test Navigation")
    
    if st.sidebar.button("🏠 Test Dashboard", use_container_width=True):
        st.sidebar.success("✅ Dashboard button works!")
        st.balloons()
    
    if st.sidebar.button("📦 Test Inventory", use_container_width=True):
        st.sidebar.success("✅ Inventory button works!")
        st.balloons()
    
    if st.sidebar.button("📊 Test Analytics", use_container_width=True):
        st.sidebar.success("✅ Analytics button works!")
        st.balloons()
    
    st.sidebar.markdown("---")
    st.sidebar.markdown("### ✅ Status")
    st.sidebar.success("Sidebar is working perfectly!")
    
    # MAIN CONTENT
    st.title("🚨 EMERGENCY SIDEBAR TEST")
    
    st.markdown("""
    <div style="
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        color: white;
        padding: 2rem;
        border-radius: 16px;
        text-align: center;
        margin: 2rem 0;
        box-shadow: 0 8px 25px rgba(16, 185, 129, 0.3);
    ">
        <h2 style="color: white; margin: 0 0 1rem 0;">✅ SIDEBAR VISIBILITY TEST</h2>
        <p style="color: white; font-size: 1.2rem; margin: 0;">
            Look to the LEFT - you should see the emergency sidebar with navigation buttons!
        </p>
    </div>
    """, unsafe_allow_html=True)
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("### 🔍 What to Look For:")
        st.markdown("""
        - **Left side**: Emergency sidebar with red header
        - **Navigation buttons**: Dashboard, Inventory, Analytics
        - **Toggle button**: Red button in top-left corner (if sidebar collapsed)
        """)
    
    with col2:
        st.markdown("### 🛠️ If Still Not Visible:")
        st.markdown("""
        - **Refresh the page** (F5 or Ctrl+R)
        - **Check browser zoom** (should be 100%)
        - **Try different browser** (Chrome, Firefox, Edge)
        - **Clear browser cache**
        """)
    
    if st.button("🔄 Force Refresh", type="primary"):
        st.rerun()
    
    st.markdown("---")
    st.markdown("### 📊 Debug Information")
    st.info(f"Page config: initial_sidebar_state='expanded'")
    st.info(f"Streamlit version: {st.__version__}")

if __name__ == "__main__":
    main()
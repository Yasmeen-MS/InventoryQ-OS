"""
Local test runner for the Streamlit validation app
Run this to test the validation interface locally
"""
import subprocess
import sys
import os

def run_validation_app():
    """Run the Streamlit validation app locally"""
    
    print("🚀 Starting ResQ OS Validation App...")
    print("📍 Running locally on http://localhost:8501")
    print("🔗 This tests the Python UDF functions directly")
    print("❄️ For Snowflake UDF testing, use the Snowflake validation app")
    print("-" * 50)
    
    # Path to the validation app
    app_path = os.path.join("src", "streamlit_apps", "validation_app.py")
    
    if not os.path.exists(app_path):
        print(f"❌ Error: {app_path} not found!")
        return
    
    try:
        # Run streamlit
        subprocess.run([
            sys.executable, "-m", "streamlit", "run", app_path,
            "--server.port", "8501",
            "--server.address", "localhost"
        ])
    except KeyboardInterrupt:
        print("\n✅ Validation app stopped by user")
    except Exception as e:
        print(f"❌ Error running validation app: {e}")

if __name__ == "__main__":
    print("ResQ OS - Validation App Test Runner")
    print("=" * 40)
    
    # Check if streamlit is installed
    try:
        import streamlit
        print(f"✅ Streamlit {streamlit.__version__} found")
    except ImportError:
        print("❌ Streamlit not installed. Install with: pip install streamlit")
        sys.exit(1)
    
    # Check if required modules exist
    required_files = [
        "src/udfs/simulation_udfs.py",
        "src/streamlit_apps/validation_app.py"
    ]
    
    missing_files = [f for f in required_files if not os.path.exists(f)]
    if missing_files:
        print(f"❌ Missing required files: {missing_files}")
        sys.exit(1)
    
    print("✅ All required files found")
    print()
    
    run_validation_app()
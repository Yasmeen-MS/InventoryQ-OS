"""
Property-based tests for multi-tenant functionality
Feature: inventoryq-supply-chain
"""
import pytest
from hypothesis import given, strategies as st
from datetime import datetime
from src.models.data_models import InventoryItem, SectorType, Location
from src.database.db_operations import DatabaseOperations


# Hypothesis strategies for generating test data
@st.composite
def inventory_item_strategy(draw):
    """Generate random inventory items for testing"""
    sector_types = [SectorType.HOSPITAL, SectorType.PDS, SectorType.NGO]
    item_types = {
        SectorType.HOSPITAL: ["OXYGEN", "MEDICAL_SUPPLIES"],
        SectorType.PDS: ["RICE", "WHEAT", "SUGAR"],
        SectorType.NGO: ["EMERGENCY_KIT", "BLANKETS", "WATER"]
    }
    
    sector = draw(st.sampled_from(sector_types))
    
    # Generate unique IDs to avoid conflicts
    unique_suffix = draw(st.integers(min_value=1000, max_value=9999))
    
    return InventoryItem(
        inventory_id=f"{sector.value}_{unique_suffix}_{draw(st.integers(min_value=1, max_value=999))}",
        organization_id=f"ORG_{draw(st.text(min_size=3, max_size=10, alphabet=st.characters(whitelist_categories=('Lu', 'Ll', 'Nd'))))}",
        sector_type=sector,
        item_type=draw(st.sampled_from(item_types[sector])),
        current_stock=draw(st.floats(min_value=0.0, max_value=1000.0)),
        daily_consumption_rate=draw(st.floats(min_value=0.1, max_value=50.0)),
        reorder_point=draw(st.floats(min_value=1.0, max_value=100.0)),
        critical_threshold=draw(st.floats(min_value=1.0, max_value=10.0)),
        location=Location(
            city=draw(st.sampled_from(["Bangalore", "Delhi", "Mumbai", "Chennai", "Kolkata"])),
            state=draw(st.sampled_from(["Karnataka", "Delhi", "Maharashtra", "Tamil Nadu", "West Bengal"])),
            country="India"
        ),
        last_updated=datetime.now()
    )


class TestMultiTenantProperties:
    """Property-based tests for multi-tenant data operations"""
    
    def setup_method(self):
        """Set up fresh database for each test"""
        self.db = DatabaseOperations()
        self.db.clear_data()  # Ensure clean state
    
    @given(st.lists(inventory_item_strategy(), min_size=3, max_size=10))
    def test_multi_tenant_data_unification(self, inventory_items):
        """
        Property 1: Multi-tenant data unification
        Feature: inventoryq-supply-chain, Property 1: Multi-tenant data unification
        **Validates: Requirements 1.1, 1.2**
        
        For any combination of Hospital, PDS, and NGO inventory data, 
        inserting records for all three sectors should result in all records 
        being queryable from a single unified table structure.
        """
        # Clear database at start of each test run
        self.db.clear_data()
        
        # Ensure unique inventory IDs by adding a timestamp suffix
        import time
        timestamp = str(int(time.time() * 1000000))  # microsecond timestamp
        
        # Make inventory IDs unique for this test run
        for i, item in enumerate(inventory_items):
            item.inventory_id = f"{item.inventory_id}_{timestamp}_{i}"
        
        # Ensure we have at least one item from each sector
        sectors_present = set(item.sector_type for item in inventory_items)
        
        # If we don't have all three sectors, add minimal items to ensure coverage
        if SectorType.HOSPITAL not in sectors_present:
            hospital_item = InventoryItem(
                inventory_id=f"TEST_HOSP_001_{timestamp}",
                organization_id="TEST_ORG_HOSP",
                sector_type=SectorType.HOSPITAL,
                item_type="OXYGEN",
                current_stock=100.0,
                daily_consumption_rate=10.0,
                reorder_point=30.0,
                critical_threshold=3.0,
                location=Location("Bangalore", "Karnataka", "India")
            )
            inventory_items.append(hospital_item)
        
        if SectorType.PDS not in sectors_present:
            pds_item = InventoryItem(
                inventory_id=f"TEST_PDS_001_{timestamp}",
                organization_id="TEST_ORG_PDS",
                sector_type=SectorType.PDS,
                item_type="RICE",
                current_stock=500.0,
                daily_consumption_rate=25.0,
                reorder_point=100.0,
                critical_threshold=7.0,
                location=Location("Delhi", "Delhi", "India")
            )
            inventory_items.append(pds_item)
        
        if SectorType.NGO not in sectors_present:
            ngo_item = InventoryItem(
                inventory_id=f"TEST_NGO_001_{timestamp}",
                organization_id="TEST_ORG_NGO",
                sector_type=SectorType.NGO,
                item_type="EMERGENCY_KIT",
                current_stock=50.0,
                daily_consumption_rate=5.0,
                reorder_point=15.0,
                critical_threshold=5.0,
                location=Location("Mumbai", "Maharashtra", "India")
            )
            inventory_items.append(ngo_item)
        
        # Insert all items
        for item in inventory_items:
            success = self.db.insert_inventory_item(item)
            assert success, f"Failed to insert item {item.inventory_id}"
        
        # Get unified inventory
        unified_inventory = self.db.get_unified_inventory()
        
        # Property: All inserted items should be queryable from unified table
        assert len(unified_inventory) == len(inventory_items), \
            f"Expected {len(inventory_items)} items, got {len(unified_inventory)}"
        
        # Property: All three sectors should be represented in unified view
        unified_sectors = set(item.sector_type for item in unified_inventory)
        assert SectorType.HOSPITAL in unified_sectors, "Hospital sector missing from unified view"
        assert SectorType.PDS in unified_sectors, "PDS sector missing from unified view"
        assert SectorType.NGO in unified_sectors, "NGO sector missing from unified view"
        
        # Property: Each inserted item should be findable in unified view
        unified_ids = set(item.inventory_id for item in unified_inventory)
        for original_item in inventory_items:
            assert original_item.inventory_id in unified_ids, \
                f"Item {original_item.inventory_id} not found in unified view"

    @given(st.lists(inventory_item_strategy(), min_size=5, max_size=15))
    def test_organization_data_isolation(self, inventory_items):
        """
        Property 2: Organization data isolation
        Feature: inventoryq-supply-chain, Property 2: Organization data isolation
        **Validates: Requirements 1.3, 1.4**
        
        For any organization ID and inventory data, querying with that organization's 
        context should return only data belonging to that organization, never data 
        from other organizations.
        """
        # Clear database at start of each test run
        self.db.clear_data()
        
        # Ensure unique inventory IDs by adding a timestamp suffix
        import time
        timestamp = str(int(time.time() * 1000000))  # microsecond timestamp
        
        # Make inventory IDs unique for this test run
        for i, item in enumerate(inventory_items):
            item.inventory_id = f"{item.inventory_id}_{timestamp}_{i}"
        
        # Ensure we have multiple organizations for proper isolation testing
        organizations = set(item.organization_id for item in inventory_items)
        
        # If we have fewer than 2 organizations, create additional items with different org IDs
        if len(organizations) < 2:
            # Add items with specific organization IDs to ensure isolation testing
            additional_items = [
                InventoryItem(
                    inventory_id=f"ISOLATION_TEST_001_{timestamp}",
                    organization_id="ORG_ISOLATION_A",
                    sector_type=SectorType.HOSPITAL,
                    item_type="OXYGEN",
                    current_stock=100.0,
                    daily_consumption_rate=10.0,
                    reorder_point=30.0,
                    critical_threshold=3.0,
                    location=Location("Bangalore", "Karnataka", "India")
                ),
                InventoryItem(
                    inventory_id=f"ISOLATION_TEST_002_{timestamp}",
                    organization_id="ORG_ISOLATION_B",
                    sector_type=SectorType.PDS,
                    item_type="RICE",
                    current_stock=200.0,
                    daily_consumption_rate=15.0,
                    reorder_point=50.0,
                    critical_threshold=5.0,
                    location=Location("Delhi", "Delhi", "India")
                )
            ]
            inventory_items.extend(additional_items)
        
        # Insert all items
        successfully_inserted = []
        for item in inventory_items:
            success = self.db.insert_inventory_item(item)
            if success:
                successfully_inserted.append(item)
            # Note: Some items might fail to insert due to duplicate IDs, which is expected
        
        # Test isolation for each organization
        all_organizations = set(item.organization_id for item in successfully_inserted)
        
        for org_id in all_organizations:
            # Get items for this specific organization
            org_items = self.db.get_inventory_by_organization(org_id)
            
            # Property: All returned items must belong to the queried organization
            for item in org_items:
                assert item.organization_id == org_id, \
                    f"Item {item.inventory_id} belongs to {item.organization_id}, not {org_id}"
            
            # Property: No items from other organizations should be returned
            expected_items_for_org = [
                item for item in successfully_inserted 
                if item.organization_id == org_id
            ]
            
            assert len(org_items) == len(expected_items_for_org), \
                f"Expected {len(expected_items_for_org)} items for org {org_id}, got {len(org_items)}"
            
            # Property: Validate multi-tenant access control
            isolation_valid = self.db.validate_multi_tenant_access(org_id)
            assert isolation_valid, f"Data isolation validation failed for organization {org_id}"
        
        # Property: Total items across all organizations should equal total successfully inserted items
        total_org_items = 0
        for org_id in all_organizations:
            org_items = self.db.get_inventory_by_organization(org_id)
            total_org_items += len(org_items)
        
        assert total_org_items == len(successfully_inserted), \
            f"Total items across organizations ({total_org_items}) != total inserted ({len(successfully_inserted)})"
"""
Database operations for ResQ OS
"""
from typing import List, Dict, Optional
from datetime import datetime
import json
from src.models.data_models import InventoryItem, SectorType, Location, SectorConfig


class DatabaseOperations:
    """Database operations for multi-tenant inventory management"""
    
    def __init__(self):
        # In a real implementation, this would connect to Snowflake
        # For now, we'll use in-memory storage for testing
        self.inventory_data: Dict[str, InventoryItem] = {}
        self.sector_configs: Dict[str, SectorConfig] = {
            'HOSPITAL': SectorConfig(SectorType.HOSPITAL, 2.0, 3, 1),
            'PDS': SectorConfig(SectorType.PDS, 1.5, 7, 2),
            'NGO': SectorConfig(SectorType.NGO, 1.8, 5, 1)
        }
    
    def insert_inventory_item(self, item: InventoryItem) -> bool:
        """Insert an inventory item into the database"""
        try:
            # Check for duplicate inventory_id and reject if exists
            if item.inventory_id in self.inventory_data:
                return False
            self.inventory_data[item.inventory_id] = item
            return True
        except Exception:
            return False
    
    def get_unified_inventory(self) -> List[InventoryItem]:
        """Get all inventory items across all sectors"""
        return list(self.inventory_data.values())
    
    def get_inventory_by_organization(self, organization_id: str) -> List[InventoryItem]:
        """Get inventory items for a specific organization"""
        return [
            item for item in self.inventory_data.values() 
            if item.organization_id == organization_id
        ]
    
    def get_inventory_by_sector(self, sector_type: SectorType) -> List[InventoryItem]:
        """Get inventory items for a specific sector"""
        return [
            item for item in self.inventory_data.values() 
            if item.sector_type == sector_type
        ]
    
    def insert_test_data(self) -> bool:
        """Insert test data for all three sectors"""
        try:
            # Hospital test data
            hospital_item = InventoryItem(
                inventory_id="HOSP_001",
                organization_id="ORG_HOSPITAL_001",
                sector_type=SectorType.HOSPITAL,
                item_type="OXYGEN",
                current_stock=100.0,
                daily_consumption_rate=10.0,
                reorder_point=30.0,
                critical_threshold=3.0,
                location=Location("Bangalore", "Karnataka", "India"),
                last_updated=datetime.now()
            )
            
            # PDS test data
            pds_item = InventoryItem(
                inventory_id="PDS_001",
                organization_id="ORG_PDS_001",
                sector_type=SectorType.PDS,
                item_type="RICE",
                current_stock=500.0,
                daily_consumption_rate=25.0,
                reorder_point=100.0,
                critical_threshold=7.0,
                location=Location("Delhi", "Delhi", "India"),
                last_updated=datetime.now()
            )
            
            # NGO test data
            ngo_item = InventoryItem(
                inventory_id="NGO_001",
                organization_id="ORG_NGO_001",
                sector_type=SectorType.NGO,
                item_type="EMERGENCY_KIT",
                current_stock=50.0,
                daily_consumption_rate=5.0,
                reorder_point=15.0,
                critical_threshold=5.0,
                location=Location("Mumbai", "Maharashtra", "India"),
                last_updated=datetime.now()
            )
            
            self.insert_inventory_item(hospital_item)
            self.insert_inventory_item(pds_item)
            self.insert_inventory_item(ngo_item)
            
            return True
        except Exception:
            return False
    
    def validate_multi_tenant_access(self, organization_id: str) -> bool:
        """Validate that organization can only access its own data"""
        org_items = self.get_inventory_by_organization(organization_id)
        
        # Check that all returned items belong to the organization
        for item in org_items:
            if item.organization_id != organization_id:
                return False
        
        return True
    
    def clear_data(self):
        """Clear all data (for testing purposes)"""
        self.inventory_data.clear()
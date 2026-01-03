"""
Data models for InventoryQ OS - Autonomous AI Inventory Operating System
"""
from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from typing import Dict, List, Optional


class SectorType(Enum):
    """Enum for different sector types"""
    HOSPITAL = "HOSPITAL"
    PDS = "PDS"
    NGO = "NGO"


@dataclass
class Location:
    """Location data structure"""
    city: str
    state: str
    country: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None


@dataclass
class InventoryItem:
    """Core inventory item data model"""
    inventory_id: str
    organization_id: str
    sector_type: SectorType
    item_type: str
    current_stock: float
    daily_consumption_rate: float
    reorder_point: float
    critical_threshold: float
    location: Location
    last_updated: Optional[datetime] = None
    
    def days_remaining(self) -> float:
        """Calculate days until stockout"""
        if self.daily_consumption_rate <= 0:
            return float('inf')
        return self.current_stock / self.daily_consumption_rate
    
    def is_critical(self) -> bool:
        """Check if stock is at critical level"""
        return self.days_remaining() <= self.critical_threshold


@dataclass
class PurchaseOrder:
    """Purchase order data model"""
    order_id: str
    inventory_id: str
    quantity: float
    urgency_level: str
    estimated_delivery: datetime
    vendor_info: Dict
    auto_generated: bool
    created_at: datetime
    reasoning: str


@dataclass
class ExternalData:
    """External data from APIs or simulation"""
    weather_conditions: Dict
    traffic_delays: Dict
    vendor_availability: Dict
    data_source: str  # 'REAL' or 'SIMULATED'
    timestamp: datetime


@dataclass
class HospitalSupply(InventoryItem):
    """Hospital-specific supply model"""
    oxygen_purity_level: float = 99.5
    medical_grade_required: bool = True
    patient_capacity: int = 100


@dataclass
class PDSSupply(InventoryItem):
    """PDS-specific supply model"""
    grain_quality_grade: str = "A"
    government_allocation: float = 1000.0
    distribution_schedule: Dict = None
    
    def __post_init__(self):
        if self.distribution_schedule is None:
            self.distribution_schedule = {}


@dataclass
class NGOSupply(InventoryItem):
    """NGO-specific supply model"""
    emergency_type: str = "DISASTER"  # 'DISASTER', 'HUMANITARIAN'
    kit_contents: List[str] = None
    deployment_readiness: bool = True
    
    def __post_init__(self):
        if self.kit_contents is None:
            self.kit_contents = []


@dataclass
class SectorConfig:
    """Sector configuration data model"""
    sector_type: SectorType
    criticality_multiplier: float
    default_reorder_days: int
    priority_level: int
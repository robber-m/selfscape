import uuid
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field

class AcquisitionModel(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    description: str
    imageUrl: str
    dateAcquired: datetime
    source: str
    tags: List[str]

class AcquisitionCreate(BaseModel):
    name: str
    description: str
    imageUrl: str
    dateAcquired: datetime
    source: str
    tags: List[str]

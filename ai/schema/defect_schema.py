from pydantic import BaseModel
from typing import List, Optional

class ReportRequest(BaseModel):
    lat: float
    lng: float
    description: str
    title: str

class AnalyzeRequest(BaseModel):
    lat: float
    lng: float

class DefectResponse(BaseModel):
    id: Optional[str]
    # defect_score: float
from pydantic import BaseModel
from typing import List, Optional
from PIL import Image

class ReportRequest(BaseModel):
    title: str
    description: str
    lat: float
    lng: float
    image: Optional[str] #base64

class AnalyzeRequest(BaseModel):
    lat: float
    lng: float

class DefectResponse(BaseModel):
    id: Optional[str]
    defect_score: Optional[float]
    message: Optional[str]
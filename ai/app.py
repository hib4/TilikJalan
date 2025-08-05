from fastapi import FastAPI, HTTPException
from typing import List, Optional
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from services.firebase_service import FirebaseService
from services.street_view import capture_road_images
from schema.defect_schema import DefectResponse, AnalyzeRequest, ReportRequest
from inference_sdk import InferenceHTTPClient
from dotenv import load_dotenv
import os
import uvicorn
import base64

load_dotenv()

app = FastAPI(
    title='Tilik Jalan',
    description='Analyze road damages in Indonesia',
    version='1.0.0'
)

# Allow CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Storage
firebase = FirebaseService()

# Initialize Inference Client
client = InferenceHTTPClient(
    api_url="https://serverless.roboflow.com",
    api_key=os.getenv('ROBOFLOW_API_KEY')
)

@app.post("/api/v1/ai/analyze-sensor", response_model=Optional[DefectResponse])
async def analyze_sensor(request:AnalyzeRequest):
    # Confirm the occurence of damages in the road
    print('Capturing road images...')
    result = capture_road_images(request.lat, request.lng)
    inference_results = []
    for i, image in enumerate(result['images']):
        print(f'Analyzing image {i}/{len(result['images'])}')
        try:
            inference_result = client.run_workflow(
                workspace_name="safe-road",
                workflow_id="tilik-jalan",
                images={"image":image}
            )[0]
            if inference_result['details']['predictions']:
                inference_results.append(inference_result)
        except:
            print(f'Exception in detecting road damages: {e}')
    
    # If present then try to save to firebase
    if inference_results:
        print('Road defect found! Creating report...')
        try:
            metadata = {
                'lat': request.lat,
                'lng': request.lng,
                'street_name': result['street_name'],
                'taken_date': result['taken_date']
            }
            
            original_images = [result['original_image'] for result in inference_results]
            annotated_images = [result['annotated_image'] for result in inference_results]
            
            # Aggregate confidence score and classes
            total_conf = 0
            all_class = []
            for result in inference_results:
                records = result['details']['predictions']
                for record in records:
                    total_conf += record['confidence']
                    all_class.append(record['class'])
            
            metadata['avg_confidence'] = total_conf / len(records)
            metadata['detected_classes'] = set(all_class)
            
            print('Uploading report to Firestore...')
            report_id = firebase.upload_sensor_report(
                original_images,
                annotated_images,
                metadata
            )
            
            print(f'Report successfully uploaded as {report_id}')
            return DefectResponse(id=report_id)
        except Exception as e:
            print(f'An exception occurred when saving to Firebase: {e}')
    else:
        print(f"Road damage for coordinate {request.lat}, {request.lng} can't be found in Street View !")
        return None

@app.post("/api/v1/ai/analyze-manual-report", response_model=Optional[DefectResponse])
async def analyze_manual(request:ReportRequest):
    image = base64.b64decode(request.image)
    
    # Check if there's really road damage in the image
    try:
        inference_result = client.run_workflow(
                workspace_name="safe-road",
                workflow_id="tilik-jalan",
                images={"image":image}
            )[0]
        if not inference_result['details']['predictions']:
            print('no damages')
            return DefectResponse(message='No road damages detected in the picture, please take a better picture')
    except Exception as e:
        print(f'Exception in detecting road damages: {e}')
    
    report_id = firebase.upload_manual_report(
        original_image=inference_result['original_image'],
        annotated_image=inference_result['annotated_image'],
        metadata={
            'title': request.title,
            'description': request.description,
            'lat': request.lat,
            'lng': request.lng
        }
    )
    
    return DefectResponse(id=report_id)

@app.get("/")
async def root():
    return {"message": "Tilik Jalan API is running!"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)
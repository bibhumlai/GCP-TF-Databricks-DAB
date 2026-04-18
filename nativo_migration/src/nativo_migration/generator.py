import json
import os
from datetime import datetime
from google.cloud import storage

def generate_and_upload_to_gcs(bucket_name, folder_name):
    # 1. Generate Dummy Data
    data = [
        {"user_id": 101, "event": "click", "ts": datetime.now().isoformat(), "amt": 50.0},
        {"user_id": 102, "event": "view", "ts": datetime.now().isoformat(), "amt": 0.0},
        {"user_id": 103, "event": "purchase", "ts": datetime.now().isoformat(), "amt": 120.5}
    ]
    
    file_name = f"nativo_data_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    
    # 2. Upload to GCS
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(f"{folder_name}/{file_name}")
    
    blob.upload_from_string(data=json.dumps(data), content_type='application/json')
    print(f"Successfully uploaded {file_name} to gs://{bucket_name}/{folder_name}/")

if __name__ == "__main__":
    # Ensure you have 'google-cloud-storage' installed: pip install google-cloud-storage
    generate_and_upload_to_gcs("life-migration-data-db", "raw_landing_zone")
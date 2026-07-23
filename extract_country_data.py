"""
Data extraction script used to:
1. Fetch raw country/travel data from the countries.dev API (REST Countries replacement).
2. Upload the raw JSON payload into an AWS S3 bucket for downstream processing.

This script is executed inside GitHub Actions.
"""

import os
import json
import datetime
import requests
import boto3

# Configuration (loaded from environment variables)
# ==========================================

# Free, keyless API endpoint for country data
API_URL = "https://countries.dev/countries"

# S3 bucket name & AWS region
BUCKET_NAME = os.getenv("AWS_S3_BUCKET_NAME", "triplens-landing-zone-ifeoma1")
AWS_REGION = os.getenv("AWS_REGION", "eu-north-1")


# Step 1 - Fetch Data from Countries API
# ==========================================
def fetch_country_data():
    """
    Calls the Countries API and returns the raw JSON response.
    """
    print("Fetching data from Countries API...")

    response = requests.get(API_URL, timeout=30)
    response.raise_for_status()  # Raises an error if the API call fails

    print("Successfully fetched country data.")
    return response.json()


# Step 2 - Upload Raw Data to AWS S3
# ==========================================
def upload_to_s3(data):
    """
    Uploads the raw JSON data into an S3 bucket.
    The file is timestamped so each extraction run is stored separately.
    """

    print("Preparing to upload data to AWS S3...")

    # Creating an S3 client using environment variables
    s3_client = boto3.client(
        "s3",
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
        region_name=AWS_REGION
    )

    # Generating a timestamped file name
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    file_key = f"raw_travel_data/countries_{timestamp}.json"

    print(f"Uploading file to S3 bucket '{BUCKET_NAME}' at key '{file_key}'...")

    # Uploading JSON payload
    s3_client.put_object(
        Bucket=BUCKET_NAME,
        Key=file_key,
        Body=json.dumps(data),
        ContentType="application/json"
    )

    print("Upload complete. Raw data successfully stored in S3.")


# Main Execution Block
# ==========================================
if __name__ == "__main__":
    try:
        raw_data = fetch_country_data()
        upload_to_s3(raw_data)
    except Exception as e:
        print(f"Pipeline Execution Failed: {str(e)}")
        exit(1)
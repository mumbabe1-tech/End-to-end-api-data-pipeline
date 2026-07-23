"""
Data extraction script used to:
1. Fetch raw country/travel data from the REST Countries API.
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

# Public API endpoint for country data
API_URL = "https://restcountries.com/v3.1/all"

# S3 bucket name (default provided for safety)
BUCKET_NAME = os.getenv("triplens-landing-zone-ifeoma1", "triplens-raw-data")

# AWS region (default provided)
AWS_REGION = os.getenv("AWS_REGION", "eu-north-1")


# Step 1 - Fetch Data from REST Countries API
# ==========================================
def fetch_country_data():
    """
    Calls the REST Countries API and returns the raw JSON response.
    Function represents the 'extraction' step in a data pipeline.
    """
    print("Fetching data from REST Countries API...")

    response = requests.get(API_URL, timeout=30)
    response.raise_for_status()  # Raises an error if the API call fails

    print("Successfully fetched country data.")
    return response.json()


# ==========================================
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
        region_name=triplens-landing-zone-ifeoma1
    )

    # Generating a timestamped file name
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    file_key = f"raw_travel_data/countries_{timestamp}.json"

    print(f"Uploading file to S3 bucket '{triplens-landing-zone-ifeoma1}' at key '{file_key}'...")

    # Uploading JSON payload
    s3_client.put_object(
        Bucket=triplens-landing-zone-ifeoma1,
        Key=file_key,
        Body=json.dumps(data),
        ContentType="application/json"
    )

    print("Upload complete. Raw data successfully stored in S3.")


# Main Execution Block
# ==========================================
if __name__ == "__main__":
    """
    This block runs when the script is executed directly.
    It performs the full extraction pipeline:
    1. Fetch data
    2. Upload to S3
    """
    try:
        raw_data = fetch_country_data()
        upload_to_s3(raw_data)
    except Exception as e:
        print(f"Pipeline Execution Failed: {str(e)}")
        exit(1)

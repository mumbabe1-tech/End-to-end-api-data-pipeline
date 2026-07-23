# TripLens Local Data Pipeline Makefile
# Purpose:
#   Run the local data pipeline steps:
#   - Install dependencies
#   - Extract raw data
#   - Run dbt models
#   - Run dbt tests
#   - Clean project artifacts

.PHONY: setup extract run-dbt test-dbt pipeline clean

# 1. Install Python dependencies
setup:
    uv pip install -r requirements.txt

# 2. Extract raw data and upload to S3
extract:
    python scripts/fetch_and_upload.py

# 3. Run dbt transformations
run-dbt:
    cd dbt_project && dbt run --profiles-dir .

# 4. Run dbt tests
test-dbt:
    cd dbt_project && dbt test --profiles-dir .

# 5. Run the entire pipeline end-to-end
pipeline: extract run-dbt test-dbt

# 6. Clean local cache and dbt artifacts
clean:
    rm -rf dbt_project/target dbt_project/dbt_packages .venv __pycache__

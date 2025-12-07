#!/usr/bin/env python3
"""
Push compliance data to Elasticsearch for Kibana visualization.
"""

import json
import requests
from datetime import datetime
import sys
import os

ES_HOST = os.getenv("ES_HOST", "http://localhost:9200")
INDEX_NAME = "cis-compliance"

def create_index():
    """Create Elasticsearch index with proper mapping."""
    mapping = {
        "mappings": {
            "properties": {
                "timestamp": {"type": "date"},
                "scan_type": {"type": "keyword"},
                "profile": {"type": "keyword"},
                "environment": {"type": "keyword"},
                "compliance_score": {"type": "float"},
                "total_controls": {"type": "integer"},
                "passed_controls": {"type": "integer"},
                "failed_controls": {"type": "integer"},
                "skipped_controls": {"type": "integer"},
                "control_id": {"type": "keyword"},
                "control_title": {"type": "text"},
                "control_status": {"type": "keyword"},
                "control_impact": {"type": "float"},
                "resource_id": {"type": "keyword"},
                "resource_type": {"type": "keyword"},
                "severity": {"type": "keyword"},
                "cis_section": {"type": "keyword"}
            }
        }
    }
    
    response = requests.put(f"{ES_HOST}/{INDEX_NAME}", json=mapping)
    print(f"Index creation: {response.status_code}")
    return response.ok

def push_summary(data):
    """Push compliance summary to Elasticsearch."""
    doc = {
        "timestamp": datetime.now().isoformat(),
        "scan_type": "summary",
        "profile": data.get("profile", "aws-cis-benchmark"),
        "environment": data.get("environment", "production"),
        "compliance_score": data.get("compliance_score", 0),
        "total_controls": data.get("total_controls", 0),
        "passed_controls": data.get("passed", 0),
        "failed_controls": data.get("failed", 0),
        "skipped_controls": data.get("skipped", 0)
    }
    
    response = requests.post(f"{ES_HOST}/{INDEX_NAME}/_doc", json=doc)
    print(f"Summary pushed: {response.status_code}")
    return response.ok

def push_controls(inspec_data):
    """Push individual control results to Elasticsearch."""
    profiles = inspec_data.get("profiles", [])
    
    for profile in profiles:
        profile_name = profile.get("name", "unknown")
        
        for control in profile.get("controls", []):
            control_id = control.get("id", "unknown")
            results = control.get("results", [])
            
            # Determine overall status
            if not results:
                status = "skipped"
            elif all(r.get("status") == "passed" for r in results):
                status = "passed"
            else:
                status = "failed"
            
            # Extract CIS section from control ID
            cis_section = control_id.split("-")[2] if len(control_id.split("-")) > 2 else "unknown"
            
            doc = {
                "timestamp": datetime.now().isoformat(),
                "scan_type": "control",
                "profile": profile_name,
                "control_id": control_id,
                "control_title": control.get("title", ""),
                "control_status": status,
                "control_impact": control.get("impact", 0.5),
                "cis_section": cis_section,
                "severity": "critical" if control.get("impact", 0) >= 0.9 else "high" if control.get("impact", 0) >= 0.7 else "medium"
            }
            
            response = requests.post(f"{ES_HOST}/{INDEX_NAME}/_doc", json=doc)
            print(f"Control {control_id}: {response.status_code}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python push_to_elasticsearch.py <json_file>")
        print("Example: python push_to_elasticsearch.py ../demo/sample-outputs/compliance_summary.json")
        sys.exit(1)
    
    json_file = sys.argv[1]
    
    # Create index
    create_index()
    
    # Load and push data
    with open(json_file, 'r') as f:
        data = json.load(f)
    
    # Check if it's a summary or InSpec report
    if "compliance_score" in data:
        push_summary(data)
    elif "profiles" in data:
        push_controls(data)
    else:
        print("Unknown data format")
        sys.exit(1)
    
    print("Data pushed to Elasticsearch successfully!")

if __name__ == "__main__":
    main()

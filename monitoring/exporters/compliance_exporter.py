#!/usr/bin/env python3
"""
Prometheus Exporter for CIS Compliance Metrics
Exports compliance data from InSpec scans to Prometheus format
"""

from prometheus_client import start_http_server, Gauge, Counter, Histogram, Info
import json
import time
import os
import sys
from datetime import datetime

# Prometheus metrics
compliance_score = Gauge('cis_compliance_score', 'Overall CIS compliance score', ['environment', 'profile'])
controls_total = Gauge('cis_controls_total', 'Total number of controls', ['environment', 'profile'])
controls_passed = Gauge('cis_controls_passed', 'Number of passed controls', ['environment', 'profile'])
controls_failed = Gauge('cis_controls_failed', 'Number of failed controls', ['environment', 'profile'])
controls_skipped = Gauge('cis_controls_skipped', 'Number of skipped controls', ['environment', 'profile'])

control_status = Gauge('cis_control_status', 'Status of individual control (1=pass, 0=fail)', 
                       ['control_id', 'title', 'severity', 'section'])

scan_duration = Histogram('cis_scan_duration_seconds', 'Duration of compliance scan', ['profile'])
scan_timestamp = Gauge('cis_last_scan_timestamp', 'Timestamp of last scan', ['environment', 'profile'])

violations_by_severity = Gauge('cis_violations_by_severity', 'Number of violations by severity',
                               ['severity', 'environment'])

# Info metrics
scan_info = Info('cis_scan', 'Information about the compliance scan')


def load_inspec_results(json_file):
    """Load InSpec JSON results"""
    try:
        with open(json_file, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: File {json_file} not found")
        return None
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in {json_file}")
        return None


def extract_metrics(inspec_data, environment='production'):
    """Extract metrics from InSpec results"""
    if not inspec_data:
        return
    
    profiles = inspec_data.get('profiles', [])
    
    for profile in profiles:
        profile_name = profile.get('name', 'unknown')
        controls = profile.get('controls', [])
        
        total = len(controls)
        passed = 0
        failed = 0
        skipped = 0
        
        severity_counts = {'critical': 0, 'high': 0, 'medium': 0, 'low': 0}
        
        for control in controls:
            control_id = control.get('id', 'unknown')
            title = control.get('title', '')
            impact = control.get('impact', 0.5)
            
            # Determine severity
            if impact >= 0.9:
                severity = 'critical'
            elif impact >= 0.7:
                severity = 'high'
            elif impact >= 0.4:
                severity = 'medium'
            else:
                severity = 'low'
            
            # Extract section from control ID (e.g., cis-aws-1.1 -> 1)
            section = control_id.split('-')[2].split('.')[0] if '-' in control_id else 'unknown'
            
            results = control.get('results', [])
            
            # Determine control status
            if not results:
                skipped += 1
                status = -1  # skipped
            elif all(r.get('status') == 'passed' for r in results):
                passed += 1
                status = 1  # passed
            else:
                failed += 1
                status = 0  # failed
                severity_counts[severity] += 1
            
            # Set control-level metric
            control_status.labels(
                control_id=control_id,
                title=title[:50],  # Truncate long titles
                severity=severity,
                section=section
            ).set(status)
        
        # Calculate compliance score
        score = (passed / total * 100) if total > 0 else 0
        
        # Set aggregate metrics
        compliance_score.labels(environment=environment, profile=profile_name).set(score)
        controls_total.labels(environment=environment, profile=profile_name).set(total)
        controls_passed.labels(environment=environment, profile=profile_name).set(passed)
        controls_failed.labels(environment=environment, profile=profile_name).set(failed)
        controls_skipped.labels(environment=environment, profile=profile_name).set(skipped)
        
        # Set violations by severity
        for sev, count in severity_counts.items():
            violations_by_severity.labels(severity=sev, environment=environment).set(count)
        
        # Set scan timestamp
        scan_timestamp.labels(environment=environment, profile=profile_name).set(time.time())
        
        print(f"✅ Metrics updated for {profile_name}:")
        print(f"   Compliance Score: {score:.1f}%")
        print(f"   Passed: {passed}, Failed: {failed}, Skipped: {skipped}")


def watch_directory(directory, environment='production'):
    """Watch directory for new InSpec results"""
    print(f"👀 Watching {directory} for InSpec results...")
    
    seen_files = set()
    
    while True:
        try:
            # Check for JSON files
            if os.path.exists(directory):
                for filename in os.listdir(directory):
                    if filename.endswith('.json') and filename not in seen_files:
                        filepath = os.path.join(directory, filename)
                        print(f"📊 Processing new file: {filename}")
                        
                        data = load_inspec_results(filepath)
                        if data:
                            extract_metrics(data, environment)
                            seen_files.add(filename)
            
            time.sleep(10)  # Check every 10 seconds
            
        except KeyboardInterrupt:
            print("\n👋 Shutting down exporter...")
            break
        except Exception as e:
            print(f"❌ Error: {e}")
            time.sleep(10)


def main():
    port = int(os.getenv('EXPORTER_PORT', 9090))
    environment = os.getenv('ENVIRONMENT', 'production')
    watch_dir = os.getenv('INSPEC_RESULTS_DIR', 'reports')
    
    print(f"🚀 Starting CIS Compliance Prometheus Exporter on port {port}")
    print(f"   Environment: {environment}")
    print(f"   Watching: {watch_dir}")
    
    # Start HTTP server for Prometheus to scrape
    start_http_server(port)
    
    # Set scan info
    scan_info.info({
        'version': '1.0.0',
        'environment': environment,
        'exporter': 'cis-compliance-exporter'
    })
    
    # Load initial data if exists
    initial_file = os.path.join(watch_dir, 'inspec_aws_report.json')
    if os.path.exists(initial_file):
        print(f"📂 Loading initial data from {initial_file}")
        data = load_inspec_results(initial_file)
        if data:
            extract_metrics(data, environment)
    
    # Watch for new files
    watch_directory(watch_dir, environment)


if __name__ == '__main__':
    main()

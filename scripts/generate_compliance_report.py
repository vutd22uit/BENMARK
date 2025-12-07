#!/usr/bin/env python3
"""
CIS Benchmark Compliance Report Generator

This script aggregates InSpec JSON results and generates a compliance score
and detailed report for CIS Benchmark compliance.
"""

import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any


class ComplianceReportGenerator:
    def __init__(self, inspec_json_path: str):
        self.inspec_json_path = Path(inspec_json_path)
        self.report_data = None
        
    def load_inspec_results(self) -> Dict[str, Any]:
        """Load InSpec JSON results"""
        with open(self.inspec_json_path, 'r') as f:
            return json.load(f)
    
    def calculate_compliance_score(self, results: Dict[str, Any]) -> Dict[str, Any]:
        """Calculate compliance score from InSpec results"""
        profiles = results.get('profiles', [])
        
        total_controls = 0
        passed_controls = 0
        failed_controls = 0
        skipped_controls = 0
        
        control_details = []
        
        for profile in profiles:
            for control in profile.get('controls', []):
                total_controls += 1
                control_id = control.get('id', 'unknown')
                control_title = control.get('title', 'No title')
                control_impact = control.get('impact', 0.0)
                
                results_list = control.get('results', [])
                
                # Determine control status
                if not results_list:
                    skipped_controls += 1
                    status = 'skipped'
                elif all(r.get('status') == 'passed' for r in results_list):
                    passed_controls += 1
                    status = 'passed'
                elif any(r.get('status') == 'failed' for r in results_list):
                    failed_controls += 1
                    status = 'failed'
                else:
                    skipped_controls += 1
                    status = 'skipped'
                
                control_details.append({
                    'id': control_id,
                    'title': control_title,
                    'impact': control_impact,
                    'status': status,
                    'results': results_list
                })
        
        compliance_percentage = (passed_controls / total_controls * 100) if total_controls > 0 else 0
        
        return {
            'total_controls': total_controls,
            'passed_controls': passed_controls,
            'failed_controls': failed_controls,
            'skipped_controls': skipped_controls,
            'compliance_percentage': round(compliance_percentage, 2),
            'control_details': control_details,
            'scan_timestamp': datetime.now().isoformat(),
            'profile_name': profiles[0].get('name', 'Unknown') if profiles else 'Unknown'
        }
    
    def generate_markdown_report(self, compliance_data: Dict[str, Any]) -> str:
        """Generate markdown compliance report"""
        report = f"""# CIS Benchmark Compliance Report

**Generated:** {compliance_data['scan_timestamp']}  
**Profile:** {compliance_data['profile_name']}

## Executive Summary

| Metric | Value |
|--------|-------|
| **Compliance Score** | **{compliance_data['compliance_percentage']}%** |
| Total Controls | {compliance_data['total_controls']} |
| ✅ Passed | {compliance_data['passed_controls']} |
| ❌ Failed | {compliance_data['failed_controls']} |
| ⚠️ Skipped | {compliance_data['skipped_controls']} |

## Compliance Status

"""
        
        # Add status indicator
        if compliance_data['compliance_percentage'] >= 90:
            report += "🟢 **Status: COMPLIANT** (≥90%)\n\n"
        elif compliance_data['compliance_percentage'] >= 70:
            report += "🟡 **Status: PARTIALLY COMPLIANT** (70-89%)\n\n"
        else:
            report += "🔴 **Status: NON-COMPLIANT** (<70%)\n\n"
        
        # Failed controls
        failed_controls = [c for c in compliance_data['control_details'] if c['status'] == 'failed']
        if failed_controls:
            report += "## ❌ Failed Controls (Requires Attention)\n\n"
            for control in failed_controls:
                report += f"### {control['id']}: {control['title']}\n"
                report += f"**Impact:** {control['impact']}\n\n"
                
                for result in control['results']:
                    if result.get('status') == 'failed':
                        report += f"- **Message:** {result.get('message', 'No message')}\n"
                        if 'code_desc' in result:
                            report += f"- **Check:** `{result['code_desc']}`\n"
                
                report += "\n"
        
        # Passed controls summary
        passed_controls = [c for c in compliance_data['control_details'] if c['status'] == 'passed']
        if passed_controls:
            report += f"## ✅ Passed Controls ({len(passed_controls)})\n\n"
            report += "| Control ID | Title |\n"
            report += "|------------|-------|\n"
            for control in passed_controls:
                report += f"| {control['id']} | {control['title']} |\n"
            report += "\n"
        
        # Skipped controls
        skipped_controls = [c for c in compliance_data['control_details'] if c['status'] == 'skipped']
        if skipped_controls:
            report += f"## ⚠️ Skipped Controls ({len(skipped_controls)})\n\n"
            report += "| Control ID | Title |\n"
            report += "|------------|-------|\n"
            for control in skipped_controls:
                report += f"| {control['id']} | {control['title']} |\n"
            report += "\n"
        
        report += """## Recommendations

1. **Address Failed Controls:** Prioritize remediation of failed controls based on impact level.
2. **Review Skipped Controls:** Investigate why controls were skipped and enable them if applicable.
3. **Continuous Monitoring:** Schedule regular compliance scans to maintain compliance posture.
4. **Automated Remediation:** Enable Cloud Custodian policies for automatic remediation where possible.

## Next Steps

- Run `scripts/run_custodian.sh --execute` to automatically remediate violations
- Review and update exception policies for controls that cannot be remediated
- Schedule this scan to run weekly via CI/CD pipeline

---
*This report was generated automatically by the Compliance-as-Code framework.*
"""
        
        return report
    
    def generate_json_summary(self, compliance_data: Dict[str, Any]) -> str:
        """Generate JSON summary for programmatic consumption"""
        summary = {
            'compliance_score': compliance_data['compliance_percentage'],
            'total_controls': compliance_data['total_controls'],
            'passed': compliance_data['passed_controls'],
            'failed': compliance_data['failed_controls'],
            'skipped': compliance_data['skipped_controls'],
            'timestamp': compliance_data['scan_timestamp'],
            'profile': compliance_data['profile_name'],
            'failed_control_ids': [c['id'] for c in compliance_data['control_details'] if c['status'] == 'failed']
        }
        return json.dumps(summary, indent=2)
    
    def run(self, output_dir: str = 'reports'):
        """Run the report generation"""
        print("Loading InSpec results...")
        results = self.load_inspec_results()
        
        print("Calculating compliance score...")
        compliance_data = self.calculate_compliance_score(results)
        
        print(f"\nCompliance Score: {compliance_data['compliance_percentage']}%")
        print(f"Passed: {compliance_data['passed_controls']}/{compliance_data['total_controls']}")
        print(f"Failed: {compliance_data['failed_controls']}")
        
        # Create output directory
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
        
        # Generate markdown report
        print("\nGenerating markdown report...")
        markdown_report = self.generate_markdown_report(compliance_data)
        markdown_path = output_path / 'compliance_report.md'
        with open(markdown_path, 'w') as f:
            f.write(markdown_report)
        print(f"Markdown report saved to: {markdown_path}")
        
        # Generate JSON summary
        print("Generating JSON summary...")
        json_summary = self.generate_json_summary(compliance_data)
        json_path = output_path / 'compliance_summary.json'
        with open(json_path, 'w') as f:
            f.write(json_summary)
        print(f"JSON summary saved to: {json_path}")
        
        return compliance_data


def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_compliance_report.py <inspec_json_file> [output_dir]")
        print("Example: python generate_compliance_report.py reports/aws-cis-report.json reports")
        sys.exit(1)
    
    inspec_json_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else 'reports'
    
    generator = ComplianceReportGenerator(inspec_json_path)
    generator.run(output_dir)


if __name__ == '__main__':
    main()

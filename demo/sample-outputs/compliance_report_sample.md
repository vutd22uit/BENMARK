# CIS Benchmark Compliance Report

**Generated:** 2024-12-08T01:45:00+07:00  
**Profile:** aws-cis-benchmark

## Executive Summary

| Metric | Value |
|--------|-------|
| **Compliance Score** | **92.5%** |
| Total Controls | 40 |
| ✅ Passed | 37 |
| ❌ Failed | 2 |
| ⚠️ Skipped | 1 |

## Compliance Status

🟢 **Status: COMPLIANT** (≥90%)

## ❌ Failed Controls (Requires Attention)

### cis-aws-1.4: Ensure access keys are rotated every 90 days or less
**Impact:** 1.0

- **Message:** Access key AKIAIOSFODNN7EXAMPLE is 120 days old
- **Check:** `AWS IAM Access Keys created_days_ago should cmp <= 90`

### cis-aws-2.4.1: Ensure S3 bucket versioning is enabled
**Impact:** 0.5

- **Message:** S3 bucket cis-compliance-temp-lab does not have versioning enabled
- **Check:** `S3 Bucket should have versioning enabled`

## ✅ Passed Controls (37)

| Control ID | Title |
|------------|-------|
| cis-aws-1.1 | Avoid the use of the "root" account |
| cis-aws-1.5 | Ensure IAM password policy requires at least one uppercase letter |
| cis-aws-1.6 | Ensure IAM password policy requires at least one lowercase letter |
| cis-aws-1.7 | Ensure IAM password policy requires at least one symbol |
| cis-aws-1.8 | Ensure IAM password policy requires at least one number |
| cis-aws-1.9 | Ensure IAM password policy requires minimum length of 14 or greater |
| cis-aws-1.10 | Ensure IAM password policy prevents password reuse |
| cis-aws-1.11 | Ensure IAM password policy expires passwords within 90 days or less |
| cis-aws-2.1 | Ensure CloudTrail is enabled in all regions |
| cis-aws-2.2 | Ensure CloudTrail log file validation is enabled |
| cis-aws-2.3 | Ensure the S3 bucket used to store CloudTrail logs is not publicly accessible |
| cis-aws-2.6 | Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket |
| cis-aws-2.7 | Ensure CloudTrail logs are encrypted at rest using KMS CMKs |
| cis-aws-2.1.1 | Ensure all S3 buckets employ encryption-at-rest |
| cis-aws-2.2.1 | Ensure S3 buckets are not publicly accessible |
| cis-aws-2.3.1 | Ensure S3 bucket access logging is enabled |
| cis-aws-4.1 | Ensure no security groups allow ingress from 0.0.0.0/0 to port 22 |
| cis-aws-4.2 | Ensure no security groups allow ingress from 0.0.0.0/0 to port 3389 |
| cis-aws-4.3 | Ensure the default security group of every VPC restricts all traffic |
| ... | (18 more controls passed) |

## ⚠️ Skipped Controls (1)

| Control ID | Title |
|------------|-------|
| cis-aws-4.4 | Ensure routing tables for VPC peering are "least access" |

## Recommendations

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

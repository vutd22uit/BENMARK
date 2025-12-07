# User Guide - CIS Benchmark Compliance-as-Code Framework

## Overview

This framework automates CIS Benchmark compliance checking and remediation for AWS and Linux environments. It provides three layers of protection:

1. **Pre-Deploy Gates**: Catch violations before infrastructure is deployed
2. **Runtime Scanning**: Continuously monitor deployed infrastructure
3. **Automated Remediation**: Automatically fix violations when detected

## Quick Start

### Running Your First Compliance Scan

1. **Scan Infrastructure Code (Pre-Deploy)**
   ```bash
   ./scripts/run_checkov.sh
   ```

2. **Scan Running AWS Environment**
   ```bash
   ./scripts/run_inspec_aws.sh
   ```

3. **Generate Compliance Report**
   ```bash
   python scripts/generate_compliance_report.py \
     reports/aws-cis-report.json \
     reports
   
   # View the report
   cat reports/compliance_report.md
   ```

## Workflow Guide

### 1. Development Workflow (Pre-Deploy Checks)

When developing infrastructure code:

```bash
# 1. Write Terraform code
vim iac/aws/my_resource.tf

# 2. Format code
terraform fmt iac/aws/

# 3. Run local compliance checks
./scripts/run_checkov.sh

# 4. Fix any violations
# Edit your Terraform files based on Checkov output

# 5. Commit and push
git add .
git commit -m "Add compliant S3 bucket"
git push
```

The CI/CD pipeline will automatically:
- Run Terraform validation
- Run Checkov compliance checks
- Run OPA policy validation
- Block the PR if critical violations are found

### 2. Runtime Compliance Monitoring

**Scheduled Scans:**
- Automated scans run every Monday at 9 AM UTC
- Results are posted as GitHub Actions artifacts
- Compliance score is tracked over time

**Manual Scans:**
```bash
# Scan AWS environment
./scripts/run_inspec_aws.sh

# Scan Linux instance
inspec exec policies/inspec/linux-cis-benchmark \
  -t ssh://user@hostname \
  --sudo \
  --reporter cli json:reports/linux-cis-report.json html:reports/linux-cis-report.html
```

### 3. Remediation Workflow

**Automated Remediation (Cloud Custodian):**

```bash
# 1. Dry-run to see what would be changed
./scripts/run_custodian.sh

# 2. Review the proposed changes in reports/custodian/

# 3. Execute remediation
./scripts/run_custodian.sh --execute
```

**Manual Remediation (Ansible for Linux):**

```bash
# Remediate SSH configuration on Linux instances
ansible-playbook \
  -i inventory.ini \
  scripts/ansible/remediate-ssh-config.yml \
  --check  # Dry-run mode

# Apply changes
ansible-playbook \
  -i inventory.ini \
  scripts/ansible/remediate-ssh-config.yml
```

## Understanding Compliance Reports

### Compliance Score Interpretation

| Score | Status | Action Required |
|-------|--------|-----------------|
| ≥90% | 🟢 COMPLIANT | Maintain current posture |
| 70-89% | 🟡 PARTIALLY COMPLIANT | Address failed controls |
| <70% | 🔴 NON-COMPLIANT | Immediate action required |

### Report Sections

1. **Executive Summary**: High-level compliance metrics
2. **Failed Controls**: Violations that need immediate attention
3. **Passed Controls**: Controls that are compliant
4. **Skipped Controls**: Controls that were not evaluated
5. **Recommendations**: Suggested next steps

## CIS Controls Coverage

### AWS CIS Benchmark

| Section | Controls | Coverage |
|---------|----------|----------|
| 1. Identity and Access Management | 1.1-1.11 | ✅ Full |
| 2. Storage & Logging | 2.1-2.7 | ✅ Full |
| 4. Networking | 4.1-4.4 | ✅ Full |

### Linux CIS Benchmark

| Section | Controls | Coverage |
|---------|----------|----------|
| 5.2 SSH Server Configuration | 5.2.1-5.2.14 | ✅ Full |

## Policy Customization

### Adding Custom Checkov Policies

1. Create a new policy file in `policies/checkov/`:
   ```yaml
   # policies/checkov/custom_policy.yaml
   metadata:
     name: "Ensure custom tag exists"
     id: "CUSTOM_001"
   
   definition:
     cond_type: "attribute"
     resource_types:
       - "aws_s3_bucket"
     attribute: "tags.Environment"
     operator: "exists"
   ```

2. Update `.checkov.yaml` to include your custom policy

### Adding Custom OPA Policies

1. Create a new Rego file in `policies/opa/`:
   ```rego
   # policies/opa/custom_policy.rego
   package terraform.custom
   
   deny[msg] {
     resource := input.resource_changes[_]
     resource.type == "aws_instance"
     not resource.change.after.tags.Owner
     
     msg := sprintf("Instance %s missing Owner tag", [resource.address])
   }
   ```

2. Test your policy:
   ```bash
   conftest test tfplan.json --policy policies/opa --namespace terraform
   ```

### Adding Custom InSpec Controls

1. Create a new control file in `policies/inspec/aws-cis-benchmark/controls/`:
   ```ruby
   # policies/inspec/aws-cis-benchmark/controls/custom.rb
   control 'custom-1.0' do
     impact 1.0
     title 'Ensure custom requirement is met'
     desc 'Custom control description'
     
     describe aws_s3_bucket('my-bucket') do
       it { should have_versioning_enabled }
     end
   end
   ```

2. Run InSpec to test:
   ```bash
   inspec exec policies/inspec/aws-cis-benchmark -t aws://
   ```

## Exception Management

### Creating Exceptions

For controls that cannot be remediated or are not applicable:

1. **Checkov Exceptions:**
   ```hcl
   # In your Terraform file
   resource "aws_s3_bucket" "example" {
     # checkov:skip=CKV_AWS_18:Logging not required for this bucket
     bucket = "example-bucket"
   }
   ```

2. **OPA Exceptions:**
   Create an exception list in your Rego policy:
   ```rego
   exception_resources := [
     "aws_s3_bucket.logs",
     "aws_s3_bucket.temp"
   ]
   
   deny[msg] {
     resource := input.resource_changes[_]
     not resource.address in exception_resources
     # ... rest of policy
   }
   ```

3. **InSpec Exceptions:**
   Use InSpec waivers:
   ```yaml
   # waiver.yaml
   cis-aws-2.6:
     expiration_date: 2025-12-31
     justification: "Logging bucket does not require access logging"
   ```
   
   Run with waiver:
   ```bash
   inspec exec profile --waiver-file waiver.yaml
   ```

## Best Practices

### 1. Development
- Always run local checks before committing
- Use descriptive commit messages referencing CIS controls
- Document exceptions with justifications

### 2. Deployment
- Never bypass CI/CD checks
- Review compliance reports before deploying to production
- Test remediation in staging environment first

### 3. Monitoring
- Review weekly compliance reports
- Track compliance score trends
- Set up alerts for compliance score drops

### 4. Remediation
- Always run in dry-run mode first
- Verify changes in staging before production
- Document all manual remediations

## Troubleshooting

### Common Issues

**Issue: Checkov reports false positives**
- Review the specific check documentation
- Add inline skip comments with justification
- Update `.checkov.yaml` to skip the check globally if needed

**Issue: InSpec fails to connect to AWS**
- Verify AWS credentials: `aws sts get-caller-identity`
- Check IAM permissions for read access
- Ensure correct region is set

**Issue: Cloud Custodian doesn't remediate**
- Check if you're running in dry-run mode
- Verify IAM permissions for write access
- Review CloudWatch Logs for error messages

**Issue: Compliance score doesn't improve**
- Verify remediation was actually applied
- Re-run InSpec scan after remediation
- Check for drift (manual changes overriding automation)

## FAQ

**Q: How often should I run compliance scans?**
A: Pre-deploy scans run on every PR. Runtime scans should run at least weekly, or daily for production environments.

**Q: Can I customize the compliance threshold?**
A: Yes, edit `.github/workflows/runtime-compliance-scan.yml` and change the threshold value (default: 70%).

**Q: What if a control cannot be remediated automatically?**
A: Document it as an exception with justification, and implement manual remediation procedures.

**Q: How do I add support for more CIS controls?**
A: Add new InSpec controls in `policies/inspec/`, Checkov checks in `.checkov.yaml`, and OPA policies in `policies/opa/`.

## Support

For additional help:
- Review the [Setup Guide](setup_guide.md)
- Check the [Architecture Documentation](architecture.md)
- Open an issue on GitHub

---
*Last updated: 2024-12-08*

# Frequently Asked Questions (FAQ)

## General Questions

### What is Compliance-as-Code?

Compliance-as-Code is the practice of defining compliance requirements as executable code that can be automatically tested, validated, and enforced throughout the infrastructure lifecycle.

### Why CIS Benchmarks?

CIS (Center for Internet Security) Benchmarks are globally recognized best practices for securing IT systems and data. They provide prescriptive guidance for establishing a secure configuration posture.

### What cloud providers are supported?

Currently, the framework supports:
- **AWS** (Amazon Web Services) - Full support
- **Linux** (via SSH) - SSH configuration controls

Future releases will add Azure and GCP support.

## Installation & Setup

### What are the prerequisites?

- AWS account (free tier is sufficient)
- Terraform 1.0+
- Python 3.9+
- Ruby 3.0+ (for InSpec)
- Git

See the [Setup Guide](docs/setup_guide.md) for detailed requirements.

### Do I need to install all tools?

For basic usage:
- **Required**: Terraform, Checkov, AWS CLI
- **Recommended**: InSpec, OPA/Conftest
- **Optional**: Cloud Custodian, Ansible

### How do I configure AWS credentials?

Three options:
1. AWS CLI: `aws configure`
2. Environment variables: `export AWS_ACCESS_KEY_ID=...`
3. AWS Profile: `export AWS_PROFILE=my-profile`

See [Setup Guide](docs/setup_guide.md#aws-configuration) for details.

## Usage

### How do I run my first scan?

```bash
# Scan infrastructure code
./scripts/run_checkov.sh

# Scan running AWS environment
./scripts/run_inspec_aws.sh

# Generate report
python scripts/generate_compliance_report.py reports/aws-cis-report.json reports
```

### How often should I run scans?

- **Pre-deploy scans**: On every PR (automated via GitHub Actions)
- **Runtime scans**: Weekly minimum, daily for production
- **Remediation**: As needed when violations are detected

### What is a good compliance score?

- **≥90%**: Compliant (excellent)
- **70-89%**: Partially compliant (needs improvement)
- **<70%**: Non-compliant (immediate action required)

### Can I customize the compliance threshold?

Yes, edit `.github/workflows/runtime-compliance-scan.yml` and change the threshold value in the "Fail if compliance below threshold" step.

## Policies & Controls

### How do I add a new CIS control?

1. Add InSpec control in `policies/inspec/`
2. Add Checkov check in `.checkov.yaml`
3. Add OPA policy if needed in `policies/opa/`
4. Update `docs/control_mapping.md`

See [Contributing Guide](CONTRIBUTING.md#adding-new-cis-controls) for details.

### How do I skip a specific check?

**Checkov (inline):**
```hcl
resource "aws_s3_bucket" "example" {
  # checkov:skip=CKV_AWS_18:Logging not required for this bucket
  bucket = "example"
}
```

**OPA (exception list):**
Add resource to exception list in the Rego policy.

**InSpec (waiver):**
Create a waiver file and use `--waiver-file` flag.

### What if a control cannot be remediated?

Document it as an exception with:
- Justification
- Compensating controls
- Expiration date
- Approval from security team

## Remediation

### Is automated remediation safe?

Yes, when used properly:
1. Always test in **dry-run mode** first
2. Test in **staging** before production
3. Review proposed changes carefully
4. Have rollback plan ready

### What does Cloud Custodian remediate?

- S3 public access blocking
- S3 encryption enablement
- Security group rule removal
- CloudTrail configuration

See [Cloud Custodian policies](policies/custodian/) for full list.

### Can remediation break my infrastructure?

Potentially, if:
- You skip dry-run testing
- You don't review changes
- You have dependencies on non-compliant configurations

**Always test first!**

## CI/CD Integration

### How do I set up GitHub Actions?

1. Add AWS credentials to GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
2. Workflows are already configured in `.github/workflows/`
3. They run automatically on PR and schedule

### Can I use this with GitLab CI or Jenkins?

Yes, the scripts are tool-agnostic. You'll need to:
1. Adapt the workflow YAML to your CI/CD syntax
2. Configure secrets/credentials
3. Install required tools in CI environment

### How do I block non-compliant PRs?

The workflow is already configured to block PRs with critical violations. The "Compliance Gate" job will fail if Checkov or OPA finds violations.

## Troubleshooting

### Checkov reports false positives

1. Review the specific check documentation
2. Add inline skip comment with justification
3. Update `.checkov.yaml` to skip globally if needed

### InSpec fails to connect to AWS

1. Verify credentials: `aws sts get-caller-identity`
2. Check IAM permissions (read access required)
3. Ensure correct region is set

### Cloud Custodian doesn't remediate

1. Verify you're not in dry-run mode
2. Check IAM permissions (write access required)
3. Review CloudWatch Logs for errors

### Compliance score doesn't improve after remediation

1. Verify remediation was actually applied
2. Re-run InSpec scan after remediation
3. Check for drift (manual changes)

## Cost & Performance

### How much does this cost to run?

- **AWS Free Tier**: Most scans are free
- **GitHub Actions**: Free for public repos, included minutes for private
- **Tools**: All open-source tools are free

Costs only occur if you deploy actual infrastructure.

### How long do scans take?

- **Checkov**: 10-30 seconds
- **OPA**: 5-10 seconds
- **InSpec (AWS)**: 2-5 minutes
- **Cloud Custodian**: 1-3 minutes

Times vary based on number of resources.

### Can I scan multiple AWS accounts?

Yes, but requires additional setup:
1. Configure cross-account IAM roles
2. Update InSpec target configuration
3. Run scans sequentially or in parallel

## Security & Compliance

### Are my AWS credentials secure?

Yes, if you follow best practices:
- Store in GitHub Secrets (encrypted)
- Use IAM roles with least privilege
- Rotate credentials regularly
- Never commit to repository

### Is this audit-ready?

Yes, the framework provides:
- Complete audit trail in GitHub Actions
- Compliance reports with evidence
- Versioned policies in Git
- Timestamped scan results

### Does this replace manual audits?

No, it complements them by:
- Automating repetitive checks
- Providing continuous monitoring
- Reducing manual effort
- Improving consistency

Manual audits are still needed for complex controls.

## Advanced Usage

### Can I integrate with SIEM?

Yes, you can:
1. Export InSpec results to JSON
2. Send to SIEM via API or file upload
3. Use Cloud Custodian CloudWatch integration

### Can I create custom dashboards?

Yes, use the JSON reports to build dashboards in:
- Grafana
- Kibana
- Custom web app
- AWS QuickSight

### Can I scan on-premises infrastructure?

Yes, for Linux servers:
```bash
inspec exec policies/inspec/linux-cis-benchmark \
  -t ssh://user@on-prem-server \
  --sudo
```

## Support

### Where can I get help?

1. Check this FAQ
2. Review [User Guide](docs/user_guide.md)
3. Search GitHub Issues
4. Open a new issue
5. Contact the compliance team

### How do I report a bug?

Open a GitHub Issue with:
- Clear description
- Steps to reproduce
- Expected vs actual behavior
- Environment details
- Logs/screenshots

### Can I contribute?

Yes! See [Contributing Guide](CONTRIBUTING.md) for details.

---
*Last updated: 2024-12-08*

# Demo Guide - CIS Benchmark Compliance-as-Code Framework

## Complete Demo Flow (15-20 minutes)

This guide combines all three demo scenarios into a cohesive presentation.

## Pre-Demo Preparation

### 1. Open Required Files
Open these files in your IDE before the demo:

- `iac/aws/s3_bucket.tf`
- `policies/opa/s3_public_deny.rego`
- `policies/inspec/aws-cis-benchmark/controls/storage.rb`
- `policies/custodian/s3-enforce-private.yml`
- `scripts/run_checkov.sh`

### 2. Prepare Terminal Windows
Open 2-3 terminal windows:
- Terminal 1: For running commands
- Terminal 2: For showing logs/output
- Terminal 3: For tailing sample outputs

### 3. Pre-Load Sample Outputs
```bash
cd /Users/vutruongdoan/.gemini/antigravity/playground/crystal-nova

# Verify sample files exist
ls -la demo/sample-outputs/
ls -la demo/scenarios/
```

## Demo Flow

### Opening (2 minutes)

```
"Today I'm going to demonstrate our CIS Benchmark Compliance-as-Code 
framework. This framework automates security compliance across the 
entire infrastructure lifecycle.

We'll see three key capabilities:
1. Pre-deploy gates that BLOCK non-compliant code
2. Runtime scanning that DETECTS violations in deployed infrastructure
3. Automated remediation that FIXES violations automatically

Let's get started."
```

### Part 1: Architecture Overview (3 minutes)

Show the README.md architecture diagram:

```
┌─────────────────────────────────────────────────────────────────┐
│                     Developer Workflow                          │
│  IaC Code → Pre-commit → Checkov → Git Push → GitHub Actions   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      CI/CD Pipeline                             │
│  Terraform Validate → Checkov → OPA/Conftest → Block/Allow     │
└─────────────────────────────────────────────────────────────────┘
```

**Key points**:
- "Three layers of protection"
- "Shift-left security - catch issues early"
- "Continuous monitoring for drift"
- "Self-healing with auto-remediation"

### Part 2: Pre-Deploy Gates (5 minutes)

Follow `demo/scenarios/01_pre_deploy_blocking.md`:

1. Show compliant S3 bucket code
2. Run Checkov - all passes
3. Add non-compliant bucket (public ACL)
4. Run Checkov - fails with detailed error
5. Show how CI/CD would block the PR
6. Fix the code - passes again

**Key message**: "We catch violations BEFORE deployment"

### Part 3: Runtime Scanning (5 minutes)

Follow `demo/scenarios/02_runtime_scanning.md`:

1. Show InSpec profile structure
2. Show a sample control (S3 public check)
3. Show sample scan output (JSON)
4. Generate compliance report
5. Show compliance score and executive summary
6. Show scheduled scans in GitHub Actions

**Key message**: "Continuous monitoring catches drift"

### Part 4: Automated Remediation (5 minutes)

Follow `demo/scenarios/03_automated_remediation.md`:

1. Show Cloud Custodian policy
2. Run dry-run mode - preview changes
3. Explain execute mode - apply changes
4. Show remediation report (before/after state)
5. Show Ansible for Linux remediation
6. Explain verification cycle

**Key message**: "Self-healing infrastructure"

### Closing (2 minutes)

```
"Let me summarize what we've seen:

1. PRE-DEPLOY GATES: Our Checkov and OPA policies catch violations 
   before code is deployed. No manual review needed.

2. RUNTIME SCANNING: InSpec continuously monitors our deployed 
   infrastructure. We catch drift and manual changes.

3. AUTO-REMEDIATION: Cloud Custodian and Ansible automatically fix 
   violations. The system is self-healing.

4. AUDIT EVIDENCE: All scans and remediations are logged for 
   compliance auditors.

This framework implements 36 CIS controls and is production-ready.

Any questions?"
```

## Quick Demo Commands Reference

```bash
# Pre-deploy scanning
./scripts/run_checkov.sh

# OPA policy testing
./tests/test_rego_policies.sh

# Show sample outputs
cat demo/sample-outputs/checkov_passed_report.json | jq '.summary'
cat demo/sample-outputs/compliance_report_sample.md
cat demo/sample-outputs/custodian_remediation_report.json | jq '.summary'

# Cloud Custodian (dry-run)
./scripts/run_custodian.sh
```

## Handling Q&A

### Common Questions

**Q: Can this work with Azure/GCP?**
A: "The architecture is extensible. We can add Azure/GCP InSpec profiles and policies. The core framework is cloud-agnostic."

**Q: What about false positives?**
A: "We have three ways to handle exceptions:
   1. Inline skip comments in Terraform
   2. InSpec waivers for specific resources
   3. Exception policies with expiration dates"

**Q: How much does this slow down deployment?**
A: "Checkov scan takes 10-30 seconds. InSpec scan takes 2-5 minutes. This is minimal compared to the cost of a security incident."

**Q: Is this audit-ready?**
A: "Yes. All scan results are stored as GitHub Actions artifacts with timestamps. We can export PDF reports for auditors."

## Demo Checklist

Before the demo:
- [ ] All sample files are in place
- [ ] Terminal windows are open
- [ ] IDE has required files open
- [ ] Internet connection is working (for GitHub references)
- [ ] Backup sample outputs ready

During the demo:
- [ ] Speak slowly and clearly
- [ ] Point to specific code when explaining
- [ ] Use the terminal to show actual commands
- [ ] Pause for questions after each section

## Troubleshooting

**If commands fail:**
- Use `cat` to show sample output files instead
- Say "Let me show you the expected output from our sample runs"

**If time is short:**
- Skip Part 3 (Runtime Scanning)
- Focus on Pre-deploy gates and Remediation

**If audience is non-technical:**
- Focus more on the business value
- Less time on code, more on reports and metrics

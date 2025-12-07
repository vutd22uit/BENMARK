# Demo Scenario 2: Runtime Compliance Scanning

## Scenario Overview

**Objective**: Demonstrate how the framework continuously monitors deployed infrastructure for compliance.

**Duration**: 5-7 minutes

## Step-by-Step Demo

### Step 1: Show InSpec Profile Structure

Open the InSpec profile directory:

```
policies/inspec/aws-cis-benchmark/
├── inspec.yml
└── controls/
    ├── iam.rb
    ├── logging.rb
    ├── storage.rb
    └── networking.rb
```

**Explain**: "Our InSpec profile contains controls for each CIS Benchmark section."

### Step 2: Show a Sample Control

Open `policies/inspec/aws-cis-benchmark/controls/storage.rb`:

```ruby
# CIS 2.2.1: Ensure S3 buckets are not publicly accessible
control 'cis-aws-2.2.1' do
  impact 1.0
  title 'Ensure S3 buckets are not publicly accessible'
  desc 'Amazon S3 buckets should not be configured to allow public access.'
  
  aws_s3_buckets.bucket_names.each do |bucket|
    describe aws_s3_bucket(bucket) do
      it { should_not be_public }
    end
  end
end
```

**Explain**: "This control checks EVERY S3 bucket in your AWS account to ensure it's not public."

### Step 3: Run InSpec Scan (Simulated)

Since we may not have AWS credentials, show the sample output:

```bash
# Show the command that would run
cat scripts/run_inspec_aws.sh

# Show sample output
cat demo/sample-outputs/inspec_aws_report.json | jq '.profiles[0].controls | length'
# Output: 4 (controls evaluated)
```

**Expected Output** (from sample file):
```
Profile: CIS AWS Foundations Benchmark
Version: 1.0.0

  ✅ cis-aws-1.1: Avoid the use of the root account - PASSED
  ✅ cis-aws-2.1: Ensure CloudTrail is enabled - PASSED
  ✅ cis-aws-2.2.1: Ensure S3 buckets are not public - PASSED
  ✅ cis-aws-4.1: Ensure no security groups allow SSH from 0.0.0.0/0 - PASSED

Profile Summary: 4 successful, 0 failures, 0 skipped
```

### Step 4: Generate Compliance Report

```bash
# Show the report generator
python scripts/generate_compliance_report.py \
  demo/sample-outputs/inspec_aws_report.json \
  demo/sample-outputs/

# View the generated report
cat demo/sample-outputs/compliance_report_sample.md
```

**Show the key metrics**:
- Compliance Score: 92.5%
- Passed: 37 / 40 controls
- Status: COMPLIANT

### Step 5: Show Linux CIS Controls

Open `policies/inspec/linux-cis-benchmark/controls/ssh.rb`:

```ruby
# CIS 5.2.6: Ensure SSH root login is disabled
control 'cis-linux-5.2.6' do
  impact 1.0
  title 'Ensure SSH root login is disabled'
  desc 'The PermitRootLogin parameter specifies if root can log in using ssh.'
  
  describe sshd_config do
    its('PermitRootLogin') { should eq 'no' }
  end
end
```

**Explain**: "For Linux servers, we check SSH configuration against CIS Linux Benchmark."

### Step 6: Show Scheduled Scans in CI/CD

Open `.github/workflows/runtime-compliance-scan.yml`:

```yaml
on:
  schedule:
    # Run every Monday at 9 AM UTC
    - cron: '0 9 * * 1'
```

**Explain**: "Scans run automatically every week. No manual intervention needed."

## Key Talking Points

1. **Continuous Monitoring**: "We don't just scan once - we continuously monitor."
2. **Drift Detection**: "If someone makes a manual change that breaks compliance, we catch it."
3. **Evidence for Auditors**: "All scan results are stored as artifacts for audit purposes."
4. **Multiple Platforms**: "We support AWS and Linux with the same framework."

## Demo Script

```
"Now let me show you how we monitor deployed infrastructure for ongoing compliance.

[Show InSpec profile]
Our InSpec profiles contain controls for each CIS Benchmark requirement.

[Show control code]
Here's a control that checks if S3 buckets are public. It scans ALL 
buckets in your AWS account.

[Run/Show scan]
When we run the scan, we get detailed results for each control.

[Show report]
The report generator creates an executive summary with compliance score
and detailed findings.

[Show scheduled scans]
These scans run automatically every week via GitHub Actions.

This gives us continuous visibility into our compliance posture, 
and creates an audit trail for compliance teams."
```

## Files Needed

- `policies/inspec/aws-cis-benchmark/controls/storage.rb`
- `policies/inspec/linux-cis-benchmark/controls/ssh.rb`
- `scripts/run_inspec_aws.sh`
- `scripts/generate_compliance_report.py`
- `demo/sample-outputs/inspec_aws_report.json`
- `demo/sample-outputs/compliance_report_sample.md`
- `.github/workflows/runtime-compliance-scan.yml`

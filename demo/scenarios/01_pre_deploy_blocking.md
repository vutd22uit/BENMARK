# Demo Scenario 1: Pre-Deploy Gate - Blocking Non-Compliant Code

## Scenario Overview

**Objective**: Demonstrate how the framework blocks non-compliant infrastructure code before deployment.

**Duration**: 5-7 minutes

## Step-by-Step Demo

### Step 1: Show Compliant Code (Starting Point)

Open `iac/aws/s3_bucket.tf` and show the compliant S3 bucket:

```hcl
# COMPLIANT S3 Bucket
resource "aws_s3_bucket" "compliant_bucket" {
  bucket = "${var.project_name}-compliant-${var.environment}"
  
  tags = {
    Name        = "Compliant S3 Bucket"
    CIS_Control = "2.2, 2.6"
  }
}

resource "aws_s3_bucket_public_access_block" "compliant_bucket" {
  bucket = aws_s3_bucket.compliant_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

**Explain**: "This S3 bucket follows CIS control 2.2 - it has public access blocked."

### Step 2: Run Checkov on Compliant Code

```bash
./scripts/run_checkov.sh
```

**Expected Output**:
```
Running Checkov CIS Benchmark Compliance Checks
==================================================

Passed checks: 6
Failed checks: 0
Skipped checks: 0

✅ All CIS compliance checks passed!
```

### Step 3: Introduce a Violation

Uncomment the non-compliant S3 bucket in `iac/aws/s3_bucket.tf`:

```hcl
# NON-COMPLIANT S3 Bucket (for testing detection)
resource "aws_s3_bucket" "non_compliant_bucket" {
  bucket = "${var.project_name}-public-${var.environment}"
  acl    = "public-read"  # CIS 2.2 VIOLATION

  tags = {
    Name        = "Non-Compliant S3 Bucket"
    CIS_Control = "VIOLATION"
  }
}
```

**Explain**: "Now I'm adding a bucket with public-read ACL, which violates CIS control 2.2."

### Step 4: Run Checkov Again

```bash
./scripts/run_checkov.sh
```

**Expected Output**:
```
Running Checkov CIS Benchmark Compliance Checks
==================================================

Check: CKV_AWS_20: "Ensure S3 Bucket has public access blocks"
        FAILED for resource: aws_s3_bucket.non_compliant_bucket
        File: /iac/aws/s3_bucket.tf:70-82

Passed checks: 6
Failed checks: 1
Skipped checks: 0

❌ CIS compliance checks failed! Deployment blocked.
```

### Step 5: Show CI/CD Blocking (If GitHub Actions enabled)

Open the sample GitHub Actions output:

```
❌ Compliance Gate Failed

CKV_AWS_20: S3 bucket has public-read ACL
  File: iac/aws/s3_bucket.tf
  Line: 70-82
  Severity: HIGH

This PR cannot be merged until compliance issues are resolved.
```

### Step 6: Fix the Violation

Comment out the non-compliant bucket and run Checkov again:

```bash
./scripts/run_checkov.sh
```

**Expected Output**:
```
✅ All CIS compliance checks passed!
```

## Key Talking Points

1. **Shift-Left Security**: "We catch violations BEFORE deployment, not after."
2. **Developer Friendly**: "Developers get immediate feedback in their workflow."
3. **Automated Enforcement**: "No manual review needed - the pipeline enforces compliance."
4. **Cost Savings**: "Fixing issues early is 10x cheaper than in production."

## Demo Script

```
"Let me show you how our Compliance-as-Code framework prevents non-compliant 
infrastructure from being deployed.

[Show compliant code]
Here we have an S3 bucket following CIS control 2.2 - public access is blocked.

[Run Checkov]
When we run our compliance scanner, all checks pass.

[Add violation]
Now, watch what happens when someone tries to create a public bucket...

[Run Checkov again]
The scanner immediately catches the violation and blocks deployment.

[Show CI/CD]
In our CI/CD pipeline, this would block the pull request automatically.

[Fix violation]
Once we fix the code, the checks pass and deployment can proceed.

This is the power of Shift-Left Security - we catch issues before they 
become production problems."
```

## Files Needed

- `iac/aws/s3_bucket.tf`
- `scripts/run_checkov.sh`
- `demo/sample-outputs/checkov_failed_report.json`

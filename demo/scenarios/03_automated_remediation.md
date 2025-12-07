# Demo Scenario 3: Automated Remediation

## Scenario Overview

**Objective**: Demonstrate how the framework automatically fixes compliance violations.

**Duration**: 5-7 minutes

## Step-by-Step Demo

### Step 1: Show Cloud Custodian Policy

Open `policies/custodian/s3-enforce-private.yml`:

```yaml
policies:
  - name: s3-enforce-block-public-access
    description: |
      CIS 2.2: Ensure S3 buckets are not publicly accessible.
      This policy automatically enables S3 Block Public Access.
    resource: aws.s3
    filters:
      - or:
          - type: value
            key: PublicAccessBlockConfiguration.BlockPublicAcls
            value: false
    actions:
      - type: set-public-block
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
      - type: notify
        template: default.html
        subject: '[Cloud Custodian] S3 Bucket Public Access Blocked'
        to:
          - compliance@example.com
```

**Explain**: "This policy finds S3 buckets without public access blocking and automatically fixes them."

### Step 2: Show Dry-Run Mode

```bash
# Run in dry-run mode (safe)
./scripts/run_custodian.sh
```

**Expected Output**:
```
Running in DRY-RUN mode (no changes will be applied)
Use --execute to apply changes

Running S3 remediation policies...
custodian run --dryrun policies/custodian/s3-enforce-private.yml

Policy: s3-enforce-block-public-access
  Resource count: 2
  Would fix: public-bucket-1, public-bucket-2

Running Security Group remediation policies...
Policy: security-group-ssh-remediate
  Resource count: 1
  Would fix: sg-12345678 (remove SSH from 0.0.0.0/0)

Cloud Custodian dry-run complete!
```

### Step 3: Show Execute Mode (Simulated)

```bash
# Explain the execute command
echo "To actually apply changes, run:"
echo "./scripts/run_custodian.sh --execute"
```

**Simulated Output**:
```
WARNING: Running in EXECUTE mode - changes will be applied!
Are you sure? (yes/no): yes

Running S3 remediation policies...
Policy: s3-enforce-block-public-access
  ✅ Fixed: public-bucket-1 - Enabled public access block
  ✅ Fixed: public-bucket-2 - Enabled public access block
  📧 Notification sent to: compliance@example.com

Running Security Group remediation policies...
Policy: security-group-ssh-remediate
  ✅ Fixed: sg-12345678 - Removed SSH rule from 0.0.0.0/0
  📧 Notification sent to: compliance@example.com

Cloud Custodian execution complete!
Reports saved to: reports/custodian/
```

### Step 4: Show Ansible Remediation for Linux

Open `scripts/ansible/remediate-ssh-config.yml`:

```yaml
- name: CIS 5.2.6 - Disable SSH root login
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^#?PermitRootLogin'
    line: 'PermitRootLogin no'
  notify: restart sshd

- name: CIS 5.2.9 - Configure strong SSH ciphers
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^#?Ciphers'
    line: 'Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com'
  notify: restart sshd
```

**Explain**: "For Linux instances, we use Ansible to fix SSH configuration issues."

### Step 5: Show Remediation Report

```bash
cat demo/sample-outputs/custodian_remediation_report.json
```

**Show**:
- Resources fixed
- Before/after state
- Timestamp
- Action taken

### Step 6: Verify Remediation with InSpec

```bash
# After remediation, run InSpec again
echo "After remediation, we verify with InSpec:"
echo "./scripts/run_inspec_aws.sh"
echo ""
echo "Expected result: All previously failed controls now pass"
```

## Key Talking Points

1. **Self-Healing Infrastructure**: "The system automatically fixes violations."
2. **Safe Testing**: "Dry-run mode lets you preview changes before applying."
3. **Audit Trail**: "Every remediation is logged with before/after state."
4. **Multiple Methods**: "Cloud Custodian for AWS, Ansible for Linux."

## Demo Script

```
"Now let me show you how we automatically FIX compliance violations.

[Show Custodian policy]
This Cloud Custodian policy finds S3 buckets without public access 
blocking and automatically enables it.

[Run dry-run]
First, we run in dry-run mode to see what WOULD be changed without 
actually making changes.

[Show results]
It found 2 S3 buckets and 1 security group that need fixing.

[Explain execute mode]
When we're confident, we run with --execute to apply the fixes.

[Show Ansible]
For Linux servers, we use Ansible to fix SSH configuration issues.

[Show verification]
After remediation, we run InSpec again to verify the fixes.

This creates a self-healing compliance cycle - violations are detected 
and fixed automatically."
```

## Files Needed

- `policies/custodian/s3-enforce-private.yml`
- `policies/custodian/security-group-ssh-remediate.yml`
- `scripts/run_custodian.sh`
- `scripts/ansible/remediate-ssh-config.yml`
- `demo/sample-outputs/custodian_remediation_report.json`

# Setup Guide - CIS Benchmark Compliance-as-Code Framework

This guide will help you set up the CIS Benchmark Compliance-as-Code framework on your local machine and in your AWS environment.

## Prerequisites

### Required Software
- **Terraform** (v1.0+): Infrastructure as Code tool
- **Python** (3.9+): For Cloud Custodian and reporting scripts
- **Ruby** (3.0+): For InSpec
- **Git**: Version control
- **AWS CLI**: AWS command-line interface

### Optional Software
- **Ansible** (2.9+): For Linux instance remediation
- **Docker**: For containerized scanning (optional)
- **pre-commit**: For local git hooks

## Installation Steps

### 1. Install Terraform

**macOS (Homebrew):**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Verify installation:**
```bash
terraform --version
```

### 2. Install Python Dependencies

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install --upgrade pip
pip install checkov c7n boto3
```

### 3. Install InSpec

```bash
# Using Ruby gem
gem install inspec-bin

# Verify installation
inspec --version
```

### 4. Install Conftest (OPA)

```bash
# macOS (Homebrew)
brew install conftest

# Or download from GitHub releases
wget https://github.com/open-policy-agent/conftest/releases/download/v0.49.1/conftest_0.49.1_Linux_x86_64.tar.gz
tar xzf conftest_0.49.1_Linux_x86_64.tar.gz
sudo mv conftest /usr/local/bin/
```

### 5. Install Ansible (Optional)

```bash
pip install ansible
```

### 6. Install pre-commit (Optional)

```bash
pip install pre-commit
pre-commit install
```

## AWS Configuration

### 1. Configure AWS Credentials

**Option A: AWS CLI Configuration**
```bash
aws configure
```

**Option B: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

**Option C: AWS Profile**
```bash
export AWS_PROFILE="your-profile-name"
```

### 2. Verify AWS Access

```bash
aws sts get-caller-identity
```

## Project Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd crystal-nova
```

### 2. Initialize Terraform

```bash
cd iac/aws
terraform init
```

### 3. Review Terraform Plan

```bash
terraform plan
```

### 4. Deploy Infrastructure (Optional)

> ⚠️ **Warning:** This will create real AWS resources that may incur costs.

```bash
terraform apply
```

## Running Compliance Checks

### 1. IaC Static Analysis (Pre-Deploy)

**Run Checkov:**
```bash
./scripts/run_checkov.sh
```

**Run OPA/Conftest:**
```bash
cd iac/aws
terraform init
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
conftest test tfplan.json --policy ../../policies/opa --namespace terraform
```

### 2. Runtime Compliance Scanning

**Run InSpec against AWS:**
```bash
./scripts/run_inspec_aws.sh
```

**Run InSpec against Linux instance:**
```bash
inspec exec policies/inspec/linux-cis-benchmark \
  -t ssh://user@hostname \
  --sudo \
  --reporter cli json:reports/linux-cis-report.json
```

### 3. Generate Compliance Report

```bash
python scripts/generate_compliance_report.py \
  reports/aws-cis-report.json \
  reports
```

### 4. Run Automated Remediation

**Dry-run mode (recommended first):**
```bash
./scripts/run_custodian.sh
```

**Execute mode (applies changes):**
```bash
./scripts/run_custodian.sh --execute
```

## CI/CD Integration

### GitHub Actions Setup

1. **Add AWS Credentials to GitHub Secrets:**
   - Go to repository Settings → Secrets and variables → Actions
   - Add `AWS_ACCESS_KEY_ID`
   - Add `AWS_SECRET_ACCESS_KEY`

2. **Enable GitHub Actions:**
   - The workflows are already configured in `.github/workflows/`
   - They will run automatically on PR and push events

3. **Manual Workflow Trigger:**
   - Go to Actions tab
   - Select "Runtime Compliance Scan"
   - Click "Run workflow"

## Troubleshooting

### Checkov Issues

**Error: "checkov: command not found"**
```bash
pip install checkov
# Or
pip install --user checkov
export PATH="$HOME/.local/bin:$PATH"
```

### InSpec Issues

**Error: "AWS credentials not found"**
```bash
# Verify credentials
aws sts get-caller-identity

# Set credentials explicitly
export AWS_PROFILE=your-profile
```

**Error: "inspec: command not found"**
```bash
gem install inspec-bin
# Or add to PATH
export PATH="$HOME/.gem/ruby/3.0.0/bin:$PATH"
```

### Terraform Issues

**Error: "Backend initialization required"**
```bash
cd iac/aws
terraform init
```

**Error: "Provider registry.terraform.io/hashicorp/aws not found"**
```bash
terraform init -upgrade
```

### Cloud Custodian Issues

**Error: "c7n: command not found"**
```bash
pip install c7n
```

**Error: "Access Denied" when running policies**
- Verify your AWS credentials have sufficient permissions
- Check IAM policies for required permissions

## Next Steps

1. Review the [User Guide](user_guide.md) for detailed usage instructions
2. Review the [Architecture Documentation](architecture.md) to understand the system design
3. Customize policies in `policies/` directory for your organization's needs
4. Set up scheduled scans in CI/CD pipeline

## Support

For issues or questions:
- Check the [User Guide](user_guide.md)
- Review GitHub Issues
- Contact the compliance team

---
*Last updated: 2024-12-08*

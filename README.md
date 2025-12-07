# Compliance-as-Code Framework (CIS Benchmark)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-1.0+-purple.svg)](https://www.terraform.io/)
[![InSpec](https://img.shields.io/badge/inspec-5.0+-orange.svg)](https://www.inspec.io/)

## Overview
This Capstone Project demonstrates a **Compliance-as-Code** framework designed to automate the testing, reporting, and remediation of policy violations across **OpenStack (Private Cloud)** and **AWS (Public Cloud)** environments.

The framework adheres to the **CIS Benchmarks** (AWS Foundations, Linux) security standards.

## 🎯 Objectives
- **Shift-Left Security:** Catch violations early using IaC scanning (Checkov, OPA).
- **Continuous Compliance:** Monitor runtime environments using automated scanners (InSpec, CloudSploit).
- **Automated Enforcement:** Block non-compliant deployments and auto-remediate runtime drift (Cloud Custodian, AWS Config).
- **Unified Reporting:** Centralize evidence and compliance status.

## 🏗️ Architecture

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
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                   Runtime Monitoring                            │
│  InSpec Scans (Weekly) → Compliance Report → Violations?       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Automated Remediation                          │
│  Cloud Custodian → Auto-fix → Notify → Re-scan                 │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Repository Structure
```text
/
├── .github/workflows/   # CI/CD Pipelines (GitHub Actions)
│   ├── iac-compliance-check.yml      # Pre-deploy IaC scanning
│   └── runtime-compliance-scan.yml   # Scheduled runtime scans
├── docs/                # Documentation
│   ├── architecture.md
│   ├── control_mapping.md
│   ├── setup_guide.md
│   └── user_guide.md
├── iac/                 # Infrastructure as Code (Terraform)
│   ├── aws/             # AWS resources
│   └── openstack/       # OpenStack resources
├── policies/            # Compliance Policies (The "Code")
│   ├── checkov/         # Static analysis policies
│   ├── opa/             # Rego policies for OPA
│   ├── inspec/          # Runtime verification profiles
│   │   ├── aws-cis-benchmark/
│   │   └── linux-cis-benchmark/
│   └── custodian/       # Remediation policies
├── scripts/             # Utility scripts
│   ├── run_checkov.sh
│   ├── run_inspec_aws.sh
│   ├── run_custodian.sh
│   ├── generate_compliance_report.py
│   └── ansible/
│       └── remediate-ssh-config.yml
└── README.md
```

## 🚀 Quick Start

### Prerequisites
- **AWS Account** (Sandbox/Free Tier recommended)
- **Terraform** (v1.0+)
- **Python** (3.9+) & **Ruby** (for InSpec)
- **Checkov**, **OPA**, **InSpec**, **Cloud Custodian**

See [Setup Guide](docs/setup_guide.md) for detailed installation instructions.

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd crystal-nova

# 2. Install Python dependencies
pip install checkov c7n

# 3. Install InSpec
gem install inspec-bin

# 4. Install Conftest (OPA)
brew install conftest  # macOS

# 5. Configure AWS credentials
aws configure
```

### Running Compliance Checks

**1. Scan Infrastructure Code (Pre-Deploy)**
```bash
./scripts/run_checkov.sh
```

**2. Scan Running AWS Environment**
```bash
./scripts/run_inspec_aws.sh
```

**3. Generate Compliance Report**
```bash
python scripts/generate_compliance_report.py \
  reports/aws-cis-report.json \
  reports

# View the report
cat reports/compliance_report.md
```

**4. Run Automated Remediation**
```bash
# Dry-run mode (recommended first)
./scripts/run_custodian.sh

# Execute mode (applies changes)
./scripts/run_custodian.sh --execute
```

## 📊 CIS Controls Coverage

### AWS CIS Benchmark
| Section | Controls | Status |
|---------|----------|--------|
| 1. Identity and Access Management | 1.1-1.11 | ✅ Implemented |
| 2. Storage & Logging | 2.1-2.7 | ✅ Implemented |
| 4. Networking | 4.1-4.4 | ✅ Implemented |

### Linux CIS Benchmark
| Section | Controls | Status |
|---------|----------|--------|
| 5.2 SSH Server Configuration | 5.2.1-5.2.14 | ✅ Implemented |

See [Control Mapping](docs/control_mapping.md) for detailed mapping.

## 🔧 Tools & Technologies

| Tool | Purpose | Layer |
|------|---------|-------|
| **Checkov** | Static IaC analysis | Pre-Deploy |
| **OPA (Conftest)** | Policy-as-code validation | Pre-Deploy |
| **InSpec** | Runtime compliance testing | Runtime |
| **Cloud Custodian** | AWS resource remediation | Remediation |
| **Ansible** | Linux instance remediation | Remediation |
| **Terraform** | Infrastructure as Code | IaC |
| **GitHub Actions** | CI/CD automation | CI/CD |

## 📖 Documentation

- **[Setup Guide](docs/setup_guide.md)**: Installation and configuration
- **[User Guide](docs/user_guide.md)**: How to use the framework
- **[Architecture](docs/architecture.md)**: System design and data flow
- **[Control Mapping](docs/control_mapping.md)**: CIS controls to checks mapping

## 🧪 Testing

### Unit Tests (OPA Policies)
```bash
# Test Rego policies
conftest test iac/aws/tfplan.json \
  --policy policies/opa \
  --namespace terraform
```

### Integration Tests
```bash
# Run full CI/CD pipeline locally
terraform init iac/aws
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
./scripts/run_checkov.sh
conftest test tfplan.json --policy policies/opa
```

## 🔐 Security

### Secrets Management
- AWS credentials stored in GitHub Secrets
- Never commit credentials to repository
- Use IAM roles with least privilege

### IAM Permissions Required
- **Read permissions**: For InSpec scanning
- **Write permissions**: For Cloud Custodian remediation (optional)

See [Architecture](docs/architecture.md#security-considerations) for detailed IAM policies.

## 📈 Compliance Metrics

The framework tracks:
- **Compliance Score**: Percentage of passed controls
- **Violations by Severity**: Critical, High, Medium, Low
- **Mean Time To Remediate (MTTR)**: Time to fix violations
- **Trend Analysis**: Compliance score over time

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-control`)
3. Commit your changes (`git commit -m 'Add CIS control X.Y'`)
4. Push to the branch (`git push origin feature/new-control`)
5. Open a Pull Request

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- CIS Benchmarks for security standards
- HashiCorp for Terraform
- Chef for InSpec
- Open Policy Agent for policy-as-code
- Cloud Custodian community

## 📧 Contact

For questions or support:
- Open an issue on GitHub
- Review the [User Guide](docs/user_guide.md)
- Contact the compliance team

---
**Project Status**: ✅ Production Ready  
**Last Updated**: 2024-12-08  
**Compliance Framework**: CIS Benchmark (AWS Foundations, Linux)


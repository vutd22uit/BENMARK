# Control Mapping Table

This document maps the selected compliance controls to the specific automated checks and enforcement mechanisms implemented in this project.

## Cloud Provider: AWS
| CIS Control ID | Title | Level | IaC Check (Checkov) | Runtime Check (InSpec) | Enforcement |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1.1** | Avoid the use of the "root" account | 1 | N/A | `aws_iam_root_user` | AWS SCP |
| **1.4** | Ensure access keys are rotated every 90 days or less | 1 | N/A | `aws_iam_access_keys` | Python Script / Config Rule |
| **2.1.1** | Ensure CloudTrail is enabled in all regions | 1 | `CKV_AWS_67` | `aws_cloudtrail_trails` | AWS Config + SSM |
| **2.2** | Ensure S3 buckets are not public | 1 | `CKV_AWS_20`, `CKV_AWS_53` | `aws_s3_bucket.be_public` | Cloud Custodian / Config |
| **2.6** | Ensure S3 bucket access logging is enabled | 2 | `CKV_AWS_18` | `aws_s3_bucket.logging` | Block Deployment |
| **4.1** | Ensure no security groups allow ingress from 0.0.0.0/0 to port 22 | 1 | `CKV_AWS_24` | `aws_security_group` | Cloud Custodian |

## Private Cloud: OpenStack (Linux Instances)
| CIS Control ID | Title | Level | IaC Check (Terraform) | Runtime Check (OpenSCAP/InSpec) | Enforcement |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **5.2.1** | Ensure SSH LogLevel is INFO or VERBOSE | 1 | N/A (User Data) | `sshd_config` | Ansible Playbook |
| **1.1.2** | Ensure separate partition exists for /tmp | 2 | Terraform `volume_attachment` | `mount` | N/A (Hard to remediate live) |

*Note: This table focuses exclusively on CIS Benchmarks.*

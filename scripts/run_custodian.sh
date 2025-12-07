#!/bin/bash
# Script to run Cloud Custodian policies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Running Cloud Custodian CIS Remediation Policies${NC}"
echo "=================================================="

# Change to project root
cd "$(dirname "$0")/.."

# Check if custodian is installed
if ! command -v custodian &> /dev/null; then
    echo -e "${RED}Error: Cloud Custodian is not installed${NC}"
    echo "Install with: pip install c7n"
    exit 1
fi

# Check AWS credentials
if [ -z "$AWS_ACCESS_KEY_ID" ] && [ -z "$AWS_PROFILE" ]; then
    echo -e "${YELLOW}Warning: No AWS credentials found${NC}"
    echo "Set AWS_PROFILE or AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY"
    exit 1
fi

# Create output directory
mkdir -p reports/custodian

# Default to dry-run mode unless --execute is passed
DRY_RUN="--dryrun"
if [ "$1" == "--execute" ]; then
    DRY_RUN=""
    echo -e "${YELLOW}WARNING: Running in EXECUTE mode - changes will be applied!${NC}"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        exit 0
    fi
else
    echo -e "${YELLOW}Running in DRY-RUN mode (no changes will be applied)${NC}"
    echo "Use --execute to apply changes"
fi

# Run S3 policies
echo -e "\n${YELLOW}Running S3 remediation policies...${NC}"
custodian run $DRY_RUN \
    --output-dir reports/custodian/s3 \
    --region us-east-1 \
    policies/custodian/s3-enforce-private.yml

# Run Security Group policies
echo -e "\n${YELLOW}Running Security Group remediation policies...${NC}"
custodian run $DRY_RUN \
    --output-dir reports/custodian/security-groups \
    --region us-east-1 \
    policies/custodian/security-group-ssh-remediate.yml

# Run CloudTrail policies
echo -e "\n${YELLOW}Running CloudTrail remediation policies...${NC}"
custodian run $DRY_RUN \
    --output-dir reports/custodian/cloudtrail \
    --region us-east-1 \
    policies/custodian/cloudtrail-enable.yml

echo -e "\n${GREEN}Cloud Custodian execution complete!${NC}"
echo "Reports saved to: reports/custodian/"

# Generate summary report
echo -e "\n${YELLOW}Generating summary report...${NC}"
custodian report \
    --output-dir reports/custodian \
    --format grid \
    policies/custodian/*.yml

echo -e "\n${GREEN}Done!${NC}"

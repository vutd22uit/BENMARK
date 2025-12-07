#!/bin/bash
# Script to run InSpec against AWS environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Running InSpec CIS Benchmark Compliance Checks for AWS${NC}"
echo "=========================================================="

# Change to project root
cd "$(dirname "$0")/.."

# Check if inspec is installed
if ! command -v inspec &> /dev/null; then
    echo -e "${RED}Error: InSpec is not installed${NC}"
    echo "Install with: gem install inspec-bin"
    exit 1
fi

# Check AWS credentials
if [ -z "$AWS_ACCESS_KEY_ID" ] && [ -z "$AWS_PROFILE" ]; then
    echo -e "${YELLOW}Warning: No AWS credentials found${NC}"
    echo "Set AWS_PROFILE or AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY"
    exit 1
fi

# Create output directory
mkdir -p reports

# Run InSpec profile
echo -e "\n${YELLOW}Scanning AWS environment...${NC}"

inspec exec policies/inspec/aws-cis-benchmark \
    -t aws:// \
    --reporter cli json:reports/aws-cis-report.json html:reports/aws-cis-report.html \
    --chef-license accept

echo -e "\n${GREEN}InSpec scan complete!${NC}"
echo "Reports saved to:"
echo "  - reports/aws-cis-report.json"
echo "  - reports/aws-cis-report.html"

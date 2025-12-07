#!/bin/bash
# Script to run Checkov for CIS Benchmark compliance checks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Running Checkov CIS Benchmark Compliance Checks${NC}"
echo "=================================================="

# Change to project root
cd "$(dirname "$0")/.."

# Check if checkov is installed
if ! command -v checkov &> /dev/null; then
    echo -e "${RED}Error: Checkov is not installed${NC}"
    echo "Install with: pip install checkov"
    exit 1
fi

# Run Checkov with configuration file
echo -e "\n${YELLOW}Scanning Terraform code in iac/aws/${NC}"

checkov \
    --config-file policies/checkov/.checkov.yaml \
    --directory iac/aws \
    --output cli \
    --output json \
    --output-file-path . \
    --download-external-modules false \
    --quiet

echo -e "\n${GREEN}Checkov scan complete!${NC}"
echo "Results saved to: results_cli.txt and results_json.json"

#!/bin/bash
# Quick start script to help users get started with the framework

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║   CIS Benchmark Compliance-as-Code Framework              ║
║   Quick Start Script                                      ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${GREEN}Welcome to the CIS Compliance Framework!${NC}\n"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "  ✅ $1 is installed"
        return 0
    else
        echo -e "  ❌ $1 is NOT installed"
        return 1
    fi
}

all_installed=true

check_command "terraform" || all_installed=false
check_command "python3" || all_installed=false
check_command "aws" || all_installed=false

echo ""
echo -e "${YELLOW}Checking optional tools...${NC}"
check_command "checkov" || echo -e "  ℹ️  Install with: pip install checkov"
check_command "inspec" || echo -e "  ℹ️  Install with: gem install inspec-bin"
check_command "conftest" || echo -e "  ℹ️  Install with: brew install conftest"

if [ "$all_installed" = false ]; then
    echo -e "\n${YELLOW}Some required tools are missing. Please install them first.${NC}"
    echo -e "See docs/setup_guide.md for installation instructions.\n"
    exit 1
fi

echo -e "\n${GREEN}All required tools are installed!${NC}\n"

# Check AWS credentials
echo -e "${YELLOW}Checking AWS credentials...${NC}"
if aws sts get-caller-identity &> /dev/null; then
    echo -e "  ✅ AWS credentials are configured"
    aws sts get-caller-identity --query 'Account' --output text | xargs echo -e "  Account ID:"
else
    echo -e "  ❌ AWS credentials are NOT configured"
    echo -e "  Run: aws configure"
    echo ""
fi

# Offer to run initial scan
echo -e "\n${BLUE}What would you like to do?${NC}\n"
echo "1. Run Checkov scan on infrastructure code"
echo "2. Run InSpec scan on AWS environment"
echo "3. Run OPA policy tests"
echo "4. Initialize Terraform"
echo "5. View documentation"
echo "6. Exit"
echo ""

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        echo -e "\n${GREEN}Running Checkov scan...${NC}\n"
        if [ -f "./scripts/run_checkov.sh" ]; then
            ./scripts/run_checkov.sh
        else
            echo -e "${YELLOW}Checkov script not found. Make sure you're in the project root.${NC}"
        fi
        ;;
    2)
        echo -e "\n${GREEN}Running InSpec scan...${NC}\n"
        if [ -f "./scripts/run_inspec_aws.sh" ]; then
            ./scripts/run_inspec_aws.sh
        else
            echo -e "${YELLOW}InSpec script not found. Make sure you're in the project root.${NC}"
        fi
        ;;
    3)
        echo -e "\n${GREEN}Running OPA policy tests...${NC}\n"
        if [ -f "./tests/test_rego_policies.sh" ]; then
            ./tests/test_rego_policies.sh
        else
            echo -e "${YELLOW}Test script not found. Make sure you're in the project root.${NC}"
        fi
        ;;
    4)
        echo -e "\n${GREEN}Initializing Terraform...${NC}\n"
        cd iac/aws
        terraform init
        echo -e "\n${GREEN}Terraform initialized!${NC}"
        echo -e "Next steps:"
        echo -e "  1. Review terraform.tfvars.example"
        echo -e "  2. Create terraform.tfvars with your values"
        echo -e "  3. Run: terraform plan"
        ;;
    5)
        echo -e "\n${GREEN}Documentation:${NC}\n"
        echo -e "  📖 README.md - Project overview"
        echo -e "  📖 docs/setup_guide.md - Installation guide"
        echo -e "  📖 docs/user_guide.md - Usage guide"
        echo -e "  📖 docs/architecture.md - Architecture details"
        echo -e "  📖 docs/FAQ.md - Frequently asked questions"
        echo ""
        ;;
    6)
        echo -e "\n${GREEN}Goodbye!${NC}\n"
        exit 0
        ;;
    *)
        echo -e "\n${YELLOW}Invalid choice. Exiting.${NC}\n"
        exit 1
        ;;
esac

echo -e "\n${GREEN}Done!${NC}"
echo -e "\nFor more information, see:"
echo -e "  📖 docs/user_guide.md"
echo -e "  📖 docs/FAQ.md"
echo ""

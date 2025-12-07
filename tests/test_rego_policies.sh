#!/bin/bash
# Unit tests for OPA Rego policies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Running OPA Rego Policy Tests${NC}"
echo "======================================"

# Change to project root
cd "$(dirname "$0")/.."

# Check if conftest is installed
if ! command -v conftest &> /dev/null; then
    echo -e "${RED}Error: Conftest is not installed${NC}"
    echo "Install with: brew install conftest"
    exit 1
fi

# Create test data directory
mkdir -p tests/data

# Test 1: S3 public bucket should be denied
echo -e "\n${YELLOW}Test 1: S3 public bucket (should FAIL)${NC}"
cat > tests/data/s3_public.json << 'EOF'
{
  "resource_changes": [
    {
      "address": "aws_s3_bucket.test",
      "type": "aws_s3_bucket",
      "change": {
        "after": {
          "bucket": "test-bucket",
          "acl": "public-read"
        }
      }
    }
  ]
}
EOF

conftest test tests/data/s3_public.json \
  --policy policies/opa \
  --namespace terraform.s3 \
  && echo -e "${RED}FAIL: Should have denied public S3 bucket${NC}" \
  || echo -e "${GREEN}PASS: Correctly denied public S3 bucket${NC}"

# Test 2: S3 private bucket should pass
echo -e "\n${YELLOW}Test 2: S3 private bucket (should PASS)${NC}"
cat > tests/data/s3_private.json << 'EOF'
{
  "resource_changes": [
    {
      "address": "aws_s3_bucket.test",
      "type": "aws_s3_bucket",
      "change": {
        "after": {
          "bucket": "test-bucket"
        }
      }
    },
    {
      "address": "aws_s3_bucket_public_access_block.test",
      "type": "aws_s3_bucket_public_access_block",
      "change": {
        "after": {
          "bucket": "test-bucket",
          "block_public_acls": true,
          "block_public_policy": true,
          "ignore_public_acls": true,
          "restrict_public_buckets": true
        }
      }
    }
  ]
}
EOF

conftest test tests/data/s3_private.json \
  --policy policies/opa \
  --namespace terraform.s3 \
  && echo -e "${GREEN}PASS: Private S3 bucket allowed${NC}" \
  || echo -e "${RED}FAIL: Should have allowed private S3 bucket${NC}"

# Test 3: Security group with SSH from 0.0.0.0/0 should be denied
echo -e "\n${YELLOW}Test 3: Security group SSH from 0.0.0.0/0 (should FAIL)${NC}"
cat > tests/data/sg_ssh_open.json << 'EOF'
{
  "resource_changes": [
    {
      "address": "aws_security_group.test",
      "type": "aws_security_group",
      "change": {
        "after": {
          "name": "test-sg",
          "ingress": [
            {
              "from_port": 22,
              "to_port": 22,
              "protocol": "tcp",
              "cidr_blocks": ["0.0.0.0/0"]
            }
          ]
        }
      }
    }
  ]
}
EOF

conftest test tests/data/sg_ssh_open.json \
  --policy policies/opa \
  --namespace terraform.security_groups \
  && echo -e "${RED}FAIL: Should have denied SSH from 0.0.0.0/0${NC}" \
  || echo -e "${GREEN}PASS: Correctly denied SSH from 0.0.0.0/0${NC}"

# Test 4: Security group with SSH from private IP should pass
echo -e "\n${YELLOW}Test 4: Security group SSH from private IP (should PASS)${NC}"
cat > tests/data/sg_ssh_private.json << 'EOF'
{
  "resource_changes": [
    {
      "address": "aws_security_group.test",
      "type": "aws_security_group",
      "change": {
        "after": {
          "name": "test-sg",
          "ingress": [
            {
              "from_port": 22,
              "to_port": 22,
              "protocol": "tcp",
              "cidr_blocks": ["10.0.0.0/8"]
            }
          ]
        }
      }
    }
  ]
}
EOF

conftest test tests/data/sg_ssh_private.json \
  --policy policies/opa \
  --namespace terraform.security_groups \
  && echo -e "${GREEN}PASS: SSH from private IP allowed${NC}" \
  || echo -e "${RED}FAIL: Should have allowed SSH from private IP${NC}"

# Cleanup
rm -rf tests/data

echo -e "\n${GREEN}All OPA policy tests completed!${NC}"

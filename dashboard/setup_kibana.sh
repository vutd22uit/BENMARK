#!/bin/bash
# Setup and run Kibana dashboard for CIS Compliance

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}CIS Compliance Kibana Dashboard Setup${NC}"
echo "========================================"

cd "$(dirname "$0")"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

# Start ELK stack
echo -e "\n${YELLOW}Starting Elasticsearch and Kibana...${NC}"
docker-compose up -d

echo -e "\n${YELLOW}Waiting for Elasticsearch...${NC}"
until curl -s http://localhost:9200 > /dev/null; do
    sleep 5
    echo "Waiting..."
done
echo "Elasticsearch is ready!"

echo -e "\n${YELLOW}Waiting for Kibana...${NC}"
until curl -s http://localhost:5601/api/status > /dev/null; do
    sleep 5
    echo "Waiting..."
done
echo "Kibana is ready!"

# Push sample data
echo -e "\n${YELLOW}Pushing sample compliance data...${NC}"
pip install requests -q
python scripts/push_to_elasticsearch.py ../demo/sample-outputs/compliance_summary.json
python scripts/push_to_elasticsearch.py ../demo/sample-outputs/inspec_aws_report.json

# Import dashboard
echo -e "\n${YELLOW}Importing Kibana dashboard...${NC}"
curl -X POST "http://localhost:5601/api/saved_objects/_import" \
    -H "kbn-xsrf: true" \
    --form file=@kibana/dashboard_export.ndjson

echo -e "\n${GREEN}Setup complete!${NC}"
echo ""
echo "Access Kibana at: http://localhost:5601"
echo "Dashboard: CIS Benchmark Compliance Dashboard"
echo ""
echo "To stop: docker-compose down"

# 📊 Hướng Dẫn Grafana + Prometheus Monitoring

## Tổng Quan

Stack monitoring real-time cho CIS Compliance:
- **Prometheus**: Thu thập metrics
- **Grafana**: Visualization dashboard
- **Alertmanager**: Gửi cảnh báo
- **Compliance Exporter**: Export metrics từ InSpec results

---

## 🚀 Setup Nhanh (5 phút)

### Bước 1: Khởi động stack

```bash
cd monitoring
docker-compose up -d
```

### Bước 2: Truy cập dashboards

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana** | http://localhost:3000 | admin / admin |
| **Prometheus** | http://localhost:9091 | N/A |
| **Alertmanager** | http://localhost:9093 | N/A |
| **Exporter** | http://localhost:9090/metrics | N/A |

### Bước 3: Xem dashboard

1. Mở Grafana: http://localhost:3000
2. Login: admin / admin
3. Vào **Dashboards** → **CIS Compliance**
4. Dashboard sẽ tự động load metrics

---

## 📈 Dashboard Features

### Panel 1: Compliance Score Gauge
- Hiển thị điểm tuân thủ tổng thể (%)
- 🟢 Green: ≥90%
- 🟠 Orange: 70-90%
- 🔴 Red: <70%

### Panel 2: Controls Status Pie Chart
- Phân bổ Passed/Failed/Skipped controls
- Real-time updates

### Panel 3: Violations by Severity
- Bar chart theo mức độ nghiêm trọng
- Critical → High → Medium → Low

### Panel 4: Compliance Score Trend
- Biểu đồ xu hướng 24h
- Theo dõi cải thiện hoặc suy giảm

### Panel 5: Failed Controls Table
- Danh sách chi tiết các controls vi phạm
- Sort theo severity

### Panel 6-9: Stats Tiles
- Total failed controls
- Critical violations count
- High severity violations
- Last scan timestamp

---

## 🔔 Alerts Configuration

### Đã cấu hình sẵn 9 alerts:

| Alert | Trigger | Severity | Action |
|-------|---------|----------|--------|
| **ComplianceScoreCriticallyLow** | Score < 70% | Critical | Slack + Email |
| **ComplianceScoreLow** | Score < 90% | Warning | Slack |
| **CriticalViolationsDetected** | Critical violations > 0 | Critical | Slack + Email |
| **HighNumberOfFailedControls** | Failed > 10 | Warning | Slack |
| **ComplianceScoreDropped** | Drop > 10% in 1h | Warning | Slack |
| **ComplianceScanStale** | No scan 24h | Warning | Slack |
| **CriticalControlFailing** | IAM/Logging controls fail | Critical | Slack + Email |
| **HighSeverityViolationsIncreasing** | Increase > 3 in 1h | Warning | Slack |
| **ComplianceExporterDown** | Exporter down | Critical | Slack + Email |

### Cấu hình Slack alerts:

```bash
# File: prometheus/alertmanager.yml
# Thay YOUR/SLACK/WEBHOOK bằng webhook URL của bạn

slack_api_url: 'https://hooks.slack.com/services/T00/B00/XXX'
```

---

## 📊 Metrics Exported

### Aggregate Metrics

```promql
# Compliance score (%)
cis_compliance_score{environment="production", profile="aws-cis-benchmark"}

# Total controls
cis_controls_total{environment="production", profile="aws-cis-benchmark"}

# Passed controls
cis_controls_passed{environment="production", profile="aws-cis-benchmark"}

# Failed controls
cis_controls_failed{environment="production", profile="aws-cis-benchmark"}

# Skipped controls
cis_controls_skipped{environment="production", profile="aws-cis-benchmark"}
```

### Detailed Metrics

```promql
# Individual control status (1=pass, 0=fail, -1=skip)
cis_control_status{control_id="cis-aws-1.1", title="...", severity="high", section="1"}

# Violations by severity
cis_violations_by_severity{severity="critical", environment="production"}

# Last scan timestamp (Unix timestamp)
cis_last_scan_timestamp{environment="production", profile="aws-cis-benchmark"}
```

---

## 🔍 Useful Queries

### Top 5 failing controls
```promql
topk(5, cis_control_status == 0)
```

### Compliance score change (last hour)
```promql
cis_compliance_score - cis_compliance_score offset 1h
```

### Critical violations count
```promql
sum(cis_violations_by_severity{severity="critical"})
```

### Controls failing in Section 1 (IAM)
```promql
count(cis_control_status{section="1"} == 0)
```

### Average compliance score (all environments)
```promql
avg(cis_compliance_score)
```

---

## 🎯 Integration with CI/CD

### Push metrics từ GitHub Actions

```yaml
# .github/workflows/runtime-compliance-scan.yml
- name: Push metrics to Prometheus
  run: |
    # Copy InSpec results to exporter
    cp reports/inspec_aws_report.json monitoring/watch-dir/
    
    # Exporter sẽ tự động detect và update metrics
```

### Exporter auto-watch directory

Exporter sẽ tự động:
1. Watch directory `reports/` (hoặc configured dir)
2. Detect file JSON mới
3. Parse InSpec results
4. Update Prometheus metrics
5. Prometheus scrape metrics mỗi 15s

---

## 🛠️ Troubleshooting

### Dashboard không hiển thị data

```bash
# 1. Check exporter logs
docker logs cis-compliance-exporter

# 2. Check Prometheus targets
# Mở http://localhost:9091/targets
# Verify "cis-compliance" target UP

# 3. Check metrics endpoint
curl http://localhost:9090/metrics | grep cis_

# 4. Verify InSpec results exist
ls -la demo/sample-outputs/inspec_aws_report.json
```

### Alerts không gửi

```bash
# 1. Check Alertmanager
docker logs cis-alertmanager

# 2. Test Slack webhook
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test alert"}' \
  https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK

# 3. Check alert rules
curl http://localhost:9091/api/v1/rules
```

### Exporter không update metrics

```bash
# 1. Check file permissions
ls -la demo/sample-outputs/

# 2. Restart exporter
docker-compose restart compliance-exporter

# 3. Check environment variables
docker exec cis-compliance-exporter env | grep INSPEC
```

---

## 📝 Customization

### Thêm alert mới

```yaml
# File: prometheus/alerts.yml
- alert: CustomAlert
  expr: your_prometheus_query
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Custom alert summary"
    description: "{{ $value }}"
```

### Thêm panel vào Grafana dashboard

1. Vào dashboard
2. Click "Add panel"
3. Chọn visualization type
4. Nhập Prometheus query
5. Save dashboard

### Thêm metric mới vào exporter

```python
# File: exporters/compliance_exporter.py

# Define metric
custom_metric = Gauge('cis_custom_metric', 'Description', ['label1'])

# Set value
custom_metric.labels(label1='value').set(123)
```

---

## 🔄 Update & Maintenance

### Update dashboards

```bash
# Export dashboard từ Grafana UI
# Save to grafana/dashboards/

# Hoặc edit JSON trực tiếp
vi monitoring/grafana/dashboards/cis-compliance.json

# Restart Grafana
docker-compose restart grafana
```

### Backup data

```bash
# Backup Prometheus data
docker cp cis-prometheus:/prometheus ./backup/prometheus

# Backup Grafana data
docker cp cis-grafana:/var/lib/grafana ./backup/grafana
```

### Clean up

```bash
# Stop all services
cd monitoring
docker-compose down

# Remove volumes (warning: deletes all data)
docker-compose down -v
```

---

## 📊 Demo với Sample Data

Stack đã có sẵn sample data từ `demo/sample-outputs/`:

```bash
# 1. Start stack
docker-compose up -d

# 2. Wait 30 seconds for exporter to load data
sleep 30

# 3. Verify metrics
curl http://localhost:9090/metrics | grep cis_compliance_score

# 4. Open Grafana
open http://localhost:3000

# 5. View dashboard
# Dashboards → CIS Compliance
```

Bạn sẽ thấy:
- ✅ Compliance Score: 100%
- ✅ 4/4 controls passed
- ✅ Trend chart với data points

---

## 🎓 Best Practices

1. **Regular scans**: Chạy InSpec scan ít nhất hàng tuần
2. **Alert tuning**: Điều chỉ thresholds theo môi trường
3. **Data retention**: Configure Prometheus retention (default: 15 days)
4. **Dashboard access**: Restrict Grafana access với RBAC
5. **Backup**: Backup Prometheus + Grafana data định kỳ

---

## 📞 Support

Gặp vấn đề?
1. Check logs: `docker-compose logs -f`
2. Xem docs: `docs/FAQ.md`
3. GitHub issues

---

**Chúc bạn monitor thành công! 📊📈**

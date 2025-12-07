# Kibana Dashboard Setup Guide

## Cài đặt Kibana Dashboard

### Yêu cầu
- Docker và Docker Compose
- Python 3.9+

### Bước 1: Khởi động ELK Stack

```bash
cd dashboard
./setup_kibana.sh
```

Hoặc chạy thủ công:

```bash
cd dashboard
docker-compose up -d

# Đợi services khởi động
sleep 30

# Push data
pip install requests
python scripts/push_to_elasticsearch.py ../demo/sample-outputs/compliance_summary.json
python scripts/push_to_elasticsearch.py ../demo/sample-outputs/inspec_aws_report.json
```

### Bước 2: Truy cập Kibana

Mở trình duyệt: **http://localhost:5601**

### Bước 3: Import Dashboard

1. Vào **Stack Management** → **Saved Objects**
2. Click **Import**
3. Chọn file: `dashboard/kibana/dashboard_export.ndjson`
4. Click **Import**

### Bước 4: Xem Dashboard

1. Vào **Dashboard**
2. Chọn **CIS Benchmark Compliance Dashboard**

## Dashboard Features

| Panel | Mô tả |
|-------|-------|
| **Compliance Score** | Điểm tuân thủ tổng thể (%) |
| **Controls by Status** | Biểu đồ tròn: Passed/Failed/Skipped |
| **Controls by Section** | Biểu đồ cột theo CIS Section |
| **Score Trend** | Xu hướng điểm theo thời gian |
| **Failed Controls** | Bảng các controls vi phạm |

## Dừng Dashboard

```bash
cd dashboard
docker-compose down
```

## Xóa dữ liệu

```bash
docker-compose down -v
```

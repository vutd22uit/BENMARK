# 🚀 HƯỚNG DẪN CHẠY DỰ ÁN - SIÊU DỄ HIỂU

## 📌 Dự án này làm gì?

Dự án **CIS Benchmark Compliance-as-Code** tự động kiểm tra và sửa lỗi bảo mật cho:
- ☁️ **AWS** (Amazon Web Services)
- 🐧 **Linux** servers

---

## 🎯 3 BƯỚC CHẠY NHANH

### Bước 1️⃣: Cài đặt công cụ

```bash
# Cài Terraform (quản lý hạ tầng)
brew install terraform

# Cài Checkov (kiểm tra bảo mật)
pip3 install checkov

# Kiểm tra đã cài xong chưa
terraform --version
checkov --version
```

### Bước 2️⃣: Chạy kiểm tra bảo mật

```bash
# Vào thư mục dự án
cd crystal-nova

# Chạy Checkov để kiểm tra code
checkov -d iac/aws --skip-download
```

### Bước 3️⃣: Xem kết quả

```bash
# Tạo báo cáo đẹp
python3 scripts/generate_compliance_report.py \
  demo/sample-outputs/inspec_aws_report.json \
  demo/sample-outputs/

# Xem báo cáo
cat demo/sample-outputs/compliance_report.md
```

---

## 📚 HƯỚNG DẪN CHI TIẾT

### 🔧 Phần 1: Cài Đặt Môi Trường

#### 1.1. Cài Terraform
```bash
# macOS
brew install terraform

# Hoặc download từ: https://terraform.io/downloads
```

#### 1.2. Cài Checkov
```bash
pip3 install checkov
```

#### 1.3. Cài AWS CLI (tùy chọn - nếu muốn test với AWS thật)
```bash
brew install awscli
aws configure  # Nhập Access Key và Secret Key
```

---

### 🔍 Phần 2: Kiểm Tra Code Terraform (Pre-Deploy)

**Mục đích**: Phát hiện lỗi bảo mật TRƯỚC KHI deploy lên AWS.

#### 2.1. Khởi tạo Terraform
```bash
cd iac/aws
terraform init
```
✅ **Kết quả mong đợi**: "Terraform has been successfully initialized!"

#### 2.2. Kiểm tra cú pháp
```bash
terraform validate
```
✅ **Kết quả mong đợi**: "Success! The configuration is valid."

#### 2.3. Chạy Checkov
```bash
cd ../..  # Về thư mục gốc
checkov -d iac/aws --skip-download --compact
```
✅ **Kết quả mong đợi**: Danh sách các checks PASSED và FAILED

---

### 📊 Phần 3: Tạo Báo Cáo Compliance

#### 3.1. Chạy report generator
```bash
python3 scripts/generate_compliance_report.py \
  demo/sample-outputs/inspec_aws_report.json \
  demo/sample-outputs/
```

#### 3.2. Xem báo cáo
```bash
# Xem trong terminal
cat demo/sample-outputs/compliance_report.md

# Hoặc mở bằng VS Code
code demo/sample-outputs/compliance_report.md
```

✅ **Kết quả**: Báo cáo với điểm Compliance Score (ví dụ: 100%)

---

### 📈 Phần 4: Chạy Kibana Dashboard (Tùy chọn)

**Yêu cầu**: Cần có Docker

#### 4.1. Khởi động Dashboard
```bash
cd dashboard
docker-compose up -d
```

#### 4.2. Mở trình duyệt
Truy cập: **http://localhost:5601**

#### 4.3. Dừng Dashboard
```bash
docker-compose down
```

---

## 🎬 DEMO CHO NGƯỜI XEM

### Demo Script (5 phút)

**Bước 1**: Giới thiệu (30 giây)
```
"Đây là framework tự động kiểm tra bảo mật theo chuẩn CIS Benchmark"
```

**Bước 2**: Chạy Checkov (1 phút)
```bash
checkov -d iac/aws --skip-download --compact
```
→ Chỉ ra các checks PASSED

**Bước 3**: Xem code vi phạm (1 phút)
```bash
# Mở file s3_bucket.tf
# Chỉ ra phần compliant và non-compliant
```

**Bước 4**: Xem báo cáo (1 phút)
```bash
cat demo/sample-outputs/compliance_report.md
```
→ Chỉ ra Compliance Score

**Bước 5**: Kết luận (30 giây)
```
"Framework này giúp phát hiện lỗi bảo mật tự động, 
trước khi code được deploy lên production"
```

---

## ❓ CÂU HỎI THƯỜNG GẶP

### Q: Không có AWS account có chạy được không?
**A**: Có! Dùng sample outputs trong thư mục `demo/sample-outputs/`

### Q: Checkov báo lỗi SSL certificate?
**A**: Thêm flag `--skip-download`:
```bash
checkov -d iac/aws --skip-download
```

### Q: Terraform init bị lỗi?
**A**: Kiểm tra internet connection và chạy lại:
```bash
cd iac/aws
terraform init
```

### Q: Python script báo lỗi module not found?
**A**: Cài thêm thư viện:
```bash
pip3 install requests
```

---

## 📁 CẤU TRÚC THƯ MỤC

```
crystal-nova/
│
├── 📂 iac/aws/          ← Code Terraform (kiểm tra với Checkov)
│
├── 📂 policies/         ← Các chính sách bảo mật
│   ├── checkov/         ← Cấu hình Checkov
│   ├── opa/             ← Policy OPA
│   ├── inspec/          ← InSpec profiles
│   └── custodian/       ← Cloud Custodian
│
├── 📂 demo/             ← Minh chứng cho demo
│   ├── sample-outputs/  ← Kết quả mẫu
│   └── scenarios/       ← Kịch bản demo
│
├── 📂 dashboard/        ← Kibana dashboard
│
├── 📂 scripts/          ← Scripts tự động
│
└── 📂 docs/             ← Tài liệu
```

---

## ✅ CHECKLIST TRƯỚC KHI DEMO

- [ ] Đã cài Terraform
- [ ] Đã cài Checkov
- [ ] Đã chạy `terraform init`
- [ ] Đã test `checkov -d iac/aws`
- [ ] Đã có báo cáo trong `demo/sample-outputs/`
- [ ] Đã mở sẵn các file cần show

---

## 🆘 CẦN HỖ TRỢ?

1. Xem file `docs/FAQ.md` để tìm câu trả lời
2. Xem file `docs/setup_guide.md` để cài đặt chi tiết
3. Xem file `demo/DEMO_GUIDE.md` để hướng dẫn demo

---

**Chúc bạn demo thành công! 🎉**

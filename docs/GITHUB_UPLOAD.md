# Hướng dẫn Upload Project lên GitHub

## Bước 1: Tạo Repository trên GitHub

1. Truy cập https://github.com
2. Đăng nhập vào tài khoản của bạn
3. Click vào nút **"+"** ở góc trên bên phải → chọn **"New repository"**
4. Điền thông tin:
   - **Repository name**: `cis-compliance-framework` (hoặc tên bạn muốn)
   - **Description**: `CIS Benchmark Compliance-as-Code Framework for AWS and Linux`
   - **Visibility**: Chọn **Public** hoặc **Private**
   - **KHÔNG** tick vào "Initialize this repository with a README" (vì đã có sẵn)
5. Click **"Create repository"**

## Bước 2: Khởi tạo Git Repository (Local)

Mở Terminal và chạy các lệnh sau:

```bash
# Di chuyển vào thư mục project
cd /Users/vutruongdoan/.gemini/antigravity/playground/crystal-nova

# Khởi tạo git repository
git init

# Thêm tất cả files vào staging
git add .

# Commit lần đầu
git commit -m "Initial commit: CIS Benchmark Compliance-as-Code Framework v1.0.0"
```

## Bước 3: Kết nối với GitHub Repository

Thay `YOUR_USERNAME` bằng username GitHub của bạn:

```bash
# Thêm remote repository
git remote add origin https://github.com/YOUR_USERNAME/cis-compliance-framework.git

# Hoặc nếu dùng SSH:
# git remote add origin git@github.com:YOUR_USERNAME/cis-compliance-framework.git

# Kiểm tra remote đã được thêm
git remote -v
```

## Bước 4: Push Code lên GitHub

```bash
# Push code lên branch main
git branch -M main
git push -u origin main
```

## Bước 5: Xác nhận Upload thành công

1. Truy cập repository trên GitHub: `https://github.com/YOUR_USERNAME/cis-compliance-framework`
2. Kiểm tra xem tất cả files đã được upload
3. README.md sẽ tự động hiển thị trên trang chính

## Lệnh Nhanh (Copy & Paste)

**Thay `YOUR_USERNAME` bằng username GitHub của bạn:**

```bash
cd /Users/vutruongdoan/.gemini/antigravity/playground/crystal-nova
git init
git add .
git commit -m "Initial commit: CIS Benchmark Compliance-as-Code Framework v1.0.0"
git remote add origin https://github.com/YOUR_USERNAME/cis-compliance-framework.git
git branch -M main
git push -u origin main
```

## Cập nhật Code sau này

Khi có thay đổi, chạy:

```bash
git add .
git commit -m "Mô tả thay đổi"
git push
```

## Lưu ý Quan trọng

### ⚠️ Bảo mật

Trước khi push, đảm bảo:

1. **KHÔNG commit AWS credentials**
   - File `.gitignore` đã được cấu hình để loại trừ:
     - `*.pem`, `*.key`
     - `secrets.yaml`, `credentials.json`
     - `terraform.tfvars` (chứa thông tin nhạy cảm)

2. **Kiểm tra lại:**
   ```bash
   # Xem files sẽ được commit
   git status
   
   # Nếu thấy file nhạy cảm, thêm vào .gitignore
   echo "terraform.tfvars" >> .gitignore
   ```

### 📝 GitHub Actions Secrets

Để CI/CD hoạt động, cần thêm secrets:

1. Vào repository trên GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Thêm:
   - `AWS_ACCESS_KEY_ID`: Access key của bạn
   - `AWS_SECRET_ACCESS_KEY`: Secret key của bạn

### 🔧 Cấu hình Git (Nếu chưa có)

```bash
# Cấu hình tên và email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Kiểm tra cấu hình
git config --list
```

## Xử lý Lỗi Thường gặp

### Lỗi: "remote origin already exists"

```bash
# Xóa remote cũ
git remote remove origin

# Thêm lại
git remote add origin https://github.com/YOUR_USERNAME/cis-compliance-framework.git
```

### Lỗi: "failed to push some refs"

```bash
# Pull code từ remote trước
git pull origin main --allow-unrelated-histories

# Sau đó push lại
git push -u origin main
```

### Lỗi: Authentication failed

**Nếu dùng HTTPS:**
- GitHub không còn hỗ trợ password authentication
- Cần tạo **Personal Access Token**:
  1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
  2. Generate new token → Chọn scopes: `repo`
  3. Copy token và dùng thay cho password

**Hoặc dùng SSH:**
```bash
# Tạo SSH key (nếu chưa có)
ssh-keygen -t ed25519 -C "your.email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Thêm vào GitHub: Settings → SSH and GPG keys → New SSH key
```

## Kiểm tra Repository

Sau khi push thành công, kiểm tra:

- ✅ README.md hiển thị đúng
- ✅ Tất cả files đã được upload
- ✅ GitHub Actions workflows xuất hiện trong tab "Actions"
- ✅ Không có file nhạy cảm (credentials, keys)

## Chia sẻ Repository

Sau khi upload, bạn có thể:

1. **Chia sẻ link**: `https://github.com/YOUR_USERNAME/cis-compliance-framework`
2. **Clone về máy khác**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/cis-compliance-framework.git
   ```

---

**Chúc bạn thành công! 🚀**

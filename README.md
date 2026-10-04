# Bài 4: Cấu hình tường lửa bảo vệ máy chủ (UFW & Cloud Firewall Integration)

## 🎯 1. Mục Tiêu
- Thiết lập tường lửa UFW (Uncomplicated Firewall) ngay trong hệ điều hành Ubuntu để lọc các gói tin mạng đi vào máy chủ.
- Kết hợp cấu hình DigitalOcean Cloud Firewall ở tầng hạ tầng đám mây để bảo vệ máy chủ từ biên mạng trước khi gói tin chạm tới Droplet.

---

## 📋 2. Yêu Cầu Chi Tiết (Requirements)
- **Bối cảnh**: Tránh máy chủ bị tấn công hoặc khai thác qua các cổng dịch vụ không sử dụng bằng cấu hình tường lửa 2 lớp bảo vệ, chỉ cho phép lưu lượng SSH và HTTP đi vào Droplet.
- **Ràng buộc**:
  1. **Lớp 1 (UFW trong OS)**: Kích hoạt tường lửa UFW, thiết lập chặn mặc định lưu lượng đi vào (`default deny incoming`), cho phép lưu lượng đi ra ngoài (`default allow outgoing`). Mở cổng `22/tcp` (SSH) và `80/tcp` (HTTP).
  2. **Lớp 2 (DO Cloud Firewall)**: Trên DigitalOcean Console, tạo Cloud Firewall mới với Inbound Rules chỉ mở cổng `22` (SSH) và `80` (HTTP). Gán Droplet vào Cloud Firewall này.

---

## 🛠️ 3. Hướng Dẫn Các Bước Thực Hiện (Step-by-Step Guide)

### Lớp 1: Cấu hình UFW Firewall trên hệ điều hành Ubuntu

Thực hiện các câu lệnh sau trên máy chủ Droplet:

```bash
# 1. Chặn tất cả lưu lượng truy cập đi vào mặc định
sudo ufw default deny incoming

# 2. Cho phép tất cả lưu lượng đi ra ngoài mặc định
sudo ufw default allow outgoing

# 3. Cho phép cổng 22 (SSH)
sudo ufw allow 22/tcp comment 'Allow SSH'

# 4. Cho phép cổng 80 (HTTP)
sudo ufw allow 80/tcp comment 'Allow HTTP'

# 5. Kích hoạt tường lửa UFW
sudo ufw enable
```

### Lớp 2: Cấu hình DigitalOcean Cloud Firewall (Tầng Hạ Tầng)

1. Đăng nhập vào DigitalOcean Console -> Chọn mục **Networking** -> chọn **Firewalls**.
2. Click **Create Firewall**, đặt tên: `web-server-firewall`.
3. Cấu hình **Inbound Rules**:
   - Type: **SSH** | Protocol: **TCP** | Port Range: `22` | Sources: **All IPv4, All IPv6** (hoặc IP cố định của bạn).
   - Type: **HTTP** | Protocol: **TCP** | Port Range: `80` | Sources: **All IPv4, All IPv6**.
4. Cấu hình **Outbound Rules**: Mặc định cho phép tất cả (All IPv4, All IPv6).
5. Section **Apply to Droplets**: Chọn tên Droplet của bạn (`devops-ubuntu-droplet`).
6. Bấm **Create Firewall**.

---

## ✅ 4. Lệnh Kiểm Tra & Kết Quả Mong Đợi (Verification)

### 1. Kiểm tra trạng thái UFW trên Droplet:
```bash
sudo ufw status verbose
```
**Kết quả mong đợi**:
```text
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere                   # Allow SSH
80/tcp                     ALLOW IN    Anywhere                   # Allow HTTP
22/tcp (v6)                ALLOW IN    Anywhere (v6)              # Allow SSH
80/tcp (v6)                ALLOW IN    Anywhere (v6)              # Allow HTTP
```

### 2. Kiểm tra truy cập từ máy cá nhân:
- Kết nối SSH: `ssh -i ~/.ssh/id_ed25519 devops@<IP_ADDRESS_DROPLET>` -> **Thành công**.
- Truy cập HTTP: `curl http://<IP_ADDRESS_DROPLET>` -> **Thành công (200 OK)**.
- Thử kết nối cổng bị đóng (ví dụ port 3306 hoặc 8080): `curl http://<IP_ADDRESS_DROPLET>:8080` -> **Timeout / Connection Refused**.

---

## 💡 5. Script Khởi Tạo Nhanh UFW (Automation Script)
File `setup_firewall.sh` được cung cấp trong thư mục này giúp thiết lập tự động UFW rules.

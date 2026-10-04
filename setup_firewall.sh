#!/bin/bash
# Script tự động cấu hình UFW Firewall cho Web Server
set -e

echo "=== 1. Chặn mặc định incoming và cho phép outgoing ==="
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "=== 2. Mở cổng SSH (22) và HTTP (80) ==="
sudo ufw allow 22/tcp comment 'Allow SSH'
sudo ufw allow 80/tcp comment 'Allow HTTP'

echo "=== 3. Kích hoạt UFW Firewall ==="
echo "y" | sudo ufw enable

echo "=== 4. Kiểm tra trạng thái UFW ==="
sudo ufw status verbose

echo "=== HOÀN TẤT THIẾT LẬP UFW FIREWALL! ==="

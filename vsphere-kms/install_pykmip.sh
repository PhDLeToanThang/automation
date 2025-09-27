#!/bin/bash

# ============================================================================
# Script cài đặt PyKMIP Server trên Ubuntu 24.04 LTS
# Hỗ trợ tùy chỉnh: user, password, home path, database, chứng chỉ
# ============================================================================

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Hàm hiển thị thông báo
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Hàm kiểm tra lệnh cần sudo
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        log_warn "Lệnh này cần quyền sudo. Đang thử lại với sudo..."
        sudo "$0" "$@"
        exit $?
    fi
}

# Thiết lập thông số
USERNAME="adminsso"
HOME_PATH="/home/adminsso"

log_info "=== Sửa lỗi PyKMIP ==="

# 1. Tạo lại file dịch vụ systemd
log_info "Tạo lại file dịch vụ systemd..."
check_sudo

cat > /etc/systemd/system/pykmip.service <<SERVICE
[Unit]
Description=PyKMIP KMS Server
After=network.target

[Service]
Type=simple
User=$USERNAME
Group=$USERNAME
WorkingDirectory=$HOME_PATH/pykmip-server
Environment=PATH=$HOME_PATH/pykmip-server/venv/bin
ExecStart=$HOME_PATH/pykmip-server/venv/bin/python3 -m pykmip.server.server --config $HOME_PATH/pykmip-server/config/pykmip.conf
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE

# 2. Kiểm tra và sửa môi trường ảo
log_info "Kiểm tra và sửa môi trường ảo..."
su - "$USERNAME" <<EOF

# Kích hoạt môi trường ảo
source $HOME_PATH/pykmip-server/venv/bin/activate

# Kiểm tra liên kết python
echo "Kiểm tra liên kết python:"
which python3
ls -la $HOME_PATH/pykmip-server/venv/bin/python*

# Tạo liên kết mềm nếu cần
echo "Tạo liên kết mềm python -> python3..."
ln -sf $HOME_PATH/pykmip-server/venv/bin/python3 $HOME_PATH/pykmip-server/venv/bin/python

# Kiểm tra lại
echo "Kiểm tra lại liên kết:"
python --version

# Kiểm tra quyền thực thi
echo "Kiểm tra quyền thực thi:"
ls -la $HOME_PATH/pykmip-server/venv/bin/python3
chmod +x $HOME_PATH/pykmip-server/venv/bin/python3

EOF

# 3. Khởi động lại dịch vụ
log_info "Khởi động lại dịch vụ..."
sudo systemctl daemon-reload
sudo systemctl restart pykmip

# 4. Kiểm tra trạng thái
log_info "Kiểm tra trạng thái dịch vụ..."
sudo systemctl status pykmip --no-pager -l

# 5. Kiểm tra cổng
if sudo netstat -tulnp | grep -q ":5696"; then
    log_info "PyKMIP đang chạy trên cổng 5696"
else
    log_error "PyKMIP không chạy trên cổng 5696"
fi

# 6. Kiểm tra log
log_info "Kiểm tra log dịch vụ:"
sudo journalctl -u pykmip -n 10 --no-pager

log_info "Hoàn thành sửa lỗi!"

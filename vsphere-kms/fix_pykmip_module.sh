#!/bin/bash

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

log_info "=== Khắc phục lỗi module PyKMIP ==="

# 1. Kiểm tra môi trường ảo
log_info "1. Kiểm tra môi trường ảo..."
if [ ! -d "$HOME_PATH/pykmip-server/venv" ]; then
    log_error "Môi trường ảo không tồn tại"
    exit 1
fi

# 2. Kích hoạt môi trường ảo
log_info "2. Kích hoạt môi trường ảo..."
cd "$HOME_PATH/pykmip-server"
source venv/bin/activate

# 3. Kiểm tra Python và pip
log_info "3. Kiểm tra Python và pip..."
python --version
pip --version

# 4. Kiểm tra các gói đã cài đặt
log_info "4. Kiểm tra các gói đã cài đặt..."
pip list | grep -E "(pykmip|cryptography|pyopenssl|service-identity)"

# 5. Gỡ bỏ cài đặt cũ (nếu có)
log_info "5. Gỡ bỏ cài đặt cũ..."
pip uninstall -y pykmip cryptography pyopenssl service-identity

# 6. Cập nhật pip
log_info "6. Cập nhật pip..."
pip install --upgrade pip
pip install --upgrade setuptools wheel

# 7. Cài đặt lại các gói
log_info "7. Cài đặt lại các gói..."
pip install cryptography==41.0.3
pip install pyopenssl==23.2.0
pip install service-identity

# 8. Cài đặt PyKMIP từ source
log_info "8. Cài đặt PyKMIP từ source..."
cd "$HOME_PATH"
git clone https://github.com/OpenKMIP/PyKMIP.git
cd PyKMIP
pip install -e .

# 9. Kiểm tra cài đặt PyKMIP
log_info "9. Kiểm tra cài đặt PyKMIP..."
cd "$HOME_PATH/pykmip-server"
python -c "import pykmip; print('PyKMIP version:', pykmip.__version__ if hasattr(pykmip, '__version__') else 'Unknown')"

# 10. Kiểm tra module server
log_info "10. Kiểm tra module server..."
python -c "from pykmip.server import server; print('PyKMIP server module imported successfully')"

# 11. Kiểm tra đường dẫn module
log_info "11. Kiểm tra đường dẫn module..."
python -c "import pykmip.server; print('PyKMIP server path:', pykmip.server.__file__)"

# 12. Thử validate config
log_info "12. Thử validate config..."
python -m pykmip.server.server --config config/pykmip.conf --validate-config

# 13. Khởi tạo lại cơ sở dữ liệu
log_info "13. Khởi tạo lại cơ sở dữ liệu..."
python -m pykmip.server.server --config config/pykmip.conf --init-db

# 14. Tạo lại dịch vụ systemd
log_info "14. Tạo lại dịch vụ systemd..."
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
ExecStart=$HOME_PATH/pykmip-server/venv/bin/python -m pykmip.server.server --config $HOME_PATH/pykmip-server/config/pykmip.conf
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE

# 15. Khởi động lại dịch vụ
log_info "15. Khởi động lại dịch vụ..."
sudo systemctl daemon-reload
sudo systemctl restart pykmip

# 16. Kiểm tra dịch vụ
log_info "16. Kiểm tra dịch vụ..."
sudo systemctl status pykmip --no-pager -l

# 17. Kiểm tra cổng
if sudo netstat -tulnp | grep -q ":5696"; then
    log_info "PyKMIP đang chạy trên cổng 5696"
else
    log_error "PyKMIP không chạy trên cổng 5696"
fi

# 18. Kiểm tra log
log_info "18. Kiểm tra log..."
sudo journalctl -u pykmip -n 10 --no-pager

log_info "Hoàn thành khắc phục lỗi module PyKMIP!"

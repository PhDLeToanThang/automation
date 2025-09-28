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

# Hàm xác nhận trước khi tiếp tục
confirm_continue() {
    read -p "Tiếp tục? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Hủy cài đặt."
        exit 1
    fi
}

# ============================================================================
# PHẦN 1: THIẾT LẬP THAM SỐ
# ============================================================================
log_info "=== Thiết lập tham số cài đặt ==="

# Thiết lập giá trị mặc định
DEFAULT_USERNAME="adminsso"
DEFAULT_PASSWORD="VMware1!"
DEFAULT_HOME="/home/adminsso"
DEFAULT_DB="pykmip.db"
DEFAULT_CERT_DAYS=3650
DEFAULT_KEY_TYPE="RSA"
DEFAULT_KEY_SIZE=4096
DEFAULT_HOSTNAME="sso.vclass.local"
PYTHON_VERSION="3.10.14"

# Nhập tham số từ người dùng
read -p "Nhập username [$DEFAULT_USERNAME]: " USERNAME
USERNAME=${USERNAME:-$DEFAULT_USERNAME}

read -s -p "Nhập password [$DEFAULT_PASSWORD]: " PASSWORD
PASSWORD=${PASSWORD:-$DEFAULT_PASSWORD}
echo

read -p "Nhập home path [$DEFAULT_HOME]: " HOME_PATH
HOME_PATH=${HOME_PATH:-$DEFAULT_HOME}

read -p "Nhập database name [$DEFAULT_DB]: " DB_NAME
DB_NAME=${DB_NAME:-$DEFAULT_DB}

read -p "Nhập thời hạn chứng chỉ (ngày) [$DEFAULT_CERT_DAYS]: " CERT_DAYS
CERT_DAYS=${CERT_DAYS:-$DEFAULT_CERT_DAYS}

read -p "Nhập kiểu chữ ký số [$DEFAULT_KEY_TYPE]: " KEY_TYPE
KEY_TYPE=${KEY_TYPE:-$DEFAULT_KEY_TYPE}

read -p "Nhập kích thước khóa [$DEFAULT_KEY_SIZE]: " KEY_SIZE
KEY_SIZE=${KEY_SIZE:-$DEFAULT_KEY_SIZE}

read -p "Nhập hostname/URL [$DEFAULT_HOSTNAME]: " HOSTNAME
HOSTNAME=${HOSTNAME:-$DEFAULT_HOSTNAME}

# Hiển thị thông tin cài đặt
log_info "Thông tin cài đặt:"
echo "  Username: $USERNAME"
echo "  Home Path: $HOME_PATH"
echo "  Database: $DB_NAME"
echo "  Thời hạn chứng chỉ: $CERT_DAYS ngày"
echo "  Kiểu chữ ký số: $KEY_TYPE $KEY_SIZE-bit"
echo "  Hostname/URL: $HOSTNAME"
echo "  Python Version: $PYTHON_VERSION"
echo ""

confirm_continue

# ============================================================================
# PHẦN 2: KIỂM TRA HỆ THỐNG
# ============================================================================
log_info "=== Kiểm tra hệ thống ==="

# Kiểm tra phiên bản Ubuntu
if ! lsb_release -a | grep -q "Ubuntu 24.04"; then
    log_error "Script này chỉ hỗ trợ Ubuntu 24.04 LTS"
    exit 1
fi

# Kiểm tra user tồn tại
if ! id "$USERNAME" &>/dev/null; then
    log_error "User $USERNAME không tồn tại"
    exit 1
fi

# ============================================================================
# PHẦN 3: CÀI ĐẶT PYTHON 3.10 TỪ SOURCE (CẦN SUDO)
# ============================================================================
log_info "=== Cài đặt Python $PYTHON_VERSION từ source ==="

check_sudo

# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y

# Cài đặt các gói cần thiết để build Python
sudo apt install -y wget build-essential libssl-dev zlib1g-dev \
libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev \
libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev libffi-dev \
liblzma-dev tk-dev uuid-dev libgdbm-compat-dev

# Tạo thư mục tạm thời
cd /tmp
mkdir -p python-build
cd python-build

# Tải source code Python
log_info "Tải source code Python $PYTHON_VERSION..."
wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz

# Giải nén
tar -xzf Python-$PYTHON_VERSION.tgz
cd Python-$PYTHON_VERSION

# Cấu hình và cài đặt
log_info "Cấu hình và cài đặt Python $PYTHON_VERSION..."
./configure --enable-optimizations --enable-loadable-sqlite-extensions
make -j $(nproc)
sudo make altinstall

# Xác minh cài đặt
log_info "Xác minh cài đặt Python $PYTHON_VERSION:"
python3.10 --version

# Cài đặt pip và venv
log_info "Cài đặt pip và venv cho Python 3.10..."
wget https://bootstrap.pypa.io/get-pip.py
python3.10 get-pip.py
python3.10 -m pip install --upgrade pip
python3.10 -m pip install virtualenv

# Dọn dẹp
cd /tmp
rm -rf python-build

# ============================================================================
# PHẦN 4: XÓA CÀI ĐẶT CŨ (NẾU CÓ)
# ============================================================================
log_info "=== Xóa cài đặt cũ (nếu có) ==="

# Dừng dịch vụ nếu đang chạy
sudo systemctl stop pykmip 2>/dev/null || true
sudo systemctl disable pykmip 2>/dev/null || true

# Xóa file dịch vụ
sudo rm -f /etc/systemd/system/pykmip.service

# Xóa thư mục cài đặt cũ
if [ -d "$HOME_PATH/pykmip-server" ]; then
    log_info "Xóa thư mục cài đặt cũ..."
    rm -rf "$HOME_PATH/pykmip-server"
fi

# ============================================================================
# PHẦN 5: CHUẨN BỊ MÔI TRƯỜNG (KHÔNG CẦN SUDO)
# ============================================================================
log_info "=== Chuẩn bị môi trường ==="

# Tạo thư mục dự án
log_info "Tạo thư mục dự án..."
mkdir -p "$HOME_PATH/pykmip-server"/{config,logs,keys,ssl}

# Tạo môi trường ảo
log_info "Tạo môi trường ảo Python 3.10..."
cd "$HOME_PATH"
python3.10 -m venv pykmip-server/venv

# Xác minh môi trường ảo đã được tạo
if [ ! -f "$HOME_PATH/pykmip-server/venv/bin/python" ]; then
    log_error "Môi trường ảo không được tạo đúng cách"
    exit 1
fi

# Kích hoạt môi trường ảo và cài đặt PyKMIP
log_info "Cài đặt PyKMIP và các phụ thuộc..."
cd pykmip-server
source venv/bin/activate

# Cập nhật pip
pip install --upgrade pip

# Cài đặt PyKMIP và các phụ thuộc
pip install pykmip==0.10.0 cryptography==41.0.3 pyopenssl==23.2.0 service-identity

# Kiểm tra cài đặt
log_info "Kiểm tra các gói đã cài đặt:"
pip list | grep -E "(pykmip|cryptography|pyopenssl|service-identity)"

# ============================================================================
# PHẦN 6: TẠO CHỨNG CHỈ SSL
# ============================================================================
log_info "=== Tạo chứng chỉ SSL ==="

# Tạo private key
openssl genrsa -out ssl/pykmip.key $KEY_SIZE

# Tạo CSR với hostname
openssl req -new -key ssl/pykmip.key -out ssl/pykmip.csr -subj "/C=VN/ST=HCM/L=HCM/O=PyKMIP/OU=IT/CN=$HOSTNAME"

# Tạo chứng chỉ tự ký
openssl x509 -req -days $CERT_DAYS -in ssl/pykmip.csr -signkey ssl/pykmip.key -out ssl/pykmip.crt

# Tạo chứng chỉ CA
openssl req -new -x509 -extensions v3_ca -keyout ssl/pykmip-ca.key -out ssl/pykmip-ca.crt -days $CERT_DAYS -subj "/C=VN/ST=HCM/L=HCM/O=PyKMIP/OU=IT/CN=PyKMIP-CA"

# ============================================================================
# PHẦN 7: TẠO FILE CẤU HÌNH
# ============================================================================
log_info "=== Tạo file cấu hình ==="

cat > config/pykmip.conf <<CONF
[server]
hostname=0.0.0.0
port=5696
certificate_path=$HOME_PATH/pykmip-server/ssl/pykmip.crt
key_path=$HOME_PATH/pykmip-server/ssl/pykmip.key
ca_path=$HOME_PATH/pykmip-server/ssl/pykmip-ca.crt
auth_suite=TLS1.2
encryption_protocol=TLS
logging_level=INFO

[database]
engine=sqlite
database_url=$HOME_PATH/pykmip-server/keys/$DB_NAME

[policies]
enable=True
CONF

# ============================================================================
# PHẦN 8: KHỞI TẠO CƠ SỞ DỮ LIỆU
# ============================================================================
log_info "=== Khởi tạo cơ sở dữ liệu ==="

# Kiểm tra file cấu hình
log_info "Kiểm tra file cấu hình:"
cat config/pykmip.conf

# Khởi tạo cơ sở dữ liệu
python -m pykmip.server.server --config config/pykmip.conf --init-db

# ============================================================================
# PHẦN 9: KIỂM TRA CÀI ĐẶT
# ============================================================================
log_info "=== Kiểm tra cài đặt ==="

# Kiểm tra môi trường ảo
log_info "Kiểm tra môi trường ảo:"
which python
python --version

# Kiểm tra PyKMIP
log_info "Kiểm tra PyKMIP:"
python -c "import pykmip; print('PyKMIP version:', pykmip.__version__ if hasattr(pykmip, '__version__') else 'Unknown')"

# Kiểm tra module server
log_info "Kiểm tra module server:"
python -c "from pykmip.server import server; print('PyKMIP server module imported successfully')"

# Thử validate config
log_info "Thử validate config:"
python -m pykmip.server.server --config config/pykmip.conf --validate-config

# ============================================================================
# PHẦN 10: TẠO DỊCH VỤ SYSTEMD
# ============================================================================
log_info "=== Tạo dịch vụ systemd ==="

check_sudo

# Tạo file dịch vụ
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

# ============================================================================
# PHẦN 11: KHỞI ĐỘNG DỊCH VỤ
# ============================================================================
log_info "=== Khởi động dịch vụ ==="

# Tải lại systemd
sudo systemctl daemon-reload

# Kích hoạt dịch vụ
sudo systemctl enable pykmip

# Khởi động dịch vụ
sudo systemctl start pykmip

# Chờ dịch vụ khởi động
sleep 5

# ============================================================================
# PHẦN 12: CẤU HÌNH TƯỜNG LỬA
# ============================================================================
log_info "=== Cấu hình tường lửa ==="

# Cho phép cổng KMIP
sudo ufw allow 5696/tcp

# Kích hoạt tường lửa nếu chưa bật
if ! sudo ufw status | grep -q "Status: active"; then
    sudo ufw --force enable
fi

# ============================================================================
# PHẦN 13: KIỂM TRA DỊCH VỤ
# ============================================================================
log_info "=== Kiểm tra dịch vụ ==="

# Kiểm tra trạng thái dịch vụ
log_info "Trạng thái dịch vụ:"
sudo systemctl status pykmip --no-pager -l

# Kiểm tra cổng
if sudo netstat -tulnp | grep -q ":5696"; then
    log_info "PyKMIP đang chạy trên cổng 5696"
else
    log_error "PyKMIP không chạy trên cổng 5696"
fi

# Kiểm tra log
log_info "Log dịch vụ gần nhất:"
sudo journalctl -u pykmip -n 10 --no-pager

# ============================================================================
# PHẦN 14: TẠO SCRIPT KÍCH HOẠT MÔI TRƯỜNG ẢO
# ============================================================================
log_info "=== Tạo script kích hoạt môi trường ảo ==="

cat > "$HOME_PATH/pykmip-activate.sh" <<ACTIVATE
#!/bin/bash
source $HOME_PATH/pykmip-server/venv/bin/activate
cd $HOME_PATH/pykmip-server
echo "Đã kích hoạt môi trường ảo Python 3.10 cho PyKMIP"
echo "Để kiểm tra PyKMIP, chạy: python -m pykmip.server.server --config config/pykmip.conf --validate-config"
ACTIVATE

chmod +x "$HOME_PATH/pykmip-activate.sh"

# ============================================================================
# PHẦN 15: CẬP NHẬT HOSTS (NẾU CẦN)
# ============================================================================
log_info "=== Cập nhật file hosts ==="

# Kiểm tra nếu hostname đã có trong /etc/hosts
if ! grep -q "$HOSTNAME" /etc/hosts; then
    log_info "Thêm $HOSTNAME vào file hosts..."
    echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts
else
    log_info "$HOSTNAME đã có trong file hosts"
fi

# ============================================================================
# PHẦN 16: HOÀN THÀNH
# ============================================================================
log_info "=== Hoàn thành cài đặt ==="
echo ""
log_info "Thông tin kết nối PyKMIP:"
echo "  URL: $HOSTNAME"
echo "  Địa chỉ IP: $(hostname -I | awk '{print $1}')"
echo "  Cổng: 5696"
echo "  Certificate: $HOME_PATH/pykmip-server/ssl/pykmip-ca.crt"
echo ""
log_info "Để kích hoạt môi trường ảo, chạy:"
echo "  source $HOME_PATH/pykmip-activate.sh"
echo ""
log_info "Để kiểm tra dịch vụ:"
echo "  sudo systemctl status pykmip"
echo ""
log_info "Để xem log:"
echo "  sudo journalctl -u pykmip -f"
echo ""
log_info "Để cấu hình vSphere Standard Key Provider:"
echo "  1. Đăng nhập vào vCenter Server"
echo "  2. Điều hướng đến Menu > Key Providers"
echo "  3. Nhấp Add Key Provider"
echo "  4. Chọn Trust a KMIP server"
echo "  5. Điền thông tin:"
echo "     - Name: PyKMIP-KMS"
echo "     - Address: $HOSTNAME"
echo "     - Port: 5696"
echo "     - Certificate: Tải lên file $HOME_PATH/pykmip-server/ssl/pykmip-ca.crt"
echo "  6. Nhấp Add"
echo ""
log_info "Cài đặt hoàn tất!"

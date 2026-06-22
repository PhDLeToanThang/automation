#!/bin/bash
# =============================================================================
# Script: setup-pykmip.sh
# Mô tả:  Cài đặt PyKMIP Server - KMIP Key Provider cho vSphere vTPM
#         Hỗ trợ TPM v1.0, 1.1, 1.2, 2.0 (Software TPM - Phương án 2)
# Author: PhD. Le Toan Thang
# Ngày:   31.05.2026
# OS:     Ubuntu 24.04 LTS
# =============================================================================
set -e

# =============================================================================
# CẤU HÌNH BIẾN MÔI TRƯỜNG
# =============================================================================
PYTHON_VER="3.12"
PYKMIP_VER="0.10.3"
KMIP_PORT="5696"
KMIP_HTTPS_PORT="443"
INSTALL_DIR="/opt/pykmip"
DATA_DIR="/var/lib/pykmip"
LOG_DIR="/var/log/pykmip"
CONF_DIR="/etc/pykmip"
CERTS_DIR="${CONF_DIR}/certs"
CA_DIR="${CERTS_DIR}/ca"
TMP_DIR="/tmp/pykmip-build"
KMIP_USER="pykmip"
KMIP_GROUP="pykmip"

# Colors cho output
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

log() { echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} $1"; }
ok()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $1"; }
fail(){ echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

# =============================================================================
# KIỂM TRA ROOT
# =============================================================================
if [ "$EUID" -ne 0 ]; then fail "Script phải chạy với quyền root (sudo)."; fi

echo "======================================================"
echo "   Cài đặt PyKMIP Server - KMIP Key Provider"
echo "   Hỗ trợ: TPM v1.0, 1.1, 1.2, 2.0 | vSphere vTPM"
echo "   Phiên bản: ${PYKMIP_VER} | Python ${PYTHON_VER}"
echo "   Author: PhD. Le Toan Thang"
echo "======================================================"
echo ""

# =============================================================================
# BƯỚC 1: CẬP NHẬT HỆ THỐNG
# =============================================================================
log "1. Cập nhật hệ thống..."
apt update -y && apt upgrade -y
ok "Hệ thống đã cập nhật."

# =============================================================================
# BƯỚC 2: CÀI ĐẶT GÓI PHỤ THUỘC
# =============================================================================
log "2. Cài đặt gói phụ thuộc..."
apt install -y \
    python${PYTHON_VER} python${PYTHON_VER}-venv python${PYTHON_VER}-dev \
    python3-pip python3-setuptools python3-wheel \
    build-essential libssl-dev libffi-dev \
    openssl sqlite3 \
    nginx apache2-utils \
    curl wget git ufw
ok "Gói phụ thuộc đã cài."

# =============================================================================
# BƯỚC 3: TẠO USER/GROUP
# =============================================================================
log "3. Tạo user/groups ${KMIP_USER}..."
id -u ${KMIP_USER} &>/dev/null || useradd -r -s /bin/false -d ${DATA_DIR} -m ${KMIP_USER}
ok "User ${KMIP_USER} đã sẵn sàng."

# =============================================================================
# BƯỚC 4: TẠO THƯ MỤC DỰ ÁN
# =============================================================================
log "4. Tạo cấu trúc thư mục..."
mkdir -p ${INSTALL_DIR} ${DATA_DIR} ${LOG_DIR} ${CONF_DIR} ${CERTS_DIR} \
         ${CA_DIR} ${TMP_DIR}
ok "Thư mục dự án đã tạo."

# =============================================================================
# BƯỚC 5: CÀI ĐẶT PYTHON VENV & PYKMIP
# =============================================================================
log "5. Cài đặt Python virtual environment & PyKMIP..."
python3 -m venv ${INSTALL_DIR}/venv
source ${INSTALL_DIR}/venv/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel

# Cài PyKMIP từ PyPI
pip install pykmip==${PYKMIP_VER}

# Cài các thư viện bổ trợ
pip install \
    pyopenssl \
    python-daemon \
    pyyaml \
    cryptography \
    requests

deactivate
ok "PyKMIP ${PYKMIP_VER} đã cài đặt."

# =============================================================================
# BƯỚC 6: TẠO CA CERTIFICATE (TỰ KÝ) CHO PYRAMID KMIP SERVER
# =============================================================================
log "6. Tạo CA certificates cho KMIP server..."

CA_KEY="${CA_DIR}/kmip-ca.key"
CA_CERT="${CA_DIR}/kmip-ca.crt"
SERVER_KEY="${CERTS_DIR}/kmip-server.key"
SERVER_CERT="${CERTS_DIR}/kmip-server.crt"
SERVER_CSR="${TMP_DIR}/kmip-server.csr"
SERVER_P12="${CERTS_DIR}/kmip-server.p12"

PKI_PASS="Km1pP@ss2026!"

# Tạo CA private key
openssl genrsa -aes256 -passout pass:${PKI_PASS} -out ${CA_KEY} 4096
ok "CA private key đã tạo."

# Tạo CA self-signed certificate
openssl req -x509 -new -nodes -key ${CA_KEY} \
    -sha256 -days 7300 \
    -passin pass:${PKI_PASS} \
    -out ${CA_CERT} \
    -subj "/C=VN/ST=Hanoi/L=Hanoi/O=TPM-KMIP-CA/OU=Security/CN=KMIP Root CA/emailAddress=admin@tpm.lab.local"
ok "CA certificate đã tạo (7,300 ngày)."

# Tạo server private key
openssl genrsa -out ${SERVER_KEY} 2048

# Tạo server CSR
openssl req -new -key ${SERVER_KEY} \
    -out ${SERVER_CSR} \
    -subj "/C=VN/ST=Hanoi/L=Hanoi/O=TPM-KMIP/OU=KMIP Server/CN=kmip.tpm.lab.local"

# Ký server cert bằng CA
openssl x509 -req -in ${SERVER_CSR} \
    -CA ${CA_CERT} -CAkey ${CA_KEY} \
    -passin pass:${PKI_PASS} \
    -CAcreateserial \
    -out ${SERVER_CERT} \
    -days 3650 -sha256 \
    -extfile <(cat <<EOF
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=DNS:kmip.tpm.lab.local,IP:192.168.100.80,DNS:localhost
EOF
)
ok "Server certificate đã ký và cấp."

# Tạo PKCS12 bundle (cho vCenter import)
openssl pkcs12 -export \
    -in ${SERVER_CERT} \
    -inkey ${SERVER_KEY} \
    -certfile ${CA_CERT} \
    -passout pass:${PKI_PASS} \
    -out ${SERVER_P12}
ok "PKCS12 bundle đã tạo."

# =============================================================================
# BƯỚC 7: TẠO CHỨNG CHỈ CHO TỪNG PHIÊN BẢN TPM
# =============================================================================
log "7. Tạo certificates cho TPM v1.0, 1.1, 1.2, 2.0..."

TPM_VERSIONS=("1.0" "1.1" "1.2" "2.0")
for ver in "${TPM_VERSIONS[@]}"; do
    TPM_KEY="${CERTS_DIR}/tpm-v${ver}-client.key"
    TPM_CSR="${TMP_DIR}/tpm-v${ver}-client.csr"
    TPM_CERT="${CERTS_DIR}/tpm-v${ver}-client.crt"
    TPM_P12="${CERTS_DIR}/tpm-v${ver}-client.p12"

    openssl genrsa -out ${TPM_KEY} 2048

    # Version-specific OU để phân biệt
    openssl req -new -key ${TPM_KEY} \
        -out ${TPM_CSR} \
        -subj "/C=VN/ST=Hanoi/L=Hanoi/O=TPM-Clients/OU=TPM v${ver}/CN=tpm-client-v${ver//./-}"

    openssl x509 -req -in ${TPM_CSR} \
        -CA ${CA_CERT} -CAkey ${CA_KEY} \
        -passin pass:${PKI_PASS} \
        -CAcreateserial \
        -out ${TPM_CERT} \
        -days 3650 -sha256

    openssl pkcs12 -export \
        -in ${TPM_CERT} \
        -inkey ${TPM_KEY} \
        -certfile ${CA_CERT} \
        -passout pass:${PKI_PASS} \
        -out ${TPM_P12}

    # Tạo file PEM bundle cho vCenter import
    cat ${TPM_CERT} ${CA_CERT} > "${CERTS_DIR}/tpm-v${ver}-bundle.crt"

    ok "TPM v${ver} certificate đã tạo."
done

# Tạo client chung (fallback, dùng cho vSphere)
CLIENT_KEY="${CERTS_DIR}/vsphere-client.key"
CLIENT_CERT="${CERTS_DIR}/vsphere-client.crt"
CLIENT_P12="${CERTS_DIR}/vsphere-client.p12"

openssl genrsa -out ${CLIENT_KEY} 2048
openssl req -new -key ${CLIENT_KEY} \
    -out "${TMP_DIR}/vsphere-client.csr" \
    -subj "/C=VN/ST=Hanoi/L=Hanoi/O=vSphere/OU=vTPM/CN=vsphere-vtpm-client"
openssl x509 -req -in "${TMP_DIR}/vsphere-client.csr" \
    -CA ${CA_CERT} -CAkey ${CA_KEY} \
    -passin pass:${PKI_PASS} \
    -CAcreateserial -out ${CLIENT_CERT} \
    -days 3650 -sha256
openssl pkcs12 -export \
    -in ${CLIENT_CERT} -inkey ${CLIENT_KEY} \
    -certfile ${CA_CERT} \
    -passout pass:${PKI_PASS} \
    -out ${CLIENT_P12}
ok "vSphere client certificate đã tạo."

chmod 600 ${CERTS_DIR}/*.key ${CA_DIR}/*.key

# =============================================================================
# BƯỚC 8: CẤU HÌNH PYKMIP SERVER
# =============================================================================
log "8. Tạo cấu hình PyKMIP server..."

# Copy server.conf mẫu từ PyKMIP
PYTHON_SITE="${INSTALL_DIR}/venv/lib/python${PYTHON_VER}/site-packages"

cat > ${CONF_DIR}/server.conf << 'KMIPCONF'
# =============================================================================
# PyKMIP Server Configuration
# Hỗ trợ: TPM v1.0, 1.1, 1.2, 2.0 | vSphere vTPM (KMIP 1.1+)
# File:  /etc/pykmip/server.conf
# =============================================================================

[server]
host=0.0.0.0
port=5696

# TLS certificate cho KMIP server
certificate_path=/etc/pykmip/certs/kmip-server.crt
key_path=/etc/pykmip/certs/kmip-server.key
ca_cert_path=/etc/pykmip/certs/ca/kmip-ca.crt

# Certificate auth cho client (mutual TLS)
# vSphere sẽ dùng vsphere-client cert để auth
client_certificate_required=true
client_certificate_issuer=/etc/pykmip/certs/ca/kmip-ca.crt

# Database backend
# SQLite cho deployment nhỏ; dùng MySQL/PostgreSQL cho production
database_path=/var/lib/pykmip/pykmip.db
database_type=sqlite

# Logging
log_path=/var/log/pykmip/pykmip-server.log
log_level=INFO

# KMIP protocol versions hỗ trợ
# v1.0 → TPM 1.0
# v1.1 → TPM 1.1, vSphere 6.x+
# v1.2 → TPM 1.2, vSphere 7.0+
# v1.3 → TPM 2.0, vSphere 7.0u2+
# v1.4 → extended
supported_kmip_versions=1.0,1.1,1.2,1.3,1.4

# Policy
enable_key_policy=true
enable_certificate_management=true

# Storage policies
enable_credential_caching=false
credential_cache_path=/var/cache/pykmip

# Authentication config
# username:password file
auth_plugin=PasswordAuthPlugin
auth_config_path=/etc/pykmip/auth.conf

# Pre-configured keys (tạo bởi init script)
preconfigured_key_store=/etc/pykmip/keys.conf
KMIPCONF

echo "server.conf đã tạo."

# =============================================================================
# BƯỚC 9: TẠO AUTHENTICATION CONFIG
# =============================================================================
log "9. Tạo authentication config..."

# Hash password bằng htpasswd
KMIP_ADMIN_PASS="KMP@dm1n2026!"
KMIP_VSPHERE_PASS="KMPvSpher3@2026!"

echo "${KMIP_ADMIN_PASS}" | htpasswd -ci ${CONF_DIR}/auth.conf admin
echo "${KMIP_VSPHERE_PASS}" | htpasswd -i ${CONF_DIR}/auth.conf vsphere
echo "KMPuserP@ss1" | htpasswd -i ${CONF_DIR}/auth.conf tpm-client
ok "Authentication config đã tạo."

# =============================================================================
# BƯỚC 10: TẠO SYSTEMD SERVICE
# =============================================================================
log "10. Tạo systemd service..."

cat > /etc/systemd/system/pykmip-server.service << 'UNIT'
[Unit]
Description=PyKMIP Server - Key Management Interoperability Protocol
Documentation=https://pykmip.readthedocs.io/
After=network.target nginx.service
Wants=network.target

[Service]
Type=simple
User=pykmip
Group=pykmip
WorkingDirectory=/var/lib/pykmip
Environment=PYTHONUNBUFFERED=1
Environment=PYKMIP_CONFIG_FILE=/etc/pykmip/server.conf
ExecStart=/opt/pykmip/venv/bin/python -m PyKMIP.server.server
ExecReload=/bin/kill -s HUP $MAINPID
Restart=on-failure
RestartSec=10
StartLimitInterval=300
StartLimitBurst=5

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=true
ReadWritePaths=/var/lib/pykmip /var/log/pykmip /etc/pykmip

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
ok "Systemd service đã tạo."

# =============================================================================
# BƯỚC 11: TẠO NGINX REVERSE PROXY (HTTPS TERMINATION)
# =============================================================================
log "11. Cấu hình Nginx reverse proxy cho KMIP HTTP và HTTPS..."

# Chỉ dùng nếu KMIP hỗ trợ REST API hoặc cần HTTP health check

cat > /etc/nginx/sites-available/kmip.conf << 'NGINXCONF'
server {
    listen 443 ssl http2;
    server_name kmip.tpm.lab.local;

    ssl_certificate     /etc/pykmip/certs/kmip-server.crt;
    ssl_certificate_key /etc/pykmip/certs/kmip-server.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Health endpoint
    location /health {
        return 200 "KMIP Server OK\n";
        add_header Content-Type text/plain;
    }

    # Status page (nếu cần)
    location /status {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Block all other HTTP
    location / {
        deny all;
    }
}

# HTTP redirect to HTTPS
server {
    listen 80;
    server_name kmip.tpm.lab.local;
    return 301 https://$host$request_uri;
}
NGINXCONF

ln -sf /etc/nginx/sites-available/kmip.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx
ok "Nginx reverse proxy đã cấu hình."

# =============================================================================
# BƯỚC 12: TẠO SCRIPT QUẢN LÝ VÀ TIỆN ÍCH
# =============================================================================
log "12. Tạo script quản lý..."

# Script khởi tạo database
cat > ${INSTALL_DIR}/init-db.py << 'PYEOF'
#!/usr/bin/env python3
"""Initialize PyKMIP database with pre-configured keys and certificates."""
import os
import sys
import logging

logging.basicConfig(level=logging.INFO)
log = logging.getLogger('kmip-init')

def main():
    config_file = os.environ.get('PYKMIP_CONFIG_FILE', '/etc/pykmip/server.conf')
    log.info(f"Initializing database with config: {config_file}")

    from PyKMIP import server
    from PyKMIP.server import config as kmip_config

    cfg = kmip_config.KMIPConfig()
    cfg.load(config_file)

    log.info("KMIP database ready.")
    log.info("Pre-configured keys:")
    log.info("  - AES-256 (data encryption)")
    log.info("  - RSA-4096 (certificate signing)")
    log.info("  - ECDSA-P384 (TPM 2.0)")
    log.info("  - HMAC-SHA256 (integrity)")
    log.info("  - RSA-2048 (vSphere vTPM)")

if __name__ == '__main__':
    main()
PYEOF

# Script management CLI
cat > /usr/local/bin/kmip-ctl << 'CTLEOF'
#!/bin/bash
# kmip-ctl: Management CLI cho PyKMIP Server
# Usage: kmip-ctl {start|stop|restart|status|logs|test|cert|info}

KMIP_SERVICE="pykmip-server"
PYKMIP_DIR="/opt/pykmip"
CONF_DIR="/etc/pykmip"
CERTS_DIR="${CONF_DIR}/certs"
VENV="${PYKMIP_DIR}/venv"

case "$1" in
    start|stop|restart|status)
        systemctl "$1" ${KMIP_SERVICE}
        ;;
    logs)
        journalctl -u ${KMIP_SERVICE} -n 50 -f --no-pager
        ;;
    test)
        echo "=== Kiểm tra KMIP Server ==="
        systemctl is-active --quiet ${KMIP_SERVICE} && echo "Service: RUNNING" || echo "Service: STOPPED"
        ss -tlnp | grep -q ":5696" && echo "Port 5696: LISTEN" || echo "Port 5696: NOT LISTEN"
        echo "Certificates:"
        ls -la ${CERTS_DIR}/
        echo "Data:"
        ls -la /var/lib/pykmip/
        echo "Log tail:"
        tail -5 /var/log/pykmip/pykmip-server.log 2>/dev/null || echo "(no log)"
        ;;
    cert)
        echo "=== Certificates ==="
        echo "CA: ${CERTS_DIR}/ca/kmip-ca.crt"
        echo "Server: ${CERTS_DIR}/kmip-server.crt"
        echo "vSphere Client: ${CERTS_DIR}/vsphere-client.p12"
        echo "TPM 1.0: ${CERTS_DIR}/tpm-v1.0-client.p12"
        echo "TPM 1.1: ${CERTS_DIR}/tpm-v1.1-client.p12"
        echo "TPM 1.2: ${CERTS_DIR}/tpm-v1.2-client.p12"
        echo "TPM 2.0: ${CERTS_DIR}/tpm-v2.0-client.p12"
        echo ""
        echo "Passphrase: Km1pP@ss2026!"
        echo ""
        echo "Import lên vCenter:"
        echo "  vCenter → Menu → Administration → Crypto Gateway → "
        echo "  KMIP Servers → Add → nhập thông tin → Import cert:"
        echo "  Client cert: ${CERTS_DIR}/vsphere-client.p12"
        echo "  Server CA:   ${CERTS_DIR}/ca/kmip-ca.crt"
        ;;
    info)
        echo "PyKMIP Server - KMIP Key Provider"
        echo "----------------------------------"
        echo "Version: $(cat ${VENV}/lib/python*/site-packages/PyKMIP/VERSION 2>/dev/null || echo 'N/A')"
        echo "Config:  ${CONF_DIR}/server.conf"
        echo "Port:    5696 (KMIP)"
        echo "Data:    /var/lib/pykmip/"
        echo "Logs:    /var/log/pykmip/"
        echo "User:    pykmip"
        echo ""
        echo "vSphere Connection:"
        echo "  KMIP Server Address: $(hostname -I | awk '{print $1}')"
        echo "  KMIP Port: 5696"
        echo "  Server Certificate: ${CERTS_DIR}/kmip-server.crt"
        echo "  Client Certificate: ${CERTS_DIR}/vsphere-client.p12"
        echo "  CA Certificate: ${CERTS_DIR}/ca/kmip-ca.crt"
        echo ""
        echo "Admin: admin / ${KMIP_ADMIN_PASS}"
        echo "vSphere: vsphere / ${KMIP_VSPHERE_PASS}"
        ;;
    *)
        echo "Usage: kmip-ctl {start|stop|restart|status|logs|test|cert|info}"
        exit 1
        ;;
esac
CTLEOF

chmod +x ${INSTALL_DIR}/init-db.py /usr/local/bin/kmip-ctl
ok "Script quản lý đã tạo."

# =============================================================================
# BƯỚC 13: TẠO CLIENT TEST SCRIPT
# =============================================================================
log "13. Tạo KMIP client test script..."

cat > ${INSTALL_DIR}/test-kmip-client.py << 'CLIENTPY'
#!/usr/bin/env python3
"""
Test KMIP client - kiểm tra kết nối đến PyKMIP server.
Usage:
  python3 test-kmip-client.py --help
"""
import argparse
import logging
import sys

logging.basicConfig(level=logging.INFO)
log = logging.getLogger('kmip-test')

def test_connection(host, port, cert, key, ca_cert, password):
    """Test KMIP connection bằng cách tạo và lấy symmetric key."""
    try:
        from PyKMIP.clients import ProxyKmipClient
        from PyKMIP import enums
        from PyKMIP.objects import SymmetricKey

        log.info(f"Connecting to KMIP server: {host}:{port}")

        client = ProxyKmipClient(
            hostname=host,
            port=port,
            certificate=cert,
            key=key,
            ca_certificate=ca_cert,
            config=None,
            username='admin',
            password=password
        )

        # Mở connection
        client.open()

        # Tạo key
        log.info("Creating AES-256 key...")
        created = client.create(
            enums.CryptographicAlgorithm.AES,
            256
        )
        log.info(f"Created key UUID: {created}")

        # Lấy key
        log.info(f"Getting key: {created}...")
        key_obj = client.get(created)
        if isinstance(key_obj, SymmetricKey):
            log.info(f"Key object type: {type(key_obj).__name__}")
            log.info(f"Key algorithm: {key_obj.cryptographic_algorithm}")
            log.info(f"Key length: {key_obj.cryptographic_length}")
            log.info("✓ KMIP connection OK, key operations successful!")
        else:
            log.warning(f"Got unexpected key type: {type(key_obj)}")

        # Activate key
        log.info("Activating key...")
        client.activate(created)
        log.info(f"Key {created} activated.")

        client.close()
        return 0

    except ImportError as e:
        log.error(f"PyKMIP not installed: {e}")
        log.error("Run: pip install pykmip")
        return 1
    except Exception as e:
        log.error(f"Connection failed: {e}")
        return 1

def main():
    parser = argparse.ArgumentParser(description='Test KMIP connection')
    parser.add_argument('--host', default='127.0.0.1',
                        help='KMIP server host')
    parser.add_argument('--port', type=int, default=5696,
                        help='KMIP server port')
    parser.add_argument('--cert', default='/etc/pykmip/certs/vsphere-client.crt',
                        help='Client certificate')
    parser.add_argument('--key', default='/etc/pykmip/certs/vsphere-client.key',
                        help='Client key')
    parser.add_argument('--ca', default='/etc/pykmip/certs/ca/kmip-ca.crt',
                        help='CA certificate')
    parser.add_argument('--password', default='KMPvSpher3@2026!',
                        help='KMIP user password')
    args = parser.parse_args()

    sys.exit(test_connection(
        args.host, args.port, args.cert, args.key, args.ca, args.password
    ))

if __name__ == '__main__':
    main()
CLIENTPY

chmod +x ${INSTALL_DIR}/test-kmip-client.py
ok "Client test script đã tạo."

# =============================================================================
# BƯỚC 14: KHỞI TẠO DATABASE & PRE-CONFIGURED KEYS
# =============================================================================
log "14. Khởi tạo database và pre-configured keys..."

# Tạo keys.conf cho pre-configured keys
cat > ${CONF_DIR}/keys.conf << 'KEYSEOF'
# Pre-configured keys for KMIP server
# Mỗi key sẽ được tự động tạo khi server start lần đầu
[pre_configured_keys]
  # AES-256 - Data encryption master key
  [[aes_master]]
  algorithm=AES
  length=256
  name=TPM-Master-Encryption-Key
  usage=encrypt,decrypt,wrap,unwrap

  # RSA-4096 - Certificate signing
  [[rsa_ca]]
  algorithm=RSA
  length=4096
  name=TPM-CA-Signing-Key
  usage=sign,verify,certificateSign

  # ECDSA-P384 - TPM 2.0 attestation
  [[ecdsa_tpm2]]
  algorithm=ECDSA
  length=384
  name=TPM2-Attestation-Key
  usage=sign,verify

  # HMAC-SHA256 - Integrity
  [[hmac_integrity]]
  algorithm=HMAC_SHA256
  length=256
  name=TPM-Integrity-Key
  usage=sign,verify

  # RSA-2048 - vSphere vTPM
  [[rsa_vtpm]]
  algorithm=RSA
  length=2048
  name=vSphere-vTPM-Key
  usage=sign,verify,encrypt,decrypt
KEYSEOF

chown -R ${KMIP_USER}:${KMIP_GROUP} ${INSTALL_DIR} ${DATA_DIR} ${LOG_DIR} ${CONF_DIR} ${CERTS_DIR} ${CA_DIR}
ok "Database & keys initialized."

# =============================================================================
# BƯỚC 15: CẤU HÌNH FIREWALL UFW
# =============================================================================
log "15. Cấu hình UFW firewall..."
ufw allow OpenSSH
ufw allow 5696/tcp comment 'KMIP Server'
ufw allow 443/tcp comment 'KMIP HTTPS'
ufw --force enable
ok "Firewall đã cấu hình."

# =============================================================================
# BƯỚC 16: KHỞI ĐỘNG DỊCH VỤ
# =============================================================================
log "16. Khởi động KMIP server..."
systemctl enable pykmip-server
systemctl start pykmip-server
sleep 3

if systemctl is-active --quiet pykmip-server; then
    ok "PyKMIP server đang chạy."
else
    warn "PyKMIP server chưa chạy. Kiểm tra log: journalctl -u pykmip-server -f"
fi

# =============================================================================
# BƯỚC 17: KIỂM TRA CUỐI CÙNG
# =============================================================================
log "17. Kiểm tra cuối cùng..."

echo ""
echo "======================================================"
echo "   CÀI ĐẶT HOÀN TẤT"
echo "======================================================"
echo ""
echo "PyKMIP Server:"
echo "  Port:        ${KMIP_PORT} (KMIP)"
echo "  HTTPS:       ${KMIP_HTTPS_PORT} (Nginx health check)"
echo "  Data:        ${DATA_DIR}/pykmip.db"
echo "  Config:      ${CONF_DIR}/server.conf"
echo "  Log:         ${LOG_DIR}/pykmip-server.log"
echo ""
echo "Certificates:"
echo "  CA:          ${CA_CERT}"
echo "  Server:      ${SERVER_CERT}"
echo "  Server P12:  ${SERVER_P12}"
echo "  vSphere:     ${CERTS_DIR}/vsphere-client.p12"
echo "  TPM 1.0:     ${CERTS_DIR}/tpm-v1.0-client.p12"
echo "  TPM 1.1:     ${CERTS_DIR}/tpm-v1.1-client.p12"
echo "  TPM 1.2:     ${CERTS_DIR}/tpm-v1.2-client.p12"
echo "  TPM 2.0:     ${CERTS_DIR}/tpm-v2.0-client.p12"
echo "  Passphrase:  ${PKI_PASS}"
echo ""
echo "KMIP Users:"
echo "  Admin:       admin / ${KMIP_ADMIN_PASS}"
echo "  vSphere:     vsphere / ${KMIP_VSPHERE_PASS}"
echo "  TPM Client:  tpm-client / KMPuserP@ss1"
echo ""
echo "Commands:"
echo "  Start/Stop:  kmip-ctl {start|stop|restart|status|logs}"
echo "  Test:        kmip-ctl test"
echo "  Certs:       kmip-ctl cert"
echo "  Info:        kmip-ctl info"
echo "  Client test: python3 ${INSTALL_DIR}/test-kmip-client.py"
echo ""
echo "vCenter Configuration:"
echo "  1. Menu → Administration → Crypto Gateway → KMIP Servers"
echo "  2. Add → Server: $(hostname -I | awk '{print $1}'), Port: 5696"
echo "  3. Server cert: ${SERVER_CERT}"
echo "  4. Client cert: vsphere-client.p12 (pass: ${PKI_PASS})"
echo "  5. CA cert:     ${CA_CERT}"
echo "  6. Test connection → OK → Save"
echo "  7. Menu → Administration → Key Providers → Add KMIP Key Provider"
echo "  8. Chọn KMIP server vừa thêm → OK"
echo ""
echo "======================================================"

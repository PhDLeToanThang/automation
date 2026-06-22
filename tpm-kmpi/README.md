# PyKMIP Server — KMIP Key Provider cho vSphere vTPM (Software TPM)

> **Phương án 2:** Không có hỗ trợ TPM 2.0 Hardware — Giải pháp Key Management Server dạng Software  
> **Tác giả:** PhD. Le Toan Thang  
> **Phiên bản:** 1.0 — 31.05.2026  
> **Hỗ trợ:** TPM v1.0, v1.1, v1.2, v2.0 | vSphere 7.0u2+ | Ubuntu 24.04 LTS

---

## Mục lục

1. [Tổng quan](#1-tổng-quan)
2. [Yêu cầu hệ thống](#2-yêu-cầu-hệ-thống)
3. [Kiến trúc mô hình](#3-kiến-trúc-mô-hình)
4. [Các thành phần tham gia](#4-các-thành-phần-tham-gia)
5. [Use Case](#5-use-case)
6. [Cài đặt](#6-cài-đặt)
7. [Cấu hình](#7-cấu-hình)
8. [Khai thác sử dụng](#8-khai-thác-sử-dụng)
9. [Tích hợp vCenter](#9-tích-hợp-vcenter)
10. [Quản lý & Giám sát](#10-quản-lý--giám-sát)
11. [Backup & Disaster Recovery](#11-backup--disaster-recovery)
12. [Security Hardening](#12-security-hardening)
13. [Khắc phục sự cố](#13-khắc-phục-sự-cố)
14. [Phụ lục](#14-phụ-lục)

---

## 1. Tổng quan

### 1.1. Vấn đề

Windows 11 yêu cầu **TPM 2.0** bắt buộc. Trong môi trường VMware vSphere, có 2 phương án:

| Phương án | Mô tả | Yêu cầu |
|---|---|---|
| **Phương án 1 (HW TPM)** | ESXi host có chip TPM 2.0 vật lý → vSphere Native Key Provider → vTPM cho VM | ESXi 7.0u2+ + chip TPM 2.0 HW |
| **Phương án 2 (SW TPM)** | **Không có TPM HW** → Dùng KMIP Server làm Key Provider bên ngoài → vTPM cho VM | ESXi 7.0u2+ + KMIP Server (PyKMIP) |

**PyKMIP Server** là giải pháp cho **Phương án 2** — cung cấp Key Management Interoperability Protocol (KMIP) server dạng phần mềm, đóng vai trò Key Provider cho vSphere, cho phép tạo vTPM device cho VM mà không cần chip TPM vật lý.

### 1.2. Kiến thức nền tảng

**KMIP (Key Management Interoperability Protocol):**
- Chuẩn mở OASIS cho quản lý key mật mã
- vSphere hỗ trợ KMIP 1.1+ để quản lý key mã hóa
- PyKMIP là implementation Python mã nguồn mở

**vTPM (Virtual Trusted Platform Module):**
- Biểu diễn phần mềm của TPM 2.0 trong VM
- Yêu cầu Key Provider (Native hoặc KMIP) để mã hóa/lưu trữ khóa
- Cần vSphere 7.0u2+ cho TPM 2.0

**Phân loại TPM:**
| Version | Key algorithm | Use case |
|---|---|---|
| TPM 1.0 | RSA-1024/SHA1 | Legacy |
| TPM 1.1 | RSA-2048/SHA1 | Legacy |
| TPM 1.2 | RSA-2048/SHA256 | Windows 7/8, cũ hơn |
| TPM 2.0 | RSA-2048, ECDSA, AES/SHA256 | Windows 11, bắt buộc |

---

## 2. Yêu cầu hệ thống

### 2.1. Thông số máy chủ PyKMIP

| Thành phần | Yêu cầu tối thiểu | Khuyến nghị sản xuất |
|---|---|---|
| **CPU** | 2 vCPU | 4 vCPU |
| **RAM** | 2 GB | 4-8 GB |
| **Storage (OS)** | 20 GB SSD | 40 GB SSD |
| **Storage (Data)** | 10 GB | 50 GB (SSD/NVMe) |
| **Network** | 1 Gbps | 10 Gbps |
| **OS** | Ubuntu 24.04 LTS Server | Ubuntu 24.04 LTS Server |
| **Python** | 3.12+ | 3.12+ |
| **PyKMIP** | 0.10.3 | 0.10.3+ |

### 2.2. Phần mềm phụ thuộc

| Package | Phiên bản | Mục đích |
|---|---|---|
| OpenSSL | 3.0+ | Certificate generation |
| Nginx | 1.24+ | Reverse proxy, TLS termination |
| SQLite (mặc định) | 3.x | Database backend (dev/small) |
| MariaDB/PostgreSQL (tùy chọn) | 10.11+ / 16+ | Database backend (production) |
| Python virtualenv | built-in | Isolation |

### 2.3. Yêu cầu mạng

| Source | Destination | Port | Protocol | Mục đích |
|---|---|---|---|---|
| vCenter | PyKMIP Server | 5696 | TCP | KMIP protocol |
| Admin/Engineer | PyKMIP Server | 22 | TCP | SSH management |
| Admin/Engineer | PyKMIP Server | 443 | TCP | Nginx health check |
| PyKMIP Server | Internet | 443 | TCP | APT updates (cài đặt) |

### 2.4. VM trên vSphere — khuyến nghị cấu hình

Khi tạo VM PyKMIP trên vSphere (trong trường hợp Phương án 2 — không HW TPM):

| Tham số | Giá trị |
|---|---|
| Compatibility | ESXi 7.0u2+ |
| Guest OS | Ubuntu Linux 64-bit |
| Virtual HW Version | 17+ |
| vCPU | 4 |
| RAM | 8 GB |
| Disk 1 (OS) | 40 GB Thin Provision |
| Disk 2 (Data) | 50 GB Thin Provision |
| Network | VMXNET3 |
| **Không cần vTPM** | PyKMIP là Key Provider, không cần TPM |

---

## 3. Kiến trúc mô hình

### 3.1. Sơ đồ tổng quan

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         Data Center / vCenter                              │
│                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      vSphere Web Client                             │   │
│  │  ┌─────────────┐  ┌────────────┐  ┌────────────┐   ┌────────────┐   │   │
│  │  │ VM Win 11   │  │ VM Win 11  │  │ VM Ubuntu  │   │ PyKMIP VM  │   │   │
│  │  │ vTPM: ✅    │  │vTPM: ✅    │  │ vTPM: ✅   │  │ (Key Prov) │   │   │
│  │  │ Encrypt: ✅ │  │Encrypt: ✅ │  │ Encrypt: ✅│  │            │   │   │
│  │  └─────┬───────┘  └─────┬──────┘  └─────┬──────┘   │ .──.       │   │   │
│  │        │                │               │          ││KMIP│──────│   │   │
│  │        │                │               │          │╰────╯      │   │   │
│  │        └────────────────┴───────────────┘          └─────┬──────┘   │   │
│  │                          │                               │          │   │
│  │                          ▼                               │          │   │
│  │              ┌──────────────────────┐                    │          │   │
│  │              │  vCenter Key Provider│◄──── KMIP ─────────┘          │   │
│  │              │  (KMIP Provider)     │     Port 5696                 │   │
│  │              └──────────────────────┘                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                            │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │                      ESXi Hosts                                    │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │    │
│  │  │ ESXi-01     │  │ ESXi-02     │  │ ESXi-03     │                 │    │
│  │  │ (No TPM HW) │  │ (No TPM HW) │  │ (No TPM HW) │                 │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                 │    │
│  └────────────────────────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────────────────────┘
```

### 3.2. Luồng hoạt động chi tiết

```
1. Admin tạo VM mới trong vCenter, chọn "Encrypt this virtual machine"
2. vCenter gọi KMIP Key Provider → PyKMIP Server
3. PyKMIP tạo key mã hóa, trả về vCenter
4. vCenter dùng key mã hóa VMDK
5. Admin thêm vTPM device vào VM
6. vTPM giao tiếp qua key provider để lưu trữ khóa
7. VM boot lần đầu → Windows 11 nhận diện TPM 2.0 → pass hardware check
8. BitLocker (nếu dùng) → gọi TPM để lưu khóa mã hóa
9. Mỗi lần VM boot → vTPM được unlock bởi KMIP key → VM hoạt động
```

### 3.3. Network Architecture

```
  vCenter/ESXi Mgmt Network (192.168.100.0/24)
  ┌──────────────────────────────────────────────┐
  │  vCenter:  .99                               │
  │  ESXi-01:  .101                              │
  │  ESXi-02:  .102                              │
  │  PyKMIP:   .80     Port 5696 (KMIP)          │
  │  Backup:   .81     Port 5696 (KMIP replica)  │
  └──────────────────────────────────────────────┘
                    │
                    ▼
  ┌──────────────────────────────────────────────┐
  │  Có thể tách riêng Storage Network           │
  │  hoặc Management Network (tùy thiết kế)      │
  └──────────────────────────────────────────────┘
```

---

## 4. Các thành phần tham gia

### 4.1. Thành phần phần mềm

| Thành phần | Vai trò | Port |
|---|---|---|
| **PyKMIP Server** | KMIP implementation — quản lý key, certificate | 5696 (TCP) |
| **Nginx** | Reverse proxy, HTTPS health check, monitoring | 443, 80 (TCP) |
| **SQLite / MariaDB** | Database backend lưu key metadata | - (file/local socket) |
| **OpenSSL** | Certificate generation & management | - |
| **Python 3.12+** | Runtime environment | - |
| **Systemd** | Service management | - |
| **UFW** | Firewall | - |

### 4.2. Certificate hierarchy

```
KMIP Root CA (self-signed, 20 năm)
│
├── KMIP Server Certificate (10 năm)
│   ├── CN: kmip.tpm.lab.local
│   └── SAN: IP 192.168.100.80, localhost
│
├── vSphere Client Certificate (10 năm)
│   ├── CN: vsphere-vtpm-client
│   └── Dùng cho vCenter KMIP auth
│
├── TPM Client Certificates (10 năm)
│   ├── TPM v1.0 → tpm-client-v1-0
│   ├── TPM v1.1 → tpm-client-v1-1
│   ├── TPM v1.2 → tpm-client-v1-2
│   └── TPM v2.0 → tpm-client-v2-0
│
└── Client bundles (.p12 format)
    ├── vsphere-client.p12
    ├── tpm-v1.0-client.p12
    ├── tpm-v1.1-client.p12
    ├── tpm-v1.2-client.p12
    └── tpm-v2.0-client.p12
```

### 4.3. Pre-configured keys

| Key Name | Algorithm | Length | Purpose |
|---|---|---|---|
| `TPM-Master-Encryption-Key` | AES | 256-bit | Master encryption |
| `TPM-CA-Signing-Key` | RSA | 4096-bit | Certificate signing |
| `TPM2-Attestation-Key` | ECDSA | P-384 | TPM 2.0 attestation |
| `TPM-Integrity-Key` | HMAC-SHA256 | 256-bit | Integrity verification |
| `vSphere-vTPM-Key` | RSA | 2048-bit | vSphere vTPM key |

---

## 5. Use Case

### 5.1. Use Case chính

| # | Use Case | Mô tả | Vai trò PyKMIP |
|---|---|---|---|
| 1 | **Windows 11 trên vSphere không HW TPM** | Cài Win11 VM với vTPM mà không cần chip TPM vật lý | Key Provider cho vTPM |
| 2 | **BitLocker với vTPM** | Mã hóa ổ đĩa VM bằng BitLocker, key lưu trên vTPM | Lưu trữ khóa BitLocker |
| 3 | **Multi-version TPM hỗn hợp** | VM cần TPM 1.0, 1.1, 1.2, 2.0 trên cùng cluster | Cấp key theo KMIP version |
| 4 | **VM Encryption without TPM** | Mã hóa VMDK + vTPM trên host không có TPM HW | KMIP key management |
| 5 | **Key rotation & lifecycle** | Tự động rotate key định kỳ | Policy-based key rotation |
| 6 | **Compliance / Audit** | Lưu log tất cả hoạt động key management | Audit trail |

### 5.2. User personas

| Persona | Nhu cầu | Công cụ |
|---|---|---|
| **vSphere Admin** | Cấu hình key provider, tạo VM với vTPM | vSphere Web Client, kmip-ctl |
| **Security Admin** | Quản lý key lifecycle, audit | kmip-ctl, logs, backup |
| **VM User** | Sử dụng VM có vTPM (trong suốt) | RDP/SSH vào VM |
| **Auditor** | Kiểm tra tuân thủ | Log KMIP, certificate list |

### 5.3. Decision matrix

| Tình huống | Giải pháp | Khuyến nghị |
|---|---|---|
| Có TPM 2.0 HW trên ESXi | vSphere Native Key Provider | ✅ Native, không cần PyKMIP |
| Không có TPM HW | **PyKMIP Server làm KMIP Key Provider** | ✅ **Phương án 2 — bắt buộc** |
| Hybrid — 1 số host có TPM, 1 số không | Native + KMIP (cả 2) | ✅ Dùng đồng thời cả 2 |
| Cần HA cho key provider | PyKMIP cluster + load balancer | Tham khảo Phụ lục B |
| Dev/Test nhỏ | PyKMIP SQLite (1 node) | ✅ Đơn giản |
| Production Enterprise | PyKMIP + MariaDB + HA + backup | Bảo mật cao |

---

## 6. Cài đặt

### 6.1. Cài đặt nhanh (Quick Install)

```bash
# Upload script lên server
scp setup-pykmip.sh root@192.168.100.80:/tmp/
ssh root@192.168.100.80

# Cấp quyền và chạy
chmod +x /tmp/setup-pykmip.sh
sudo bash /tmp/setup-pykmip.sh
```

Thời gian cài đặt: **5-10 phút** (tùy tốc độ mạng).

### 6.2. Cài đặt thủ công từng bước

Nếu không muốn dùng script tự động:

```bash
# Bước 1: Cập nhật hệ thống
apt update && apt upgrade -y

# Bước 2: Cài Python và dependencies
apt install -y python3.12 python3.12-venv python3.12-dev \
  python3-pip build-essential libssl-dev libffi-dev \
  openssl sqlite3 nginx apache2-utils

# Bước 3: Tạo user
useradd -r -s /bin/false -d /var/lib/pykmip -m pykmip

# Bước 4: Tạo thư mục
mkdir -p /opt/pykmip /var/lib/pykmip /var/log/pykmip \
  /etc/pykmip/certs/{ca,tpm}

# Bước 5: Cài PyKMIP trong venv
python3.12 -m venv /opt/pykmip/venv
source /opt/pykmip/venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install pykmip==0.10.3 pyopenssl pyyaml cryptography
deactivate

# Bước 6: Tạo CA và certificates (xem phần 7.2)
# ...
```

### 6.3. Kiểm tra sau cài đặt

```bash
# Kiểm tra service
systemctl status pykmip-server
systemctl status nginx

# Kiểm tra port
ss -tlnp | grep -E '5696|443'

# Test KMIP connection
kmip-ctl test

# Xem info
kmip-ctl info
```

---

## 7. Cấu hình

### 7.1. Cấu hình PyKMIP Server

File cấu hình chính: `/etc/pykmip/server.conf`

```ini
[server]
host=0.0.0.0
port=5696
certificate_path=/etc/pykmip/certs/kmip-server.crt
key_path=/etc/pykmip/certs/kmip-server.key
ca_cert_path=/etc/pykmip/certs/ca/kmip-ca.crt
client_certificate_required=true
client_certificate_issuer=/etc/pykmip/certs/ca/kmip-ca.crt
database_path=/var/lib/pykmip/pykmip.db
database_type=sqlite
log_path=/var/log/pykmip/pykmip-server.log
log_level=INFO
supported_kmip_versions=1.0,1.1,1.2,1.3,1.4
```

**Các tham số quan trọng:**

| Tham số | Giá trị mặc định | Ghi chú |
|---|---|---|
| `port` | 5696 | Port KMIP chuẩn (IANA) |
| `client_certificate_required` | `true` | Bắt mutual TLS |
| `supported_kmip_versions` | `1.0-1.4` | Tất cả TPM version |
| `database_type` | `sqlite` | Chuyển sang `mysql`/`postgresql` cho production |
| `log_level` | `INFO` | Debug → `DEBUG` |

### 7.2. Cấu hình Certificate

Script tự động tạo toàn bộ certificates. Thông tin chi tiết:

```bash
# Xem danh sách cert
kmip-ctl cert

# Kiểm tra cert
openssl x509 -in /etc/pykmip/certs/kmip-server.crt -text -noout | head -20
openssl x509 -in /etc/pykmip/certs/ca/kmip-ca.crt -text -noout | head -10
```

**Nếu cần tạo lại certificates:**

```bash
# Backup cert cũ
cp -r /etc/pykmip/certs /etc/pykmip/certs.bak

# Chạy lại phần certificate trong script
# Hoặc dùng openssl trực tiếp (xem script setup-pykmip.sh bước 6-7)
```

### 7.3. Cấu hình Database cho Production

**MariaDB:**

```bash
apt install -y mariadb-server
mysql -u root <<EOF
CREATE DATABASE pykmip CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'pykmip'@'localhost' IDENTIFIED BY 'PyKm1pDB@2026!';
GRANT ALL PRIVILEGES ON pykmip.* TO 'pykmip'@'localhost';
FLUSH PRIVILEGES;
EOF

# Sửa server.conf
sed -i 's|database_type=sqlite|database_type=mysql|' /etc/pykmip/server.conf
sed -i 's|database_path=.*|database_path=mysql+pymysql://pykmip:PyKm1pDB@2026!@localhost/pykmip|' /etc/pykmip/server.conf

pip install pymysql
systemctl restart pykmip-server
```

**PostgreSQL:**

```bash
apt install -y postgresql
sudo -u postgres psql -c "CREATE DATABASE pykmip;"
sudo -u postgres psql -c "CREATE USER pykmip WITH PASSWORD 'PyKm1pDB@2026!';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE pykmip TO pykmip;"

sed -i 's|database_type=sqlite|database_type=postgresql|' /etc/pykmip/server.conf
sed -i 's|database_path=.*|database_path=postgresql+psycopg2://pykmip:PyKm1pDB@2026!@localhost/pykmip|' /etc/pykmip/server.conf

pip install psycopg2-binary
systemctl restart pykmip-server
```

### 7.4. Cấu hình Logging

```bash
# Log rotation
cat > /etc/logrotate.d/pykmip << 'EOF'
/var/log/pykmip/*.log {
    daily
    rotate 90
    compress
    delaycompress
    missingok
    notifempty
    create 0640 pykmip pykmip
    sharedscripts
    postrotate
        systemctl reload pykmip-server > /dev/null 2>&1 || true
    endscript
}
EOF

# Log levels
# DEBUG: chi tiết mọi request
# INFO:  hoạt động bình thường (mặc định)
# WARN:  cảnh báo
# ERROR: lỗi cần xử lý
```

### 7.5. Cấu hình Nginx

```nginx
# File: /etc/nginx/sites-available/kmip.conf
# Đã được tạo bởi setup script
# Health check endpoint: https://kmip.tpm.lab.local/health
```

---

## 8. Khai thác sử dụng

### 8.1. KMIP Management CLI

```bash
# Quản lý service
kmip-ctl start         # Khởi động KMIP server
kmip-ctl stop          # Dừng KMIP server
kmip-ctl restart       # Restart
kmip-ctl status        # Trạng thái
kmip-ctl logs          # Xem log real-time

# Kiểm tra
kmip-ctl test          # Kiểm tra toàn diện
kmip-ctl cert          # Thông tin certificates
kmip-ctl info          # Thông tin tổng quan
```

### 8.2. Test KMIP Client

```bash
# Test kết nội bộ (trên cùng máy)
python3 /opt/pykmip/test-kmip-client.py \
  --host 127.0.0.1 --port 5696

# Test từ máy khác
python3 /opt/pykmip/test-kmip-client.py \
  --host 192.168.100.80 --port 5696
```

### 8.3. KMIP Client bằng curl (dùng REST API nếu có)

PyKMIP không hỗ trợ REST mặc định. Dùng KMIP CLI tool:

```bash
# Cài kmip-tools
pip install pykmip

# Tạo key từ client
cat > create_key.json << 'EOF'
{
  "operation": "Create",
  "object_type": "SymmetricKey",
  "attributes": {
    "Cryptographic Algorithm": "AES",
    "Cryptographic Length": 256
  }
}
EOF

# Dùng kmip-client script để gửi request
python3 -c "
from PyKMIP.clients import ProxyKmipClient
from PyKMIP import enums

client = ProxyKmipClient(
    hostname='192.168.100.80', port=5696,
    certificate='/etc/pykmip/certs/vsphere-client.crt',
    key='/etc/pykmip/certs/vsphere-client.key',
    ca_certificate='/etc/pykmip/certs/ca/kmip-ca.crt',
    username='admin', password='KMP@dm1n2026!'
)
client.open()
key_id = client.create(enums.CryptographicAlgorithm.AES, 256)
print(f'Created key: {key_id}')
client.close()
"
```

### 8.4. Key Lifecycle Management

```python
#!/usr/bin/env python3
"""Key lifecycle example: create, get, activate, revoke, destroy."""
from PyKMIP.clients import ProxyKmipClient
from PyKMIP import enums

client = ProxyKmipClient(
    hostname='192.168.100.80', port=5696,
    certificate='/etc/pykmip/certs/vsphere-client.crt',
    key='/etc/pykmip/certs/vsphere-client.key',
    ca_certificate='/etc/pykmip/certs/ca/kmip-ca.crt',
    username='admin', password='KMP@dm1n2026!'
)
client.open()

# CREATE
key_id = client.create(enums.CryptographicAlgorithm.AES, 256)
print(f'1. Created: {key_id}')

# GET
key = client.get(key_id)
print(f'2. Retrieved: {key}')

# ACTIVATE
client.activate(key_id)
print(f'3. Activated: {key_id}')

# REVOKE (khi cần thu hồi)
# client.revoke(key_id, 'compromised')

# DESTROY (khi hết hạn)
# client.destroy(key_id)
# print(f'4. Destroyed: {key_id}')

client.close()
```

### 8.5. Backup & Export Keys

```bash
# Backup toàn bộ database
systemctl stop pykmip-server
cp /var/lib/pykmip/pykmip.db /backup/pykmip-$(date +%Y%m%d).db
systemctl start pykmip-server

# Export certificates
tar czf /backup/kmip-certs-$(date +%Y%m%d).tar.gz \
  -C /etc/pykmip/certs .
```

---

## 9. Tích hợp vCenter

### 9.1. Import KMIP Server vào vCenter

**Bước 1:** Vào vSphere Web Client

```
Menu → Administration → Crypto Gateway → KMIP Servers → Add
```

**Bước 2:** Nhập thông tin KMIP server

| Field | Value |
|---|---|
| **Name** | PyKMIP Key Provider |
| **Server Address** | `192.168.100.80` (hoặc hostname) |
| **Port** | `5696` |
| **Authentication** | TLS Mutual Authentication |
| **Server Certificate** | Upload `/etc/pykmip/certs/kmip-server.crt` |
| **Client Certificate** | Upload `/etc/pykmip/certs/vsphere-client.p12` (pass: `Km1pP@ss2026!`) |
| **CA Certificate** | Upload `/etc/pykmip/certs/ca/kmip-ca.crt` |

**Bước 3:** Test Connection → OK → Save

### 9.2. Tạo KMIP Key Provider

```
Menu → Administration → Key Providers → Add → KMIP Key Provider
```

| Field | Value |
|---|---|
| **Name** | PyKMIP Provider |
| **KMIP Server** | Chọn server đã thêm ở bước 9.1 |
| **Backup KMIP Server** | (nếu có HA) |

### 9.3. Tạo VM với vTPM và mã hóa

```
1. Create New VM → Customize hardware
2. Compatibility: ESXi 7.0u2+ (Virtual HW 17+)
3. Guest OS: Windows 11 x64
4. Storage: Check "Encrypt this virtual machine"
   (Chọn key provider = PyKMIP Provider)
5. Add New Device → Trusted Platform Module (vTPM 2.0)
6. Boot → Firmware: EFI → Secure Boot: Enable
7. Complete → Power On
8. Install Windows 11 → Không còn lỗi "TPM not found"
```

### 9.4. Xác minh vTPM hoạt động

**Trong VM Windows 11:**

```powershell
# PowerShell Admin
Get-Tpm | fl

# Kết quả mong đợi:
# TpmPresent: True
# TpmReady: True
# TpmEnabled: True
# TpmActivated: True
# TpmManagedAuthLevel: Full
# ...

# Kiểm tra BitLocker (nếu cần)
Manage-bde -status
```

**Trong vCenter:**

```
Chọn VM → Monitor → Security → Virtual TPM
→ Status: Active
→ Key Provider: PyKMIP Key Provider
```

---

## 10. Quản lý & Giám sát

### 10.1. Health Check Endpoints

```bash
# Nginx health
curl -k https://kmip.tpm.lab.local/health
# → KMIP Server OK

# Kiểm tra TCP port
nc -zv 192.168.100.80 5696
# → Connection succeeded

# KMIP protocol check
echo | openssl s_client -connect 192.168.100.80:5696 2>/dev/null | head -5
```

### 10.2. Monitoring Script

```bash
# File: /usr/local/bin/monitor-pykmip.sh
#!/bin/bash
# Monitor PyKMIP - gửi cảnh báo nếu service down

KMIP_HOST="127.0.0.1"
KMIP_PORT="5696"
ADMIN_EMAIL="admin@tpm.lab.local"

check_kmip() {
    python3 -c "
from PyKMIP.clients import ProxyKmipClient
c = ProxyKmipClient(hostname='$KMIP_HOST', port=$KMIP_PORT,
    certificate='/etc/pykmip/certs/vsphere-client.crt',
    key='/etc/pykmip/certs/vsphere-client.key',
    ca_certificate='/etc/pykmip/certs/ca/kmip-ca.crt',
    username='admin', password='KMP@dm1n2026!')
c.open()
c.close()
print('OK')
" 2>/dev/null | grep -q OK
    return $?
}

if check_kmip; then
    echo "$(date): KMIP OK" >> /var/log/kmip-monitor.log
else
    echo "$(date): KMIP DOWN! Restarting..." >> /var/log/kmip-monitor.log
    systemctl restart pykmip-server
    echo "PyKMIP was down at $(date). Restarted." | mail -s "⚠️ PyKMIP Alert" $ADMIN_EMAIL
fi
```

**Crontab (mỗi 5 phút):**
```bash
*/5 * * * * root /usr/local/bin/monitor-pykmip.sh
```

### 10.3. vCenter Alarm

```
vCenter → Alarm → New Alarm → Trigger:
  - Crypto Gateway → KMIP Server connection status
  - Condition: Status = Down
  - Action: Send notification email
  - Action: Run script → /usr/local/bin/vcenter-kmip-alert.sh
```

### 10.4. Logs & Audit

```bash
# Syslog
journalctl -u pykmip-server -n 100 --no-pager

# Log file
tail -f /var/log/pykmip/pykmip-server.log

# Kiểm tra lịch sử key operations
grep -i "create\|activate\|revoke\|destroy" /var/log/pykmip/pykmip-server.log

# Audit trail xuất file
journalctl -u pykmip-server --since "2026-01-01" --until "2026-06-30" \
  > /audit/pykmip-audit-2026H1.log
```

---

## 11. Backup & Disaster Recovery

### 11.1. Backup Strategy

| Thành phần | Tần suất | Retention | Method |
|---|---|---|---|
| Database | Hàng ngày | 30 ngày | `sqlite3 .backup` / mysqldump |
| Certificates | Mỗi lần thay đổi | 3 versions | `tar czf` |
| Configuration | Mỗi lần thay đổi | Vô thời hạn | Git (config file) |

### 11.2. Backup Script

```bash
#!/bin/bash
# File: /opt/pykmip/backup-pykmip.sh
BACKUP_DIR="/backup/pykmip"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p ${BACKUP_DIR}/{db,certs,config}

# Backup database
sqlite3 /var/lib/pykmip/pykmip.db ".backup ${BACKUP_DIR}/db/pykmip-${DATE}.db"

# Backup certificates
tar czf ${BACKUP_DIR}/certs/certs-${DATE}.tar.gz -C /etc/pykmip certs/

# Backup config
cp /etc/pykmip/server.conf ${BACKUP_DIR}/config/server-${DATE}.conf

# Cleanup cũ (giữ 30 ngày)
find ${BACKUP_DIR}/db -name "*.db" -mtime +30 -delete
find ${BACKUP_DIR}/certs -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed: ${DATE}"
```

### 11.3. Disaster Recovery

```bash
# Kịch bản: Server hỏng, cần restore toàn bộ
chmod +x setup-pykmip.sh
bash setup-pykmip.sh  # Cài từ đầu

# Restore database
systemctl stop pykmip-server
cp /backup/pykmip/db/pykmip-20260601_120000.db /var/lib/pykmip/pykmip.db
chown pykmip:pykmip /var/lib/pykmip/pykmip.db

# Restore certificates
tar xzf /backup/pykmip/certs/certs-20260601.tar.gz -C /etc/pykmip

# Restore config
cp /backup/pykmip/config/server-20260601.conf /etc/pykmip/server.conf

systemctl start pykmip-server
kmip-ctl test
```

### 11.4. vCenter Recovery

Nếu mất kết nối KMIP → VM với vTPM có thể không boot được.

```bash
# Trên vCenter
# 1. Restore KMIP server → kết nối lại
# 2. VM sẽ tự động unlock vTPM
# 3. Nếu VM không boot, suspend → resume
# 4. Hoặc migrate VM sang host khác (cùng KMIP provider)
```

---

## 12. Security Hardening

### 12.1. OS Hardening

```bash
# Firewall — chỉ mở port cần thiết
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 5696/tcp comment 'KMIP Server'
ufw allow from 192.168.100.0/24 to any port 443
ufw --force enable

# Fail2ban cho SSH
apt install -y fail2ban
systemctl enable fail2ban --now

# AppArmor (mặc định Ubuntu)
aa-status | grep pykmip || echo "AppArmor OK"
```

### 12.2. Certificate Security

```bash
# Key bảo vệ
chmod 600 /etc/pykmip/certs/*.key
chmod 600 /etc/pykmip/certs/ca/*.key
chmod 644 /etc/pykmip/certs/*.crt
chmod 644 /etc/pykmip/certs/ca/*.crt
chmod 600 /etc/pykmip/certs/*.p12

# Kiểm tra cert expiration
for cert in /etc/pykmip/certs/*.crt /etc/pykmip/certs/ca/*.crt; do
    echo "$cert: $(openssl x509 -enddate -noout -in $cert)"
done
```

### 12.3. KMIP Mutual TLS

```bash
# Bắt buộc client cert để gọi KMIP
# Đã cấu hình trong server.conf:
#   client_certificate_required=true
#   client_certificate_issuer=/etc/pykmip/certs/ca/kmip-ca.crt

# Chỉ client có cert ký bởi KMIP CA mới được kết nối
# vCenter dùng vsphere-client.p12 → đã ký bởi KMIP CA
```

### 12.4. Authentication

```bash
# Auth config: /etc/pykmip/auth.conf
# Tạo bằng htpasswd, format:
#   admin:$2y$...hash...
#   vsphere:$2y$...hash...
#   tpm-client:$2y$...hash...

# Passwords:
#   admin:     KMP@dm1n2026!
#   vsphere:   KMPvSpher3@2026!
#   tpm-client: KMPuserP@ss1

# Thay đổi password:
echo "NewP@ssw0rd!" | htpasswd -i /etc/pykmip/auth.conf admin
```

### 12.5. Network Isolation

```bash
# Cách ly KMIP trong VLAN riêng
# Management VLAN:  VLAN 100  (192.168.100.0/24)
# KMIP VLAN:        VLAN 200  (10.0.200.0/24)

# Chỉ cho phép vCenter và ESXi access KMIP port
ufw allow from 192.168.100.99 to any port 5696  # vCenter
ufw allow from 192.168.100.0/24 to any port 5696  # ESXi mgmt
```

---

## 13. Khắc phục sự cố

### 13.1. Service không start

```bash
# Kiểm tra log
journalctl -u pykmip-server -n 50 --no-pager

# Kiểm tra config syntax
python3 -c "
from PyKMIP.server import config
c = config.KMIPConfig()
c.load('/etc/pykmip/server.conf')
print('Config OK')
"

# Kiểm tra port conflict
ss -tlnp | grep 5696

# Fix: port conflict → đổi port khác trong server.conf
```

### 13.2. vCenter không kết nối được KMIP

```bash
# Kiểm tra từ vCenter (qua SSH)
curl -k https://192.168.100.80/health

# Test TCP
nc -zv 192.168.100.80 5696

# Test openssl
openssl s_client -connect 192.168.100.80:5696 -cert /tmp/vsphere-client.crt \
  -key /tmp/vsphere-client.key -CAfile /tmp/kmip-ca.crt

# Log PyKMIP
tail -50 /var/log/pykmip/pykmip-server.log | grep -i error
```

### 13.3. VM không boot với vTPM

```bash
# Nguyên nhân: KMIP server offline khi VM boot
# Fix:
# 1. Restore KMIP server → online
# 2. Trong vCenter: Chọn VM → Actions → Crypto → Retry vTPM
# 3. Nếu vẫn lỗi: Power Off → Edit Settings → Remove vTPM
#    → Power On → Add vTPM lại

# Kiểm tra trạng thái vTPM
# Trong vCenter: VM → Monitor → Security → Virtual TPM
```

### 13.4. Certificate expired

```bash
# Kiểm tra expiration
for cert in /etc/pykmip/certs/*.crt; do
    echo "$cert: $(openssl x509 -checkend 86400 -noout -in $cert && echo 'OK' || echo 'EXPIRING')"
done

# Nếu server cert hết hạn → không renew được → tạo lại toàn bộ
# Nếu client cert hết hạn → tạo lại và import lại vào vCenter
```

### 13.5. Database corrupt

```bash
# SQLite
sqlite3 /var/lib/pykmip/pykmip.db ". integrity_check"
# Nếu lỗi: restore từ backup

# MariaDB
mysqlcheck -u pykmip -p pykmip
# Nếu lỗi: mysqlcheck --repair pykmip
```

---

## 14. Phụ lục

### A. Kiến trúc HA (High Availability)

```
                 ┌───────────────────────┐
                 │   HAProxy / Nginx     │
                 │   Load Balancer       │
                 │   Port 5696           │
                 └────┬─────────┬────────┘
                      │         │
              ┌───────▼──┐  ┌───▼────────┐
              │ PyKMIP   │  │ PyKMIP     │
              │ Node 1   │  │ Node 2     │
              │ .80      │  │ .81        │
              ├──────────┤  ├────────────┤
              │ Active   │  │ Standby    │
              └─────┬────┘  └──────┬─────┘
                    │              │
                    └──────┬───────┘
                           ▼
                 ┌──────────────────┐
                 │  MariaDB Galera  │
                 │  (Shared DB)     │
                 └──────────────────┘
```

Cấu hình HA:

```bash
# Node 1 & 2: cài PyKMIP như nhau
# DB: MariaDB Galera cluster (3 nodes)
# Load balancer: HAProxy mode tcp → backend 2 nodes
# IP: 192.168.100.82 (VIP)
```

### B. Hướng dẫn cập nhật PyKMIP

```bash
# Kiểm tra phiên bản hiện tại
source /opt/pykmip/venv/bin/activate
pip show pykmip
deactivate

# Cập nhật lên phiên bản mới
systemctl stop pykmip-server
source /opt/pykmip/venv/bin/activate
pip install --upgrade pykmip
deactivate
systemctl start pykmip-server

# Kiểm tra sau update
kmip-ctl test
```

### C. Tham khảo

| Tài liệu | URL |
|---|---|
| PyKMIP Documentation | https://pykmip.readthedocs.io/ |
| KMIP OASIS Standard | https://docs.oasis-open.org/kmip/spec/v1.4/ |
| VMware vTPM Guide | https://docs.vmware.com/en/VMware-vSphere/7.0/vsphere-security/doc/GUID-0C6B7F8F-1C5E-4EE5-9E5E-1C7F9C8F0E5E.html |
| VMware Native Key Provider | https://docs.vmware.com/en/VMware-vSphere/7.0/vsphere-security/doc/GUID-0C6B7F8F-1C5E-4EE5-9E5E-1C7F9C8F0E5E.html |
| vSphere 7.0u2 Release Notes | https://docs.vmware.com/en/VMware-vSphere/7.0/rn/vsphere-esxi-70u2-release-notes.html |
| TPM 2.0 Specification | https://trustedcomputinggroup.org/resource/tpm-library-specification/ |

### D. Danh sách file dự án

```
C:\iam.cloud.edu.vn\tpm-pykmip\
├── setup-pykmip.sh           # Script cài đặt tự động (17 bước)
├── README.md                 # File này
└── (sau khi chạy trên Ubuntu)
    /opt/pykmip/
    ├── venv/                 # Python virtual environment
    ├── init-db.py            # Khởi tạo database
    └── test-kmip-client.py   # Test KMIP connection
    /etc/pykmip/
    ├── server.conf           # Cấu hình KMIP server
    ├── auth.conf             # Authentication (htpasswd)
    ├── keys.conf             # Pre-configured keys
    └── certs/
        ├── ca/               # Root CA certificate & key
        ├── kmip-server.*     # Server certificate
        ├── vsphere-client.*  # vSphere KMIP client
        └── tpm-v*.client.*   # TPM version certificates
```

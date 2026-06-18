# Chuẩn bị - Thiết kế - Triển khai Labs NSX 4.x

## Mục lục

1. [Tổng quan về tài liệu](#1-tổng-quan-về-tài-liệu)
2. [Kiến trúc tổng thể Lab NSX 4.x](#2-kiến-trúc-tổng-thể-lab-nsx-4x)
3. [Yêu cầu tài nguyên phần cứng](#3-yêu-cầu-tài-nguyên-phần-cứng)
4. [Thiết kế mạng lớp ngoài (Physical/Outer vSphere)](#4-thiết-kế-mạng-lớp-ngoài-physicalouter-vsphere)
5. [Cấu hình Switch ảo và MAC Learning](#5-cấu-hình-switch-ảo-và-mac-learning)
6. [Tạo và cấu hình Nested ESXi](#6-tạo-và-cấu-hình-nested-esxi)
7. [Triển khai vCenter Server](#7-triển-khai-vcenter-server)
8. [Triển khai NSX Manager 4.x](#8-triển-khai-nsx-manager-4x)
9. [Cấu hình Transport Zones, Uplink Profiles, IP Pools](#9-cấu-hình-transport-zones-uplink-profiles-ip-pools)
10. [Transport Nodes - Host và Edge](#10-transport-nodes---host-và-edge)
11. [Triển khai NSX Edge Cluster và T0/T1 Gateway](#11-triển-khai-nsx-edge-cluster-và-t0t1-gateway)
12. [Nested NSX-T on NSX-T (Nested_nsx flag)](#12-nested-nsx-t-on-nsx-t-nested_nsx-flag)
13. [Cấu hình ENS (Enhanced Network Stack) cho Nested ESXi](#13-cấu-hình-ens-enhanced-network-stack-cho-nested-esxi)
14. [Tự động hóa triển khai Lab](#14-tự-động-hóa-triển-khai-lab)
15. [Checklist kiểm tra và Troubleshooting](#15-checklist-kiểm-tra-và-troubleshooting)
16. [Phụ lục: Tham khảo](#16-phụ-lục-tham-khảo)

---

## 1. Tổng quan về tài liệu

Tài liệu này tổng hợp kiến thức từ các nguồn tham khảo uy tín của cộng đồng VMware, đặc biệt là William Lam (Distinguished Platform Engineering Architect tại Broadcom/VCF Division), để hướng dẫn chi tiết việc **chuẩn bị, thiết kế và triển khai** môi trường Lab NSX 4.x (NSX-T Data Center) trên nền tảng **Nested Virtualization**.

NSX 4.x là thế hệ mới nhất của nền tảng ảo hóa mạng và bảo mật của VMware (Broadcom), cung cấp khả năng:

-   **Virtual Private Cloud (VPC):** Mô hình mạng đơn giản hóa, self-service ngay từ vCenter (VCF 9.0+)
-   **Multi-tenancy:** Phân chia tài nguyên mạng cho nhiều tenant qua NSX Projects
-   **Distributed Firewall & Security:** Bảo mật phân tán ở lớp hypervisor
-   **Load Balancing, VPN, NAT:** Dịch vụ mạng tích hợp
-   **Tích hợp Kubernetes:** NSX Container Plugin (NCP) cho Tanzu/PKS

### Mục tiêu của tài liệu

1.  Hướng dẫn thiết kế kiến trúc Lab NSX 4.x nested trên 1 hoặc nhiều máy chủ vật lý
2.  Cung cấp cấu hình chi tiết từng bước từ hạ tầng vật lý đến NSX Manager
3.  Tổng hợp các kỹ thuật nested virtualization tối ưu (MAC Learning, ENS, nested_nsx flag)
4.  Hướng dẫn tự động hóa triển khai bằng PowerCLI/PowerShell
5.  Checklist kiểm tra và troubleshooting các lỗi thường gặp

---

## 2. Kiến trúc tổng thể Lab NSX 4.x

### 2.1 Mô hình kiến trúc 3 lớp (Three-Tier Architecture)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    LỚP 1: HẠ TẦNG VẬT LÝ (Physical Layer)               │
│                                                                         │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                  │
│   │ Physical     │  │ Physical     │  │ Physical     │   (tối thiểu 1   │
│   │ ESXi Host 1  │  │ ESXi Host 2  │  │ ESXi Host 3  │    host,         │
│   │ (12-16 cores,│  │ (12-16 cores,│  │ (12-16 cores,│    khuyến nghị   │
│   │  64-96GB RAM)│  │  64-96GB RAM)│  │  64-96GB RAM)│    2-3 hosts)    │
│   └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                  │
│          │                 │                 │                          │
│          └─────────────────┴─────────────────┘                          │
│                           │ vDS / vSS                                   │
│                    Port Groups: Management / VM Network / NSX Tunnel    │
└───────────────────────────┬─────────────────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────────────────┐
│                    LỚP 2: NESTED ESXi (Virtualization Layer)            │
│                                                                         │
│   ┌──────────────────────────────────────────────────────────────┐      │
│   │              Cluster: PKS-Lab (Compute Cluster)              │      │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐                    │      │
│   │  │ Nested   │  │ Nested   │  │ Nested   │  (tối thiểu 3)     │      │
│   │  │ ESXi-1   │  │ ESXi-2   │  │ ESXi-3   │                    │      │
│   │  │ 4 vCPU   │  │ 4 vCPU   │  │ 4 vCPU   │                    │      │
│   │  │ 12-16GB  │  │ 12-16GB  │  │ 12-16GB  │                    │      │
│   │  │ RAM      │  │ RAM      │  │ RAM      │                    │      │
│   │  └────┬─────┘  └────┬─────┘  └────┬─────┘                    │      │
│   │       │             │             │                          │      │
│   │       └─────────────┴─────────────┘                          │      │
│   │               vmk0: Management                               │      │
│   │               vmk10: VTEP (Tunnel Endpoint)                  │      │
│   │               vmk50: Hyperbus (NSX Control)                  │      │
│   └──────────────────────────────────────────────────────────────┘      │
│                                                                         │
│   ┌──────────────────────────────────────────────────────────────┐      │
│   │              Cluster: Management Cluster                     │      │
│   │  ┌──────────┐  ┌──────────┐                                  │      │
│   │  │ Nested   │  │  Edge    │  (các VM quản lý)                │      │
│   │  │ vCenter  │  │  Node    │                                  │      │
│   │  │ NSX Mgr  │  │  8vCPU   │                                  │      │
│   │  │ ...      │  │  16GB    │                                  │      │
│   │  └──────────┘  └──────────┘                                  │      │
│   └──────────────────────────────────────────────────────────────┘      │
└───────────────────────────┬─────────────────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────────────────┐
│                    LỚP 3: NSX OVERLAY (Network Virtualization Layer)    │
│                                                                         │
│   ┌───────────────────────────────────────────────┐                     │
│   │        Transport Zone: Overlay (TZ-Overlay)   │                     │
│   │  ┌───────────────┐  ┌──────────────┐          │                     │
│   │  │ Geneve Tunnel │  │ Geneve Tunnel│          │                     │
│   │  │ giữa các Host │  │ tới Edge Node│          │                     │
│   │  └───────────────┘  └──────────────┘          │                     │
│   ├───────────────────────────────────────────────┤                     │
│   │        Transport Zone: VLAN (TZ-VLAN)         │                     │
│   │         Kết nối ra physical network           │                     │
│   ├───────────────────────────────────────────────┤                     │
│   │  ┌───────────┐  ┌───────────┐  ┌──────────┐   │                     │
│   │  │ T0-Gateway│  │ T1-Gateway│  │Segments  │   │                     │
│   │  │ (BGP/     │  │ (K8s Mgmt)│  │(Logical  │   │                     │
│   │  │ Static)   │  │           │  │Switches) │   │                     │
│   │  └───────────┘  └───────────┘  └──────────┘   │                     │
│   └───────────────────────────────────────────────┘                     │
└─────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Các thành phần chính của Lab

| Thành phần | Số lượng | Vai trò |
|------------|----------|---------|
| Physical ESXi Host(s) | 1-3 | Hạ tầng nền tảng chạy tất cả VM nested |
| Nested ESXi Hosts | 3 | Compute cluster cho NSX Transport Nodes |
| vCenter Server Appliance | 1 | Quản lý tập trung các ESXi host |
| NSX Manager | 1 | Controller plane cho NSX |
| NSX Edge Node (Large) | 1-2 | Data plane, T0/T1 Gateway, LB, NAT |
| Router ảo (pfSense/VyOS) | 1 | Định tuyến giữa các VLAN, BGP peer |
| DNS/NTP Server | 1 | Dịch vụ phân giải tên và đồng bộ thời gian |

---

## 3. Yêu cầu tài nguyên phần cứng

### 3.1 Cấu hình tối thiểu (1 máy chủ vật lý)

Nếu triển khai tất cả trên 1 máy chủ vật lý duy nhất:

| Thành phần | Yêu cầu tối thiểu | Khuyến nghị |
|------------|-------------------|-------------|
| CPU | 12 cores (Intel Skylake/AMD EPYC trở lên) | 16-20 cores |
| RAM | 64 GB | 96-128 GB |
| Storage | 500 GB SSD/NVMe | 1 TB+ NVMe |
| Network | 1 GbE | 10 GbE |

### 3.2 Phân bổ tài nguyên chi tiết

| VM | vCPU | RAM (GB) | Disk (GB) | Số lượng |
|----|------|----------|-----------|----------|
| Nested ESXi host | 4 | 12-16 | 50 (OS) + 100 (data) | 3 |
| vCenter Server | 4 | 12 | 300 | 1 |
| NSX Manager | 4 | 12-16 | 200 | 1 |
| NSX Edge (Large) | 8 | 16 | 200 | 1-2 |
| DNS/NTP | 1 | 1 | 20 | 1 |
| Router ảo (pfSense) | 1 | 2 | 10 | 1 |
| **Tổng cộng** | **~32** | **~80-96** | **~700-900** | |

> **Lưu ý quan trọng:** NSX Edge bắt buộc phải dùng **large** deployment size (8 vCPU, 16 GB RAM) khi tích hợp với PKS/Tanzu. Edge nhỏ hơn sẽ gây lỗi NSX-T Validation errand. Tuy nhiên nếu chỉ học NSX thuần túy (không PKS) thì có thể dùng medium (4 vCPU, 8 GB RAM).

### 3.3 Yêu cầu ổ cứng

-   Sử dụng Thin Provision để tiết kiệm dung lượng
-   Nested ESXi cần ít nhất 2 ổ đĩa: 1 ổ OS (50GB) + 1 ổ data (100GB+)
-   Nếu dùng vSAN nested: cần thêm 1 ổ caching (4GB) và 1 ổ capacity (60GB) mỗi host
-   Shared storage có thể dùng iSCSI target từ VM Linux

---

## 4. Thiết kế mạng lớp ngoài (Physical/Outer vSphere)

### 4.1 Quy hoạch VLAN và IP

Đây là bước quan trọng nhất. Cần quy hoạch VLAN và dải IP trước khi triển khai.

| Tên mạng | VLAN ID | Dải IP Ví dụ | CIDR | Gateway | Ghi chú |
|----------|---------|--------------|------|---------|---------|
| Management | 10 (native) | 192.168.10.0/24 | /24 | 192.168.10.1 | vCenter, NSX Manager, ESXi VMkernel |
| vMotion | 20 | 192.168.20.0/24 | /24 | 192.168.20.1 | Di chuyển VM giữa các host |
| Storage (VLAN) | 30 | 192.168.30.0/24 | /24 | 192.168.30.1 | iSCSI/NFS storage |
| Host TEP (VTEP) | 40 | 192.168.40.0/24 | /24 | 192.168.40.1 | Overlay tunnel - ESXi hosts |
| Edge TEP | 41 | 192.168.41.0/24 | /24 | 192.168.41.1 | Overlay tunnel - Edge Nodes |
| Uplink External | 50 | 192.168.50.0/24 | /24 | 192.168.50.1 | Kết nối T0 ra Router vật lý |
| VM Network ( Tenant) | 100 | 10.10.0.0/16 | /16 | - | Mạng cho workload tenant |

> **Ghi chú:** VTEP network yêu cầu **MTU >= 1600** (khuyến nghị 9000 Jumbo Frames). Nếu không có Jumbo Frames ở switch vật lý, các gói tin Geneve (có kích thước ~1550 bytes) sẽ bị phân mảnh gây mất gói.

### 4.2 Mô hình mạng cho Nested ESXi

Mỗi Nested ESXi VM cần ít nhất **4 vNICs**:

```
Nested ESXi VM
┌─────────────────────────────────┐
│ vNIC 1: Management VLAN         │ → Quản lý, vMotion, Storage
│ vNIC 2: Management VLAN         │ → Dự phòng (optional)
│ vNIC 3: NSX Tunnel (VLAN 0/40)  │ → VTEP traffic (Overlay)
│ vNIC 4: NSX Tunnel (VLAN 0/40)  │ → Dự phòng (optional)
└─────────────────────────────────┘
```

> **Lưu ý:** vNIC 3 và 4 **không gán Port Group** ở vSwitch của ESXi con. Các card này sẽ được NSX quản lý trực tiếp qua N-DVS sau khi host được prep làm Transport Node.

### 4.3 Router ảo (pfSense / VyOS)

Cần 1 Router ảo để:
1.  Định tuyến giữa các VLAN
2.  Làm BGP peer cho NSX T0 Gateway
3.  NAT ra internet cho các VM trong lab
4.  Cung cấp DHCP/DNS relay

Cấu hình tối thiểu cho Router ảo:
-   1 vCPU, 1-2 GB RAM
-   2 vNICs: 1 WAN (ra internet), 1 LAN (quản lý các VLAN nội bộ)
-   BGP ASN: 65000 (cho Router vật lý), NSX T0 dùng ASN 65001+

---

## 5. Cấu hình Switch ảo và MAC Learning

### 5.1 Vấn đề với Promiscuous Mode

Khi chạy Nested ESXi, switch lớp ngoài (vSS/vDS) cần xử lý các địa chỉ MAC ảo bên trong nested host. Phương pháp truyền thống là bật **Promiscuous Mode** trên Port Group, nhưng điều này gây tốn CPU và giảm hiệu năng mạng.

### 5.2 Giải pháp: MAC Learning (Khuyến nghị)

**Với VDS (vSphere Distributed Switch) từ vSphere 6.7 trở lên:**

MAC Learning là tính năng native trên VDS, cho phép switch học địa chỉ MAC ảo mà không cần Promiscuous Mode. Đây là giải pháp khuyến nghị cho tất cả lab nested.

```
Cấu hình MAC Learning trên VDS:
1.  Vào vCenter → Networking → Chọn VDS
2.  Action → Settings → Edit Port Settings
3.  Chọn Port Group chứa Nested ESXi
4.  Policy → MAC Learning → Enable
5.  Bật "MAC Learning Enabled" và "Forged Transmits" = Accept
```

**Với VSS (vSphere Standard Switch):**

Dùng **ESXi MAC Learn dvFilter Fling** của William Lam:
-   Tải từ VMware Flings
-   Cài VIB lên physical ESXi host
-   Thêm tham số advanced setting cho VM nested: `ethernet0.filter1.name = "maclearn"`

### 5.3 MAC Learning trong NSX-T (cho Nested trên nền NSX-T)

Khi chạy Nested ESXi trên nền NSX-T (physical NSX-T chạy bên dưới), MAC Learning được cấu hình trong **NSX-T Manager** thay vì vCenter:

```
Cấu hình Segment Profile với MAC Learning:
1.  NSX Manager → Segments → Segment Profiles
2.  Tab MAC Discovery → Add Segment Profile
3.  Bật "MAC Learning Enabled"
4.  Áp dụng profile này cho Segment chứa Nested ESXi VMs
```

### 5.4 So sánh các phương pháp

| Phương pháp | Yêu cầu | Hiệu năng | Độ phức tạp | Khuyến nghị |
|-------------|---------|-----------|-------------|-------------|
| Promiscuous Mode | Tất cả | Thấp (CPU tốn kém) | Thấp | Chỉ dùng tạm thời |
| MAC Learn dvFilter | VSS, ESXi 6.x | Cao | Trung bình | Không còn cần thiết |
| VDS MAC Learning | vSphere 6.7+ | Cao | Thấp | **Khuyến nghị** |
| NSX-T MAC Learning | NSX-T | Cao | Trung bình | Cho NSX-on-NSX |

### 5.5 Tổng hợp cấu hình Switch ảo lớp ngoài

Dù chọn phương pháp nào, cần đảm bảo các thiết lập sau trên Port Group chứa Nested ESXi:

| Thiết lập | Giá trị | Ghi chú |
|-----------|---------|---------|
| Promiscuous Mode | Accept (hoặc dùng MAC Learning) | Bắt buộc nếu không dùng MAC Learning |
| MAC Changes | Accept | Cho phép nested guest tùy chỉnh MAC |
| Forged Transmits | Accept | Cho phép nested guest gửi gói với MAC khác |
| MTU | 9000 (Jumbo Frames) | Bắt buộc cho Geneve (tối thiểu 1600) |

---

## 6. Tạo và cấu hình Nested ESXi

### 6.1 Chuẩn bị Nested ESXi OVA

Sử dụng **Nested ESXi Virtual Appliance Template** của William Lam:
-   Tải từ: https://williamlam.com/nested-virtualization
-   Phiên bản: ESXi 8.0 (tương thích NSX 4.x)
-   Định dạng: OVA template, cấu hình sẵn

### 6.2 Triển khai bằng OVFTool

Script mẫu triển khai 3 Nested ESXi hosts:

```bash
#!/bin/bash
# Triển khai vesxi-1
ovftool \
  --name=vesxi-1 \
  --X:injectOvfEnv \
  --allowExtraConfig \
  --datastore=datastore-ssd \
  --network="VM Network" \
  --acceptAllEulas \
  --noSSLVerify \
  --diskMode=thin \
  --powerOn \
  --prop:guestinfo.hostname=vesxi-1 \
  --prop:guestinfo.ipaddress=192.168.10.81 \
  --prop:guestinfo.netmask=255.255.255.0 \
  --prop:guestinfo.gateway=192.168.10.1 \
  --prop:guestinfo.dns=192.168.10.10 \
  --prop:guestinfo.domain=lab.local \
  --prop:guestinfo.ntp=pool.ntp.org \
  --prop:guestinfo.password=VMware123! \
  --prop:guestinfo.ssh=True \
  Nested_ESXi8.0_Appliance_Template_v1.0.ova \
  vi://admin@vcenter.lab.local:password@vcenter.lab.local/?ip=192.168.10.10

# Triển khai vesxi-2 (tương tự, IP khác)
# Triển khai vesxi-3 (tương tự, IP khác)
```

### 6.3 Cấu hình vNICs cho mỗi Nested ESXi VM

Sau khi triển khai, thêm 2 vNICs bổ sung cho mỗi Nested ESXi:

| vNIC | Port Group | Mục đích |
|------|------------|----------|
| Network Adapter 1 | VM Network / Management | Management traffic (vmk0) |
| Network Adapter 2 | VM Network / Management | vMotion / Storage |
| Network Adapter 3 | NSX Tunnel | VTEP Overlay (vmk10) |
| Network Adapter 4 | NSX Tunnel | VTEP dự phòng |

> **Quan trọng:** vNIC 3 và 4 không được gán vào bất kỳ Port Group nào từ menu network của VM trong vCenter. Các card này sẽ được NSX Manager gán trực tiếp vào N-DVS sau khi host được prep.

### 6.4 Kích hoạt Hardware Virtualization (VHV)

Mỗi Nested ESXi VM **bắt buộc** phải bật:
```
CPU → Hardware Virtualization: Expose hardware assisted virtualization to the guest OS
```
(Là dấu tick vào ô "Expose hardware assisted virtualization to the guest OS")

### 6.5 Cấu hình iSCSI Shared Storage (tùy chọn - thay thế vSAN)

Nếu không dùng vSAN cho nested cluster, cần shared storage. Cách đơn giản:

1.  Tạo 1 VM Linux (CentOS/Ubuntu) làm iSCSI target
2.  Cấu hình LIO (LinuxIO) target:
```bash
# Trên VM iSCSI target
yum install targetcli -y
targetcli
/> backstores/fileio create disk1 /iscsi/disk1.img 100G
/> /iscsi create iqn.2025-08.lab:storage
/> /iscsi/iqn.2025-08.lab:storage/tpg1/luns create /backstores/fileio/disk1
/> /iscsi/iqn.2025-08.lab:storage/tpg1/acls create iqn.1998-01.com.vmware:vesxi-1
/> /iscsi/iqn.2025-08.lab:storage/tpg1/acls create iqn.1998-01.com.vmware:vesxi-2
/> /iscsi/iqn.2025-08.lab:storage/tpg1/acls create iqn.1998-01.com.vmware:vesxi-3
/> saveconfig
```

3.  Trên mỗi Nested ESXi, cấu hình Software iSCSI Adapter nhận diện LUN

### 6.6 Tham số kernel cho Nested ESXi

Tối ưu hiệu năng cho nested:

```
# Trên mỗi Nested ESXi host
esxcli system settings advanced set -o /Net/FollowHardwareMac -i 1
esxcli system settings advanced set -o /UserVars/SuppressShellWarning -i 1
```

---

## 7. Triển khai vCenter Server

### 7.1 Chuẩn bị

-   OVA: VMware-vCenter-Server-Appliance-8.0.x.ova
-   DNS: Cần record A và PTR cho vCenter FQDN
-   NTP: Đồng bộ thời gian (NSX cực kỳ khắt khe về thời gian)

### 7.2 Cấu hình DNS

```bind
; Forward zone
vcenter.lab.local.  IN A 192.168.10.20
nsx-mgr.lab.local.  IN A 192.168.10.30
nsx-edge1.lab.local. IN A 192.168.10.50
nsx-edge2.lab.local. IN A 192.168.10.51
vesxi-1.lab.local.  IN A 192.168.10.81
vesxi-2.lab.local.  IN A 192.168.10.82
vesxi-3.lab.local.  IN A 192.168.10.83

; Reverse zone
20.10.168.192.in-addr.arpa. IN PTR vcenter.lab.local.
```

### 7.3 Triển khai VCSA

Sử dụng CLI installer:
```bash
cd /path/to/vcsa-cli-installer/lin64
./vcsa-deploy install \
  --accept-eula \
  --acknowledge-ceip \
  vcsa.json
```

File JSON mẫu `vcsa.json`:
```json
{
  "deployment": {
    "network": {
      "ip_family": "ipv4",
      "mode": "static",
      "system_name": "vcenter.lab.local",
      "ip": "192.168.10.20",
      "prefix": "24",
      "gateway": "192.168.10.1",
      "dns_servers": ["192.168.10.10"],
      "dns_suffixes": ["lab.local"]
    },
    "appliance": {
      "deployment_option": "medium",
      "name": "vcenter"
    },
    "sso": {
      "sso_domain": "lab.local",
      "sso_password": "VMware123!",
      "sso_username": "administrator"
    }
  }
}
```

---

## 8. Triển khai NSX Manager 4.x

### 8.1 Yêu cầu tiên quyết

-   vCenter đã hoạt động và quản lý được các Nested ESXi host
-   DNS forward/reverse resolution hoạt động
-   NTP đồng bộ trên tất cả hosts
-   Time synchronization giữa vCenter, ESXi và NSX Manager (**quan trọng**)

### 8.2 Triển khai NSX Manager bằng OVFTool

```bash
ovftool \
  --name=nsx-manager \
  --X:injectOvfEnv \
  --allowExtraConfig \
  --datastore=datastore-ssd \
  --network="VM Network" \
  --acceptAllEulas \
  --noSSLVerify \
  --diskMode=thin \
  --powerOn \
  --prop:nsx_role=nsx-manager \
  --prop:nsx_ip_0=192.168.10.30 \
  --prop:nsx_netmask_0=255.255.255.0 \
  --prop:nsx_gateway_0=192.168.10.1 \
  --prop:nsx_dns1_0=192.168.10.10 \
  --prop:nsx_domain_0=lab.local \
  --prop:nsx_ntp_0=pool.ntp.org \
  --prop:nsx_isSSHEnabled=True \
  --prop:nsx_allowSSHRootLogin=True \
  --prop:nsx_passwd_0=VMware123! \
  --prop:nsx_cli_passwd_0=VMware123! \
  --prop:nsx_hostname=nsx-manager \
  nsx-unified-appliance-4.x.x.ova \
  vi://administrator@vsphere.local:password@vcenter.lab.local/?ip=192.168.10.20
```

### 8.3 Cấu hình NSX Manager sau triển khai

1.  **Truy cập:** https://nsx-manager.lab.local (hoặc IP)
2.  **Login:** admin / VMware123!
3.  **Xác thực License:** Nhập NSX license key
4.  **Đăng ký Compute Manager:**
    -   System → Fabric → Compute Managers → Add
    -   vCenter: vcenter.lab.local
    -   Username: administrator@vsphere.local
    -   Password: VMware123!
5.  **Đồng bộ:** Đợi inventory sync hoàn tất (5-10 phút)

### 8.4 Cluster NSX Manager (tùy chọn)

Đối với production cần 3 node cluster. Với lab, 1 node là đủ.

---

## 9. Cấu hình Transport Zones, Uplink Profiles, IP Pools

### 9.1 Transport Zones

Tạo 2 Transport Zones trong NSX Manager:

**1. Overlay Transport Zone (TZ-Overlay)**
```
Name: TZ-Overlay
Host Switch Name: nsxswitch-overlay
Transport Type: OVERLAY
Nested NSX: FALSE (để FALSE nếu physical NSX, TRUE nếu nested NSX-on-NSX)
```

**2. VLAN Transport Zone (TZ-VLAN)**
```
Name: TZ-VLAN
Host Switch Name: nsxswitch-vlan
Transport Type: VLAN
```

> **Khi chạy Nested NSX-T trên nền NSX-T physical**, cần bật flag `nested_nsx = true` cho Overlay Transport Zone. Chi tiết ở [Mục 12](#12-nested-nsx-t-on-nsx-t-nested_nsx-flag).

### 9.2 Uplink Profiles

**1. Host Uplink Profile (host-uplink)**
```
Name: host-uplink
Teaming Policy: FAILOVER_ORDER
Active Uplinks: vmnic2 (→ NSX Tunnel vNIC của Nested ESXi)
Transport VLAN: 0
MTU: 1600 (hoặc 9000)
```

**2. Edge Uplink Profile (edge-uplink)**
```
Name: edge-uplink
Teaming Policy: FAILOVER_ORDER
Active Uplinks: fp-eth1 (→ VLAN traffic của Edge VM)
Transport VLAN: 0
MTU: 1600 (hoặc 9000)
```

### 9.3 IP Pools

**1. VTEP IP Pool (ESXi Hosts)**
```
Name: Host-VTEP-Pool
IP Range: 192.168.40.10 - 192.168.40.20
CIDR: 192.168.40.0/24
Gateway: 192.168.40.1
DNS: 192.168.10.10
```

**2. VTEP IP Pool (Edge Nodes)**
```
Name: Edge-VTEP-Pool
IP Range: 192.168.41.10 - 192.168.41.20
CIDR: 192.168.41.0/24
Gateway: 192.168.41.1
DNS: 192.168.10.10
```

**3. Load Balancer IP Pool (cho K8s)**
```
Name: LB-IP-Pool
IP Range: 10.20.0.10 - 10.20.0.50
CIDR: 10.20.0.0/24
Gateway: 10.20.0.1
```

### 9.4 IP Blocks (cho VPC)
```
Name: PKS-IP-Block
Network: 172.16.0.0/16
```

---

## 10. Transport Nodes - Host và Edge

### 10.1 Host Transport Nodes (Nested ESXi hosts)

**Cách 1: Configure Cluster (tự động hóa)**
```
1. NSX Manager → Fabric → Nodes → Hosts
2. Chọn Compute Manager (vCenter)
3. Expand cluster chứa Nested ESXi hosts
4. Checkbox ở cấp cluster → Configure Cluster
5. Transport Zone: TZ-Overlay, TZ-VLAN
6. Uplink Profile: host-uplink
7. VTEP IP Pool: Host-VTEP-Pool
8. VLAN: 0
9. Apply
```

**Cách 2: Configure từng host (thủ công)**
```
1. NSX Manager → Fabric → Nodes → Hosts
2. Chọn từng host → Configure NSX
3. Cấu hình tương tự cách 1
```

### 10.2 Kiểm tra Host Transport Node

SSH vào Nested ESXi và kiểm tra:

```bash
# Kiểm tra interface VTEP
esxcli network ip interface ipv4 get
# Output mẫu:
# vmk0   192.168.10.81  255.255.255.0    STATIC
# vmk10  192.168.40.10  255.255.255.0    STATIC (VTEP)
# vmk50  169.254.1.1    255.255.0.0      STATIC (Hyperbus)

# Kiểm tra VDS của NSX
esxcli network ip interface list
# Output mẫu cho vmk10:
# Portset: DvsPortset-1
# Netstack Instance: vxlan
# VDS Name: nsxswitch-overlay
# MTU: 1600

# Ping VTEP của các host khác
vmkping ++netstack=vxlan 192.168.40.11  # sang vesxi-2
vmkping ++netstack=vxlan 192.168.40.12  # sang vesxi-3
vmkping ++netstack=vxlan 192.168.41.10  # sang Edge Node
```

### 10.3 Triển khai NSX Edge Node

```bash
ovftool \
  --name=nsx-edge1 \
  --deploymentOption=large \
  --X:injectOvfEnv \
  --allowExtraConfig \
  --datastore=datastore-ssd \
  --net:"Network 0=VM Network" \
  --net:"Network 1=NSX Tunnel" \
  --net:"Network 2=NSX Tunnel" \
  --net:"Network 3=NSX Tunnel" \
  --acceptAllEulas \
  --noSSLVerify \
  --diskMode=thin \
  --powerOn \
  --prop:nsx_ip_0=192.168.10.50 \
  --prop:nsx_netmask_0=255.255.255.0 \
  --prop:nsx_gateway_0=192.168.10.1 \
  --prop:nsx_dns1_0=192.168.10.10 \
  --prop:nsx_domain_0=lab.local \
  --prop:nsx_ntp_0=pool.ntp.org \
  --prop:nsx_isSSHEnabled=True \
  --prop:nsx_allowSSHRootLogin=True \
  --prop:nsx_passwd_0=VMware123! \
  --prop:nsx_cli_passwd_0=VMware123! \
  --prop:nsx_hostname=nsx-edge1 \
  nsx-edge-4.x.x.ova \
  vi://administrator@vsphere.local:password@vcenter.lab.local/?ip=192.168.10.20
```

> **Quan trọng:** Edge VM bắt buộc để ở **Management Cluster** (cùng với vCenter, NSX Manager), **không phải** Compute Cluster.

**Cấu hình vNICs cho Edge Node:**

| vNIC OVF | Port Group | Mục đích |
|----------|------------|----------|
| Network 0 | VM Network | Management (eth0) |
| Network 1 | NSX Tunnel | Overlay (fp-eth0) |
| Network 2 | NSX Tunnel | Overlay dự phòng |
| Network 3 | NSX Tunnel | VLAN Uplink (fp-eth1) |

### 10.4 Edge Transport Node

Sau khi Edge VM được triển khai:
```
1. NSX Manager → Fabric → Nodes → Edge Transport Nodes → Add
2. Chọn Edge VM vừa triển khai
3. General: Chọn cả 2 Transport Zones
4. N-DVS Overlay (TZ-Overlay):
   - Uplink Profile: edge-uplink
   - VTEP IP Pool: Edge-VTEP-Pool
   - Virtual NIC: fp-eth0 → fp-eth0
5. N-DVS VLAN (TZ-VLAN):
   - Uplink Profile: edge-uplink
   - Virtual NIC: fp-eth1 → fp-eth1
6. Save
```

---

## 11. Triển khai NSX Edge Cluster và T0/T1 Gateway

### 11.1 Tạo Edge Cluster
```
1. NSX Manager → Networking → Edge Clusters → Add
2. Name: Edge-Cluster-01
3. Chọn Edge Node(s) vừa tạo
4. Save
```

### 11.2 Tạo Logical Switches (Segments)

**K8s Mgmt Cluster Segment:**
```
Name: K8S-Mgmt-Cluster-LS
Transport Zone: TZ-Overlay
Replication Mode: MTEP
```

**Uplink Segment:**
```
Name: Uplink-LS
Transport Zone: TZ-VLAN
VLAN: 0 (trunk) hoặc VLAN ID cụ thể
```

### 11.3 Tạo T0 Gateway (với Static Route)

```
1. NSX Manager → Networking → Tier-0 Gateways → Add
2. Name: T0-LR
3. Edge Cluster: Edge-Cluster-01
4. HA Mode: ACTIVE_STANDBY
5. Add Uplink Interface:
   - Name: Uplink-1
   - Segment: Uplink-LS
   - Switch Port Name: Uplink-1-Port
   - IP: 192.168.50.2/24
6. Add Static Route:
   - Network: 0.0.0.0/0
   - Next Hop: 192.168.50.1 (Router vật lý)
```

### 11.4 Tạo T1 Gateway (cho K8s Management)

```
1. NSX Manager → Networking → Tier-1 Gateways → Add
2. Name: T1-K8S-Mgmt
3. Edge Cluster: Edge-Cluster-01
4. HA Mode: ACTIVE_STANDBY
5. Linked Tier-0: T0-LR
6. Add Downlink Interface:
   - Name: Downlink-1
   - Segment: K8S-Mgmt-Cluster-LS
   - IP: 10.10.0.1/24
```

### 11.5 Cấu hình BGP (Tùy chọn thay cho Static Route)

Nếu Router ảo hỗ trợ BGP:
```
1. T0 Gateway → BGP → Enable
2. Local AS: 65001
3. BGP Neighbor: 192.168.50.1 (Router ảo)
4. Remote AS: 65000
5. Password: VMware123!
```

---

## 12. Nested NSX-T on NSX-T (nested_nsx flag)

### 12.1 Kịch bản

Khi bạn chạy **Nested NSX-T** (NSX-T bên trong Nested ESXi) trên nền **Physical NSX-T** (NSX-T chạy trên host vật lý), cần một cấu hình đặc biệt cho Overlay Transport Zone.

### 12.2 Vấn đề

Physical NSX-T mặc định không biết rằng các gói tin Geneve từ nested layer sẽ được bọc thêm một lớp Geneve nữa (Geneve-in-Geneve). Điều này gây ra lỗi kết nối overlay giữa các Nested ESXi transport nodes.

### 12.3 Giải pháp: nested_nsx flag

Flag `nested_nsx` là thuộc tính boolean trên Overlay Transport Zone, báo hiệu cho physical NSX-T rằng các transport nodes được kết nối qua nested NSX.

**Cách 1: Dùng PowerCLI (Khuyến nghị)**
```powershell
Connect-NsxtServer -Server nsx-mgr.lab.local

$transportZoneService = Get-NsxtService -Name "com.vmware.nsx.transport_zones"
$overlayTZSpec = $transportZoneService.help.create.transport_zone.Create()
$overlayTZSpec.display_name = "TZ-Nested-NSX-T"
$overlayTZSpec.host_switch_name = "nsxswitch-nested"
$overlayTZSpec.transport_type = "OVERLAY"
$overlayTZSpec.nested_nsx = "true"
$transportZoneService.create($overlayTZSpec)
```

**Cách 2: Dùng NSX-T REST API**
```bash
curl -k -u 'admin:VMware123!' \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "display_name": "TZ-Nested-NSX-T",
    "host_switch_name": "nsxswitch-nested",
    "transport_type": "OVERLAY",
    "nested_nsx": true
  }' \
  https://nsx-mgr.lab.local/api/v1/transport-zones
```

**Cách 3: Dùng PowerCLI với NSX-T 4.x module**
```powershell
# Nếu dùng NSX-T 4.x, có thể dùng module VMware.VimAutomation.Nsx
Import-Module VMware.VimAutomation.Nsx
Connect-NsxtServer -Server nsx-mgr.lab.local -User admin -Password 'VMware123!'

$tz = New-NsxtTransportZone -Name "TZ-Nested-NSX-T" `
  -HostSwitchName "nsxswitch-nested" `
  -TransportType "OVERLAY" `
  -NestedNsx $true
```

### 12.4 Xác nhận

Sau khi tạo Transport Zone với `nested_nsx=true`, kiểm tra trong NSX Manager UI:
```
Networking → Transport Zones → Chọn TZ vừa tạo → Xem details
```
Cột "Nested NSX" sẽ hiển thị "True".

### 12.5 Lưu ý

-   Flag `nested_nsx` **chỉ cần thiết trên physical NSX-T** (lớp ngoài), không cần ở nested NSX-T (lớp trong)
-   Khi chạy Nested NSX-V hoặc Nested VSS/VDS trên nền NSX-T, **chỉ cần MAC Learning**, không cần flag này
-   Flag chỉ áp dụng cho **Overlay Transport Zone**, không áp dụng cho VLAN Transport Zone

---

## 13. Cấu hình ENS (Enhanced Network Stack) cho Nested ESXi

### 13.1 Giới thiệu

**Enhanced Network Stack (ENS)** còn gọi là Enhanced Data Path, là tính năng NSX-T dành cho **NFV workloads** (Telco, 5G, IoT) yêu cầu high-performance data path.

**Khi nào cần ENS trong Lab:**
-   Lab NFV/Telco/5G workloads
-   Kiểm tra cấu hình ENS trước khi triển khai production
-   **Không cần** cho lab NSX thông thường

### 13.2 Yêu cầu

-   NSX-T 2.3+ (ENS được giới thiệu từ NSX-T 2.3)
-   vSphere 6.7 Update 2+ (native VMXNET3 ENS driver)
-   Nested ESXi VM dùng VMXNET3 vNIC (đã có sẵn trong Nested ESXi OVA template)

### 13.3 Cấu hình

**Bước 1:** Kiểm tra driver hiện tại trên Nested ESXi:
```bash
esxcfg-nics -e
# Output ban đầu:
# vmnic0  ENS Capable: true   ENS Driven: false
```

**Bước 2:** Tạo Transport Zone với host switch type ENS:

*Nếu dùng NSX-T 2.4+ (có UI):*
```
NSX Manager → Networking → Transport Zones → Add
- Name: TZ-VLAN-ENS
- Host Switch Name: vlan-ens-nsxswitch
- Transport Type: VLAN
- Host Switch Mode: ENS
```

*Nếu dùng NSX-T cũ hơn hoặc thích API:*
```powershell
Connect-NsxtServer -Server nsx-mgr.lab.local

$transportZoneService = Get-NsxtService -Name "com.vmware.nsx.transport_zones"
$overlayTZSpec = $transportZoneService.help.create.transport_zone.Create()
$overlayTZSpec.display_name = "TZ-VLAN-ENS"
$overlayTZSpec.host_switch_name = "vlan-ens-nsxswitch"
$overlayTZSpec.transport_type = "VLAN"
$overlayTZSpec.host_switch_mode = "ENS"
$transportZoneService.create($overlayTZSpec)
```

**Bước 3:** Cấu hình Transport Nodes với Transport Zone chứa ENS

**Bước 4:** Kiểm tra driver sau khi prep:
```bash
esxcfg-nics -e
# Output sau khi prep:
# vmnic0  ENS Capable: true   ENS Driven: true
# Driver: nvmxnet3_ens (thay vì nvmxnet3)
```

### 13.4 Lưu ý

-   ENS chỉ cần cho NFV workloads; lab NSX thông thường không cần
-   ENS yêu cầu vNIC VMXNET3 (có sẵn trong Nested ESXi template)
-   Sau khi host được prep với ENS Transport Zone, NSX sẽ tự động claim driver `nvmxnet3_ens`

---

## 14. Tự động hóa triển khai Lab

### 14.1 PowerCLI Script cho VPC Automation (NSX 4.x / VCF 9+)

Module `VMware.VimAutomation.Vpc` cho phép tự động hóa VPC deployment:

```powershell
# 1. Import module và kết nối vCenter
Import-Module VMware.VimAutomation.Vpc
Connect-VIServer -Server vcenter.lab.local -Protocol https -User administrator@vsphere.local -Password VMware123!

# 2. Tạo VPC
New-Vpc -Name Corp-VPC | Out-Null
New-Vpc -Name Shared-SVC-VPC -PrivateIp 192.168.2.0/24 | Out-Null

# 3. Tạo Subnets
New-VpcSubnet -Vpc Corp-VPC -Name Web-Subnet-Public -DhcpMode Server -AccessMode public -IpV4Size 16 -GatewayConnectivity | Out-Null
New-VpcSubnet -Vpc Shared-SVC-VPC -Name App-Subnet-TGW -DhcpMode Server -AccessMode privatetgw -IpV4Size 16 -GatewayConnectivity | Out-Null
New-VpcSubnet -Vpc Shared-SVC-VPC -Name DB-Subnet-Private -DhcpMode Server -AccessMode private -IpV4Size 16 -GatewayConnectivity | Out-Null

# 4. Kết nối VM vào Subnets
Get-NetworkAdapter -VM web-01a -Name "Network adapter 1" | Set-NetworkAdapter -Subnet Web-Subnet-Public -Confirm:$false | Out-Null
Get-NetworkAdapter -VM app-01a -Name "Network adapter 1" | Set-NetworkAdapter -Subnet App-Subnet-TGW -Confirm:$false | Out-Null
Get-NetworkAdapter -VM db-01a -Name "Network adapter 1" | Set-NetworkAdapter -Subnet DB-Subnet-Private -Confirm:$false | Out-Null

# 5. Restart Web VM và gán External IP
Get-VM -Name web-01a | Restart-VM -Confirm:$false | Out-Null
Get-NetworkAdapter -VM app-01a -Name "Network adapter 1" | Set-NetworkAdapter -Subnet App-Subnet-TGW -AutoAssignExternalIp -Confirm:$false | Out-Null
```

### 14.2 PowerCLI Script triển khai toàn bộ Lab NSX-T (William Lam's Script)

Script `vmware-pks-lab-deployment.ps1` của William Lam tự động hóa toàn bộ:
-   Triển khai Nested ESXi hosts
-   Cấu hình vSAN
-   Triển khai NSX Manager, Controller, Edge
-   Tạo Transport Zones, Uplink Profiles, IP Pools
-   Cấu hình Host và Edge Transport Nodes
-   Tạo Logical Switches, T0/T1 Gateways
-   Triển khai Ops Manager, BOSH Director, PKS

Cấu hình trước khi chạy:
```powershell
# vCenter endpoint
$VIServer = "vcenter.lab.local"
$VIUsername = "administrator@vsphere.local"
$VIPassword = "VMware123!"

# Path to OVA files
$NestedESXiApplianceOVA = "C:\OVAs\Nested_ESXi8.0_Appliance_Template_v1.0.ova"
$NSXTManagerOVA = "C:\OVAs\nsx-unified-appliance-4.x.x.ova"
$NSXTEdgeOVA = "C:\OVAs\nsx-edge-4.x.x.ova"

# Network settings
$VirtualSwitchType = "VDS"
$VMNetwork = "VM Network"
$VMDatastore = "datastore-ssd"
$VMNetmask = "255.255.255.0"
$VMGateway = "192.168.10.1"
$VMDNS = "192.168.10.10"
$VMNTP = "pool.ntp.org"
$VMPassword = "VMware1!"
$VMDomain = "lab.local"
```

### 14.3 Script kiểm tra kết nối sau triển khai

```bash
#!/bin/bash
# Kiểm tra kết nối VTEP giữa các host
echo "=== VTEP Connectivity Test ==="
for host in 192.168.40.10 192.168.40.11 192.168.40.12 192.168.41.10; do
  vmkping ++netstack=vxlan -c 2 $host > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "PASS: $host reachable"
  else
    echo "FAIL: $host unreachable"
  fi
done

# Kiểm tra NSX Manager API
echo "=== NSX Manager API Test ==="
curl -k -u admin:VMware123! https://nsx-mgr.lab.local/api/v1/fabric/nodes 2>/dev/null | python -m json.tool | head -20

# Kiểm tra Logical Switches
echo "=== Logical Switches ==="
curl -k -u admin:VMware123! https://nsx-mgr.lab.local/policy/api/v1/infra/segments 2>/dev/null | python -m json.tool | grep display_name

# Kiểm tra Transport Nodes status
echo "=== Transport Node Status ==="
curl -k -u admin:VMware123! "https://nsx-mgr.lab.local/api/v1/transport-nodes" 2>/dev/null | python -c "
import json, sys
data = json.load(sys.stdin)
for node in data.get('results', []):
    print(f'{node[\"display_name\"]}: {node.get(\"node_deployment_info\", {}).get(\"host_node_deployment_info\", {}).get(\"state\", \"UNKNOWN\")}')"
```

---

## 15. Checklist kiểm tra và Troubleshooting

### 15.1 Pre-deployment Checklist

| STT | Hạng mục | Trạng thái | Ghi chú |
|-----|----------|-----------|---------|
| 1 | CPU Hardware Virtualization (VHV) enabled | ☐ | Trên mỗi Nested ESXi VM |
| 2 | MAC Learning hoặc Promiscuous Mode | ☐ | Trên Port Group lớp ngoài |
| 3 | MTU 9000 (tối thiểu 1600) | ☐ | Trên switch vật lý và vDS |
| 4 | DNS forward & reverse resolution | ☐ | Cho tất cả hosts |
| 5 | NTP đồng bộ | ☐ | Giữa tất cả ESXi, vCenter, NSX |
| 6 | NSX Tunnel Port Group | ☐ | Trên physical vDS (VLAN 0) |
| 7 | NSC (Network Security Policy) firewall rules | ☐ | Cho phép traffic giữa các VLAN VTEP |
| 8 | Shared storage ready | ☐ | vSAN hoặc iSCSI |
| 9 | License keys ready | ☐ | NSX, vSphere |
| 10 | OVA/ISO files downloaded | ☐ | NSX, vCenter, ESXi |

### 15.2 Post-deployment Checklist

| STT | Hạng mục | Lệnh kiểm tra | Kết quả mong đợi |
|-----|----------|---------------|------------------|
| 1 | VTEP interface exists | `esxcli network ip interface ipv4 get` | vmk10 có IP từ VTEP pool |
| 2 | VTEP connectivity | `vmkping ++netstack=vxlan <VTEP_IP>` | Ping thành công |
| 3 | Transport Node status | NSX Manager UI → Fabric → Nodes | Status = UP |
| 4 | Logical Switch created | `curl -k -u ... /infra/segments` | Các LS hiển thị |
| 5 | Edge Cluster created | NSX Manager → Networking → Edge Clusters | Status = UP |
| 6 | T0/T1 Gateway status | NSX Manager → Networking → Gateways | Status = SUCCESS |
| 7 | NSX Manager reachable | `curl -k https://nsx-mgr/api/v1/node` | HTTP 200 |
| 8 | Compute Manager sync | NSX Manager → System → Fabric → Compute Managers | Connected |

### 15.3 Troubleshooting các lỗi thường gặp

#### Lỗi 1: Transport Node status DOWN

**Nguyên nhân:**
-   VTEP không có IP (IP pool cạn)
-   MTU không đủ lớn (cần >= 1600)
-   Firewall chặn Geneve traffic (UDP 6081)
-   MAC Learning chưa bật

**Khắc phục:**
```bash
# Kiểm tra MTU
esxcli network ip interface list | grep -A5 vmk10

# Kiểm tra Geneve port
esxcli network ip connection list | grep 6081

# Khởi tạo lại NSX trên host
# Trên NSX Manager: Fabric → Nodes → Hosts → Chọn host → Sync/Re-apply
```

#### Lỗi 2: NSX-T Validation errand thất bại (PKS)

**Nguyên nhân:**
-   Edge Node không đủ lớn (cần Large: 8 vCPU, 16 GB RAM)
-   Errand chưa bật (mặc định OFF)
-   NSX-T không thể giao tiếp với PKS components

**Khắc phục:**
```
1. Kiểm tra Edge VM size (phải là large)
2. Ops Manager → PKS Tile → Errands → NSX-T Validation errand = ON
3. Apply changes
```

#### Lỗi 3: Nested ESXi không ping được VTEP

**Nguyên nhân:**
-   Thiếu MAC Learning hoặc Promiscuous Mode
-   VLAN không đúng
-   Port Group chưa đúng

**Khắc phục:**
```
1. Kiểm tra Port Group của vNIC 3 (phải là NSX Tunnel)
2. Kiểm tra MAC Learning trên VDS hoặc bật Promiscuous Mode
3. Kiểm tra VLAN tagging (VLAN 0 = trunk)
```

#### Lỗi 4: Geneve fragmentation

**Nguyên nhân:** MTU < 1600 trên đường truyền vật lý

**Khắc phục:**
```
1. Tăng MTU lên 9000 trên tất cả switch và vDS
2. Hoặc cấu hình NSX với MTU nhỏ hơn
   (không khuyến nghị, Geneve overhead ~100 bytes)
```

#### Lỗi 5: "1 of 3 post-start scripts failed. Failed Jobs: ncp"

**Nguyên nhân (PKS/K8s):**
-   NSX Container Plugin (NCP) thất bại khi khởi tạo
-   Edge VM chưa đúng size
-   BGP chưa được cấu hình đúng

**Khắc phục:**
```bash
# SSH vào K8s master node
bosh ssh -d <deployment-id> master/0

# Xem log NCP
cat /var/vcap/sys/log/ncp/ncp.log

# Kiểm tra kết nối NSX Manager từ K8s node
curl -k https://nsx-mgr.lab.local
```

#### Lỗi 6: Timeout khi kết nối NSX Manager

**Nguyên nhân:**
-   DNS resolution sai
-   NTP không đồng bộ (clock skew > 5 phút)
-   Firewall chặn port 443

**Khắc phục:**
```bash
# Kiểm tra NTP trên ESXi
esxcli system time get
ntpq -p

# Kiểm tra DNS
nslookup nsx-manager.lab.local

# Kiểm tra connectivity
ping nsx-manager.lab.local
```

---

## 16. Phụ lục: Tham khảo

### 16.1 Tài liệu tham khảo chính

| STT | URL | Mô tả |
|-----|-----|-------|
| 1 | https://github.com/PhDLeToanThang/automation/issues/38 | Chuẩn bị hạ tầng labs nested NSX V4X |
| 2 | https://github.com/navinrio/the-noobs-guide-to-nsxt-pks | Noob's Guide to NSX-T/PKS Home Lab |
| 3 | https://williamlam.com/2019/11/running-nested-esxi-nsx-v-or-nsx-t-on-top-of-nsx-t.html | Running Nested ESXi/NSX on NSX-T (MAC Learning & nested_nsx) |
| 4 | https://williamlam.com/2019/12/configure-nsx-t-enhanced-data-path-network-stack-ens-for-nested-esxi.html | Cấu hình ENS cho Nested ESXi |
| 5 | https://williamlam.com/2014/09/does-the-esxi-mac-learn-dvfilter-work-with-nested-esxi-on-nsx-vxlans.html | MAC Learn dvFilter với NSX VXLAN |
| 6 | https://github.com/lamw/vmware-pks-automated-lab-deployment | Automated PKS Lab Deployment Script |

### 16.2 Các blog/guide bổ sung

| URL | Mô tả |
|-----|-------|
| https://rutgerblom.com/2019/02/20/nsx-t-lab-part-1/ | NSX-T Lab Part 1 - Nested ESXi setup |
| https://vxsan.com/posts/building-a-nsx-t-nested-lab/ | Building NSX-T Nested Lab |
| https://vdives.com/2019/06/19/nsx-t-lab-setup/ | NSX-T Lab Setup |
| https://shuttletitan.com/nsx-t/nsx-t-installation-series/ | NSX-T Installation Series |
| https://adrian.heissler.at/2022/01/vmware-home-lab-nsx-t-setup/ | VMware Home Lab NSX-T Setup |
| https://iwanhoogendoorn.nl/index.php/NSX-T_(nested)_Lab_with_(3)_different_sites | NSX-T Nested Lab with 3 sites |
| https://evren-baycan.medium.com/vsphere-with-tanzu-lab-environment-installation-step-by-step | vSphere with Tanzu Lab |

### 16.3 Các cmdlet PowerCLI hữu ích

```powershell
# Kết nối NSX-T Manager
Connect-NsxtServer -Server nsx-mgr.lab.local -User admin -Password 'VMware123!'

# Liệt kê Transport Zones
Get-NsxtTransportZone

# Tạo Transport Zone với nested_nsx flag
$tzService = Get-NsxtService -Name "com.vmware.nsx.transport_zones"
$tzSpec = $tzService.help.create.transport_zone.Create()
$tzSpec.display_name = "TZ-Nested-NSX"
$tzSpec.host_switch_name = "nsxswitch"
$tzSpec.transport_type = "OVERLAY"
$tzSpec.nested_nsx = $true
$tzService.create($tzSpec)

# Liệt kê Transport Nodes
Get-NsxtTransportNode

# Liệt kê Logical Switches (Segments)
Get-NsxtSegment

# Tạo Segment Profile với MAC Learning
$profileService = Get-NsxtService -Name "com.vmware.nsx.policy.api.v1.infra.segment_mac_discovery_profiles"
$profileSpec = $profileService.help.create.Create()
$profileSpec.display_name = "MAC-Learning-Profile"
$profileSpec.mac_learning_enabled = $true
$profileService.create($profileSpec)
```

### 16.4 Các port và protocol NSX-T

| Protocol | Port | Mục đích |
|----------|------|----------|
| UDP | 6081 | Geneve (Overlay) |
| TCP | 443 | NSX Manager API/UI |
| TCP | 22 | SSH (troubleshooting) |
| TCP | 123 | NTP |
| TCP | 53 | DNS |
| ICMP | - | Ping / Kiểm tra kết nối |
| TCP | 80 | HTTP redirect to HTTPS |

---

## Phiên bản tài liệu

| Ngày | Phiên bản | Tác giả | Mô tả thay đổi |
|------|-----------|---------|----------------|
| 18/06/2026 | 1.0 | AI Assistant | Tổng hợp từ các nguồn tham khảo và tài liệu HOL |

---

> **Tài liệu tham khảo chính:** https://github.com/PhDLeToanThang/automation/issues/38, https://github.com/navinrio/the-noobs-guide-to-nsxt-pks, https://williamlam.com, https://github.com/lamw/vmware-pks-automated-lab-deployment

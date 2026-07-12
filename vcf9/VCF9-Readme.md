# VMware Cloud Foundation 9.0 - Hướng Dẫn Thiết Kế

> **Nguồn tài liệu:** Chương 2 - VMware Cloud Foundation 9.0 Design  
> **File PDF gốc:** `D:\Documents\PrivateCloud\MOOC\VMware Training\VCF9-AO\ebooks\Chapter2_VMware-Cloud-Foundation-9-0_Design.pdf`  
> **Tài liệu chính thức:** https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0/design.html  
> **Ngày tổng hợp:** 07/2026

---

## Mục Lục

1. [Tổng Quan VMware Cloud Foundation 9.0](#1-tổng-quan-vmware-cloud-foundation-90)
2. [Mục Tiêu và Mục Đích](#2-mục-tiêu-và-mục-đích)
3. [Kiến Trúc Hệ Thống VCF 9.0](#3-kiến-trúc-hệ-thống-vcf-90)
4. [Các Thành Phần Cốt Lõi](#4-các-thành-phần-cốt-lõi)
5. [Design Blueprints](#5-design-blueprints)
6. [Design Library - Thiết Kế Chi Tiết](#6-design-library---thiết-kế-chi-tiết)
7. [Tính Năng và Chức Năng](#7-tính-năng-và-chức-năng)
8. [Lợi Ích Thực Tế](#8-lợi-ích-thực-tế)
9. [VCF Planning Workbook](#9-vcf-planning-workbook)
10. [Sơ Đồ ASCII Kiến Trúc](#10-sơ-đồ-ascii-kiến-trúc)
11. [Tài Liệu Tham Khảo](#11-tài-liệu-tham-khảo)

---

## 1. Tổng Quan VMware Cloud Foundation 9.0

### 1.1 VCF Là Gì?

**VMware Cloud Foundation (VCF)** là nền tảng **cloud riêng tư (Private Cloud)** cung cấp quy mô và tính năng công khai với bảo mật, phục hồi và hiệu suất tại chỗ, đồng thời **giảm chi phí tổng thể sở hữu (TCO)**.

![VCF Architecture Overview](https://techdocs.broadcom.com/content/broadcom/techdocs/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0/_jcr_content/assetversioncopies/1bc737f1-b622-49ec-9b1b-d7e29b86460c.original.svg)

### 1.2 Điểm Nổi Bật VCF 9.0

| # | Điểm Nổi Bật | Mô Tả |
|---|-------------|-------|
| 1 | **Full-stack IaaS** | Software-defined tính toán, lưu trữ, mạng, bảo mật và quản lý |
| 2 | **Self-Service Platform** | Tự động hóa triển khai VM và container cho developer |
| 3 | **Built-in Resilience** | Phục hồi, mở rộng và phân cụm cho hoạt động liên tục |
| 4 | **Cloud Agility** | Mở rộng cơ sở hạ tầng mà không cần mở rộng nhân sự |
| 5 | **Day 0/1/2 Automation** | Đơn giản hóa các tác vụ sử dụng, vận hành và bảo trì |
| 6 | **Multi-Workload** | Hỗ trợ VM, container, Kubernetes, AI/ML |

### 1.3 VCF vs vSphere Foundation

| Tiêu Chí | VCF 9.0 | vSphere Foundation |
|----------|---------|-------------------|
| **Phạm vi** | Full-stack private cloud | Nền tảng ảo hóa |
| **Quản lý** | Fleet Management (nhiều Instance) | vCenter đơn lẻ |
| **Tự động hóa** | VCF Automation (IaaS) | Cơ bản |
| **Networking** | NSX đầy đủ | NSX cơ bản |
| **Mục đích** | Enterprise cloud platform | Virtualization platform |

---

## 2. Mục Tiêu và Mục Đích

### 2.1 Mục Tiêu Chính

```
+===========================================================================+
|                    MỤC TIÊU VCF 9.0                                       |
+===========================================================================+
|                                                                           |
|   [1] HÓA TẠN SỐ            [2] CLOUD THỐNG NHẤT                        |
|       Tăng tốc hiện đại hóa       Trải nghiệm cloud riêng tư            |
|       cơ sở hạ tầng               thống nhất mọi môi trường             |
|                                                                           |
|   [3] BẢO MẬT & PHỤC HỘI     [4] HỖ TRỢ WORKLOAD HIỆN ĐẠI            |
|       Nền tảng vững chắc về        VM, Container, AI/ML,                |
|       cybersecurity                 Kubernetes                          |
|                                                                           |
+===========================================================================+
```

### 2.2 Mục Đích Sử Dụng

| Mục Đích | Giải Thích |
|----------|------------|
| **Xây Dựng Private Cloud** | Triển khai nền tảng cloud riêng tư đầy đủ khả năng |
| **Hiện Đại Hóa Infra** | Chuyển đổi từ mô hình truyền thống sang software-defined |
| **Self-Service IaaS** | Cho phép developer tự quản lý tài nguyên |
| **Quản Lý Chu Kỳ Sống** | Tự động hóa Day 0, Day 1, Day 2 operations |
| **Mở Rộng Linh Hoạt** | Thêm tài nguyên, domain, instance theo nhu cầu |
| **Disaster Recovery** | Phục hồi khi có sự cố, đảm bảo business continuity |

---

## 3. Kiến Trúc Hệ Thống VCF 9.0

### 3.1 VCF Taxonomy - Cấu Trúc Logic

VCF 9.0 giới thiệu 3 cấp độ logic: **Fleet > Instance > Domain**

![VCF Taxonomy](https://techdocs.broadcom.com/content/broadcom/techdocs/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0/_jcr_content/assetversioncopies/8e4db722-a16d-4a51-ab59-442828d317a4.original.svg)

| Cấp Độ | Mô Tả | Thành Phần |
|--------|-------|------------|
| **VCF Fleet** | Mức quản lý cao nhất, quản lý bởi VCF Operations & VCF Automation | 1+ VCF Instance, VCF Operations, VCF Automation |
| **VCF Instance** | Cơ sở hạ tầng tính toán, lưu trữ, mạng chạy business workloads | Management Domain + Workload Domain(s) |
| **VCF Domain** | Đơn vị công nghệ riêng biệt với vCenter và cluster riêng | vCenter, vSphere Cluster, NSX Manager, Storage |

### 3.2 Các Loại VCF Domain

| Loại Domain | Mô Tả |
|-------------|-------|
| **Management Domain** | Tạo trong quá trình deploy/converge, chứa thành phần quản lý (SDDC Manager, vCenter, NSX Manager) |
| **Workload Domain** | Tạo trong VCF Operations để chạy workload của người dùng (có vCenter, NSX riêng) |

### 3.3 Các Mô Hình Phương Án Kiến Trúc

```
+===========================================================================+
|           CÁC MÔ HÌNH PHƯƠNG ÁN KIẾN TRÚC VCF 9.0                       |
+===========================================================================+
|                                                                           |
|  [1] SINGLE SITE - MINIMAL        [2] SINGLE SITE - FULL HA             |
|      +----------+                      +----------+                       |
|      | Site A   |                      | Site A   |                       |
|      | [MGMT]   |                      | [MGMT]   |                       |
|      | [WD]     |                      | [WD1]    |                       |
|      +----------+                      | [WD2]    |                       |
|      Mô hình nhỏ, nhanh              +----------+                       |
|                                        Mô hình đầy đủ HA                 |
|                                                                           |
|  [3] MULTI-SITE - SINGLE REGION    [4] MULTI-SITE - MULTI REGION        |
|      +--------+ +--------+            +--------+    +--------+           |
|      |Site A  | |Site B  |            |Site A  |    |Site B  |           |
|      |[MGMT]  |<=>[Stand]|            |[MGMT]  |--->|[DR]   |           |
|      +--------+ +--------+            +--------+    +--------+           |
|      Stretched Cluster                Async Replication                   |
|                                                                           |
|  [5] SINGLE REGION + ADDITIONAL REGION(S)                                |
|      +--------+ +--------+     +--------+                                |
|      |Site A  | |Site B  |     |Site C  |                                |
|      |[MGMT]  |<=>[WD]   |     |[DR]    |                                |
|      +--------+ +--------+     +--------+                                |
|      Kết hợp Stretched Cluster + DR                                       |
+===========================================================================+
```

---

## 4. Các Thành Phần Cốt Lõi

### 4.1 Thành Phần Phần Mềm

```
+===========================================================================+
|                    THÀNH PHẦN VCF 9.0                                     |
+===========================================================================+
|                                                                           |
|  +------------------+  +------------------+  +------------------+        |
|  |    vSPHERE       |  |     vSAN         |  |      NSX         |        |
|  |                  |  |                  |  |                  |        |
|  |  - Virtualization|  |  - Software-     |  |  - Software-     |        |
|  |  - ESX Hosts     |  |    Defined       |  |    Defined       |        |
|  |  - vCenter       |  |    Storage       |  |    Networking    |        |
|  |  - DRS / HA      |  |  - vSAN ESA      |  |  - Micro-Seg     |        |
|  |  - vMotion       |  |  - Dedup/Compress|  |  - VPC           |        |
|  +------------------+  +------------------+  +------------------+        |
|                                                                           |
|  +------------------+  +------------------+                               |
|  | VCF OPERATIONS   |  | VCF AUTOMATION   |                               |
|  |                  |  |                  |                               |
|  |  - Fleet Mgmt    |  |  - Self-Service  |                               |
|  |  - Monitoring    |  |  - IaaS          |                               |
|  |  - Logging       |  |  - Kubernetes    |                               |
|  |  - Cost Mgmt     |  |  - Governance    |                               |
|  |  - Lifecycle     |  |  - Provisioning  |                               |
|  +------------------+  +------------------+                               |
+===========================================================================+
```

### 4.2 Mô Tả Chi Tiết Từng Thành Phần

| Thành Phần | Chức Năng Chính |
|------------|-----------------|
| **vSphere** | Ảo hóa tài nguyên phần mềm - CPU, lưu trữ, mạng; hỗ trợ DRS, HA, vMotion |
| **vSAN** | Ứng dụng lưu trữ định nghĩa phần mềm (SDS); vSAN ESA tối ưu cho all-flash |
| **NSX** | Mạng định nghĩa phần mềm, bảo mật tầng mạng, micro-segmentation, VPC |
| **VCF Operations** | Trung tâm quản lý fleet - giám sát, báo cáo, quản lý chu kỳ sống, certificate |
| **VCF Automation** | Nền tảng tự dịch vụ - provisioning IaaS, Kubernetes, policy-based governance |

---

## 5. Design Blueprints

VCF 9.0 cung cấp **5 Design Blueprints** sẵn sàng sử dụng, mỗi blueprint phù hợp với yêu cầu kinh doanh khác nhau.

### 5.1 Tổng Quan 5 Blueprints

| # | Blueprint | Phù Hợp Cho | Số Site | Availability |
|---|-----------|-------------|---------|--------------|
| 1 | Single Site - Minimal Footprint | Lab, PoC, nhỏ | 1 | Cơ bản |
| 2 | Single Site | DN nhỏ/trung bình | 1 | HA |
| 3 | Multi-Site in Single Region | DN lớn, 2 site | 2+ | HA + Stretched |
| 4 | Multi-Site across Multi Regions | DR, BC/DR | 2+ region | DR |
| 5 | Single Region + Additional Region(s) | Enterprise lớn | 3+ | HA + DR |

### 5.2 Design Profile Categories

Mỗi blueprint được đánh giá theo **6 tiêu chí**:

| Tiêu Chí | Giải Thích |
|----------|------------|
| **Consumption** | Cách tiêu thụ tài nguyên (VM, Container, IaaS) |
| **Physical Site Configuration** | Cấu hình địa lý (Single/Multi Site/Region) |
| **Availability** | Mức độ sẵn sàng (HA, Stretched, DR) |
| **Isolation** | Mức độ phân tách (Network, Storage, Compute) |
| **Recoverability** | Khả năng phục hồi (Backup, Restore, DR) |
| **Expansion** | Khả năng mở rộng (Thêm host, cluster, domain) |

### 5.3 Chi Tiết Từng Blueprint

#### Blueprint 1: Single Site - Minimal Footprint

```
    +-------------------------------+
    |         SITE A                |
    |  +-------------------------+  |
    |  |   MANAGEMENT DOMAIN     |  |
    |  |   (Minimal: 4 hosts)    |  |
    |  |   - SDDC Manager        |  |
    |  |   - vCenter             |  |
    |  |   - NSX Manager         |  |
    |  +-------------------------+  |
    |  +-------------------------+  |
    |  |   WORKLOAD DOMAIN       |  |
    |  |   (Co-located)          |  |
    |  |   - Workloads chung     |  |
    |  +-------------------------+  |
    +-------------------------------+
```

#### Blueprint 2: Single Site - Full HA

```
    +-------------------------------+
    |         SITE A                |
    |  +-------------------------+  |
    |  |   MANAGEMENT DOMAIN     |  |
    |  |   (HA: 4+ hosts)        |  |
    |  |   - All mgmt components |  |
    |  +-------------------------+  |
    |  +-------------------------+  |
    |  |   WORKLOAD DOMAIN 1     |  |
    |  |   - vCenter riêng       |  |
    |  |   - vSphere Clusters    |  |
    |  +-------------------------+  |
    |  +-------------------------+  |
    |  |   WORKLOAD DOMAIN 2     |  |
    |  |   - vCenter riêng       |  |
    |  +-------------------------+  |
    +-------------------------------+
```

#### Blueprint 3: Multi-Site in Single Region

```
    +------------------+   Stretched   +------------------+
    |     SITE A       |   Cluster     |     SITE B       |
    |  +------------+  |<=============>|  +------------+   |
    |  | Management |  |               |  | Standby    |   |
    |  | Domain     |  |               |  | Hosts      |   |
    |  +------------+  |               |  +------------+   |
    |  +------------+  |               |  +------------+   |
    |  | Workload   |  |               |  | Workload   |   |
    |  | Domain     |  |               |  | (2nd Site) |   |
    |  +------------+  |               |  +------------+   |
    +------------------+               +------------------+
```

#### Blueprint 4: Multi-Site across Multi Regions

```
    +------------------+               +------------------+
    |    REGION A      |               |    REGION B      |
    |     SITE A       |  Async        |     SITE B       |
    |  +------------+  |  Replication  |  +------------+   |
    |  | Management |  |-------------->|  | Recovery   |   |
    |  | Domain     |  |               |  | Site       |   |
    |  +------------+  |               |  +------------+   |
    |  +------------+  |               |  +------------+   |
    |  | Workload   |  |               |  | DR         |   |
    |  | Domain     |  |               |  | Workloads  |   |
    |  +------------+  |               |  +------------+   |
    +------------------+               +------------------+
```

#### Blueprint 5: Single Region + Additional Region(s)

```
    +------------------+  Stretched  +------------------+
    |     SITE A       |<===========>|     SITE B       |
    |  +------------+  |             |  +------------+   |
    |  | Management |  |             |  | Standby    |   |
    |  +------------+  |             |  +------------+   |
    |  +------------+  |             |  +------------+   |
    |  | Workload   |  |             |  | Workload   |   |
    |  +------------+  |             |  +------------+   |
    +------------------+             +------------------+
              |
              | Async Replication
              v
    +------------------+
    |    REGION B      |
    |     SITE C       |
    |  +------------+  |
    |  | Recovery   |  |
    |  | Site (DR)  |  |
    |  +------------+  |
    +------------------+
```

---

## 6. Design Library - Thiết Kế Chi Tiết

Design Library cung cấp thiết kế chi tiết cho **17 thành phần** của VCF:

| # | Thành Phần | Nội Dung Chính |
|---|------------|----------------|
| 1 | **VCF Operations Design** | Cấu hình, kích thước, HA cho VCF Operations |
| 2 | **VCF Automation Design** | Mô hình triển khai VCF Automation |
| 3 | **Workload Domain Design** | Các mô hình workload domain |
| 4 | **vSphere Cluster Design** | Standard, Stretched, vSAN ESA cluster |
| 5 | **VCF Edge Design** | Cấu hình Edge cho địa lý |
| 6 | **Network Design** | Network fabric, VPC, Segments, Transit |
| 7 | **Storage Design** | vSAN ESA, NFS, FC, vVOLS |
| 8 | **vCenter Design** | Vị trí, kích thước, HA của vCenter |
| 9 | **ESX Design** | Cấu hình ESX hosts |
| 10 | **External Services** | DNS, NTP, IP addressing |
| 11 | **Information Security** | Access control, certificates, accounts |
| 12 | **Identity Broker** | SSO instance models |
| 13 | **Single Sign-On** | Authentication design |
| 14 | **NSX Management** | NSX Manager deployment |
| 15 | **Workload Networking** | Mức độ networking cho workload |
| 16 | **NSX Edge Cluster** | Edge node models |
| 17 | **vSphere Supervisor** | Self-service IaaS deployment |

---

## 7. Tính Năng và Chức Năng

### 7.1 Tính Năng Kiến Trúc

| Tính Năng | Mô Tả |
|-----------|-------|
| **Fleet Management** | Quản lý nhiều VCF Instance từ VCF Operations |
| **Workload Domains** | Tạo và quản lý các domain riêng biệt |
| **vSphere Cluster Models** | Nhiều mô hình cụm với mức độ availability khác nhau |
| **Distributed Switch Models** | Các mô hình VDS cho mức độ mạng khác nhau |
| **Storage Models** | vSAN ESA, NFS, FC, vVOLS - lựa chọn linh hoạt |
| **NSX Edge Cluster** | Các mô hình Edge cho dịch vụ mạng |
| **VCF Edge** | Mở rộng quản lý đến các điểm edge địa lý |

### 7.2 Tính Năng Vận Hành

| Tính Năng | Mô Tả |
|-----------|-------|
| **Lifecycle Management** | Tự động hóa cập nhật, nâng cấp phần mềm |
| **Infrastructure Operations** | Giám sát, báo cáo, quản lý hiệu suất |
| **Cost & Capacity Management** | Theo dõi chi phí và dung lượng |
| **Workload Mobility** | Chuyển đổi workload giữa các phiên/instance |
| **Security & Compliance** | Bảo mật, kiểm soát truy cập, tuân thủ |
| **Fleet Management** | Quản lý nhiều instance từ trung tâm |

### 7.3 Tính Năng Nâng Cao

| Tính Năng | Mô Tả |
|-----------|-------|
| **vSphere Supervisor** | Self-service IaaS cho VM, Kubernetes, Storage Volumes |
| **VCF Automation** | Provisioning tự động với policy-based governance |
| **VCF Advanced Services** | Các dịch vụ nâng cao cho enterprise |
| **Orchestration** | VCF Orchestrator cho workflow tự động |

### 7.4 Chức Năng Theo Vai Trò

| Vai Trò | Chức Năng Chính |
|---------|-----------------|
| **Cloud Admin** | Quản lý fleet, domain, cấu hình bảo mật, lifecycle |
| **VI Admin** | Quản lý vSphere, NSX, vSAN, networking |
| **DevOps / Developer** | Truy cập self-service, triển khai workload |
| **Security Admin** | Kiểm soát truy cập, compliance, bảo mật |
| **Platform Admin** | Quản lý VCF Operations, VCF Automation |

---

## 8. Lợi Ích Thực Tế

### 8.1 Lợi Ích Kinh Tế

| Lợi Ích | Chi Tiết |
|---------|----------|
| **Giảm TCO** | Tổng chi phí sở hữu thấp hơn so với giải pháp phân mảnh |
| **Giảm Nhân Sự** | Tự động hóa giúp quản lý cơ sở hạ tầng lớn với ít nhân viên |
| **Tối Ưu Hardware** | Sử dụng hiệu quả tài nguyên phân cụm, giảm waste |
| **Giảm Thời Gian Triển Khai** | Tự động hóa Day 0/1/2 giảm từ tháng thành ngày |

### 8.2 Lợi Ích Kỹ Thuật

| Lợi Ích | Chi Tiết |
|---------|----------|
| **Triển Khai Nhanh** | Tự động hóa giảm thời gian triển khai |
| **Quản Lý Đơn Giản** | Trung tâm VCF Operations đơn giản hóa operations |
| **Mở Rộng Linh Hoạt** | Thêm host, cluster, domain theo nhu cầu |
| **Phục Hồi Tự Động** | vSphere HA, DRS, Stretched Cluster |

### 8.3 Lợi Ích Phát Triển

| Lợi Ích | Chi Tiết |
|---------|----------|
| **Self-Service** | Developer tự triển khai workload mà không cần admin |
| **Kubernetes Support** | Hỗ trợ container và ứng dụng hiện đại |
| **AI/ML Ready** | Nền tảng hỗ trợ workload AI/ML |
| **Multi-Tenant** | Hỗ trợ nhiều tổ chức/bộ phận |

### 8.4 Lợi Ích Bảo Mật

| Lợi Ích | Chi Tiết |
|---------|----------|
| **Micro-Segmentation** | NSX cho bảo mật tầng mạng |
| **Identity Integration** | SSO, Identity Broker với Active Directory |
| **Compliance** | Tự động kiểm tra tuân thủ |
| **Encryption** | Mã hóa dữ liệu ở mức lưu trữ và truyền tải |

---

## 9. VCF Planning Workbook

### 9.1 Giới Thiệu

**VCF Planning and Preparation Workbook** là file **Excel động (dynamic)** giúp thu thập các thông tin cần thiết để triển khai VCF Fleet. Đây là **công cụ quan trọng nhất** cho việc lên kế hoạch và chuẩn bị.

### 9.2 Tải File Excel

| File | Link Tải Trực Tiếp |
|------|-------------------|
| **VCF 9.0 Planning Workbook** | [Tải Excel (.xlsx)](https://techdocs.broadcom.com/content/dam/broadcom/techdocs/us/en/assets/vmware-cis/vcf/vcf-9.0-planning-and-preparation-workbook.xlsx) |
| **VCF Design Guide (Full PDF)** | [Tải PDF](https://techdocs.broadcom.com/content/dam/broadcom/techdocs/us/en/pdf/vmware/vcf/vcf-90/vmware-cloud-foundation-9-0.pdf) |

### 9.3 Chức Năng Của Workbook

- **Thu Thập Input:** Thông tin hardware, mạng, IP, DNS, NTP
- **Sizing Environment:** Tính toán kích thước môi trường
- **Dynamic Specification:** Tài liệu động cập nhật theo thiết kế
- **Guardrails:** Kiểm tra ràng buộc kỹ thuật trước khi triển khai
- **Prerequisite Checklist:** Danh sách kiểm tra trước khi bắt đầu

### 9.4 Các Tab Chính Trong Workbook

| Tab | Nội Dung |
|-----|----------|
| **Prerequisites Checklist** | Danh sách kiểm tra trước khi deploy |
| **Management Domain Sizing** | Tính kích thước Management Domain |
| **VCF & VVF Planning** | Kế hoạch VCF Fleet |
| **Workload Domain Planning** | Kế hoạch Workload Domain |
| **Network Planning** | Kế hoạch mạng (VLAN, IP, Subnet) |
| **Storage Planning** | Kế hoạch lưu trữ |
| **External Services** | DNS, NTP, Certificate |

### 9.5 Công Cụ Bổ Sung

| Công Cụ | Link |
|---------|------|
| **VMware ConfigMax** | https://configmax.broadcom.com/ |
| **VMware Ports & Protocols** | https://ports.broadcom.com/ |
| **VCF Installer** | Tải từ Broadcom Support Portal |
| **VCF Download Tool** | Tải từ Broadcom Support Portal |

---

## 10. Sơ Đồ ASCII Kiến Trúc

### 10.1 Tổng Quan Hệ Thống VCF 9.0

```
================================================================================
                    VCF 9.0 - TỔNG QUAN KIẾN TRÚC HỆ THỐNG
================================================================================

  +========================================================================+
  |                         VCF PRIVATE CLOUD                              |
  |                                                                        |
  |   +================================================================+   |
  |   |                    VCF FLEET                                   |   |
  |   |                                                                |   |
  |   |   +--------------------------------------------------------+  |   |
  |   |   |        VCF OPERATIONS (Quản Lý Fleet)                   |  |   |
  |   |   |  - Giám sát, Logging, Báo cáo, License                  |  |   |
  |   |   |  - Quản Lý Chu Kỳ Sống                                  |  |   |
  |   |   |  - Quản Lý Certificate & Password                       |  |   |
  |   |   +--------------------------------------------------------+  |   |
  |   |                                                                |   |
  |   |   +--------------------------------------------------------+  |   |
  |   |   |        VCF AUTOMATION (Tự Dịch Vụ)                     |  |   |
  |   |   |  - IaaS Provisioning                                    |  |   |
  |   |   |  - Kubernetes & VM Workloads                            |  |   |
  |   |   |  - Policy-Based Governance                              |  |   |
  |   |   +--------------------------------------------------------+  |   |
  |   |                                                                |   |
  |   |   +----------------------------------------------------------+|   |
  |   |   |              VCF INSTANCE 1                               ||   |
  |   |   |  +----------------------------------------------------+  ||   |
  |   |   |  |        MANAGEMENT DOMAIN                             |  ||   |
  |   |   |  |  +----------+  +----------+  +------------------+   |  ||   |
  |   |   |  |  | SDDC     |  | vCenter  |  | NSX Manager      |   |  ||   |
  |   |   |  |  | Manager  |  | Server   |  | (3-node cluster) |   |  ||   |
  |   |   |  |  +----------+  +----------+  +------------------+   |  ||   |
  |   |   |  |  +------------------------------------------------+ |  ||   |
  |   |   |  |  |      vSphere Cluster (Management)              | |  ||   |
  |   |   |  |  |  +--------+ +--------+ +--------+ +--------+  | |  ||   |
  |   |   |  |  |  | ESX-01 | | ESX-02 | | ESX-03 | | ESX-04 |  | |  ||   |
  |   |   |  |  |  +--------+ +--------+ +--------+ +--------+  | |  ||   |
  |   |   |  |  |  [vSAN ESA Storage Pool]                       | |  ||   |
  |   |   |  |  +------------------------------------------------+ |  ||   |
  |   |   |  +----------------------------------------------------+  ||   |
  |   |   |                                                            ||   |
  |   |   |  +----------------------------------------------------+  ||   |
  |   |   |  |        WORKLOAD DOMAIN 1                             |  ||   |
  |   |   |  |  +----------+  +----------+  +------------------+   |  ||   |
  |   |   |  |  | vCenter  |  | NSX Mgr  |  | NSX Edge Cluster |   |  ||   |
  |   |   |  |  | Server   |  | (Shared) |  | (Optional)       |   |  ||   |
  |   |   |  |  +----------+  +----------+  +------------------+   |  ||   |
  |   |   |  |  +------------------------------------------------+ |  ||   |
  |   |   |  |  |      vSphere Cluster (Workload)                | |  ||   |
  |   |   |  |  |  +--------+ +--------+ +--------+ +--------+  | |  ||   |
  |   |   |  |  |  | ESX-05 | | ESX-06 | | ESX-07 | | ESX-08 |  | |  ||   |
  |   |   |  |  |  +--------+ +--------+ +--------+ +--------+  | |  ||   |
  |   |   |  |  +------------------------------------------------+ |  ||   |
  |   |   |  +----------------------------------------------------+  ||   |
  |   |   +----------------------------------------------------------+|   |
  |   +================================================================+   |
  +========================================================================+
```

### 10.2 Lớp Thành Phần (Component Layers)

```
================================================================================
                    LỚP THÀNH PHẦN - COMPONENT LAYERS
================================================================================

    +------------------+     +------------------+     +------------------+
    |    TÍNH TOÁN     |     |    LƯU TRỮ       |     |      MẠNG        |
    |   (COMPUTE)      |     |   (STORAGE)      |     |   (NETWORKING)   |
    |                  |     |                  |     |                  |
    |  - vSphere       |     |  - vSAN ESA      |     |  - NSX           |
    |  - ESX Hosts     |     |  - NFS           |     |  - VDS           |
    |  - vCenter       |     |  - FC            |     |  - VPC/Segment   |
    |  - DRS / HA      |     |  - vVOLS         |     |  - Edge Cluster  |
    +------------------+     +------------------+     +------------------+
            |                        |                        |
            +------------------------+------------------------+
                                     |
                    +----------------------------------+
                    |        LỚP QUẢN LÝ              |
                    |      (MANAGEMENT PLANE)         |
                    |                                  |
                    |  +----------------------------+  |
                    |  |     VCF OPERATIONS          |  |
                    |  |  - Fleet Management         |  |
                    |  |  - Monitoring & Logging     |  |
                    |  |  - Cost & Capacity          |  |
                    |  +----------------------------+  |
                    |                                  |
                    |  +----------------------------+  |
                    |  |     VCF AUTOMATION          |  |
                    |  |  - Self-Service Portal      |  |
                    |  |  - IaaS Provisioning        |  |
                    |  |  - Kubernetes Support       |  |
                    |  +----------------------------+  |
                    +----------------------------------+
                                     |
                                     v
                    +----------------------------------+
                    |     WORKLOAD END USER            |
                    |  - Virtual Machines              |
                    |  - Kubernetes Pods               |
                    |  - AI/ML Workloads               |
                    +----------------------------------+
```

### 10.3 Lưu Lượng Tương Tác VCF Components

```
================================================================================
                    LƯU LƯỢNG TƯƠNG TÁC - COMPONENT INTEGRATION FLOW
================================================================================

                    +-------------------+
                    |  DỊCH VỤ NGOÀI    |
                    |  - DNS            |
                    |  - NTP            |
                    |  - Certificate    |
                    |  - Identity (AD)  |
                    +---------+---------+
                              |
                              v
    +--------------------------------------------------------------+
    |                    VCF FLEET                                 |
    |                                                              |
    |  +--------------------+    +--------------------------+     |
    |  |  VCF OPERATIONS    |<-->|    VCF AUTOMATION        |     |
    |  |                    |    |                          |     |
    |  | - Fleet Dashboard  |    | - Self-Service Portal    |     |
    |  | - Monitoring       |    | - IaaS Provisioning      |     |
    |  | - Lifecycle Mgmt   |    | - Kubernetes             |     |
    |  | - Cost Management  |    | - Policy Governance      |     |
    +--+--------------------+----+--------------------------+--+
       |                                                     |
       v                                                     v
    +--------------------------------------------------------------+
    |                 VCF INSTANCE                                 |
    |                                                              |
    |  +--------------------------------------------------------+ |
    |  |  MANAGEMENT DOMAIN                                      | |
    |  |  +------------+  +----------+  +------------------+    | |
    |  |  | SDDC Mgr   |  | vCenter  |  | NSX Manager      |    | |
    |  |  +------------+  +----------+  +------------------+    | |
    |  |  +--------------------------------------------------+ | |
    |  |  | vSphere Cluster (vSAN ESA)                        | | |
    |  |  | ESX-01 | ESX-02 | ESX-03 | ESX-04                 | | |
    |  |  +--------------------------------------------------+ | |
    |  +--------------------------------------------------------+ |
    |                                                              |
    |  +--------------------------------------------------------+ |
    |  |  WORKLOAD DOMAIN(S)                                     | |
    |  |  +----------+  +------------------+  +----------------+ | |
    |  |  | vCenter  |  | NSX Manager      |  | NSX Edge       | | |
    |  |  +----------+  +------------------+  +----------------+ | |
    |  |  +--------------------------------------------------+ | |
    |  |  | vSphere Clusters                                  | | |
    |  |  | ESX-05 | ESX-06 | ESX-07 | ...                    | | |
    |  |  +--------------------------------------------------+ | |
    |  +--------------------------------------------------------+ |
    +--------------------------------------------------------------+
                              |
                              v
                    +-------------------+
                    |  WORKLOAD CUỐI    |
                    |  - Virtual Machine |
                    |  - Kubernetes Pod  |
                    |  - AI/ML Workload  |
                    +-------------------+
```

### 10.4 Kiến Trúc Mạng VCF

```
================================================================================
                    KIẾN TRÚC MẠNG - NETWORK ARCHITECTURE
================================================================================

    +================================================================+
    |                    MẠNG VẬT LÝ (PHYSICAL NETWORK)              |
    |  +----------------------------------------------------------+ |
    |  |  Management Network (VLAN)                                | |
    |  |  - vCenter, NSX Manager, SDDC Manager                    | |
    |  +----------------------------------------------------------+ |
    |  |  vSAN Network (VLAN)                                      | |
    |  |  - vSAN Traffic                                           | |
    |  +----------------------------------------------------------+ |
    |  |  VMotion Network (VLAN)                                   | |
    |  |  - vMotion Traffic                                        | |
    |  +----------------------------------------------------------+ |
    |  |  Workload Network (VLAN/NSX)                              | |
    |  |  - Tenant Workloads                                       | |
    |  +----------------------------------------------------------+ |
    +================================================================+
                              |
                              v
    +================================================================+
    |                    MẠNG ẢO (VIRTUAL NETWORK - NSX)             |
    |                                                                |
    |  +----------------------------------------------------------+ |
    |  |  NSX Manager Cluster (3 nodes)                            | |
    |  |  - Quản Lý (Management Plane)                             | |
    |  |  - Điều Khiển (Control Plane)                             | |
    |  +----------------------------------------------------------+ |
    |                                                                |
    |  +----------------------------------------------------------+ |
    |  |  NSX Edge Cluster (Tù chọn)                               | |
    |  |  - Tier-0 Gateway (Kết nối ngoài)                         | |
    |  |  - Tier-1 Gateway (Phân tách Tenant)                      | |
    |  |  - Load Balancing                                         | |
    |  |  - NAT / VPN / Firewall                                   | |
    |  +----------------------------------------------------------+ |
    |                                                                |
    |  +----------------------------------------------------------+ |
    |  |  VPC & Segments                                           | |
    |  |  - Virtual Private Clouds                                 | |
    |  |  - Network Segments                                       | |
    |  |  - Transit Gateways                                       | |
    |  +----------------------------------------------------------+ |
    +================================================================+
```

### 10.5 Quy Trình Triển Khai VCF

```
================================================================================
                    QUY TRÌNH TRIỂN KHAI - DEPLOYMENT FLOW
================================================================================

    +-------------+     +-------------+     +-------------+
    |   DAY 0     |     |   DAY 1     |     |   DAY 2     |
    |  KẾ HOẠCH   |     |  TRIỂN KHAI |     |  VẬN HÀNH   |
    +------+------+     +------+------+     +------+------+
           |                   |                   |
           v                   v                   v
    +-------------+     +-------------+     +-------------+
    | - Planning  |     | - Deploy    |     | - Monitor   |
    |   Workbook  |     |   Mgmt Domain|    | - Patch     |
    | - Sizing    |     | - Deploy    |     | - Scale     |
    | - Hardware  |     |   Workload  |     | - Optimize  |
    | - Network   |     |   Domain    |     | - Backup    |
    | - Storage   |     | - Config    |     | - DR        |
    | - DNS/NTP   |     |   NSX Edge  |     | - Upgrade   |
    +-------------+     +-------------+     +-------------+
           |                   |                   |
           v                   v                   v
    +----------------------------------------------------------+
    |                                                          |
    |  DAY 0: SỬ DỤNG PLANNING WORKBOOK EXCEL                 |
    |  - Thu thập thông tin hardware, mạng, IP                 |
    |  - Tính toán kích thước                                  |
    |  - Kiểm tra prerequisites                                |
    |                                                          |
    |  DAY 1: TRIỂN KHAI VCF                                   |
    |  - Sử dụng VCF Installer                                 |
    |  - Deploy Management Domain                              |
    |  - Deploy Workload Domain                                |
    |  - Cấu hình NSX Edge                                     |
    |                                                          |
    |  DAY 2: VẬN HÀNH VÀ BẢO TRÌ                             |
    |  - Giám sát với VCF Operations                           |
    |  - Cập nhật, nâng cấp (Lifecycle Management)             |
    |  - Mở rộng (Scale Out/Up)                                |
    |  - Backup & DR                                           |
    |                                                          |
    +----------------------------------------------------------+
```

### 10.6 Mô Hình Mở Rộng (Expansion Patterns)

```
================================================================================
                    MÔ HÌNH MỞ RỘNG - EXPANSION PATTERNS
================================================================================

    +================================================================+
    |                    RESOURCE EXPANSION                          |
    +================================================================+
    |                                                                |
    |  [1] THÊM HOST VÀO CLUSTER HIỆN TẠI                          |
    |      Cluster A: [ESX-01] [ESX-02] [ESX-03] + [ESX-04]        |
    |      -> Thêm compute + storage (vSAN)                         |
    |                                                                |
    |  [2] THÊM CLUSTER MỚI VÀO DOMAIN                             |
    |      Domain 1: [Cluster A] + [Cluster B]                      |
    |      -> Thêm compute, isolated scope                          |
    |                                                                |
    |  [3] THÊM WORKLOAD DOMAIN MỚI                                |
    |      [Mgmt Domain] + [WD1] + [WD2]                            |
    |      -> vCenter riêng, cấu hình riêng                         |
    |                                                                |
    |  [4] THÊM VCF INSTANCE MỚI                                   |
    |      [Instance 1] + [Instance 2]                               |
    |      -> Fleet management riêng                                 |
    |                                                                |
    +================================================================+
    |                                                                |
    |  +============================================================+
    |  | AVAILABILITY EXPANSION                                      |
    |  +============================================================+
    |  |                                                            |
    |  |  [5] THÊM SITE (Cùng Region)                               |
    |  |      -> Stretched Cluster                                  |
    |  |                                                            |
    |  |  [6] THÊM SITE (Region Khác)                               |
    |  |      -> DR / Async Replication                             |
    |  |                                                            |
    |  +============================================================+
    +================================================================+
```

---

## 11. Tài Liệu Tham Khảo

### 11.1 Tài Liệu Chính Thức (Official Documentation)

| Tài Liệu | Link |
|----------|------|
| VCF 9.0 Design Guide | https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0/design.html |
| Design Blueprints | https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0/design/blueprints.html |
| Design Library | https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0/design/design-library.html |
| Planning & Preparation | https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0/planning-and-preparation.html |
| VCF 9.0 Overview | https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0/overview-of-vmware-cloud-foundation-9.html |
| Architectural Options | https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0/design/vmware-cloud-foundation-concepts.html |
| VCF 9.0 Full PDF | https://techdocs.broadcom.com/content/dam/broadcom/techdocs/us/en/pdf/vmware/vcf/vcf-90/vmware-cloud-foundation-9-0.pdf |

### 11.2 Excel Templates

| File | Link |
|------|------|
| VCF 9.0 Planning Workbook (.xlsx) | https://techdocs.broadcom.com/content/dam/broadcom/techdocs/us/en/assets/vmware-cis/vcf/vcf-9.0-planning-and-preparation-workbook.xlsx |

### 11.3 Công Cụ Hỗ Trợ

| Công Cụ | Link |
|---------|------|
| VMware ConfigMax | https://configmax.broadcom.com/ |
| VMware Ports & Protocols | https://ports.broadcom.com/ |
| VCF Diagram Templates | https://tools.virtualbytes.io/vcf-diagram-templates |

### 11.4 Bài Viết & Video

| Tài Liệu | Link |
|----------|------|
| Planning a Successful VCF 9.0 Deployment | https://blogs.vmware.com/cloud-foundation/2025/07/28/planning-a-successful-vmware-cloud-foundation-9-0-deployment/ |
| VCF 9.0 Downloads Guide | https://knowledge.broadcom.com/external/article/401497/vmware-vcf-or-vvf-90-downloads-in-the-br.html |
| VCF Deployment Planning Guide | https://news.broadcom.com/broadcom-knights/vcf-9-deployment-planning-vmware-cloud-foundation |

---

> **Ghi chú:** Document này được tổng hợp từ **Chương 2 - VMware Cloud Foundation 9.0 Design Guide** và các nguồn chính thức từ **Broadcom TechDocs**. Để đọc đầy đủ PDF, sử dụng link tải ở mục 11.1.

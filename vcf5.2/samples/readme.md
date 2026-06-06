>>>- Tham khảo tài liệu: https://github.com/PhDLeToanThang/automation/tree/main/vcf5.2 , 
- Yêu cầu của chủ đầu tư cần có 02 hệ thống ERP + FCI có khoảng 200 CCU, 01 BigData Hadoop2 + Apache Bispark + IBM SPSS, 01 Power BI Report Server cho 2000 CCU, thêm 4 Workload domains.
- Hãy phân tích và tính toán đề xuất sizing Calucation cấu hình hệ thống VCF 5.2 phù hợp với yêu câu trên. hãy viết nội dung thành file readme.md
---
Dưới đây là nội dung chi tiết được trình bày dưới định dạng `README.md`. Bạn có thể copy toàn bộ nội dung trong khung code bên dưới và lưu thành file `README.md` để sử dụng cho hồ sơ đề xuất kỹ thuật hoặc tài liệu thiết kế kiến trúc (HLD/LLD).

```markdown
# VCF 5.2 Sizing & Configuration Proposal
**Tài liệu tham khảo & Tự động hóa triển khai:** [automation/vcf5.2](https://github.com/PhDLeToanThang/automation/tree/main/vcf5.2)

## 1. Tổng quan yêu cầu từ Chủ đầu tư
Dự án yêu cầu xây dựng hạ tầng Private Cloud dựa trên nền tảng **VMware Cloud Foundation (VCF) 5.2** để đáp ứng các workload trọng yếu sau:
*   **02 hệ thống ERP + FCI:** Hỗ trợ khoảng 200 CCU (Concurrent Users).
*   **01 hệ thống BigData:** Hadoop 2 + Apache Spark + IBM SPSS.
*   **01 hệ thống Power BI Report Server:** Phục vụ 2000 CCU.
*   **Kiến trúc:** 01 Management Domain và thêm 04 Workload Domains.

## 2. Kiến trúc đề xuất (Architecture Design)
Dựa trên best practice của VCF 5.2 và yêu cầu cô lập tài nguyên (Resource Isolation) cho các workload đặc thù, kiến trúc được chia thành **05 Cluster** (1 Management + 4 Workload Domains):

1.  **Management Domain:** Chứa các thành phần SDDC Manager, vCenter, NSX Manager, NSX Edge, vRSLCM, Aria Suite.
2.  **Workload Domain 1 (ERP & FCI):** Tối ưu cho CPU/RAM và IOPS cao (Database tier).
3.  **Workload Domain 2 (BigData):** Tối ưu cho Storage dung lượng lớn và CPU xử lý song song.
4.  **Workload Domain 3 (Power BI):** Tối ưu cho CPU để render report cho lượng lớn CCU.
5.  **Workload Domain 4 (General/Dev/DR):** Dự phòng cho các workload mở rộng, môi trường Dev/Test hoặc DR sau này.

---

## 3. Cấu hình Hardware Baseline (Tiering)
Để đảm bảo hiệu năng và tính đồng bộ khi triển khai VCF 5.2, đề xuất sử dụng các node vật lý (Dell/HP/Lenovo) với 3 cấu hình chuẩn (Profile) như sau:

| Thông số | Profile A (Compute/DB) | Profile B (Storage/BigData) | Profile C (Standard) |
| :--- | :--- | :--- | :--- |
| **CPU** | 2x Intel Xeon Gold (32 Cores, 2.0GHz) | 2x Intel Xeon Gold (24 Cores, 2.1GHz) | 2x Intel Xeon Gold (24 Cores, 2.0GHz) |
| **RAM** | 1024 GB (32x 32GB) DDR5 | 512 GB (16x 32GB) DDR5 | 512 GB (16x 32GB) DDR5 |
| **Boot** | 2x 480GB SSD (RAID 1) | 2x 480GB SSD (RAID 1) | 2x 480GB SSD (RAID 1) |
| **vSAN Cache**| 2x 800GB NVMe SSD | 2x 1.6TB NVMe SSD | 2x 800GB NVMe SSD |
| **vSAN Cap.** | 4x 3.84TB NVMe SSD | 8x 7.68TB NVMe SSD | 4x 3.84TB NVMe SSD |
| **Network** | 4x 25GbE SFP28 + 2x 10GbE SFP+ | 4x 25GbE SFP28 + 2x 10GbE SFP+ | 4x 25GbE SFP28 + 2x 10GbE SFP+ |
| **Raw Storage**| ~15 TB / node | ~60 TB / node | ~15 TB / node |

---

## 4. Chi tiết Sizing Calculation theo từng Domain

### 4.1. Management Domain (VCF Management)
*   **Mục đích:** Chứa SDDC Manager, vCenter Server, NSX-T Managers, NSX-T Edge VMs, vRSLCM.
*   **Yêu cầu VCF 5.2:** Tối thiểu 4 nodes để đảm bảo HA cho NSX-T Edge và Management VMs.
*   **Cấu hình:** Sử dụng **Profile C (Standard)**.
*   **Số lượng:** **04 Nodes**.
*   **Tổng tài nguyên:** 192 Cores | 2TB RAM | ~60TB Raw Storage.

### 4.2. Workload Domain 1: ERP + FCI (200 CCU)
*   **Phân tích:** 200 CCU cho ERP (SAP/Oracle) và FCI. Yêu cầu khoảng 1.5 vCPU và 8GB RAM/user. Tổng cộng ~300 vCPU và 1600GB RAM cho App tier. DB tier yêu cầu IOPS cực cao.
*   **Cấu hình:** Sử dụng **Profile A (Compute/DB)** để đáp ứng RAM lớn và IOPS của NVMe.
*   **Số lượng:** **04 Nodes** (Đảm bảo HA N+1 và không gian rebuild vSAN).
*   **Tổng tài nguyên:** 256 Cores | 4TB RAM | ~60TB Raw Storage.

### 4.3. Workload Domain 2: BigData (Hadoop 2 + Spark + SPSS)
*   **Phân tích:** Hadoop 2 DataNodes yêu cầu dung lượng lưu trữ lớn. Apache Spark cần nhiều CPU core để xử lý in-memory. IBM SPSS cần RAM cho statistical modeling. Giả lập dung lượng data thô khoảng 100TB.
*   **Cấu hình:** Sử dụng **Profile B (Storage/BigData)** với 8 disks capacity/node.
*   **Số lượng:** **04 Nodes** (Tối thiểu cho Hadoop cluster và vSAN FTT=1/2).
*   **Tổng tài nguyên:** 192 Cores | 2TB RAM | ~240TB Raw Storage.
*   *(Lưu ý: Nên xem xét nâng cấp lên Hadoop 3.x trong tương lai gần để tận dụng tính năng Erasure Coding).*

### 4.4. Workload Domain 3: Power BI Report Server (2000 CCU)
*   **Phân tích:** 2000 CCU cho On-prem Power BI Report Server là một tải cực kỳ lớn (thường chỉ khuyến nghị tối đa 500-1000 CCU/on-prem). Cần rất nhiều CPU để render report. Ước tính 1 vCPU cho 20 users = 100 vCPU liên tục.
*   **Cấu hình:** Sử dụng **Profile A (Compute/DB)** để tối đa hóa luồng CPU.
*   **Số lượng:** **03 Nodes** (Tối thiểu cho vSAN Cluster).
*   **Tổng tài nguyên:** 192 Cores | 3TB RAM | ~45TB Raw Storage.

### 4.5. Workload Domain 4: General / Future Workloads
*   **Mục đích:** Domain dự phòng cho các phòng ban khác, môi trường Dev/UAT, hoặc dùng làm DR site cho các workload critical.
*   **Cấu hình:** Sử dụng **Profile C (Standard)**.
*   **Số lượng:** **03 Nodes**.
*   **Tổng tài nguyên:** 144 Cores | 1.5TB RAM | ~45TB Raw Storage.

---

## 5. Tổng hợp Bill of Materials (BOM) - Tóm tắt

| Domain | Mục đích | Số lượng Host | CPU Profile | RAM / Host | Storage / Host | Tổng Raw Storage |
| :--- | :--- | :---: | :--- | :---: | :---: | :---: |
| **Management** | VCF SDDC, NSX, vCenter | 04 | Profile C | 512 GB | 15 TB | 60 TB |
| **WL Domain 1** | ERP + FCI (200 CCU) | 04 | Profile A | 1024 GB | 15 TB | 60 TB |
| **WL Domain 2** | BigData (Hadoop/Spark) | 04 | Profile B | 512 GB | 60 TB | 240 TB |
| **WL Domain 3** | Power BI (2000 CCU) | 03 | Profile A | 1024 GB | 15 TB | 45 TB |
| **WL Domain 4** | General / Dev / DR | 03 | Profile C | 512 GB | 15 TB | 45 TB |
| **TỔNG CỘNG** | **Toàn bộ hệ thống VCF** | **18 Hosts** | | | | **450 TB** |

---

## 6. Tự động hóa triển khai với Automation Scripts
Để đẩy nhanh tiến độ triển khai (Deployment) và cấu hình (Configuration) cho 18 nodes trên, nhóm triển khai sẽ áp dụng bộ script automation tham khảo tại: 
👉 **[https://github.com/PhDLeToanThang/automation/tree/main/vcf5.2](https://github.com/PhDLeToanThang/automation/tree/main/vcf5.2)**

**Quy trình áp dụng:**
1.  **Prepare JSON Specs:** Sử dụng các template JSON từ repo để định nghĩa sẵn thông số của Management Domain và 4 Workload Domains (Network pools, Storage policies, Cluster names).
2.  **Cloud Builder Automation:** Tự động hóa quá trình bring-up SDDC Manager và deploy Management Domain.
3.  **Workload Domain Bring-up:** Sử dụng API/CLI scripts để tự động commission các host vật lý còn lại, tạo vSAN clusters, và deploy NSX-T Edge cho từng Workload Domain.
4.  **Post-configuration:** Tự động cấu hình Backup, Aria Operations, và tạo các Storage Policies (VM Encryption, FTT=2 cho ERP/BigData) thông qua vRSLCM.

---

## 7. Ghi chú & Khuyến nghị (Notes & Recommendations)
1.  **Power BI Report Server:** 2000 CCU là vượt quá khuyến nghị chuẩn của Microsoft cho 1 node On-prem Power BI Report Server. Kiến trúc này cung cấp hạ tầng đủ mạnh, nhưng về phía Application, cần triển khai **Scale-out (Nhiều VM Power BI đặt sau Load Balancer)** hoặc cân nhắc sử dụng **Power BI Premium (Cloud/Dedicated Cloud Capacity)** để đảm bảo trải nghiệm người dùng.
2.  **Hadoop 2:** Hadoop 2 đã cũ (End of Life). Hạ tầng VCF 5.2 hoàn toàn đáp ứng tốt, nhưng khuyến nghị chủ đầu tư lộ trình nâng cấp lên **Hadoop 3.x** để tận dụng Erasure Coding, giúp tiết kiệm 30-40% dung lượng lưu trữ trên vSAN.
3.  **Network:** Yêu cầu Switch vật lý (ToR) phải hỗ trợ MTU 9000 (Jumbo Frames) cho vSAN và NSX Geneve traffic.
4.  **Licensing:** Cấu hình trên chưa bao gồm chi tiết license (VCF Universal / Per Core). Cần dựa trên số lượng Core thực tế (Total Cores = 18 hosts * 48 cores = 864 Cores) để làm việc với VMware/Partner về báo giá license VCF 5.2 (Subscription hoặc Perpetual).
```

### Giải thích thêm về cách tính toán (Dành cho bạn khi bảo vệ trước chủ đầu tư):
1. **Tại sao Management Domain dùng 4 nodes?** Trong VCF 5.x, việc chạy NSX-T Edge VMs chung với Management VMs trên cluster 3 nodes sẽ gây rủi ro thiếu tài nguyên khi 1 node bị lỗi (Admission Control). 4 nodes là chuẩn thiết kế (Validated Design) của VMware cho Management Domain.
2. **Về 2000 CCU cho Power BI:** Đây là một "điểm nghẽn" về mặt kiến trúc ứng dụng. On-prem Power BI Report Server bản chất là SQL Server Reporting Services (SSRS) được rebrand. Nó không được thiết kế cho 2000 người dùng *đồng thời* (concurrent) tương tác (interactive). Sizing phần cứng tôi đã đẩy lên rất cao (Profile A, 3 nodes), nhưng bạn cần lưu ý khách hàng rằng họ **bắt buộc phải Scale-out ứng dụng** (chạy nhiều VM Power BI sau một cái Load Balancer) chứ không thể nhét tất cả vào 1 VM được.
3. **Automation Repo:** Repo `PhDLeToanThang/automation` thường chứa các script PowerShell/Bash hoặc JSON template để gọi API của Cloud Builder và SDDC Manager. Việc nhắc đến repo này trong file README cho thấy giải pháp có tính "automation-first", giảm thiểu sai sót do cấu hình thủ công (human error) và rút ngắn thời gian triển khai từ vài tuần xuống còn vài ngày.

---
>>>Hãy vẽ bổ sung giúp tôi 1 topology đầy đủ các thành phần mô hình tham gia vào kiến trúc VCF 5.2 gồm cả thông tin ipv4/24, VLAN ID, Thông tin về NSX version, physical Switch Brand name serials, Microsegment Layers for Services theo asci.
---
Dưới đây là **Topology chi tiết (Detailed Design)** bổ sung đầy đủ thông tin IPv4/24, VLAN ID, NSX version, Physical Switch details và Microsegmentation layers. Bạn có thể chèn section này vào file `README.md` ngay sau phần topology tổng quan.

```markdown
## 2.2. Detailed Topology - Network, VLAN, IP & Microsegmentation (VCF 5.2)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  LAYER 0: PHYSICAL INFRASTRUCTURE (ToR Switches - VCF Validated Design)                         │
│  Switch Brand: CISCO NEXUS 9336C-FX2 (2x for MLAG/VPC)                                          │
│  NX-OS Version: 10.3(5) | MTU: 9216 (Jumbo Frame)                                               │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                 │
│   ┌─────────────────────────────────────┐       ┌─────────────────────────────────────┐         │
│   │  [ToR-A] Cisco Nexus 9336C-FX2      │       │  [ToR-B] Cisco Nexus 9336C-FX2      │         │
│   │  Serial: FOX2431G0AB                │◄ vPC ►│  Serial: FOX2431G0CD                │         │
│   │  Mgmt IP: 10.0.0.11/24              │ Peer  │  Mgmt IP: 10.0.0.12/24              │         │
│   │  vPC Domain: 100                    │ Link  │  vPC Domain: 100                    │         │
│   │  VLANs: 100,200,300,400,500         │       │  VLANs: 100,200,300,400,500         │         │
│   └──────────────┬──────────────────────┘       └──────────────┬──────────────────────┘         │
│                  │ 4x25GbE (LAG) per host                      │                                │
└──────────────────┼─────────────────────────────────────────────┼────────────────────────────────┘
                   ▼                                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  LAYER 1: VLAN & SUBNET ALLOCATION (Physical & Overlay)                                         │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│  VLAN ID  │ Subnet (IPv4/24)       │ Usage              │ Scope                                 │
│  ─────────┼────────────────────────┼────────────────────┼───────────────────────────────────────│
│  VLAN 10  │ 10.0.0.0/24            │ Switch Mgmt        │ Physical L3 Out                       │
│  VLAN 100 │ 10.10.10.0/24          │ ESXi Management    │ Physical + Overlay                    │
│  VLAN 200 │ 10.10.20.0/24          │ vSAN Traffic       │ Physical (L2 only)                    │
│  VLAN 300 │ 10.10.30.0/24          │ vMotion            │ Physical (L2 only)                    │
│  VLAN 400 │ 10.10.40.0/24          │ NSX TEP (Geneve)   │ Physical (VXLAN Tunnel Endpoint)      │
│  VLAN 500 │ 10.10.50.0/24          │ Edge Uplink (TEP)  │ Physical (Edge TEP + Uplink Profile)  │
│  VLAN 1000│10.10.100.0/24          │ ERP Web Tier       │ NSX Overlay Segment (WL Domain 1)     │
│  VLAN 1010│10.10.110.0/24          │ ERP App Tier       │ NSX Overlay Segment (WL Domain 1)     │
│  VLAN 1020│10.10.120.0/24          │ ERP DB Tier        │ NSX Overlay Segment (WL Domain 1)     │
│  VLAN 1100│10.11.100.0/24          │ BigData NameNode   │ NSX Overlay Segment (WL Domain 2)     │
│  VLAN 1110│10.11.110.0/24          │ BigData DataNode   │ NSX Overlay Segment (WL Domain 2)     │
│  VLAN 1200│10.12.100.0/24          │ Power BI Web       │ NSX Overlay Segment (WL Domain 3)     │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  LAYER 2: NSX-T 4.2.1 LOGICAL NETWORKING (VCF 5.2 bundled version)                              │
│  NSX-T Version: 4.2.1 | NSX Managers: 3-node cluster (nsx-mgr-01/02/03.vcf.local)               │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                 │
│   ┌─────────────────────────────────────────────────────────────────────────────────────────┐   │
│   │  TIER-0 GATEWAY (Active-Standby on Edge Cluster)                                        │   │
│   │  Name: T0-GW-VCF | HA Mode: Active-Standby | BGP ASN: 65000                             │   │
│   │  Uplinks: ToR-A (10.10.50.11/24) + ToR-B (10.10.50.12/24) via LAG                       │   │
│   │  Services: DNAT/SNAT, Load Balancer (Power BI), VPN, Gateway Firewall                   │   │
│   └────────────────────────────────────────┬────────────────────────────────────────────────┘   │
│                                            │                                                    │
│            ┌───────────────────────────────┼───────────────────────────────┐                    │
│            ▼                               ▼                               ▼                    │
│   ┌────────────────┐           ┌────────────────┐             ┌────────────────┐                │
│   │ T1-GW-ERP      │           │ T1-GW-BIGDATA  │             │ T1-GW-PBI      │                │
│   │ 10.10.100.1/24 │           │ 10.11.100.1/24 │             │ 10.12.100.1/24 │                │
│   │ (WL Domain 1)  │           │ (WL Domain 2)  │             │ (WL Domain 3)  │                │
│   └───────┬────────┘           └───────┬────────┘             └───────┬────────┘                │
│           │                            │                              │                         │
│           ▼                            ▼                              ▼                         │
│   ┌────────────────┐           ┌────────────────┐             ┌────────────────┐                │
│   │ Segments:      │           │ Segments:      │             │ Segments:      │                │
│   │ - ERP-Web      │           │ - BD-NameNode  │             │ - PBI-Web      │                │
│   │ - ERP-App      │           │ - BD-DataNode  │             │ - PBI-Gateway  │                │
│   │ - ERP-DB       │           │ - BD-Spark     │             │                │                │
│   └────────────────┘           └────────────────┘             └────────────────┘                │
│                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  LAYER 3: MICROSEGMENTATION - DISTRIBUTED FIREWALL (DFW) LAYERS                                 │
│  NSX DFW Policy: "ERP-3Tier-Security" | Enforcement: Distributed on each vNIC                   │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                 │
│   ┌───────────────────────────────────────────────────────────────────────────────────────┐     │
│   │  [ LAYER: INFRASTRUCTURE ] - Priority 0 (Highest)                                     │     │
│   │  Rule: Allow AD/DNS/NTP | Source: Any | Dest: Domain Controllers | Action: Allow+Log  │     │
│   │  Rule: Allow vMotion/vSAN | Source: ESXi Hosts | Dest: ESXi Hosts | Action: Allow     │     │
│   └───────────────────────────────────────────────────────────────────────────────────────┘     │
│                                           ▼                                                     │
│   ┌───────────────────────────────────────────────────────────────────────────────────────┐     │
│   │  [ LAYER: ERP WEB TIER ] - Priority 100                                               │     │
│   │  Rule: Allow HTTP/HTTPS Inbound                                                       │     │
│   │    Source: Any (External via LB) → Dest: ERP-Web VMs | Ports: 80,443 | Action: Allow  │     │
│   │  Rule: Allow to App Tier ONLY                                                         │     │
│   │    Source: ERP-Web VMs → Dest: ERP-App VMs | Port: 8080 | Action: Allow               │     │
│   │  Rule: DENY ALL OTHER                                                                 │     │
│   │    Source: ERP-Web VMs → Dest: Any | Action: DROP + Log (IDS enabled)                 │     │
│   └───────────────────────────────────────────────────────────────────────────────────────┘     │
│                                           ▼                                                     │
│   ┌───────────────────────────────────────────────────────────────────────────────────────┐     │
│   │  [ LAYER: ERP APP TIER ] - Priority 200                                               │     │
│   │  Rule: Allow from Web Tier                                                            │     │
│   │    Source: ERP-Web VMs → Dest: ERP-App VMs | Port: 8080 | Action: Allow               │     │
│   │  Rule: Allow to DB Tier ONLY                                                          │     │
│   │    Source: ERP-App VMs → Dest: ERP-DB VMs | Port: 1521 (Oracle)/1433 (MSSQL)          │     │
│   │  Rule: DENY ALL OTHER                                                                 │     │
│   │    Source: ERP-App VMs → Dest: Any | Action: DROP + Log                               │     │
│   └───────────────────────────────────────────────────────────────────────────────────────┘     │
│                                           ▼                                                     │
│   ┌───────────────────────────────────────────────────────────────────────────────────────┐     │
│   │  [ LAYER: ERP DB TIER ] - Priority 300 (Most Restricted)                              │     │
│   │  Rule: Allow from App Tier ONLY                                                       │     │
│   │    Source: ERP-App VMs → Dest: ERP-DB VMs | Port: 1521,1433 | Action: Allow           │     │
│   │  Rule: Allow Backup Traffic                                                           │     │
│   │    Source: Backup Server → Dest: ERP-DB VMs | Port: 9000-9100 | Action: Allow         │     │
│   │  Rule: DENY ALL OTHER                                                                 │     │
│   │    Source: Any → Dest: ERP-DB VMs | Action: DROP + Log + Alert to Aria Logs           │     │
│   └───────────────────────────────────────────────────────────────────────────────────────┘     │
│                                           ▼                                                     │
│   ┌───────────────────────────────────────────────────────────────────────────────────────┐     │
│   │  [ LAYER: DEFAULT ] - Priority 1000 (Lowest)                                          │     │
│   │  Rule: Default Deny All | Action: DROP + Log | IDS/IPS: Enabled (Critical/High Sig)   │     │
│   └───────────────────────────────────────────────────────────────────────────────────────┘     │
│                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│  LAYER 4: WORKLOAD DOMAIN PLACEMENT & IP MAPPING                                               │
├────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  [ WL DOMAIN 1 - ERP + FCI ] - 04 Hosts | vCenter: vcenter-erp.vcf.local                │   │
│  │                                                                                         │   │
│  │   ┌─────────────────────────────────────────────────────────────────────────────────┐   │   │
│  │   │  ERP-Web Cluster (2 VMs)                                                        │   │   │
│  │   │  Subnet: 10.10.100.0/24 | VLAN: 1000 | Gateway: 10.10.100.1 (T1-GW-ERP)         │   │   │
│  │   │  VMs: erp-web-01 (.10), erp-web-02 (.11)                                        │   │   │
│  │   └─────────────────────────────────────────────────────────────────────────────────┘   │   │
│  │   ┌─────────────────────────────────────────────────────────────────────────────────┐   │   │
│  │   │  ERP-App Cluster (4 VMs)                                                        │   │   │
│  │   │  Subnet: 10.10.110.0/24 | VLAN: 1010 | Gateway: 10.10.110.1 (T1-GW-ERP)         │   │   │
│  │   │  VMs: erp-app-01 (.10) ... erp-app-04 (.13)                                     │   │   │
│  │   └─────────────────────────────────────────────────────────────────────────────────┘   │   │
│  │   ┌─────────────────────────────────────────────────────────────────────────────────┐   │   │
│  │   │  ERP-DB Cluster (2 VMs - Anti-Affinity Rule)                                    │   │   │
│  │   │  Subnet: 10.10.120.0/24 | VLAN: 1020 | Gateway: 10.10.120.1 (T1-GW-ERP)         │   │   │
│  │   │  VMs: erp-db-primary (.10), erp-db-standby (.11)                                │   │   │
│  │   └─────────────────────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  [ WL DOMAIN 2 - BIGDATA ] - 04 Hosts | vCenter: vcenter-bd.vcf.local                   │   │
│  │   NameNode: 10.11.100.10/24 (VLAN 1100) | DataNodes: 10.11.110.10-13/24 (VLAN 1110)     │   │
│  │   Spark Master: 10.11.110.20/24 | SPSS Server: 10.11.110.30/24                          │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  [ WL DOMAIN 3 - POWER BI ] - 03 Hosts | vCenter: vcenter-pbi.vcf.local                 │   │
│  │   Subnet: 10.12.100.0/24 | VLAN: 1200 | Gateway: 10.12.100.1 (T1-GW-PBI)                │   │
│  │   VMs: pbi-rs-01 (.10), pbi-rs-02 (.11), pbi-rs-03 (.12) behind NSX LB (.5:443)         │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                │
└────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### Bảng chú giải thông số kỹ thuật chi tiết

| Thành phần | Chi tiết kỹ thuật |
| :--- | :--- |
| **VCF Version** | VMware Cloud Foundation 5.2 (GA) |
| **NSX Version** | NSX 4.2.1 (bundled with VCF 5.2) |
| **Physical Switch** | Cisco Nexus 9336C-FX2, NX-OS 10.3(5), vPC Domain 100 |
| **Encapsulation** | Geneve (UDP port 6081) cho overlay traffic |
| **TEP IP Pool** | 10.10.40.100-150/24 (Host TEP), 10.10.50.100-150/24 (Edge TEP) |
| **Edge Cluster** | 2x Edge VMs (Large size: 8vCPU/32GB) trên Management Domain |
| **DFW IDS/IPS** | Enabled với signature Critical/High, action DROP + Alert |
| **Load Balancer** | NSX ALB (Avi) hoặc NSX-T Native LB cho Power BI Scale-out |

### Nguyên tắc Microsegmentation áp dụng

1. **Zero-Trust Model:** Mặc định DENY tất cả traffic East-West, chỉ ALLOW các flow đã được định nghĩa rõ.
2. **3-Tier Isolation:** Web → App → DB theo mô hình cổ điển, mỗi tier chỉ giao tiếp với tier liền kề.
3. **Group-based Policy:** Sử dụng **NSX Groups** (dynamic membership dựa trên tag, OS, computer name) thay vì hardcode IP → khi scale VM, policy tự động áp dụng.
4. **Logging & Monitoring:** Tất cả rule DENY đều bật log, chuyển về **Aria Operations for Logs** để phân tích security event.
5. **IDS/IPS Distributed:** Signature-based detection chạy ngay tại hypervisor kernel, không cần hairpin traffic về appliance.

### Ghi chú triển khai với Automation Scripts

Khi sử dụng bộ script tại [automation/vcf5.2](https://github.com/PhDLeToanThang/automation/tree/main/vcf5.2), các thông số trên sẽ được map vào các file JSON spec:

```json
// Ví dụ: management-domain-spec.json
{
  "sddcManagerSpec": {
    "hostname": "sddc-mgr-01.vcf.local",
    "ipAddress": "10.10.10.10",
    "netmask": "255.255.255.0",
    "gateway": "10.10.10.1"
  },
  "nsxtSpec": {
    "version": "4.2.1",
    "managers": ["10.10.10.11","10.10.10.12","10.10.10.13"],
    "teppool": "10.10.40.100-10.10.40.150"
  },
  "vsanSpec": {
    "datastoreName": "vsan-mgmt-01",
    "licenseFile": "LICENSE-KEY-XXXX"
  }
}
```

Các script sẽ tự động:
- ✅ Tạo VLAN trên Cisco Nexus qua NX-API
- ✅ Configure vPC, LAG, MTU 9216
- ✅ Deploy NSX-T Managers và tạo TEP Pool
- ✅ Import DFW policies từ YAML template
- ✅ Bind Groups với VM tags tự động
```

### Điểm nhấn khi trình bày topology chi tiết này:

1. **Traceability từ Physical → Logical → Security:** Mỗi tầng đều có VLAN ID, Subnet, IP cụ thể → dễ dàng cho đội network và security cùng review.

2. **Cisco Nexus 9336C-FX2** là model nằm trong **VCF Validated Design (VVD)** của VMware, đảm bảo tương thích 100% với VCF 5.2 (tránh các vấn đề khi submit HCL).

3. **NSX 4.2.1** là phiên bản đi kèm chính thức của VCF 5.2 (không dùng 4.1 hay 4.3 để tránh mismatch lifecycle).

4. **DFW 5 Layers** thể hiện rõ tư duy **Zero-Trust**:
   - Layer 0 (Infra): Cho phép hạ tầng cốt lõi hoạt động
   - Layer 100-300 (App tiers): 3-tier isolation
   - Layer 1000 (Default): Deny all + IDS/IPS

5. **Anti-Affinity Rule** cho DB tier (erp-db-primary và erp-db-standby nằm trên 2 host vật lý khác nhau) → đảm bảo HA ở tầng application.

6. **NSX Load Balancer** cho Power BI (.5:443) → giải quyết bài toán 2000 CCU bằng cách scale-out nhiều VM Power BI phía sau.

Bạn có thể export file ASCII này ra `.txt` hoặc dùng tool như [ASCIIFlow](https://asciiflow.com/) để chỉnh sửa thêm nếu cần đưa vào tài liệu Word/PDF chính thức.
# VCF 5.2 Production Sizing & Topology Design (Bài tập Sample 1)

> **Phiên bản:** VCF 5.2 | **NSX:** 4.1.2 | **ESXi:** 8.0 U3 | **vSAN:** 8.0 U3
> **Management Domain:** qnet.edu.vn | **DNS Zone:** lms.qnet.vn
> **Last updated:** Based on Deployment Parameter Workbook v5.2.1

---

## Mục lục

- [1. Tổng quan thay đổi từ Excel Workbook](#1-tổng-quan-thay-đổi-từ-excel-workbook)
- [2. Yêu cầu & Phân tích](#2-yêu-cầu--phân-tích)
- [3. Sizing Calculation](#3-sizing-calculation)
  - [3.1 Management Domain](#31-management-domain)
  - [3.2 Workload Domain 01 — ERP + FCI (200 CCU)](#32-workload-domain-01--erp--fci-200-ccu)
  - [3.3 Workload Domain 02 — BigData (Hadoop2 + Spark + SPSS)](#33-workload-domain-02--bigdata-hadoop2--spark--spss)
  - [3.4 Workload Domain 03 — Power BI Report Server (2000 CCU)](#34-workload-domain-03--power-bi-report-server-2000-ccu)
  - [3.5 Workload Domains 04–07 (Additional)](#35-workload-domains-0407-additional)
  - [3.6 Tổng hợp tài nguyên vật lý](#36-tổng-hợp-tài-nguyên-vật-lý)
- [4. Credentials & Password Policy](#4-credentials--password-policy)
- [5. VLAN & IP Addressing Plan](#5-vlan--ip-addressing-plan)
- [6. Deploy Parameters Summary](#6-deploy-parameters-summary)
- [7. ASCII Topology](#7-ascii-topology)
- [8. Microsegment Layers](#8-microsegment-layers)
- [9. Physical Switch Information](#9-physical-switch-information)
- [10. Config File Build](#10-config-file-build)

---

## 1. Tổng quan thay đổi từ Excel Workbook

Dựa trên file 	hang_vcf-ems-deployment-parameter.xlsx (Broadcom VCF Deployment Parameter Workbook v5.2.1), các thông số sau được cập nhật:

| Tham số | GitHub Sample (cũ) | Excel Workbook (mới) |
|---------|-------------------|---------------------|
| **DNS Zone** | cf.lab | lms.qnet.vn |
| **VCF Mgmt Domain** | cf.lab | qnet.edu.vn |
| **VM Mgmt Network** | 172.16.30.0/24 | 172.16.15.0/24 — VLAN 666 |
| **ESXi Mgmt Network** | 172.16.30.0/24 | 172.16.11.0/24 — VLAN 667 |
| **vMotion Network** | 172.30.32.0/24 | 172.16.12.0/24 — VLAN 668 |
| **vSAN Network** | 172.30.33.0/24 | 172.16.13.0/24 — VLAN 669 |
| **NSX TEP Network** | 172.30.34.0/24 | 172.16.14.0/24 — VLAN 670 |
| **Gateway** | 172.16.1.53 | 172.16.11.253 (Mgmt), 172.16.15.253 (VM) |
| **DNS Server** | 172.16.1.3 | 172.16.11.4 |
| **NTP Server** | 172.16.1.53 | n.pool.ntp.org / 172.16.11.4 |
| **Hostname Prefix** | cf-m01-* | sfo-m01-* / sfo01-m01-* |
| **SDDC Manager** | cf-m01-sddcm01 | sfo-vcf01 |
| **Password** | VMware1!VMware1! | Vmware@123!@# |
| **vCenter Size** | — | small |
| **NSX Size** | medium | medium |
| **vLCM** | — | Enabled |
| **Architecture** | — | Standard |
| **VDS Name** | — | sfo-m01-cluster-001-vds-001 |
| **Datacenter** | — | sfo-m01-datacenter |
| **Cluster** | — | sfo-m01-cluster-001 |
| **vSAN Datastore** | — | sfo-m01-cluster-001-vsan |
| **CEIP** | — | No |
| **FIPS** | — | No |
| **License Mode** | — | License Now |
| **MTU** | 1500 | 9000 (VM Mgmt, vMotion, vSAN) |
| **Portgroups** | custom | SDDC-DPortGroup-VM-Mgmt/Mgmt/vMotion/VSAN |
## 2. Yêu cầu & Phân tích

Chủ đầu tư yêu cầu hạ tầng VCF 5.2 với các workload sau:

| # | Hệ thống | Mô tả | CCU | Domain | Cluster |
|---|----------|-------|-----|--------|---------|
| 1 | Management Domain | SDDC, vCenter, NSX, vSAN | — | Mgmt | sfo-m01-cluster-001 |
| 2 | ERP + FCI (x2) | SAP/Oracle ERP + SQL Server FCI | 200 | vcf-w01 | w01-cluster-001 |
| 3 | BigData | Hadoop 2 + Apache Spark + IBM SPSS | — | vcf-w02 | w02-cluster-001 |
| 4 | Power BI Report Server | Power BI + SQL Server + Web FE | 2000 | vcf-w03 | w03-cluster-001 |
| 5 | Workload Domain 04 | General-purpose | — | vcf-w04 | w04-cluster-001 |
| 6 | Workload Domain 05 | General-purpose | — | vcf-w05 | w05-cluster-001 |
| 7 | Workload Domain 06 | General-purpose | — | vcf-w06 | w06-cluster-001 |
| 8 | Workload Domain 07 | General-purpose | — | vcf-w07 | w07-cluster-001 |

**Total: 1 Management Domain + 7 Workload Domains (3 specific + 4 additional)**

---

## 3. Sizing Calculation

### 3.1 Management Domain

VM Mgmt Network (172.16.15.0/24), ESXi Mgmt Network (172.16.11.0/24), vLCM enabled, vSAN OSA.

| Component | vCPU | RAM (GB) | Disk (GB) | Ghi chú |
|-----------|------|----------|-----------|---------|
| Cloud Builder VM | 4 | 8 | 200 | Transient |
| SDDC Manager (sfo-vcf01) | 4 | 12 | 200 | Orchestrator |
| vCenter Server small (sfo-m01-vc01) | 4 | 8 | 300 | Mgmt vCenter |
| NSX Manager medium (x3 nodes) | 6x3 | 24x3 | 300x3 | Cluster of 3 |
| **Subtotal (VMs)** | **30** | **100** | **1920** | |
| ESXi host (x4) | 32 cores/host | 512 GB/host | 2x 960GB cache + 4x 3.84TB capacity | vSAN OSA |

**Network Pool:** networkpool-001 | **VDS:** sfo-m01-cluster-001-vds-001 | **Profile:** Profile-1

### 3.2 Workload Domain 01 — ERP + FCI (200 CCU each)

| VM | Quantity | vCPU | RAM (GB) | Disk (GB) |
|----|----------|------|----------|-----------|
| ERP App Server (Active) | 2 | 8 | 32 | 100 |
| ERP App Server (Passive) | 2 | 8 | 32 | 100 |
| SQL Server FCI (Active) | 1 | 16 | 64 | 500 (shared) |
| SQL Server FCI (Passive) | 1 | 16 | 64 | 500 (shared) |
| **Subtotal** | **6** | **64** | **256** | **1200 + shared** |

**Cluster:** 4 hosts x 24 cores, 384 GB RAM, 2x 960GB cache + 4x 1.92TB

### 3.3 Workload Domain 02 — BigData (Hadoop2 + Spark + SPSS)

| VM | Quantity | vCPU | RAM (GB) | Disk (GB) |
|----|----------|------|----------|-----------|
| Hadoop NameNode (active) | 1 | 4 | 16 | 100 |
| Hadoop NameNode (standby) | 1 | 4 | 16 | 100 |
| Hadoop DataNode | 5 | 16 | 64 | 1000 |
| YARN ResourceManager | 2 | 4 | 16 | 50 |
| Spark Master | 1 | 4 | 16 | 100 |
| Spark Worker | 5 | 16 | 64 | 500 |
| IBM SPSS Modeler | 1 | 8 | 32 | 200 |
| IBM SPSS Collaboration | 1 | 4 | 16 | 100 |
| **Subtotal** | **17** | **132** | **504** | **~9 TB** |

**Cluster:** 6 hosts x 32 cores, 512 GB RAM, 2x 960GB cache + 6x 3.84TB

### 3.4 Workload Domain 03 — Power BI Report Server (2000 CCU)

| VM | vCPU | RAM (GB) | Disk (GB) |
|----|------|----------|-----------|
| Power BI Report Server | 16 | 64 | 200 |
| SQL Server (DB Engine) | 16 | 64 | 1000 |
| Web Frontend (IIS) | 8 | 32 | 100 |
| Power BI Gateway | 4 | 16 | 50 |
| **Subtotal** | **44** | **176** | **1350** |

**Cluster:** 4 hosts x 24 cores, 256 GB RAM, 2x 480GB cache + 4x 1.92TB

### 3.5 Workload Domains 04-07 (Additional)

| Domain | Hosts | Cores/host | RAM/host | Storage/host | Use case |
|--------|-------|------------|----------|----------------|----------|
| vcf-w04 | 4 | 16 | 256 GB | 2x 480GB + 4x 960GB | Dev/Test |
| vcf-w05 | 4 | 16 | 256 GB | 2x 480GB + 4x 960GB | Staging |
| vcf-w06 | 4 | 16 | 256 GB | 2x 480GB + 4x 960GB | Container/K8s |
| vcf-w07 | 4 | 16 | 256 GB | 2x 480GB + 4x 960GB | Misc workloads |

### 3.6 Tổng hợp tài nguyên vật lý

| Domain | Hosts | CPU cores | RAM (GB) | Raw Storage (TB) | Server Model |
|--------|-------|-----------|----------|------------------|--------------|
| Mgmt (sfo-m01) | 4 | 128 | 2048 | ~18 | Dell R760xa (2x Xeon Gold 6458Q 32C) |
| ERP-FCI (vcf-w01) | 4 | 96 | 1536 | ~10 | Dell R760xa (2x Xeon Gold 6438M 32C) |
| BigData (vcf-w02) | 6 | 192 | 3072 | ~28 | Dell R760xa (2x Xeon Platinum 8480+ 56C) |
| Power BI (vcf-w03) | 4 | 96 | 1024 | ~10 | Dell R760xa (2x Xeon Gold 6438M 32C) |
| WLD 04-07 | 16 | 256 | 4096 | ~24 | Dell R760 (2x Xeon Silver 4416+ 20C) |
| **TOTAL** | **34** | **768** | **11776** | **~90** | |
## 4. Credentials & Password Policy

Theo sheet **Credentials** (Broadcom VCF 5.2.1 DPW):

| Component | Username | Password | Description |
|-----------|----------|----------|-------------|
| **ESXi Hosts** | root | Vmware@123!@# | Same for all ESXi hosts |
| **vCenter Server** | administrator@vsphere.local | Vmware@123!@# | SSO Domain Administrator |
| **vCenter Server** | root | Vmware@123!@# | VCSA Root Account |
| **NSX Manager & Edge** | root | Vmware@123!@# | NSX Root Account |
| **NSX Manager & Edge** | admin | Vmware@123!@# | NSX UI & CLI Admin |
| **NSX Manager & Edge** | audit | Vmware@123!@# | NSX Audit CLI |
| **SDDC Manager** | root | Vmware@123!@# | SDDC Manager Root |
| **SDDC Manager** | vcf | Vmware@123!@# | SDDC Manager Super User |
| **SDDC Manager** | admin@local | Vmware@123!@# | SDDC Manager Local Account |

> Password Policy: Min length, uppercase, lowercase, number, special (@!#$%?^).
> If a component password is not specified, SDDC Manager Local Account password is used.

---

## 5. VLAN & IP Addressing Plan

### 5.1 Management Domain Networks (Underlay)

Theo sheet **Hosts and Networks**:

| Network Type | VLAN ID | Portgroup Name | CIDR | Gateway | MTU |
|-------------|---------|---------------|------|---------|-----|
| **VM Management Network** | 666 | SDDC-DPortGroup-VM-Mgmt | 172.16.15.0/24 | 172.16.15.253 | 9000 |
| **Management Network** | 667 | SDDC-DPortGroup-Mgmt | 172.16.11.0/24 | 172.16.11.253 | 1500 |
| **vMotion Network** | 668 | SDDC-DPortGroup-vMotion | 172.16.12.0/24 | 172.16.12.253 | 9000 |
| **vSAN Network** | 669 | SDDC-DPortGroup-VSAN | 172.16.13.0/24 | 172.16.13.253 | 9000 |
| **NSX Host Overlay (TEP)** | 670 | (IP Pool) | 172.16.14.0/24 | 172.16.14.1 | 9000 |

### 5.2 IP Allocation — Management Components (VM Mgmt Network, VLAN 666)

| Hostname | IP Address | Role |
|----------|------------|------|
| sfo-m01-cb01.lms.qnet.vn | 172.16.15.61 | Cloud Builder (transient) |
| sfo-vcf01.lms.qnet.vn | 172.16.15.62 | SDDC Manager |
| sfo-m01-vc01.lms.qnet.vn | 172.16.15.67 | vCenter Server (small) |
| sfo-m01-nsx01.lms.qnet.vn | 172.16.15.68 | NSX VIP (Cluster) |
| sfo-m01-nsx01a.lms.qnet.vn | 172.16.15.69 | NSX Node 1 |
| sfo-m01-nsx01b.lms.qnet.vn | 172.16.15.70 | NSX Node 2 |
| sfo-m01-nsx01c.lms.qnet.vn | 172.16.15.71 | NSX Node 3 |

### 5.3 IP Allocation — ESXi Hosts (Mgmt Network, VLAN 667)

| Hostname | Mgmt IP | vMotion IP | vSAN IP | NSX TEP IP |
|----------|---------|------------|---------|------------|
| sfo01-m01-esx01 | 172.16.11.101 | 172.16.12.101 | 172.16.13.101 | 172.16.14.101 |
| sfo01-m01-esx02 | 172.16.11.102 | 172.16.12.102 | 172.16.13.102 | 172.16.14.102 |
| sfo01-m01-esx03 | 172.16.11.103 | 172.16.12.103 | 172.16.13.103 | 172.16.14.103 |
| sfo01-m01-esx04 | 172.16.11.104 | 172.16.12.104 | 172.16.13.104 | 172.16.14.104 |

**IP Ranges (Inclusion):** vMotion Start=172.16.12.101 End=172.16.12.104 | vSAN Start=172.16.13.101 End=172.16.13.104 | NSX TEP Pool Start=172.16.14.101 End=172.16.14.108

### 5.4 Workload Segments (NSX Overlay)

| VLAN | Segment | Subnet | DFW Tag |
|------|---------|--------|---------|
| 100 | erp-app | 192.168.100.0/24 | ERP:App |
| 101 | erp-db | 192.168.101.0/24 | ERP:DB |
| 110 | erp-fci-witness | 192.168.110.0/24 | ERP:Witness |
| 200 | bigdata-hdfs | 192.168.200.0/24 | BD:HDFS |
| 201 | bigdata-spark | 192.168.201.0/24 | BD:Spark |
| 202 | bigdata-spss | 192.168.202.0/24 | BD:SPSS |
| 300 | pbi-web | 192.168.300.0/24 | PBI:Web |
| 301 | pbi-db | 192.168.301.0/24 | PBI:DB |
| 400-703 | wld04-07-* | 192.168.40x-70x.0/24 | WLDxx:* |
| 888 | DMZ | 10.255.255.0/24 | DMZ:External |

### 5.5 Workload Domains IP Allocation

| Domain | vCenter IP | NSX VIP | ESXi Mgmt IP Range |
|--------|------------|---------|-------------------|
| vcf-w01 (ERP-FCI) | 172.16.15.71 | 172.16.15.78 | 172.16.11.111-114 |
| vcf-w02 (BigData) | 172.16.15.81 | 172.16.15.88 | 172.16.11.121-126 |
| vcf-w03 (PowerBI) | 172.16.15.91 | 172.16.15.98 | 172.16.11.131-134 |
| vcf-w04 | 172.16.15.101 | 172.16.15.108 | 172.16.11.141-144 |
| vcf-w05 | 172.16.15.111 | 172.16.15.118 | 172.16.11.151-154 |
| vcf-w06 | 172.16.15.121 | 172.16.15.128 | 172.16.11.161-164 |
| vcf-w07 | 172.16.15.131 | 172.16.15.138 | 172.16.11.171-174 |
## 6. Deploy Parameters Summary

Theo sheet **Deploy Parameters**:

### 6.1 Existing Infrastructure

| Parameter | Value |
|-----------|-------|
| DNS Server #1 | 172.16.11.4 |
| DNS Zone Name | lms.qnet.vn |
| NTP Server #1 | vn.pool.ntp.org |
| NTP Server #2 | 172.16.11.4 |
| CEIP | No |
| FIPS Security Mode | No |

### 6.2 License Keys

| Parameter | Value |
|-----------|-------|
| License Mode | License Now |
| ESXi / vSAN / vCenter / NSX | (to be provided) |

### 6.3 vSphere Infrastructure

| Parameter | Value |
|-----------|-------|
| vCenter Hostname | sfo-m01-vc01 |
| vCenter Appliance Size | small |
| vCenter Storage Size | default |
| Datacenter Name | sfo-m01-datacenter |
| Cluster Name | sfo-m01-cluster-001 |
| Enable vLCM Cluster Image | Yes |
| Cluster EVC Setting | n/a |
| VCF Architecture | Standard |
| vSAN Datastore Name | sfo-m01-cluster-001-vsan |
| Enable vSAN Dedup/Compression | No |
| Enable vSAN-ESA | No |

### 6.4 NSX Configuration

| Parameter | Value |
|-----------|-------|
| NSX VIP Hostname | sfo-m01-nsx01 |
| NSX Node 1-3 Hostname | sfo-m01-nsx01a/b/c |
| NSX Appliance Size | medium |
| Transport VLAN ID | 670 |
| TEP Static IP Pool: CIDR | 172.16.14.0/24, GW 172.16.14.1 |
| TEP Static IP Pool: Range | 172.16.14.101 - 172.16.14.108 |

### 6.5 SDDC Manager

| Parameter | Value |
|-----------|-------|
| SDDC Manager Hostname | sfo-vcf01 |
| SDDC Manager IP | 172.16.15.62 |
| Network Pool Name | networkpool-001 |
| Management Domain Name | qnet.edu.vn |

### 6.6 VDS Configuration

| Parameter | Value |
|-----------|-------|
| Primary VDS Name | sfo-m01-cluster-001-vds-001 |
| Primary VDS pNICs | vmnic0,vmnic1 |
| Primary VDS MTU | 9000 |
| Transport Zone Type | Overlay/VLAN |
| Secondary VDS | n/a (Profile-1) |
| Overlay Transport Zone | qnet.edu.vn-tz-overlay01 |
| VLAN Transport Zone | qnet.edu.vn-tz-vlan01 |
## 7. ASCII Topology — VCF 5.2 Production Architecture

### Physical Network Layer (Spine-Leaf)

`
=================================================================================
               VCF 5.2 — PRODUCTION TOPOLOGY | lms.qnet.vn | qnet.edu.vn
=================================================================================

[INTERNET/WAN]                    [INTERNET/WAN]
       |                                  |
+------+------+                  +-------+--------+
| ASR1001-HX  |                  | ASR1001-HX    |
| WAN-RTR-01  |                  | WAN-RTR-02    |
| 172.16.0.1  |                  | 172.16.0.2    |
| BGP AS65000 |                  | BGP AS65000   |
+------+------+                  +-------+--------+
       |                                  |
       +--------------+   +---------------+
                      |   |
              +-------+---+--------+
              |     BGP/OSPF        |
              +---------+----------+
                        |
          +-------------+-------------+
          |                           |
+---------+--------+       +---------+--------+
| NEXUS-9332C-SP1  |       | NEXUS-9332C-SP2  |
| SPINE-01         |       | SPINE-02         |
| 172.16.254.1/32  |       | 172.16.254.2/32  |
| Serial: SAL2233X |       | Serial: SAL2233Y |
+---------+--------+       +---------+--------+
          |                           |
     +----+----+----+----+----+----+-+----+
     |    |    |    |    |    |    |    |    |
+----+--+ | +--+----+ | +--+----+ | +--+----+
| L01   | | | L02   | | | L03   | | | L04   |
|93180YC| | |93180YC| | |93180YC| | |93180YC|
|FGE2426| | |FGE2426| | |FGE2426| | |FGE2426|
+---+---+ | +---+---+ | +---+---+ | +---+---+
    |     |     |     |     |     |     |
    |     |     |     |     |     |     |
+---+-----+-----+-----+-----+-----+-----+---+
| [MGMT VDS: sfo-m01-cluster-001-vds-001]   |
| [SDDC-DPortGroup-VM-Mgmt/666, Mgmt/667,   |
|  vMotion/668, VSAN/669, NSX TEP/670]      |
+----------------------------------------------+
`

### Management Domain — sfo-m01 / qnet.edu.vn

`
.---------------------------------------------------------------------------.
|                    MANAGEMENT DOMAIN — sfo-m01 / qnet.edu.vn              |
|                                                                           |
|  VDS: sfo-m01-cluster-001-vds-001  |  Profile: Profile-1                 |
|  Transport: qnet.edu.vn-tz-overlay01  |  vLCM: Enabled                   |
|  NetPool: networkpool-001           |  License: Now                      |
|---------------------------------------------------------------------------|
|                                                                           |
|  .-------------------------- vSAN OSA Cluster (4x ESXi) ---------------.  |
|  |   Dell R760xa | 32C | 512GB | 2x960GB+4x3.84TB NVMe               |  |
|  |                                                                      |  |
|  |  sfo01-m01-esx01   sfo01-m01-esx02   sfo01-m01-esx03   esx04       |  |
|  |  Mgmt .101         Mgmt .102         Mgmt .103         .104         |  |
|  |  vMot .101         vMot .102         vMot .103         .104         |  |
|  |  vSAN .101         vSAN .102         vSAN .103         .104         |  |
|  |  TEP  .101         TEP  .102         TEP  .103         .104         |  |
|  |                                                                      |  |
|  '-------------------------------------------------------------------'  |
|                                                                           |
|  VM Management Network (VLAN 666, 172.16.15.0/24)                         |
|                                                                           |
|  [Cloud Builder]    [SDDC Manager]     [vCenter]       [NSX Cluster x3]   |
|  sfo-m01-cb01       sfo-vcf01          sfo-m01-vc01    sfo-m01-nsx01      |
|  172.16.15.61       172.16.15.62       172.16.15.67     .68 .69 .70 .71   |
|  (transient)        (orchestrator)     (small size)    (medium x3)        |
|                                                                           |
|  DNS: 172.16.11.4  |  NTP: vn.pool.ntp.org / 172.16.11.4                |
'---------------------------------------------------------------------------'
`

### Workload Domain 01 — ERP + FCI (vcf-w01)

`
.---------------------------------------------------------------------------.
|           WORKLOAD DOMAIN 01 — ERP + FCI (200 CCU x 2)                   |
|           vCenter: vcf-w01-vc01 (.71) | NSX VIP: vcf-w01-nsx01 (.78)    |
|---------------------------------------------------------------------------|
|  .--------------------- vSAN Cluster (4x ESXi) ------------------------.  |
|  |  vcf-w01-esx01     esx02        esx03        esx04                  |  |
|  |  .111              .112         .113         .114 (Mgmt IP)        |  |
|  |                                                                      |  |
|  |  [ERP-App-A01]   [ERP-App-A02]   [ERP-App-P01]   [ERP-App-P02]     |  |
|  |  8v 32GB          8v 32GB         8v 32GB          8v 32GB          |  |
|  |  [SQL-FCI-A]      [NSX Node1]    [SQL-FCI-P]      [NSX Node2]      |  |
|  |  16v 64GB         4v 16GB         16v 64GB          4v 16GB         |  |
|  '-------------------------------------------------------------------'  |  |
|  NSX Edge: Active/Standby  |  T0 BGP -> Physical ASR1001               |
|  Overlay: erp-app(192.168.100.0/24)  erp-db(192.168.101.0/24)         |
'---------------------------------------------------------------------------'
`

### Workload Domain 02 — BigData (vcf-w02)

`
.---------------------------------------------------------------------------.
|       WORKLOAD DOMAIN 02 — BigData (Hadoop2 + Spark + SPSS)              |
|       vCenter: vcf-w02-vc01 (.81) | NSX VIP: vcf-w02-nsx01 (.88)        |
|---------------------------------------------------------------------------|
|  .--------------------- vSAN Cluster (6x ESXi) ------------------------.  |
|  |  Dell R760xa | 56C | 512GB | 28TB raw                               |  |
|  |                                                                      |  |
|  |  esx01(.121)  esx02(.122)  esx03(.123)  esx04(.124) esx05(.125)     |  |
|  |                                                                      |  |
|  |  [NN+RM]     [SNN+RM2]     [DN+SW01]    [DN+SW02]    [DN+SW03]     |  |
|  |  4v 16GB      4v 16GB       16v 64GB      16v 64GB     16v 64GB    |  |
|  |  [SPSS-Mod]   [SPSS-Col]    [NSX Nodes]                             |  |
|  |  8v 32GB      4v 16GB       4v16x3                                  |  |
|  '-------------------------------------------------------------------'  |
|  NN=NameNode, SNN=Standby, RM=ResMgr, DN=DataNode, SW=SparkWorker      |
|  Overlay: HDFS(.200/24) Spark(.201/24) SPSS(.202/24) Mgmt(.210/24)    |
'---------------------------------------------------------------------------'
`

### Workload Domain 03 — Power BI (vcf-w03)

`
.---------------------------------------------------------------------------.
|           WORKLOAD DOMAIN 03 — Power BI Report Server (2000 CCU)         |
|           vCenter: vcf-w03-vc01 (.91) | NSX VIP: vcf-w03-nsx01 (.98)    |
|---------------------------------------------------------------------------|
|  .--------------------- vSAN Cluster (4x ESXi) ------------------------.  |
|  |  vcf-w03-esx01(.131)  esx02(.132)  esx03(.133)  esx04(.134)       |  |
|  |                                                                      |  |
|  |  [PBI-RS]      [SQL-SVR]       [Web-IIS]       [PBI-GW]            |  |
|  |  16v 64GB      16v 64GB        8v 32GB          4v 16GB            |  |
|  |  [NSX Node1]   [NSX Node2]    [NSX Node3]      [Edge VM]           |  |
|  |  4v 16GB       4v 16GB         4v 16GB           4v 8GB            |  |
|  '-------------------------------------------------------------------'  |
|  Overlay: Web(.300/24) DB(.301/24) GW(.302/24)                          |
'---------------------------------------------------------------------------'
`

### NSX 4.1.2 Overlay & Edge Cluster

`
.---------------------------------------------------------------------------.
|                         NSX 4.1.2 OVERLAY NETWORK                         |
|---------------------------------------------------------------------------|
|                                                                           |
|  Tier-0 Gateway (Active/Standby)                                          |
|  .--------------------------------------------------------------------.  |
|  | BGP Peering -> Cisco ASR1001 (Physical)  AS65001(VCF)->AS65000     |  |
|  | ECMP: Active-Active (both Edge VMs)                                 |  |
|  '--------------------------------+-----------------------------------'  |
|                                   |                                      |
|  .-------------------------------+-----------------------------------.  |
|  |  NSX Edge Cluster (Active/Standby per Domain)                     |  |
|  |  Large: 8vCPU 32GB 200GB disk | VLAN 50,51 for Edge Uplinks       |  |
|  '-------------------------------+-----------------------------------'  |
|                                   |                                      |
|  .-------------------------------+-----------------------------------.  |
|  |  Tier-1 Gateways per Domain: ERP-T1 BD-T1 PBI-T1 W04-W07-T1      |  |
|  '-------------------------------+-----------------------------------'  |
|                                   |                                      |
|  .-------------------------------+-----------------------------------.  |
|  |  NSX Segments (Overlay):                                          |  |
|  |  100-erp-app  101-erp-db  200-hdfs  201-spark  202-spss          |  |
|  |  300-pbi-web  301-pbi-db  400-w04  500-w05  600-w06  700-w07    |  |
|  '-------------------------------------------------------------------'  |
|                                                                           |
|  Transport Zones: Overlay=qnet.edu.vn-tz-overlay01                       |
|                   VLAN=qnet.edu.vn-tz-vlan01  |  Transport VLAN=670      |
'---------------------------------------------------------------------------'
`

## 8. Microsegment Layers for Services

### 8.1 Micro-segmentation Architecture (NSX Distributed Firewall)

`
.---------------------------------------------------------------------------.
|                  MICRO-SEGMENTATION LAYERS (Zero Trust Model)              |
|---------------------------------------------------------------------------|
|                                                                           |
|  LAYER 0 — Physical Infrastructure (OOB)                                 |
|  .--------------------------------------------------------------------.  |
|  | Permit: iDRAC/BMC (OOB), NTP/DNS (VLAN 667)                        |  |
|  | Deny: All other traffic from OOB                                     |  |
|  '--------------------------------------------------------------------'  |
|                                                                           |
|  LAYER 1 — Management Infrastructure (Mgmt Domain)                      |
|  .--------------------------------------------------------------------.  |
|  | Permit: AD/LDAP -> sfo-vcf01, vc01, nsx01                           |  |
|  | Permit: sfo-vcf01 -> ESXi (443, 902)                                 |  |
|  | Permit: vCenter -> ESXi (443, 902)                                   |  |
|  | Permit: NSX -> ESXi TEP (Geneve 6081)                                |  |
|  | Permit: vSAN (2233-2234) within cluster                              |  |
|  | Permit: vMotion (8000) within cluster                                |  |
|  | Deny: All ingress from Workload Domains                              |  |
|  '--------------------------------------------------------------------'  |
|                                                                           |
|  LAYER 2 — Edge / Gateway Services                                      |
|  .--------------------------------------------------------------------.  |
|  | Permit: BGP (179) T0 -> Physical Router                              |  |
|  | Permit: SNAT/DNAT, LB VIP traffic                                    |  |
|  | Deny: East-West Inter-Domain (except approved cross-domain)          |  |
|  '--------------------------------------------------------------------'  |
|                                                                           |
|  LAYER 3 — Workload Domains (Per-Domain Isolation)                      |
|  .--------------------------------------------------------------------.  |
|  | ERP: erp-app -> erp-db MSSQL(1433)  | ERP -> Mgmt AD/DNS/NTP only    |  |
|  | BD: hdfs <-> spark YARN shuffle      | SPSS(15301)                   |  |
|  | PBI: pbi-web -> pbi-db SQL(1433)     | pbi-web -> Internet HTTPS     |  |
|  | Default: Drop all inter-segment traffic unless allowed               |  |
|  '--------------------------------------------------------------------'  |
|                                                                           |
|  LAYER 4 — DMZ / External-Facing                                        |
|  .--------------------------------------------------------------------.  |
|  | Permit: HTTPS(443) Internet -> DMZ Reverse Proxy                     |  |
|  | Permit: Reverse Proxy -> erp-app, pbi-web                            |  |
|  | Deny: All other inbound                                              |  |
|  '--------------------------------------------------------------------'  |
|                                                                           |
|  LAYER 5 — Cross-Domain (Inter-Workload)                                |
|  .--------------------------------------------------------------------.  |
|  | erp-app -> pbi-gw: ODBC(1433) [Log]  | hdfs -> pbi-web: HTTP [Log]   |  |
|  | All other cross-domain: Drop (zero-trust)                            |  |
|  '--------------------------------------------------------------------'  |
'---------------------------------------------------------------------------'
`

### 8.2 Services Micro-segmentation Table

| Layer | Segment | Source | Destination | Protocol:Port | Action |
|-------|---------|--------|-------------|---------------|--------|
| L1 | Mgmt | AD/DNS | SDDC, VCSA, NSX | LDAP:389, DNS:53 | Allow |
| L1 | Mgmt | SDDC Mgr | ESXi Hosts | HTTPS:443, CIM:902 | Allow |
| L1 | Mgmt | vCenter | ESXi Hosts | HTTPS:443, CIM:902 | Allow |
| L1 | Mgmt | NSX Mgr | ESXi TEP | Geneve:6081 | Allow |
| L1 | Mgmt | ESXi-vSAN | ESXi-vSAN | vSAN:2233-2234 | Allow |
| L1 | Mgmt | ESXi-vMotion | ESXi-vMotion | vMotion:8000 | Allow |
| L2 | Edge | T0 Router | Physical-RTR | BGP:179 | Allow |
| L3 | ERP | erp-app | erp-db | MSSQL:1433 | Allow |
| L3 | BD | hdfs-nn | hdfs-dn | HDFS:8020,50070 | Allow |
| L3 | BD | spark-master | spark-worker | Spark:7077,8080 | Allow |
| L3 | BD | spss-mod | spss-col | SPSS:15301 | Allow |
| L3 | BD | hdfs | spark | YARN:8032-8042 | Allow |
| L3 | PBI | pbi-web | pbi-db | MSSQL:1433 | Allow |
| L4 | DMZ | internet | dmz-rproxy | HTTPS:443 | Allow |
| L5 | Cross | erp-app | pbi-gw | ODBC:1433 | Allow (Log) |
| L5 | Cross | hdfs | pbi-web | HTTP:50070 | Allow (Log) |
| L0-5 | All | Any | Any | Any | **Drop** (Default) |

## 9. Physical Switch Information

### 9.1 Spine Switches (Cisco Nexus 9332C)

| Property | Spine-01 | Spine-02 |
|----------|----------|----------|
| Model | Cisco Nexus 9332C | Cisco Nexus 9332C |
| Serial | SAL2233XXXX | SAL2233YYYY |
| OS | NX-OS 10.2(6) | NX-OS 10.2(6) |
| Ports | 32x 100GbE QSFP28 | 32x 100GbE QSFP28 |
| Mgmt IP | 172.16.254.1/32 | 172.16.254.2/32 |
| Role | Spine (EVPN RR) | Spine (EVPN RR) |

### 9.2 Leaf Switches (Cisco Nexus 93180YC-FX)

| Property | Leaf-01 | Leaf-02 | Leaf-03 | Leaf-04 |
|----------|---------|---------|---------|---------|
| Model | N9K-C93180YC-FX | N9K-C93180YC-FX | N9K-C93180YC-FX | N9K-C93180YC-FX |
| Serial | FGE2426A | FGE2426B | FGE2426C | FGE2426D |
| OS | NX-OS 10.2(6) | NX-OS 10.2(6) | NX-OS 10.2(6) | NX-OS 10.2(6) |
| Downlink | 48x 25GbE SFP28 | 48x 25GbE SFP28 | 48x 25GbE SFP28 | 48x 25GbE SFP28 |
| Uplink | 6x 100GbE QSFP28 | 6x 100GbE QSFP28 | 6x 100GbE QSFP28 | 6x 100GbE QSFP28 |
| Mgmt IP | 172.16.254.11/32 | 172.16.254.12/32 | 172.16.254.13/32 | 172.16.254.14/32 |

### 9.3 Management Switches (Cisco Nexus 93108TC-FX)

| Property | Mgmt-SW-01 | Mgmt-SW-02 |
|----------|------------|------------|
| Model | Cisco Nexus 93108TC-FX | Cisco Nexus 93108TC-FX |
| Serial | FOC2427A | FOC2427B |
| OS | NX-OS 10.2(6) | NX-OS 10.2(6) |
| Ports | 48x 10GbE Base-T + 6x 100GbE | 48x 10GbE Base-T + 6x 100GbE |
| Role | OOB Mgmt + iDRAC | OOB Mgmt + iDRAC |

### 9.4 WAN Edge Routers

| Property | WAN-RTR-01 | WAN-RTR-02 |
|----------|------------|------------|
| Model | Cisco ASR1001-HX | Cisco ASR1001-HX |
| Serial | FTX2412XXXX | FTX2412YYYY |
| OS | IOS-XE 17.9.1 | IOS-XE 17.9.1 |
| Ports | 8x 1GbE + 4x 10GbE | 8x 1GbE + 4x 10GbE |
| BGP ASN | 65000 | 65000 |
| Role | WAN Edge (Active) | WAN Edge (Standby) |

### 9.5 Server Hardware

| Domain | Server Model | CPU | RAM | Storage (vSAN) | Qty |
|--------|-------------|-----|-----|----------------|-----|
| sfo-m01 (Mgmt) | Dell R760xa | 2x Xeon Gold 6458Q (32C) | 512 GB DDR5 | 2x 960GB cache + 4x 3.84TB | 4 |
| vcf-w01 (ERP) | Dell R760xa | 2x Xeon Gold 6438M (32C) | 384 GB DDR5 | 2x 960GB cache + 4x 1.92TB | 4 |
| vcf-w02 (BigData) | Dell R760xa | 2x Xeon Platinum 8480+ (56C) | 512 GB DDR5 | 2x 960GB cache + 6x 3.84TB | 6 |
| vcf-w03 (PBI) | Dell R760xa | 2x Xeon Gold 6438M (32C) | 256 GB DDR5 | 2x 480GB cache + 4x 1.92TB | 4 |
| vcf-w04-07 | Dell R760 | 2x Xeon Silver 4416+ (20C) | 256 GB DDR5 | 2x 480GB cache + 4x 960GB | 16 |


## 10. Config File Build (References)

Các tham số JSON chính từ Excel Workbook (Config_File_Build sheet) dùng cho Cloud Builder:

### 10.1 Global Settings

```json
{
  "workflowType": "VCF",
  "ceipEnabled": false,
  "fipsEnabled": false,
  "deployWithoutLicenseKeys": false,
  "workflowVersion": "vcf-ems=5.2.1"
}
```

### 10.2 NTP & DNS

```json
{
  "ntpSpec": {
    "ntpServers": [
      { "address": "vn.pool.ntp.org" },
      { "address": "172.16.11.4" }
    ]
  },
  "dnsSpec": {
    "domain": { "zoneName": "lms.qnet.vn" },
    "nameserver": "172.16.11.4",
    "subdomain": { "zoneName": "lms.qnet.vn" }
  }
}
```

### 10.3 SDDC Manager

```json
{
  "sddcManagerSpec": {
    "hostname": "sfo-vcf01",
    "ipAddress": "172.16.15.62",
    "rootUserCredentials": { "password": "Vmware@123!@#" },
    "secondUserCredentials": { "password": "Vmware@123!@#" },
    "localUserPassword": "Vmware@123!@#"
  },
  "managementPoolName": "networkpool-001",
  "sddcManager-mgmt-domainName": "qnet.edu.vn"
}
```

### 10.4 ESXi Hosts

```json
{
  "esxiHostSpecs": {
    "esxiCredentials": {
      "userName": "root",
      "password": "Vmware@123!@#"
    },
    "association": {
      "datacenter": "sfo-m01-datacenter"
    },
    "hosts": [
      { "hostname": "sfo01-m01-esx01", "ipAddress": "172.16.11.101" },
      { "hostname": "sfo01-m01-esx02", "ipAddress": "172.16.11.102" },
      { "hostname": "sfo01-m01-esx03", "ipAddress": "172.16.11.103" },
      { "hostname": "sfo01-m01-esx04", "ipAddress": "172.16.11.104" }
    ]
  },
  "esxLicense": "(to be provided)",
  "skipEsxThumbprintValidation": false
}
```

### 10.5 Cluster / vCenter / NSX Summary

```json
{
  "clusterSpecs": {
    "clusterId": "sfo-m01-cluster-001",
    "clusterImageEnabled": true,
    "clusterEvcMode": "n/a",
    "resourcePoolSpecs": { "skipResourcePoolCreation": true }
  },
  "vCenterSpecs": {
    "vcenterHostname": "sfo-m01-vc01",
    "vcenterIP": "172.16.15.67",
    "vmSize": "small",
    "rootVcenterPassword": "Vmware@123!@#",
    "adminUserSsoPassword": "Vmware@123!@#"
  },
  "nsxtSpec": {
    "nsxtManagerSize": "medium",
    "vipFqdn": "sfo-m01-nsx01",
    "vip": "172.16.15.68",
    "nsxtManagers": [
      { "hostname": "sfo-m01-nsx01a", "ip": "172.16.15.69" },
      { "hostname": "sfo-m01-nsx01b", "ip": "172.16.15.70" },
      { "hostname": "sfo-m01-nsx01c", "ip": "172.16.15.71" }
    ],
    "nsxtAdminPassword": "Vmware@123!@#",
    "rootNsxtManagerPassword": "Vmware@123!@#",
    "nsxtAuditPassword": "Vmware@123!@#",
    "sshEnabledForNsxtManager": true,
    "rootLoginEnabledForNsxtManager": true,
    "overLayTransportZones": {
      "zoneName": "qnet.edu.vn-tz-overlay01"
    },
    "vlanTransportZones": {
      "zoneName": "qnet.edu.vn-tz-vlan01"
    },
    "transportVlanId": 670,
    "ipAddressPoolSpec": {
      "name": "sfo01-m01-cl01-tep01",
      "description": "ESXi Host Overlay TEP IP Pool",
      "subnets": [{
        "cidr": "172.16.14.0/24",
        "gateway": "172.16.14.1",
        "ipAddressPoolRanges": [{
          "start": "172.16.14.101",
          "end": "172.16.14.108"
        }]
      }]
    }
  }
}
```

### 10.6 Network Specs

```json
{
  "dvsSpecs": {
    "dvsId": "sfo-m01-cluster-001-vds-001",
    "vmnics": "vmnic0,vmnic1",
    "mtu": 9000,
    "vds-profile": "Profile-1"
  },
  "networkSpecs": {
    "subnets": [
      { "type": "VM_MANAGEMENT", "cidr": "172.16.15.0/24", "gateway": "172.16.15.253", "vlanId": 666, "mtu": 9000, "portGroup": "SDDC-DPortGroup-VM-Mgmt" },
      { "type": "MANAGEMENT",   "cidr": "172.16.11.0/24", "gateway": "172.16.11.253", "vlanId": 667, "mtu": 1500, "portGroup": "SDDC-DPortGroup-Mgmt" },
      { "type": "VMOTION",      "cidr": "172.16.12.0/24", "gateway": "172.16.12.253", "vlanId": 668, "mtu": 9000, "portGroup": "SDDC-DPortGroup-vMotion" },
      { "type": "VSAN",         "cidr": "172.16.13.0/24", "gateway": "172.16.13.253", "vlanId": 669, "mtu": 9000, "portGroup": "SDDC-DPortGroup-VSAN" }
    ],
    "includeIpAddressRanges": [
      { "type": "VMOTION", "start": "172.16.12.101", "end": "172.16.12.104" },
      { "type": "VSAN",    "start": "172.16.13.101", "end": "172.16.13.104" }
    ]
  }
}
```

---

## Summary

| Resource | Total |
|----------|-------|
| Physical Servers | 34 |
| CPU Cores | 768 |
| RAM | ~11.5 TB |
| Raw Storage | ~90 TB |
| ToR/Leaf Switches | 4x Nexus 93180YC-FX |
| Spine Switches | 2x Nexus 9332C |
| Mgmt Switches | 2x Nexus 93108TC-FX |
| WAN Routers | 2x ASR1001-HX |
| NSX Version | 4.1.2 |
| ESXi Version | 8.0 U3 |
| vSAN Version | 8.0 U3 (OSA) |
| VCF Version | 5.2 (DPW 5.2.1) |
| VLANs | 30+ (10 physical + 20+ overlay) |
| Micro-seg Rules | 25+ (DFW + Gateway Firewall) |

### Design Notes

1. **vSAN OSA** cho tất cả domain; ESA optional cho BigData nếu all-NVMe.
2. **NSX Edge Cluster**: 2 Edge VMs per domain Active/Standby, Large form factor.
3. **DFW Zero Trust**: Mọi segment được bảo vệ bởi NSX Distributed Firewall, default-deny. L7 App-ID cho MSSQL, SAP, HTTP, HDFS.
4. **Single VDS Profile**: Profile-1 (sfo-m01-cluster-001-vds-001) với Overlay/VLAN, MTU 9000, pNICs vmnic0,vmnic1. Secondary VDS = n/a.
5. **vLCM**: Enabled cho Management Domain cluster image.
6. **N+1 Redundancy**: Mỗi cluster có 1 host spare.
7. **Networking**: BGP-EVPN (VXLAN) Spine-Leaf fabric. Overlay NSX Geneve (6081).
8. **Management Domain**: qnet.edu.vn, DNS zone lms.qnet.vn, vCenter small size, NSX medium x3.

---

*Document generated for VCF 5.2 Production Deployment Planning (Bài tập Sample 1).*
*Based on thang_vcf-ems-deployment-parameter.xlsx (Broadcom DPW v5.2.1).*

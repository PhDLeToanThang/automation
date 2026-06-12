# BÁO CÁO NÂNG CẤP HỆ THỐNG GIÁM SÁT VẬN HÀNH CHỦ ĐỘNG & XÁC ĐỊNH RỦI RO HỆ THỐNG DCV

## Thông tin tài liệu

| Mục | Nội dung |
|-----|----------|
| **Tên báo cáo** | Giải pháp thu thập và xử lý Log hệ thống ESXi, vCenter với RvTools 4.7 |
| **Phiên bản** | 1.0 |
| **Ngày** | 12/06/2026 |
| **Đơn vị** | Phòng Vận hành Hạ tầng CNTT |
| **Phân loại** | Nội bộ |

---

## 1. Tổng quan

### 1.1 Bối cảnh

Hệ thống **Data Center Virtualization (DCV)** dựa trên nền tảng VMware vSphere là xương sống hạ tầng CNTT của doanh nghiệp. Việc vận hành chủ động — thay vì phản ứng khi đã xảy ra sự cố — đòi hỏi một hệ thống giám sát có khả năng:

- Thu thập tự động cấu hình, trạng thái và metric từ **ESXi** và **vCenter Server**
- Phân tích tương quan giữa các lớp: **Compute (CPU/RAM)**, **Storage**, **Network**, **Cluster**
- Phát hiện sớm các rủi ro: overcommit, orphan snapshot, VMware Tools lỗi thời, cấu hình bất thường
- Trực quan hóa dữ liệu qua Dashboard và cơ chế cảnh báo

### 1.2 Mục tiêu

1. **Xây dựng hệ thống AnalyticsLOG cơ sở** nhằm thu thập, chuẩn hóa dữ liệu từ RvTools 4.7 export thành nguồn dữ liệu tin cậy
2. **Tích hợp dữ liệu DCV vào Elastic SIEM** đã triển khai (ELK Stack 9.4.2) để mở rộng khả năng giám sát bảo mật và vận hành
3. **Thiết lập quy trình xác định rủi ro** dựa trên 4 nhóm KPI chính: vCPU, vMemory, vPartition (disk), vTools/vHealth
4. **Chủ động phát hiện nguy cơ** trước khi ảnh hưởng đến hoạt động kinh doanh

---

## 2. Kiến trúc tổng thể giải pháp

### 2.1 Sơ đồ kiến trúc

```
+============================================================+
|                  HỆ THỐNG VMWARE vSPHERE                    |
|  +------------------+    +-------------------------------+  |
|  |   vCenter Server  |    |  ESXi Cluster 1..N           |  |
|  |   (SSC/SRV)       |    |  +-----+ +-----+ +-----+   |  |
|  |   APIs + Logs     |    |  |ESXi1| |ESXi2| |ESXiN|   |  |
|  +--------+----------+    |  +-----+ +-----+ +-----+   |  |
|           |               |  Datastores / Networks      |  |
|           |               +-----------------------------+  |
+-----------+------------------------------------------------+
            |
            | (PowerCLI / SDK Export - Scheduled Task)
            v
+============================================================+
|            LỚP THU THẬP - RvTools 4.7 ENGINE               |
|                                                             |
|  RvTools.exe export-all + tabvHost, tabvCPU, tabvMemory,   |
|  tabvPartition, tabvDatastore, tabvTools, tabvHealth,      |
|  tabvCluster, tabvNetwork, tabvSC_VMK, tabvDisk ... (26 tab)|
|                                                             |
|  Output: 1 file Excel (.xlsx) hoặc 26 file CSV              |
+----------------------------+-------------------------------+
                             |
              (Upload / Copy tự động)
                             v
+============================================================+
|          LỚP ETL - ANALYTICS ENGINE (Python 3.11)          |
|                                                             |
|  Extract -> Parse -> Transform -> Load                     |
|  + Kiểm tra trùng lặp (fingerprint theo tên file + UUID)   |
|  + Map cột Excel/CSV vào Schema Prisma                    |
|  + Chuẩn hóa kiểu dữ liệu, làm sạch                         |
|  + Ghi vào SQLite / PostgreSQL                             |
+----------------------------+-------------------------------+
                             |
                             v
+============================================================+
|         LỚP LƯU TRỮ & ORM (SQLite + Prisma)               |
|                                                             |
|  +----------+  +--------+  +---------+  +----------+       |
|  | VHost    |  | VCPU   |  | VMemory |  | VPartition|     |
|  +----------+  +--------+  +---------+  +----------+       |
|  +----------+  +--------+  +---------+  +----------+       |
|  | VCluster |  | VDisk  |  | VTools  |  | VHealth  |     |
|  +----------+  +--------+  +---------+  +----------+       |
|  +----------+  +--------+  +---------+  +----------+       |
|  | VInfo    |  | VNIC   |  | VSwitch |  | VDvSwitch|     |
|  +----------+  +--------+  +---------+  +----------+       |
|  +----------+  +--------+  +---------+  +----------+       |
|  | VSNAPSHOT|  |VLicense|  | VSC_VMK |  + UploadHistory  |
|  +----------+  +--------+  +---------+  +------------------ |
+----------------------------+-------------------------------+
                             |
                             v
+============================================================+
|            LỚP API & TRỰC QUAN HÓA (Next.js 16)           |
|                                                             |
|  +----------------+  +-----------------+  +-----------+    |
|  | InputDataTab   |  | ProcessDataTab  |  |MetricTab  |    |
|  | (Upload lịch   |  | (Grid dữ liệu   |  |(Chart:    |    |
|  |  sử, upload    |  |  26 bảng,       |  | CPU, RAM, |    |
|  |  mới)          |  |  search, filter) |  | Datastore)|    |
|  +----------------+  +-----------------+  +-----------+    |
|  +----------------+  +-----------------+  +-----------+    |
|  | KpiTab         |  | OrkiRiskTab     |  | AIDetect  |    |
|  | (vCPU, vMem,   |  | (Vulnerability, |  | (ML-based |    |
|  |  Partition KPI)|  |  Compliance,    |  |  anomaly) |    |
|  |                |  |  Out-of-date)   |  |           |    |
|  +----------------+  +-----------------+  +-----------+    |
+----------------------------+-------------------------------+
                             |
                             v
+============================================================+
|      LỚP TÍCH HỢP SIEM - ELK STACK 9.4.2 + DSIEM          |
|                                                             |
|  Filebeat -> Logstash -> Elasticsearch -> Kibana           |
|    + DSIEM Correlation Engine                               |
|    + Alerting Rules (Elastic Rules + Custom)                |
|    + Cases & Workflows (SOAR)                               |
+============================================================+
```

### 2.2 Luồng dữ liệu chi tiết

| Bước | Thành phần | Mô tả | Cơ chế |
|------|-----------|-------|--------|
| 1 | **Source** | ESXi Hosts, vCenter Server | VMware APIs / PowerCLI |
| 2 | **Extract** | RvTools 4.7 chạy schedule (daily) | `RvTools.exe -s <vCenter> -u <user> -p <pass> -c export-all` |
| 3 | **Transport** | File .xlsx/.csv được copy/upload tự động | Robocopy / Script tự động upload qua REST API |
| 4 | **ETL** | Python engine xử lý dữ liệu | Pandas + Openpyxl → đọc từ Excel, map schema, kiểm tra trùng |
| 5 | **Store** | Ghi vào SQLite/PostgreSQL qua Prisma ORM | `prisma.db` + `UploadHistory` (dedup) |
| 6 | **API** | Next.js API Routes cấp dữ liệu cho Dashboard | RESTful JSON APIs |
| 7 | **Visualize** | Dashboard tương tác (5 tabs) + Export báo cáo | React + Recharts + Tailwind |
| 8 | **SIEM Integration** | Đẩy cảnh báo KPI/Risk vào ELK Stack | Python script → Filebeat → Logstash → ES |
| 9 | **Correlation** | DSIEM engine tương quan sự kiện DCV với security events | NATS message bus + Directive rules |

---

## 3. Chi tiết kỹ thuật các thành phần

### 3.1 Lớp thu thập — RvTools 4.7 Engine

RvTools 4.7 là công cụ miễn phí của Robware, kết nối đến vCenter Server qua **VMware VI SDK** và xuất toàn bộ cấu hình, trạng thái của hệ thống vSphere ra file Excel/CSV.

#### 3.1.1 Các bảng dữ liệu thu thập

| Nhóm | Bảng RVTools | Mô tả | Số cột |
|------|-------------|-------|--------|
| **vCenter Info** | `vInfo` | Thông tin vCenter Server (version, build, UUID) | ~12 |
| **Compute** | `vHost` | ESXi hosts, CPU/Mem usage, VM count | ~35 |
| | `vCPU` | VM CPU config, usage, shares, limit | ~16 |
| | `vMemory` | VM Memory config, balloon, swap, active | ~18 |
| | `vCluster` | Cluster info: hosts, CPU, memory capacity | ~14 |
| **Storage** | `vDatastore` | Datastore capacity, provisioning, free space | ~14 |
| | `vPartition` | VM disk partition (OS-level) usage | ~9 |
| | `vDisk` | VM virtual disk config, thin/thick, mode | ~14 |
| | `vFileInfo` | VM file info (vmdk, vmx size) | ~12 |
| **Network** | `vNetwork` | VM NIC config, IP, MAC | ~18 |
| | `vSC_VMK` | ESXi VMkernel adapters (management, vMotion, VSAN) | ~12 |
| | `vNIC` | ESXi physical NIC | ~14 |
| | `vSwitch` | Standard vSwitch config | ~9 |
| | `vDvSwitch` | Distributed vSwitch config | ~9 |
| **Security/Health** | `vTools` | VMware Tools status per VM | ~12 |
| | `vHealth` | ESXi health status (sensor, hardware) | ~10 |
| **License/Compliance** | `vLicense` | License inventory and usage | ~10 |
| | `vSnapshot` | VM snapshot info, size, age | ~10 |
| **Others** | `vCD`, `vUSB`, `vHBA`, `vMultiPath`, `vPort`, `vDvPort`, `vRP`, `vSource`, `vSwitch` | Thiết bị CD/USB, HBA, Multipath, Port, Resource Pool | 5-12 mỗi bảng |

#### 3.1.2 Lịch trình thu thập

```
+-------------------+---------------+--------------------+
| Loại thu thập     | Tần suất      | Thời điểm          |
+-------------------+---------------+--------------------+
| Full export       | 1 lần/ngày    | 02:00 AM           |
| (all 26 tabs)     |               |                    |
| Quick check       | 4 lần/ngày    | 06/12/18/22h       |
| (vHost, vTools,   |               |                    |
|  vHealth, vCluster)|              |                    |
| On-demand         | Khi có yêu    | Theo yêu cầu       |
|                   | cầu / sự cố   |                    |
+-------------------+---------------+--------------------+
```

#### 3.1.3 Cấu hình Auto-Export Script (PowerShell)

```powershell
# RvTools Auto Export - Scheduled Task
param(
    [string]$vCenter = "vcenter.domain.com",
    [string]$outputDir = "\\NAS\rvtools\export"
)

$rvTools = "C:\Program Files (x86)\Robware\RVTools\RVTools.exe"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH.mm.ss"
$outputFile = "$outputDir\RVTools_export_$timestamp.xlsx"

# Execute full export
& $rvTools -s $vCenter -u svc-rvtools@domain.com `
    -p (Get-Content "C:\secrets\rvtools.key" | ConvertTo-SecureString) `
    -c export-all -filename $outputFile

# Kiểm tra kết quả
if (Test-Path $outputFile) {
    # Upload lên Analytics Engine
    Invoke-RestMethod -Uri "https://analytics.domain.com/api/upload" `
        -Method POST `
        -Form @{ file = Get-Item $outputFile }
}
```

### 3.2 Lớp ETL — Xử lý và chuẩn hóa dữ liệu

#### 3.2.1 Kiến trúc ETL Pipeline

```
+------------+    +-----------+    +-----------+    +----------+
|   EXTRACT  | -> | TRANSFORM | -> |  VALIDATE | -> |   LOAD   |
+------------+    +-----------+    +-----------+    +----------+
      |                |                |               |
1. Đọc Excel    2. Map cột       3. Check       6. Insert
   (Openpyxl)      theo schema      kiểu dữ liệu    vào DB
                    tương ứng       null check
                      |                |
                 4. Chuẩn hóa    5. Dedup
                    tên cột         fingerprint
                    (trim, lower)   (file + UUID)
```

#### 3.2.2 Xử lý Deduplication (Chống trùng lặp)

Cơ chế chống trùng dữ liệu dựa trên **fingerprint triple**:

```
Dedup Key = SHA256(fileName + "::" + viSdkUuid + "::" + fileSize)
```

- Nếu `UploadHistory` đã tồn tại record → bỏ qua, ghi log "skipped"
- Nếu file mới → tạo `UploadHistory.status = 'processing'`, sau đó cập nhật thành 'completed' hoặc 'failed'

#### 3.2.3 Schema Mapping thông minh

```python
TABLE_MAPPING = {
    'RVTools_tabvHost.csv': {
        'model': 'RVHost',
        'columns': {
            'Host': 'host', 'Cluster': 'cluster',
            'CPU usage %': 'cpuUsage', 'Memory usage %': 'memoryUsage',
            'Num CPU': 'numVcpus', 'VM used Memory': 'vmUsedMemory',
            'VM swapped Memory': 'vmMemorySwapped',
            'VM ballooned Memory': 'vmMemoryBallooned',
        },
        'types': {'cpuUsage': 'float', 'memoryUsage': 'float'}
    },
    'RVTools_tabvTools.csv': {
        'model': 'RVTools',
        'critical_columns': ['Tools', 'Tools Status', 'Status'],
        'types': {'ToolsVersion': 'int'}
    },
    # ... mapping cho toàn bộ 26 bảng
}
```

#### 3.2.4 Xử lý lỗi và logging

| Loại lỗi | Xử lý | Fallback |
|----------|-------|----------|
| File không đúng định dạng | Ghi log + chuyển vào thư mục `error/` | Bỏ qua file, báo admin |
| Cột thiếu hoặc sai tên | Tự động map theo fuzzy matching (>=80% similarity) | Báo warning, vẫn xử lý |
| Kiểu dữ liệu không khớp | Cast tự động (str→float, str→int) | Dùng giá trị NULL |
| Kết nối DB lỗi | Retry 3 lần (backoff 1s, 5s, 15s) | Ghi log + fail status |
| Dữ liệu rỗng (empty sheet) | Bỏ qua sheet, ghi log | Không ảnh hưởng pipeline |

### 3.3 Lớp lưu trữ — Database Schema (Prisma ORM)

#### 3.3.1 Mô hình dữ liệu

```prisma
// UploadHistory - Quản lý lịch sử upload
model UploadHistory {
  id          String   @id @default(cuid())
  fileName    String
  uploadDate  DateTime @default(now())
  fileSize    BigInt
  recordCount Int
  status      String   // completed | failed | skipped
  errorMessage String?
  viSdkServer String?
  viSdkUuid   String?

  // Relations đến tất cả bảng dữ liệu
  hosts       RVHost[]
  clusters    RVCluster[]
  datastores  RVDatastore[]
  cpuRecords  RVCPU[]
  memoryRec   RVMemory[]
  partitions  RVPartition[]
  tools       RVTools[]
  health      RVHealth[]
  // ... v.v.

  @@unique([fileName, viSdkServer])
  @@index([uploadDate])
}

// Mô hình đại diện: RVHost
model RVHost {
  id              String   @id @default(cuid())
  uploadId        String
  host            String
  datacenter      String?
  cluster         String?
  cpuUsage        Float?    // KPI: CPU usage
  memoryUsage     Float?    // KPI: Memory usage
  numVms          Int?
  numVcpus        Int?
  // ...
  createdAt       DateTime @default(now())
  uploadHistory   UploadHistory @relation(fields: [uploadId], references: [id])
}

// Mô hình đại diện: RVPartition (Disk KPI)
model RVPartition {
  id            String   @id @default(cuid())
  uploadId      String
  vm            String
  disk          String?
  capacityMiB   BigInt?
  consumedMiB   BigInt?
  freeMiB       BigInt?
  freePercent   String?   // KPI: Free space %
  uploadHistory UploadHistory @relation(fields: [uploadId], references: [id])
}
```

#### 3.3.2 Tổng số tables

| Loại | Số lượng | Ghi chú |
|------|---------|---------|
| Bảng dữ liệu | 26 | Tương ứng 26 tab RVTools |
| Bảng quản lý | 1 | UploadHistory |
| Tổng cộng | 27 | 27 models trong Prisma schema |

### 3.4 Lớp API — Next.js Backend

#### 3.4.1 Danh mục API endpoints

| Endpoint | Method | Mô tả | Response |
|----------|--------|-------|----------|
| `/api/upload` | POST | Upload file Excel/CSV | `{processedFiles, skippedFiles, results}` |
| `/api/upload/history` | GET | Lịch sử upload | `UploadHistory[]` |
| `/api/process-data` | GET | Dữ liệu grid theo bảng | `{data, summary}` |
| `/api/metrics` | GET | Metric CPU, RAM, Datastore | `{hostMetrics, memoryMetrics, datastoreMetrics, clusterMetrics}` |
| `/api/kpi` | GET | KPI tính toán | `{cpuKpis, memoryKpis, partitionKpis}` |
| `/api/compliance` | GET | Rủi ro tuân thủ | `{orphanSnapshots, toolsOutOfDate, inconsistentHealth}` |
| `/api/export` | GET | Export báo cáo PDF/CSV | File download |
| `/api/siem/push` | POST | Đẩy cảnh báo vào ELK | Webhook response |

#### 3.4.2 Xử lý upload đa file (26 files cùng lúc)

```
Client (Browser)                  API (/api/upload)              ETL Engine
      |                                |                            |
      |--- POST (multipart, 26 files) ->|                           |
      |                                |--(parallel)---> processFile1()
      |                                |--(parallel)---> processFile2()
      |                                |--(parallel)---> ...
      |                                |--(parallel)---> processFile26()
      |                                |                            |
      |<- {processed, skipped, errors}-|                           |
```

### 3.5 Lớp Dashboard — Trực quan hóa

#### 3.5.1 Cấu trúc 5 tabs

| Tab | Nội dung | Thành phần |
|-----|----------|-----------|
| **1. Input Data** | Upload file, lịch sử upload, trạng thái xử lý | Drag-drop upload, UploadHistory grid |
| **2. Process Data** | Grid dữ liệu 26 bảng, search, filter, sort | Table virtual scroll, dropdown chọn bảng |
| **3. Metric Data** | Biểu đồ CPU, RAM, Datastore, Network | Recharts (Line, Bar, Pie), KPIs cards |
| **4. KPI Performance** | vCPU/vMemory/vPartition KPI traffic light | Color-coded table (xanh/vàng/đỏ), trend chart |
| **5. ORKI Compliance** | VMware Tools lỗi thời, Snapshot orphan, Health issues | Risk matrix, compliance score |

#### 3.5.2 Logic KPI Traffic Light

```
vCPU Usage:
  🟢 < 75%    : Stable (an toàn)
  🟡 75-87.5% : Warning (cần theo dõi)
  🔴 > 87.5%  : Critical (cần can thiệp)

vMemory Usage:
  🟢 < 75%    : Stable
  🟡 75-87.5% : Warning
  🔴 > 87.5%  : Critical

vPartition Free %:
  🟢 > 20%    : Stable (còn nhiều dung lượng)
  🟡 10-20%   : Warning (sắp đầy)
  🔴 < 10%    : Critical (gần đầy)

VMware Tools Status:
  🟢 up-to-date / running
  🟡 upgradeable
  🔴 out-of-date / not running / error

vHealth Status:
  🟢 green / ok
  🟡 yellow / warning
  🔴 red / critical / unknown
```

### 3.6 Lớp tích hợp SIEM — ELK Stack 9.4.2 + DSIEM

#### 3.6.1 Luồng dữ liệu từ AnalyticsLOG vào SIEM

```
AnalyticsLOG Dashboard
  │
  │ Webhook / REST API (khi KPI vượt ngưỡng)
  ▼
Python Alert Worker
  │
  │ Ghi log JSON vào file
  ▼
Filebeat (tail log files)
  │
  │ input: /var/log/rvtools-alerts/*.json
  ▼
Logstash Pipeline
  │
  │ filter: grok + mutate + date
  │ output: elasticsearch index "rvtools-alerts-YYYY.MM.DD"
  ▼
Elasticsearch
  │
  │ Index template + ILM Policy (90 days hot, 180 days warm, delete after 365)
  ▼
Kibana
  ├── SIEM Dashboards (RVTools Overview, Risk Trends)
  ├── Alerting Rules (CPU > 85%, Disk < 10%, Tools out-of-date)
  ├── DSIEM Correlation (kết hợp với Suricata IDS alerts)
  └── Cases & Workflows (tự động tạo ticket khi có rủi ro cao)
```

#### 3.6.2 Logstash Pipeline cho RVTools Alerts

```ruby
input {
  beats {
    port => 5044
    ssl => true
    ssl_certificate => "/etc/logstash/certs/logstash.crt"
    ssl_key => "/etc/logstash/certs/logstash.key"
  }
}

filter {
  if [fields][source] == "rvtools" {
    json {
      source => "message"
      target => "rvtools"
    }

    # Extract risk level
    if [rvtools][risk_level] == "critical" {
      mutate { add_tag => ["rvtools-critical"] }
    }

    # Enrich with geoip if IP present
    if [rvtools][source_ip] {
      geoip {
        source => "[rvtools][source_ip]"
        target => "geo"
      }
    }
  }
}

output {
  if [fields][source] == "rvtools" {
    elasticsearch {
      hosts => ["https://localhost:9200"]
      index => "rvtools-alerts-%{+YYYY.MM.dd}"
      user => "logstash_rvtools"
      password => "${LOGSTASH_RVTOOLS_PASSWORD}"
    }
  }
}
```

#### 3.6.3 Elasticsearch Alerting Rules (Custom)

| Rule | Ngưỡng | Hành động |
|------|--------|-----------|
| `rvtools-cpu-overcommit` | vCPU usage > 85% bất kỳ host nào | Email + Slack + Incident case |
| `rvtools-disk-full` | Partition free < 10% | Email + Slack |
| `rvtools-balloon-high` | Ballooned memory > 20% | Email (Warning) |
| `rvtools-swap-active` | Swapped memory > 0 (any VM) | Email (Warning) |
| `rvtools-tools-outdated` | VMware Tools not running | Email batch report |
| `rvtools-snapshot-orphan` | Snapshot age > 7 ngày | Email + Slack |
| `rvtools-datastore-overprovision` | Provisioned > 95% capacity | Email (Warning) |

Hành động SOAR khi trigger:
1. Ghi vào Elasticsearch index `rvtools-alerts-*`
2. Gửi email đến nhóm vận hành (`ops@domain.com`)
3. POST webhook đến Slack channel `#dcv-alerts`
4. Tự động tạo Case trong Kibana Security Solution

#### 3.6.4 DSIEM Correlation Directives

Tích hợp sự kiện RVTools với DSIEM để phát hiện các tấn công liên quan đến hypervisor:

```json
{
  "name": "DCV - Anomalous Resource Exhaustion",
  "enabled": true,
  "priority": 5,
  "timeout": 600,
  "type": "single",
  "rules": [
    {
      "name": "vCPU spike + High balloon memory",
      "occurrence": 3,
      "timeframe": 300,
      "sources": [
        {"event_type": "rvtools_cpu_spike"},
        {"event_type": "rvtools_balloon_high"}
      ]
    }
  ],
  "response": {
    "alarm_level": "high",
    "technique": "Resource Hijacking (T1496)",
    "description": "Phát hiện bất thường tài nguyên VM - khả năng crypto mining"
  }
}
```

---

## 4. Kế hoạch xác định rủi ro

### 4.1 Ma trận rủi ro DCV

| Mã rủi ro | Mô tả | Nhóm | Tác động | Mức độ | Tần suất kiểm tra |
|-----------|-------|------|---------|--------|-------------------|
| R01 | **CPU Overcommit** - Host CPU usage > 87.5% | Compute | Performance degradation, VM readiness | **Cao** | Mỗi lần import |
| R02 | **Memory Ballooning** - Ballooned > 20% | Compute | VM performance issues | **Trung bình** | Mỗi lần import |
| R03 | **Memory Swapping** - Swapped > 0 | Compute | Severe VM performance loss | **Cao** | Mỗi lần import |
| R04 | **Disk Full** - Partition free < 10% | Storage | VM crash, application outage | **Cao** | Mỗi lần import |
| R05 | **Datastore Overprovision** - Provisioned > 95% | Storage | Datastore full, VM cannot start | **Cao** | Mỗi lần import |
| R06 | **VMware Tools Outdated** | Health | Lost advanced features, management gap | **Trung bình** | Hàng ngày |
| R07 | **Orphan Snapshots** (> 7 ngày) | Storage | Disk full, performance impact | **Trung bình** | Hàng ngày |
| R08 | **vCenter HA / Cluster Imbalance** | Cluster | Single point of failure, workload imbalance | **Cao** | Mỗi lần import |
| R09 | **VM Network Disconnect** | Network | VM isolation, service unavailable | **Cao** | Mỗi lần import |
| R10 | **ESXi Health Sensor Fail** | Health | Hardware failure risk | **Cao** | Hàng ngày |
| R11 | **License Expiry** (vSphere, vSAN) | Compliance | License violation, feature loss | **Trung bình** | Hàng tuần |
| R12 | **Multipath Misconfiguration** | Storage | Storage path failure, performance loss | **Trung bình** | Hàng tuần |

### 4.2 Quy trình xử lý khi phát hiện rủi ro

```
Rủi ro phát hiện trên Dashboard
  │
  ├── Mức THẤP (Warning)
  │     → Ghi log → Báo cáo hàng tuần
  │
  ├── Mức TRUNG BÌNH (Warning)
  │     → Ghi log → Email nhóm vận hành → Theo dõi trong 24h
  │     → Nếu không cải thiện → Tạo Incident
  │
  └── Mức CAO (Critical)
        → Ghi log → Email + Slack → Tạo Incident ngay lập tức
        → Gọi điện/zalo Admin nếu sau 1h chưa xử lý
```

---

## 5. Kiến trúc triển khai

### 5.1 Mô hình triển khai

```
+---------------------------+
|  Trung tâm Dữ liệu        |
|  +---------------------+  |
|  | vCenter + ESXi      |  |
|  +---------------------+  |
+---------------------------+
          │
          │ (RvTools Export)
          ▼
+---------------------------+
|  Server Xử lý             |  Windows Server / Linux
|  +---------------------+  |
|  | RvTools 4.7         |  |  Chạy schedule task
|  | Python ETL Engine   |  |  Xử lý Excel → SQLite
|  | Node.js Next.js API |  |  Cấp dữ liệu Dashboard
|  | Prisma + SQLite     |  |  Lưu trữ cục bộ
|  +---------------------+  |
+---------------------------+
          │
          │ (Webhook / REST API)
          ▼
+---------------------------+
|  SIEM Server (ELK 9.4.2) |  Ubuntu 24.04 LTS
|  +---------------------+  |
|  | Elasticsearch       |  |  Cluster 3 nodes
|  | Kibana              |  |  Dashboards + Alerts
|  | Logstash            |  |  Pipeline xử lý
|  | Filebeat            |  |  Thu thập alert logs
|  | DSIEM Engine        |  |  Correlation
|  +---------------------+  |
+---------------------------+
```

### 5.2 Yêu cầu tài nguyên

| Thành phần | CPU | RAM | Disk | OS |
|-----------|-----|-----|------|----|
| RvTools Server | 4 cores | 8 GB | 100 GB SSD | Windows Server 2019+ / Linux |
| Analytics Server (Optional) | 4 cores | 8 GB | 100 GB SSD | Ubuntu 22.04+ |
| SIEM Server (đã có) | 8+ cores | 16-32 GB | 200+ GB SSD | Ubuntu 24.04 LTS |

---

## 6. Kế hoạch triển khai

### Phase 1: Thiết lập thu thập (Tuần 1-2)

| Task | Mô tả | KQ đầu ra |
|------|-------|-----------|
| 1.1 | Cài đặt RvTools 4.7 và PowerCLI | Công cụ sẵn sàng |
| 1.2 | Tạo service account cho RvTools (quyền read-only) | Account + RBVA |
| 1.3 | Viết script auto-export PowerShell | Script + Scheduled Task |
| 1.4 | Thiết lập NAS share hoặc SFTP cho file export | Đường truyền file |

### Phase 2: Xây dựng Analytics Engine (Tuần 3-4)

| Task | Mô tả | KQ đầu ra |
|------|-------|-----------|
| 2.1 | Xây dựng ETL Pipeline (Python) | `etl_processor.py` |
| 2.2 | Thiết kế Database Schema (Prisma) | 27 models |
| 2.3 | Xây dựng REST API (Next.js) | 8 endpoints |
| 2.4 | Xây dựng Dashboard UI (React) | 5 tabs |

### Phase 3: Tích hợp SIEM (Tuần 5)

| Task | Mô tả | KQ đầu ra |
|------|-------|-----------|
| 3.1 | Tạo Logstash pipeline cho RVTools alerts | Pipeline config |
| 3.2 | Tạo Elasticsearch index template + ILM | Index template |
| 3.3 | Cấu hình Alerting rules (7 rules) | Alert rules (Kibana) |
| 3.4 | Tạo DSIEM directive cho DCV events | 2 directives |
| 3.5 | Tích hợp Slack/Email notification | Notification channel |

### Phase 4: Kiểm thử và vận hành (Tuần 6)

| Task | Mô tả | KQ đầu ra |
|------|-------|-----------|
| 4.1 | Kiểm thử end-to-end (export → ETL → Dashboard → Alert) | Test report |
| 4.2 | Kiểm thử ngưỡng KPI và cảnh báo | Validation report |
| 4.3 | Training cho nhóm vận hành | Training materials |
| 4.4 | Go-live và bàn giao | Handover document |

---

## 7. Kết luận và kiến nghị

### 7.1 Kết luận

**Giải pháp AnalyticsLOG Dashboard version 1** dựa trên RvTools 4.7 mang lại:

1. **Chủ động hóa hoàn toàn quy trình giám sát DCV**: Không còn phụ thuộc vào kiểm tra thủ công, ad-hoc
2. **Phát hiện sớm 12 loại rủi ro** phổ biến nhất trên hệ thống vSphere, từ compute đến storage
3. **Tích hợp sâu với ELK SIEM** hiện có: Mở rộng khả năng giám sát bảo mật xuống tận lớp hypervisor
4. **Chi phí thấp**: Tận dụng RvTools (free), SQLite (free), và ELK Stack (đã đầu tư)
5. **Kiến trúc mở**: Dễ dàng mở rộng thêm các nguồn dữ liệu khác (vSAN, NSX, Kubernetes)

### 7.2 Kiến nghị

| STT | Kiến nghị | Ưu tiên |
|-----|-----------|---------|
| 1 | **Triển khai ngay** Phase 1-2 trong tháng 6/2026 | Cao |
| 2 | **Nâng cấp lên PostgreSQL** khi dung lượng dữ liệu > 50GB/tháng | Trung bình |
| 3 | **Mở rộng Dashboard** thêm tính năng Capacity Planning (dự báo 3-6 tháng) | Trung bình |
| 4 | **Tích hợp thêm** nguồn dữ liệu NSX-T, vSAN health metrics trong Phase 2 | Thấp |
| 5 | **Xây dựng AI/ML anomaly detection** trên xu hướng CPU/Memory để phát hiện bất thường | Thấp |

---

## 8. Phụ lục

### 8.1 Sơ đồ kiến trúc Kubernetes / Docker (Tùy chọn cho Phase 2)

Khi hệ thống phát triển, có thể chuyển sang mô hình containerized:

```yaml
# docker-compose.yml
version: '3.8'
services:
  api:
    build: ./app
    ports:
      - "3000:3000"
    depends_on:
      - db
    environment:
      DATABASE_URL: "postgresql://rvtools:pass@db:5432/rvtools"
  
  etl:
    build: ./etl
    volumes:
      - ./uploads:/data/uploads
    depends_on:
      - db
    command: python scheduler.py
  
  db:
    image: postgres:15
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: rvtools
      POSTGRES_USER: rvtools
      POSTGRES_PASSWORD: ${DB_PASSWORD}

volumes:
  pgdata:
```

### 8.2 Danh mục công nghệ sử dụng

| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|----------|
| RvTools | 4.7.1 | Export dữ liệu vSphere |
| Python | 3.11+ | ETL pipeline |
| Node.js | 20 LTS | Backend API |
| Next.js | 16 (App Router) | Dashboard + API |
| Prisma | 6+ | ORM + Schema |
| SQLite / PostgreSQL | 3 / 15 | Database |
| Elastic Stack | 9.4.2 | SIEM + Alerting |
| DSIEM | latest | Security correlation |
| Docker | 24+ | Containerization |

### 8.3 Tài liệu tham khảo

1. RvTools 4.7 Documentation - https://www.robware.net/rvtools/
2. VMware vSphere Documentation - https://docs.vmware.com/en/VMware-vSphere/
3. Elastic Stack 9.4.2 - https://www.elastic.co/guide/en/elastic-stack/current
4. DSIEM Project - https://github.com/defenxor/dsiem
5. SIEM ELK Stack 9.4.2 - Hệ thống Quản lý An ninh Mạng (tài liệu nội bộ)

---

> **Người soạn thảo:** Phòng Vận hành Hạ tầng CNTT  
> **Ngày hoàn thành:** 12/06/2026  
> **File:** `BAO_CAO_NANG_CAP_Giam_Sat_DCV_RvTools.md`

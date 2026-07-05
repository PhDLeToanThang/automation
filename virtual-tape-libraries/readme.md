# TỔNG HỢP GIẢI PHÁP VIRTUAL TAPE LIBRARY (VTL) MÃ NGUỒN MỞ

> Ngày tổng hợp: 2026-07-05
> Mục tiêu: Tìm giải pháp VTL Open Source hoạt động được trên CentOS 8 / Rocky Linux 8 / AlmaLinux 8 / Ubuntu 24.04 LTS

---

## MỤC LỤC

1. [Tổng quan về VTL](#1-tổng-quan-về-vtl)
2. [Phân loại các giải pháp VTL](#2-phân-loại-các-giải-pháp-vtl)
3. [Giải pháp #1: QUADStor VTL (ĐÃ CHẾT)](#3-giải-pháp-1-quadstor-vtl-đã-chết)
4. [Giải pháp #2: mhVTL (KHUYẾN NGHỊ - ĐANG HOẠT ĐỘNG)](#4-giải-pháp-2-mhvtl-khuyến-nghị---đang-hoạt-động)
5. [Giải pháp #3: Holo-VTL (MỚI NHẤT - RUST, MIT License)](#5-giải-pháp-3-holo-vtl-mới-nhất---rust-mit-license)
6. [Giải pháp #4: StarWind VTL Free (MIỄN PHÍ NHƯNG ĐÓNG)](#6-giải-pháp-4-starwind-vtl-free-miễn-phí-nhưng-đóng)
7. [Giải pháp #5: iSCSI_Tape (CŨ - SourceForge)](#7-giải-pháp-5-iscsi_tape-cũ---sourceforge)
8. [Công nghệ nén LZ4 trong VTL](#8-công-nghệ-nén-lz4-trong-vtl)
9. [Thiết kế triển khai Virtual Machine](#9-thiết-kế-triển-khai-virtual-machine)
10. [So sánh các giải pháp](#10-so-sánh-các-giải-pháp)
11. [Kết luận & Khuyến nghị](#11-kết-luận--khuyến-nghị)
12. [Tài liệu tham khảo](#12-tài-liệu-tham-khảo)

---

## 1. TỔNG QUAN VỀ VTL

Virtual Tape Library (VTL) là công nghệ ảo hóa băng từ, biến ổ cứng (HDD/SSD) thành các thư viện băng từ ảo. Backup software (Veeam, NetBackup, Bacula, TSM...) sẽ "nhìn thấy" các ổ băng từ thật (LTO-4/5/6/7/8/9, IBM 3592, STK T10000...) và robot thư viện ảo.

### Kiến trúc tổng quát:

```
Backup Software (Veeam/NBU/Bacula/TSM)
       |
       |--- iSCSI / FC / SCSI Passthrough
       v
+======================+
|    VTL Middleware     |  <-- Kernel Module (pseudo HBA) + User-space daemons
+======================+
       |
       v
+======================+
|  Virtual Disk (VD)   |  <-- File trên hệ thống tập tin (ext4/xfs)
|  ~ Tape Media        |      Mỗi VD = 1 Tape cartridge ảo
+======================+
```

---

## 2. PHÂN LOẠI CÁC GIẢI PHÁP VTL

| Giải pháp | Loại giấy phép | Trạng thái | Hỗ trợ CentOS 8 / RHEL 8 | Hỗ trợ Ubuntu 24.04 | Kernel module |
|-----------|---------------|------------|--------------------------|---------------------|---------------|
| QUADStor VTL | GPLv2 (Open Source) | **ĐÃ CHẾT** (EOL 2021) | KHÔNG | KHÔNG | Cần kernel module riêng |
| mhVTL | GPLv2 (Open Source) | **ĐANG HOẠT ĐỘNG** | CÓ (via ELRepo) | CÓ (build từ source) | mhvtl.ko (pseudo HBA) |
| Holo-VTL | MIT (Open Source) | **MỚI** (2026) | CÓ (RHEL 8/9/10) | CÓ (20.04/24.04/25.04) | LIO/TCMU (Linux kernel built-in) |
| StarWind VTL Free | Proprietary (Free) | ĐANG HOẠT ĐỘNG | CÓ (qua Windows) | KHÔNG | Không cần (Windows) |
| iSCSI_Tape | GPLv2 | **ĐÃ CHẾT** (2013) | KHÔNG | KHÔNG | Cần kernel module |

---

## 3. GIẢI PHÁP #1: QUADStor VTL (ĐÃ CHẾT)

### Thông tin:
- **Repository gốc**: https://github.com/allfs/quadstorvtl (fork từ quadstor/quadstorvtl - đã xóa)
- **Website**: https://www.quadstor.com (trang download VTL đã bị đóng, chỉ còn documentation)
- **Trạng thái**: **NGỪNG PHÁT TRIỂN**, dự án đã chết từ khoảng 2020-2021.

### Các hệ điều hành hỗ trợ (theo README gốc):
| OS | Phiên bản | Kernel hỗ trợ |
|----|-----------|---------------|
| RHEL/CentOS 5.x | 5.x | 2.6.18 |
| RHEL/CentOS 6.x | 6.x | 2.6.32 |
| Debian 6 | Squeeze | 2.6.32 |
| Debian 7 | Wheezy | 3.2 |
| SLES 11 | SP1/SP2 | 3.0 |
| FreeBSD | 8.x/9.x | - |

### LÝ DO KHÔNG HOẠT ĐỘNG ĐƯỢC TRÊN CENTOS 8 / UBUNTU 24.04:

1. **Phụ thuộc kernel driver cũ**: Module kernel của QUADStor VTL được viết cho kernel Linux 2.6.x/3.x, không tương thích với kernel 4.x/5.x/6.x hiện tại.

2. **Thư viện phụ thuộc đã lỗi thời**: Script `installworld` yêu cầu các gói như `linux-headers-$(uname -r)` cho Debian 7, không tồn tại trên Ubuntu 24.04.

3. **PostgreSQL cũ**: Dùng PostgreSQL phiên bản cũ đi kèm source, không tương thích với hệ thống mới.

4. **Trang download đã đóng**: File RPM `quadstor-vtl-ext-3.0.78.1-rhel.x86_64.rpm` không còn tồn tại. Web UI, download page, community forum của quadstor.com đều đã ngừng hoạt động.

5. **Không có driver cho HBA ảo**: Cần kernel module `quadstor` riêng, không được build sẵn cho EL8/9.

6. **Script cài đặt midacts/quadstor.sh** chỉ hỗ trợ Debian 7 (2014), không chạy được trên hệ thống hiện đại.

### Kết luận: **KHÔNG THỂ SỬ DỤNG**. Không có bản RPM/Deb cho CentOS 8/RHEL 8/Ubuntu 24.04. Dự án đã chết.

---

## 4. GIẢI PHÁP #2: mhVTL (KHUYẾN NGHỊ - ĐANG HOẠT ĐỘNG)

### Thông tin:
- **Repository**: https://github.com/markh794/mhvtl
- **Website**: https://sites.google.com/site/linuxvtl2/
- **Tác giả**: Mark Harvey (markh794@gmail.com)
- **Giấy phép**: GPL v2
- **Ngôn ngữ**: C (88.5%), Perl (6%), Shell (4.3%)
- **Stars**: 181, **Forks**: 86, **Commits**: 1,803 (tính đến 2023)
- **Version mới nhất**: 1.7 (2023-03-10)
- **GUI**: https://github.com/tomoconnor/mhvtl-gui (Web Console PHP)

### Kiến trúc:

```
+----------------------------------------------------+
|                   mhVTL System                       |
|                                                      |
|  Kernel Space:                                       |
|    mhvtl.ko (pseudo HBA - dựa trên scsi_debug)      |
|       + char device backend                          |
|                                                      |
|  User Space:                                         |
|    vtltape           - SSC target daemon (tape)      |
|    vtllibrary        - SMC target daemon (library)   |
|    vtlcmd            - administration utility        |
|    mktape            - create virtual tapes          |
+----------------------------------------------------+
```

### Hệ điều hành hỗ trợ:

| OS | Phiên bản | Cách cài đặt |
|----|-----------|-------------|
| **RHEL / Rocky / AlmaLinux** | **7, 8, 9** | **YUM/DNF (via ELRepo)** |
| CentOS | 7 (EOL 2024-06) | YUM (via ELRepo) |
| **Ubuntu** | **20.04, 22.04, 24.04** | **Build từ source** |
| Debian | 10, 11, 12 | Build từ source |
| Fedora | Các phiên bản | DNF (ELRepo) |
| SLES | 12, 15 | Build từ source |
| openSUSE | Leap 15.x | Build từ source |

**LƯU Ý**: mhVTL có sẵn trong **ELRepo** cho RHEL 7/8/9 và các distro tương thích (Rocky Linux, AlmaLinux). Đây là cách dễ nhất.

### Các tính năng chính:

| Tính năng | Mô tả |
|-----------|-------|
| **Emulation drives** | IBM LTO-1 đến LTO-8, HP LTO-1 đến LTO-8, IBM 3592, STK T10000A/B/C, STK 9840/9940, SDLT 220/320/600, Sony AIT |
| **Emulation libraries** | STK L180/L700, Scalar, SPECTRA PYTHON, IBM library |
| **Nén dữ liệu** | LZO (mặc định), Zlib, LZ4 (từ phiên bản 1.2) |
| **WORM** | Write-Once-Read-Many (tuân thủ quy định lưu trữ) |
| **TapeAlert** | Hỗ trợ cảnh báo TapeAlert flags |
| **MAM (Media Auxiliary Memory)** | Lưu persistent metadata cho mỗi tape ảo |
| **Cleaning media** | Hỗ trợ cleaning tape ảo |
| **Multi-library** | Hỗ trợ nhiều thư viện trên cùng 1 host |
| **MAP (Media Access Port)** | Import/Export tape ảo qua cổng MAP |
| **Persistent Reservation** | Hỗ trợ SCSI Persistent Reservation |
| **iSCSI** | Có thể export qua STGT hoặc LIO target |

### Backup software tương thích:

| Phần mềm | Trạng thái |
|----------|-----------|
| **Veritas NetBackup** | 5.1 đến 8.x - **Hoạt động tốt** (được test chính thức) |
| **Veeam Backup & Replication** | **Hoạt động** (qua iSCSI) |
| **Symantec Backup Exec** | Hoạt động |
| **IBM Tivoli Storage Manager** | Hoạt động |
| **EMC NetWorker** | Hoạt động (dùng SPECTRA/PYTHON profile) |
| **CommVault** | Hoạt động (có guide 100+ trang) |
| **Bacula** | Hoạt động |
| **Bareos** | Hoạt động |
| **HP Data Protector** | Hoạt động |

### Cài đặt nhanh trên Rocky/AlmaLinux 8/9 (KHUYẾN NGHỊ):

```bash
# 1. Add ELRepo
sudo dnf install -y epel-release
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo dnf install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm

# 2. Install mhVTL
sudo dnf install -y kmod-mhvtl mhvtl-utils lsscsi sg3_utils mt-st mtx

# 3. Load kernel module
sudo modprobe mhvtl

# 4. Start mhVTL
sudo systemctl enable mhvtl.target
sudo systemctl start mhvtl.target

# 5. Kiểm tra
lsscsi -g
ps -ef | grep vtl
```

### Cấu hình cơ bản:

Cấu hình library và drive trong `/etc/mhvtl/device.conf`:

```ini
VERSION: 5

# Library
Library: 0 CHANNEL: 0 TARGET: 0 LUN: 0
  Vendor identification: STK
  Product identification: VLSTK
  Unit serial number: VLSTK
  NAA: 30:22:33:44:ab:00:08:00
  Compression: factor 1 enabled 1
  Compression type: lzo

# Drive 1
Drive: 1 CHANNEL: 0 TARGET: 1 LUN: 0
  Library ID: 0 Slot: 1
  Vendor identification: IBM
  Product identification: ULT3580-TD5
  Unit serial number: VDSTK1
  NAA: 30:22:33:44:ab:00:09:00
  Compression: factor 1 enabled 1
  Compression type: lzo
```

Cấu hình slot tape trong `/etc/mhvtl/library_contents.0`:

```
VERSION: 5
SLOTS: 40
IMPORTSLOTS: 4
MAXDRIVES: 8
```

---

## 5. GIẢI PHÁP #3: Holo-VTL (MỚI NHẤT - RUST, MIT License)

### Thông tin:
- **Repository**: https://github.com/Holo-VTL/Holo
- **Giấy phép**: MIT License (hoàn toàn mở)
- **Ngôn ngữ**: Rust (data plane), Go (control plane), TypeScript/React (web console)
- **Stars**: 16 (2026 - dự án mới)
- **Version mới nhất**: v1.0.4 (2026-06-05)

### Kiến trúc hiện đại:

```
Backup Software (Veeam, NetBackup, Bacula...)
       |
       | iSCSI (standard protocol)
       v
+------ LIO Target (kernel built-in) ------+
|  TCMU (Target Core User-space)           |
+----------------+-------------------------+
                 |
                 | UNIX socket (CDB frames)
                 v
+------ Holo Data Plane (Rust) --------+
|  + SCSI Tape State Machine            |
|  + CDB Dispatch (48 opcodes)          |
|  + Segment Storage Engine             |
|  + Dedup / LZ4 / Zlib Compression     |
|  + WORM Enforcement                   |
|  + Zero unsafe code                   |
+----------------------------------------+
```

### Hệ điều hành hỗ trợ:

| OS | Phiên bản | Ghi chú |
|----|-----------|---------|
| **RHEL** | **8, 9, 10** | Cần subscription |
| **Rocky / AlmaLinux** | **8, 9, 10** | **Khuyến nghị** |
| **Ubuntu** | **20.04 LTS, 24.04 LTS, 25.04** | **Khuyến nghị** |
| Debian | 12, 13 | |
| openSUSE Leap | 15.6 | |

### Tính năng:

| Tính năng | Mô tả |
|-----------|-------|
| **48 Drive Profiles** | IBM LTO-1..9, HP Ultrium 1..9, Quantum, Dell, STK, Spectra, Overland |
| **50+ Library Profiles** | IBM, HP, Quantum, Dell, Overland, Spectra |
| **SCSI Compliance** | SSC-3, SMC-3, SPC-4 đầy đủ |
| **Nén** | LZ4 (fast) và Zlib (compact), tự động chọn codec |
| **Dedup** | Content-hash based deduplication |
| **Crash Recovery** | Atomic writes, dirty checkpoint recovery |
| **WORM** | Write-Once-Read-Many |
| **MAM** | Media Auxiliary Memory |
| **Web UI** | React dashboard (có sẵn) |
| **Mount Locally** | Cho phép host tự mount VTL local |

### Cài đặt nhanh trên Ubuntu 24.04:

```bash
# Online install (one command)
curl -fsSL https://raw.githubusercontent.com/Holo-VTL/Holo/main/scripts/install.sh | bash

# Sau đó truy cập:
# http://<server-ip>/ui/
```

### Cài đặt trên Rocky/AlmaLinux 8/9:

```bash
curl -fsSL https://raw.githubusercontent.com/Holo-VTL/Holo/main/scripts/install.sh | bash
```

---

## 6. GIẢI PHÁP #4: StarWind VTL Free (MIỄN PHÍ NHƯNG ĐÓNG)

### Thông tin:
- **Website**: https://www.starwindsoftware.com/starwind-virtual-tape-library-free
- **Giấy phép**: Proprietary (Free version)
- **Nền tảng**: Chủ yếu là Windows

### Hạn chế:
- **KHÔNG PHẢI OPEN SOURCE** - Mã nguồn đóng
- **Giới hạn**: Chỉ 4 tapes ảo trong bản Free
- **Yêu cầu Windows Server** - Không phải Linux
- **Không hỗ trợ Ubuntu 24.04**

### Kết luận: Không phù hợp với mục tiêu Open Source trên Linux.

---

## 7. GIẢI PHÁP #5: iSCSI_Tape (CŨ - SourceForge)

### Thông tin:
- **SourceForge**: https://sourceforge.net/projects/iscsi-tape/
- **Trạng thái**: **ĐÃ CHẾT** - Last update 2013
- **Giấy phép**: GPL v2

### Lý do không hoạt động:
- Code không được bảo trì từ 2013
- Yêu cầu kernel cũ
- Không hỗ trợ kernel 4.x/5.x/6.x
- Không có driver cho CentOS 8 hay Ubuntu 24.04

---

## 8. CÔNG NGHỆ NÉN LZ4 TRONG VTL

### Thông tin:
- **Repository**: https://github.com/lz4/lz4
- **Stars**: 11.9k
- **Giấy phép**: BSD 2-Clause
- **Version mới nhất**: v1.10.0 (2024-07-22)

### Tốc độ nén:
| Thuật toán | Tỉ lệ | Nén | Giải nén |
|-----------|-------|-----|---------|
| **LZ4 default** | 2.101 | **780 MB/s** | **4970 MB/s** |
| LZ4 HC -9 | 2.721 | 41 MB/s | 4900 MB/s |
| Zlib -1 | 2.730 | 100 MB/s | 415 MB/s |
| Zstd -1 | 2.883 | 515 MB/s | 1380 MB/s |

### Ứng dụng trong VTL:
- **mhVTL**: Hỗ trợ LZ4 từ version 1.2 (dùng thư viện lzo/lz4)
- **Holo-VTL**: Dùng LZ4 làm codec nén mặc định (fast path)
- **Lợi ích**: Giảm dung lượng tape ảo ~50% mà tốc độ gần như không đổi

---

## 9. THIẾT KẾ TRIỂN KHAI VIRTUAL MACHINE

### Nguyên tắc: Single Virtual Disk = Single Track Media (1:1)

KHÔNG dùng kiểu VL Group disk của QUADStor VTL. Mỗi Virtual Disk (file .img/.qcow2/.vmdk) tương ứng với **1 Tape cartridge ảo (storage slot)**.

### Sizing số lượng VM chạy VTL:

```
Số VM VTL cần = CEILING( Số phòng ban / Số slot tối đa mỗi VM )
```

Ví dụ:
- 20 phòng ban, mỗi phòng cần 5 tapes = 100 tapes
- Mỗi VM VTL hỗ trợ tối đa 40 slots (mhVTL mặc định)
- Số VM = CEILING(100 / 40) = **3 VM VTL**

### Cấu hình VM:

| Thành phần | Khuyến nghị |
|-----------|-------------|
| **CPU** | 4-8 vCPU |
| **RAM** | 8-16 GB |
| **Disk OS** | 50 GB (SSD) |
| **Data Disk** | Theo nhu cầu tape |
| **NIC** | 1-2 (cho iSCSI) |

### Ví dụ triển khai với 5 phòng ban:

```
+=====================================================+
|                  HYPERVISOR (VMware/Proxmox)         |
+=====================================================+
         |              |              |
    +----+----+   +----+----+   +----+----+
    | VTL VM1 |   | VTL VM2 |   | VTL VM3 |
    |---------|   |---------|   |---------|
    | 8 vCPU  |   | 4 vCPU  |   | 4 vCPU  |
    | 16 GB   |   | 8 GB    |   | 8 GB    |
    |---------|   |---------|   |---------|
    | VD1: 1TB |   | VD6: 1TB |   | VD11: 1TB |  <- Mỗi VD = 1 Tape ảo
    | VD2: 1TB |   | VD7: 1TB |   | VD12: 1TB |
    | VD3: 1TB |   | VD8: 1TB |   | VD13: 1TB |
    | VD4: 1TB |   | VD9: 1TB |   | VD14: 1TB |
    | VD5: 1TB |   | VD10: 1TB|   | VD15: 1TB |
    +----------+   +----------+   +----------+
         |              |              |
    =====+==============+==============+=====  (iSCSI Network)
         |              |              |
    +----+----+   +----+----+   +----+----+
    |  Backup  |   |  Backup  |   |  Backup  |
    | Server 1 |   | Server 2 |   | Server 3 |
    | (Veeam)  |   | (Veeam)  |   | (Veeam)  |
    +----------+   +----------+   +----------+
```

### Lưu ý khi tạo Virtual Disk:

1. **Dung lượng mỗi VD = Dung lượng 1 tape cartridge ảo** (ví dụ: 1TB, 2TB, 4TB)
2. **Không dùng Thin Provisioning** cho data disk nếu cần performance ổn định
3. **Đặt data disk trên storage riêng** (không cùng volume với OS)
4. **Số lượng VD = Số slot tape cần** cho phòng ban đó

---

## 10. SO SÁNH CÁC GIẢI PHÁP

### Tổng quan:

| Tiêu chí | QUADStor VTL | mhVTL | Holo-VTL | StarWind VTL Free |
|----------|-------------|-------|-----------|-------------------|
| **Open Source** | CÓ (GPLv2) | CÓ (GPLv2) | CÓ (MIT) | KHÔNG |
| **Đang bảo trì** | KHÔNG (chết) | CÓ (đến 2023) | CÓ (đang active) | CÓ (đóng) |
| **CentOS 8/AlmaLinux 8** | KHÔNG | CÓ (ELRepo) | CÓ | KHÔNG |
| **Ubuntu 24.04** | KHÔNG | CÓ (build source) | CÓ (apt) | KHÔNG |
| **Web UI** | CÓ (CGI cũ) | CÓ (mhvtl-gui PHP) | CÓ (React) | CÓ |
| **iSCSI support** | CÓ (tích hợp) | CÓ (STGT/LIO) | CÓ (LIO TCMU) | CÓ |
| **Nén** | CÓ | LZO/Zlib/LZ4 | LZ4/Zlib | CÓ |
| **Dedup** | KHÔNG | KHÔNG | CÓ | CÓ |
| **WORM** | CÓ | CÓ | CÓ | CÓ |
| **48+ drive profiles** | Hạn chế | CÓ | CÓ | CÓ |
| **Rust/Zero unsafe** | KHÔNG | KHÔNG | CÓ | KHÔNG |
| **Dễ cài đặt** | Khó (package lỗi thời) | **Dễ** (ELRepo) | **Rất dễ** (1 script) | Dễ (Windows) |

### Hiệu năng:

| Tiêu chí | mhVTL | Holo-VTL |
|----------|-------|-----------|
| **Cơ chế** | Kernel module riêng (mhvtl.ko) | LIO/TCMU kernel built-in |
| **Ngôn ngữ data plane** | C | Rust (zero-unsafe) |
| **Nén** | LZO (mặc định) | LZ4 (mặc định) |
| **Crash recovery** | Cơ bản | Atomic writes + checkpoint |
| **SCSI compliance** | SSC-3/SMC-3 | SSC-3/SMC-3/SPC-4 |

---

## 11. KẾT LUẬN & KHUYẾN NGHỊ

### Khuyến nghị chính:

| Mục đích | Giải pháp | OS khuyến nghị |
|----------|-----------|----------------|
| **Sản xuất ổn định, nhiều tính năng** | **mhVTL** | **Rocky Linux 8 / AlmaLinux 8** |
| **Hiện đại, Rust, MIT License** | **Holo-VTL** | **Ubuntu 24.04 LTS** |
| **POC nhanh, đơn giản** | **Holo-VTL** | **Ubuntu 24.04 LTS** |
| **Cần support enterprise** | mhVTL | RHEL 8/9 (có subscription) |

### Lý do chọn mhVTL cho sản xuất:

1. **Trưởng thành**: 1,803 commits, 10+ năm phát triển
2. **Cộng đồng lớn**: 181 stars, 86 forks, nhiều người dùng
3. **Tương thích rộng**: Hoạt động với tất cả backup software chính
4. **ELRepo**: Có sẵn package cho RHEL 7/8/9
5. **Nhiều emulation**: IBM LTO, HP LTO, STK, Quantum...

### Lý do chọn Holo-VTL cho tương lai:

1. **MIT License**: Hoàn toàn tự do, không ràng buộc GPL
2. **Rust**: Memory safety, zero unsafe code
3. **Kiến trúc hiện đại**: Dùng LIO/TCMU kernel built-in, không cần kernel module riêng
4. **Web UI đẹp**: React dashboard có sẵn
5. **Cài đặt 1 câu lệnh**: Rất dễ dùng
6. **Dedup + Compression**: Tiết kiệm dung lượng

### Các giải pháp KHÔNG nên dùng:

| Giải pháp | Lý do |
|-----------|-------|
| **QUADStor VTL** | Đã chết, không có package cho OS mới, driver kernel không tương thích |
| **iSCSI_Tape** | Code từ 2013, không chạy được trên kernel mới |
| **StarWind VTL Free** | Không Open Source, Windows-only, giới hạn 4 tapes |

---

## 12. TÀI LIỆU THAM KHẢO

### GitHub Repositories:
1. https://github.com/markh794/mhvtl - mhVTL (Mark Harvey)
2. https://github.com/tomoconnor/mhvtl-gui - mhVTL Web GUI
3. https://github.com/Holo-VTL/Holo - Holo-VTL (Rust, MIT)
4. https://github.com/allfs/quadstorvtl - QUADStor VTL (đã chết)
5. https://github.com/midacts/quadstor - Script cài QUADStor cũ
6. https://github.com/lz4/lz4 - LZ4 Compression

### Websites:
7. https://sites.google.com/site/linuxvtl2/ - Linux VTL (mhVTL official)
8. https://www.quadstor.com/vtl-documentation.html - QUADStor docs (đã đóng)
9. https://elrepo.org - ELRepo (chứa package mhVTL cho RHEL)
10. https://www.starwindsoftware.com/starwind-virtual-tape-library-free - StarWind VTL Free

### Bài viết liên quan:
11. https://github.com/PhDLeToanThang/automation/issues/3 - Issue #3 (phân tích VTL)
12. https://thangletoan.wordpress.com/2023/07/05/cach-tao-vtl-la-may-ao-centos-va-ly-do-lam-vbr-appliance/ - Bài viết về VTL trên CentOS
13. https://thangletoan.wordpress.com/2023/09/03/cach-tao-virtual-tape-library-tren-centos-7-tich-hop-veeam-backup-disk-to-disk-vs-tape/ - VTL + Veeam

---

*Tài liệu được tổng hợp bởi AI Agent OpenCode, dựa trên phân tích thực tế các repository và tài liệu tham khảo.*

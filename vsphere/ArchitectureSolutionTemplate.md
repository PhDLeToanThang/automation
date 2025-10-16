# ĐỀ XUẤT MÔ HÌNH GIẢI PHÁP

## Mục lục
- [I. Hiện trạng](#i-hiện-trạng)
- [II. Mô hình tổng quan](#ii-mô-hình-tổng-quan)
  - [1. Mô hình](#1-mô-hình)
  - [2. Miêu tả các thành phần trong hệ thống](#2-miêu-tả-các-thành-phần-trong-hệ-thống)
    - [2.1 Máy chủ phục vụ tính toán: (Compute node)](#21-máy-chủ-phục-vụ-tính-toán-compute-node)
    - [2.2 Hệ thống lưu trữ (Storage)](#22-hệ-thống-lưu-trữ-storage)
    - [2.3 Hệ thống mạng kết nối nội bộ giữa các máy chủ](#23-hệ-thống-mạng-kết-nối-nội-bộ-giữa-các-máy-chủ)
    - [2.4 Hệ thống lưu trữ dữ liệu:](#24-hệ-thống-lưu-trữ-dữ-liệu)
    - [2.5 VMware vCenter Server](#25-vmware-vcenter-server)
    - [2.6 Mô hình triển khai SQL Server Cluster](#26-mô-hình-triển-khai-sql-server-cluster)
- [III. Đề xuất tài nguyên hệ thống](#iii-đề-xuất-tài-nguyên-hệ-thống)
  - [1. Tài nguyên máy chủ + mạng](#1-tài-nguyên-máy-chủ--mạng)
  - [2. Phần mềm](#2-phần-mềm)

---

## I. Hiện trạng

Lập update thông tin hiện trạng bên Richy

## II. Mô hình tổng quan

### 1. Mô hình

Chúng tôi xin được đề xuất giải pháp xây dựng hệ thống Private cloud theo công nghệ ảo hóa. Đây là công nghệ được thiết kế để tạo ra tầng trung gian giữa hệ thống phần cứng máy chủ và phần mềm chạy trên nó. Công nghệ ảo hóa máy chủ là từ một máy vật lý đơn lẻ có thể tạo thành nhiều máy ảo độc lập. Mỗi một máy ảo đều có một thiết lập nguồn hệ thống riêng rẽ, hệ điều hành riêng và các ứng dụng riêng. Để bảo đảm tối ưu hóa hiệu năng của hệ thống, một giải pháp ảo hóa kiểu 1 (Type 1 virtualization) cho phép khởi chạy các tiến trình ảo hóa ngay ở mức kernel là bắt buộc.

**Các thành phần chính của hệ thống:**
- **Management Portal**: Cung cấp cơ chế quản lý các thành phần vật lý cũng như các máy ảo trong môi trường ảo hóa từ một giao diện quản trị duy nhất, giảm bớt sự phức tạp cho người quản trị;
- **Hypervisor**: Đóng vai trò ảo hóa điện toán, tạo môi trường cho các máy ảo hoạt động;
- **Share Storage**: Hệ thống lưu trữ tập trung đảm bảo năng lực lưu trữ cho hệ thống ảo hóa, hỗ trợ nâng cao tính sẵn sàng và độ ổn định cho hệ thống;

Hệ thống được thiết kế để cung cấp khả năng chịu lỗi và chia tải trên toàn bộ các máy chủ.

**Cơ chế chịu lỗi:**
1. **Khả năng chịu lỗi về kết nối mạng**: Khi kết nối LAN tới Node 1 gặp sự cố, Node 2 sẽ điều hướng network traffic tới Node 1 thông qua kết nối dự phòng để Node 1 thực hiện các Network I/O bình thường.
2. **Khả năng chịu lỗi về kết nối của một node trong cluster tới hệ thống lưu trữ**: Khi kết nối lưu trữ trên Node 2 có sự cố, quá trình I/O sẽ được điều hướng tới Node 1, và Node 1 sẽ thực hiện I/O thay thế cho Node 2.
3. **Khả năng chịu lỗi khi một node trong cluster gặp sự cố**: Ví dụ Node đang có quyền sở hữu 1 volume sử dụng bởi 1 máy ảo hoạt động trên Node 2. Khi Node 1 gặp sự cố không thể hoạt động, quyền sở hữu volume sẽ được chuyển cho Node 2 mà không gây gián đoạn tới các máy ảo hoạt động trên Node 2.

Tính linh hoạt trong hệ thống còn được bổ sung với một tính năng mạnh mẽ đó là **Live Migration**, cho phép nhanh chóng di chuyển một máy ảo đang hoạt động trên host này sang host khác mà không gây ra bất kỳ down time hoặc gián đoạn nào qua đó giúp chia tải cho các Server vật lý cũng như giảm ảnh hưởng tới việc bảo trì cho từng Server trong khi cần.

**Mô hình hệ thống ảo hóa**

![Mô hình hệ thống ảo hóa](https://github-production-user-asset-6210df.s3.amazonaws.com/106635733/501798144-fb5662d8-ed32-4fef-b530-6f8a18376088.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20251016%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251016T025800Z&X-Amz-Expires=300&X-Amz-Signature=228f7dd2a875852acf19da647c890405e823b0f2fec8b28e64e2fd8fbfe11c9a&X-Amz-SignedHeaders=host)

### 2. Miêu tả các thành phần trong hệ thống

#### 2.1 Máy chủ phục vụ tính toán: (Compute node)

Hệ thống bao gồm:
- Gồm 03 máy chủ vật lý (Server 01, Server 02, Server 03) chạy hypervisor để tạo các máy ảo (VM).
- Tổng số 48 core/96 threads cùng dung lượng bộ nhớ cung cấp là 768GB mỗi node.
- 03 máy chủ với cấu hình như đề xuất sẽ có thể đáp ứng được đầy đủ toàn bộ khối lượng tài nguyên và dung lượng theo như yêu cầu khách hàng. Toàn bộ khối lượng tài nguyên sẽ được dự phòng theo cơ chế N+1.

Các node được trang bị các kết nối:
- 2 cổng mạng chuẩn RJ45 với tốc độ 1Gbps.
- 2-4 cổng quang 10/25Gbps
- 2 cổng FC gắn trên card HBA

#### 2.2 Hệ thống lưu trữ (Storage)

Hệ thống SAN (Storage Area Network) là giải pháp lưu trữ tập trung, kết nối các máy chủ đến thiết bị lưu trữ thông qua mạng tốc độ cao (Fibre Channel hoặc iSCSI).

Công nghệ Snapshot cho phép ghi lại trạng thái dữ liệu tại một thời điểm mà không cần sao chép toàn bộ dữ liệu, giúp backup và phục hồi nhanh chóng.

![Sơ đồ tổng quát hệ lưu trữ](https://github-production-user-asset-6210df.s3.amazonaws.com/106635733/501799101-75dbb3e5-10e5-47e9-9453-d89f6920aeb5.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20251016%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251016T030235Z&X-Amz-Expires=300&X-Amz-Signature=363e40f475edf4afd7e32e410a84464957b8d8e766e7f9f803864905786a0bb5&X-Amz-SignedHeaders=host)


**Thành phần chính**
- **SAN Storage**: Bao gồm 02 SAN kép (SAN 1 và SAN 2) kết nối qua SAN Switch 01 và SAN Switch 02 để đảm bảo dự phòng. Là thiết bị lưu trữ chính, nơi chứa các volume dữ liệu và hỗ trợ tính năng snapshot.
- **SAN Switch**: Hệ thống mạng LAN gồm Switch 01, Switch 02 và Stack Core Switch để phục vụ truy cập client và heartbeat.

#### 3. Cơ chế hoạt động Snapshot

- Khi tạo snapshot, hệ thống ghi lại metadata và chỉ lưu các block dữ liệu thay đổi (Copy-on-Write hoặc Redirect-on-Write).
- Snapshot ban đầu chiếm ít dung lượng, tăng dần theo mức độ thay đổi dữ liệu.
- Có thể tạo nhiều snapshot cho cùng một volume để phục vụ:
  - Backup nhanh mà không gián đoạn dịch vụ.
  - Khôi phục dữ liệu về trạng thái trước đó.
  - Kiểm thử và phát triển trên dữ liệu thực.

#### 4. Lợi ích

- **Tốc độ cao**: Backup gần như tức thời.
- **Không gián đoạn dịch vụ**: Snapshot không ảnh hưởng đến hoạt động của ứng dụng.
- **Khôi phục nhanh**: Dễ dàng trả dữ liệu về trạng thái trước đó.
- **Tiết kiệm dung lượng**: Chỉ lưu phần thay đổi, không sao chép toàn bộ dữ liệu.

#### 2.3 Hệ thống mạng kết nối nội bộ giữa các máy chủ

**Hệ thống chuyển mạch**
- Hệ thống mạng kết nối nội bộ giữa các máy chủ gồm Switch 01, Switch 02 để phục vụ truy cập client và heartbeat.
- 02 thiết bị Switch có từ 2-4 Port 1Gbps + 8-12 Port 10/25G SFP+ Managed Gigabit Switch.

#### 2.4 Hệ thống lưu trữ dữ liệu Backup:

Sử dụng thiết bị lưu trữ dữ liệu NAS Dung lượng 70-100 TB.

Cung cấp nhiều tính năng sao lưu, bao gồm sao lưu tự động từ máy tính cá nhân, lưu trữ tập trung cho phép truy cập từ xa và đồng bộ hóa dữ liệu với các dịch vụ đám mây. Các tính năng nâng cao còn bao gồm sao lưu đa phiên bản, nén dữ liệu và khả năng phục hồi dữ liệu dễ dàng từ nhiều đích sao lưu khác nhau.

**Tính năng sao lưu chính**

- **Sao lưu tự động và theo lịch trình**: Cấu hình để tự động sao lưu dữ liệu từ máy tính (Windows/Mac) hoặc các thiết bị khác trong mạng vào NAS theo lịch trình định trước.
- **Lưu trữ tập trung**: Lưu trữ tất cả dữ liệu vào một vị trí trung tâm, giúp việc quản lý và truy cập dữ liệu trở nên hiệu quả hơn.
- **Truy cập từ xa**: Cho phép bạn truy cập và khôi phục các bản sao lưu của mình từ bất kỳ đâu qua internet, miễn là có kết nối mạng.
- **Đồng bộ hóa đám mây**: Đồng bộ hóa dữ liệu trên NAS với các dịch vụ đám mây như Google Drive, Dropbox, Azure để tăng cường bảo mật và khả năng truy cập.
- **Sao lưu đa phiên bản**: Lưu trữ nhiều phiên bản của tệp tin, cho phép bạn khôi phục dữ liệu về một phiên bản cụ thể trong quá khứ khi cần.
- **Nhiều đích sao lưu**: Hỗ trợ sao lưu dữ liệu đến nhiều điểm đến khác nhau, bao gồm ổ đĩa ngoài, các thiết bị NAS khác hoặc dịch vụ đám mây.
- **Bảo mật**: Một số công cụ sao lưu trên NAS cung cấp mã hóa dữ liệu (ví dụ: mã hóa AES-256) để bảo vệ dữ liệu trong quá trình sao lưu.

#### 2.5 VMware vCenter Server

Hệ thống sẽ gồm ít nhất 1 máy chủ vCenter Server để quản lý tài nguyên và giám sát tập trung cho cơ sở hạ tầng ảo hóa VMware vSphere.

**Vai trò VMware vCenter Server**

VMware vCenter Server là phần mềm quản lý tài nguyên và giám sát tập trung cho cơ sở hạ tầng ảo VMware vSphere.

VMware vCenter Server thực hiện một số nhiệm vụ, bao gồm cung cấp và phân bổ tài nguyên, giám sát hiệu suất, tự động hóa quy trình làm việc và quản lý đặc quyền người dùng. Nó cho phép quản trị viên vSphere quản lý nhiều máy chủ ESX và ESXi và máy ảo (VM) thông qua một bảng điều khiển duy nhất.

Nhiều tính năng chính của vSphere, bao gồm VMware Distributed Resource Scheduler (DRS), vSphere High Availability (HA), vSphere Fault Tolerance (FT) và VMware vMotion, yêu cầu vCenter Server hoạt động.

**Kiến trúc máy chủ VMware vCenter**

![Kiến trúc máy chủ VMware vCenter](https://github-production-user-asset-6210df.s3.amazonaws.com/106635733/501799866-aa701821-5000-43cb-a292-37c4d18e445d.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20251016%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251016T030435Z&X-Amz-Expires=300&X-Amz-Signature=3bb074031853b36c2fe38407a3e531ece799550be4a3dcbd637df7b80cae9e83&X-Amz-SignedHeaders=host)

#### 2.6 Mô hình triển khai SQL Server Cluster

Mô hình này triển khai SQL Server Cluster (có thể là FCI hoặc kết hợp với Always On AG) trên nền tảng ảo hóa (ESXi, Hyper-V hoặc AHV). Hệ thống gồm:
- Các máy ảo chạy SQL Server.
- Mỗi VM là một node trong cluster, đảm bảo tính sẵn sàng cao. Các VMs này lần lượt là các nodes trên Server 01, Server 02, Server 03

**Cách hoạt động**

- Client kết nối qua Virtual Network Name (VNN) hoặc Availability Group Listener (AGL).
- Khi một node gặp sự cố, WSFC sẽ thực hiện failover sang node khác.
- SAN đảm bảo dữ liệu luôn nhất quán (FCI) hoặc đồng bộ qua mạng (AG).
- NAS Backup đảm bảo khả năng khôi phục dữ liệu.

**Ưu điểm**

- Tính sẵn sàng cao nhờ failover tự động.
- Dự phòng kép ở cả mức mạng và lưu trữ.
- Khả năng mở rộng: Có thể thêm node hoặc thêm SAN.
- Tích hợp backup để bảo vệ dữ liệu.

## III. Đề xuất tài nguyên hệ thống

### 1. Tài nguyên máy chủ + mạng

| Hệ thống máy chủ | Dvt | Số lượng | Ghi chú |
|------------------|-----|----------|---------|
| pc. | 3 | 1. Triển khai theo mô hình ảo hoá các máy chủ :<br>2. Xây dựng mô hình gồm 3 máy chủ (3 Nodes) cấu hình chức năng HA, | |
| Thiết bị mạng | | | |
| pc. | 1 | Kết nối nội bộ cho các máy chủ đặt tại DC | |

### 2. Phần mềm

| TT | Thiết bị | Thông số | Số lượng | Ghi chú |
|----|----------|----------|----------|---------|
| 1 | | | | |
| 2 | | | | |

Tham khảo html5: https://chat.z.ai/space/h0kst8st89k1-art

### ĐẶC TẢ THIẾT KẾ CHI TIẾT CƠ SỞ HẠ TẦNG VCF 5.2.1.1

#### 1\. Tổng quan về Kiến trúc Logic Hệ thống

Việc thiết lập môi trường  **VMware Cloud Foundation (VCF) 5.2.1.1 Nested Lab**  là một bước đi chiến lược trong việc làm chủ hệ sinh thái SDDC (Software-Defined Data Center) hiện đại. 
Kiến trúc phân tầng giữa lớp vật lý (Physical Layer) và lớp lồng nhau (Nested Layer) cho phép mô phỏng toàn bộ các tính năng cao cấp của VCF mà không cần đầu tư hàng tỷ đồng vào phần cứng vật lý chuyên biệt.
Về mặt logic, hệ thống được vận hành bởi hai thành phần chính:  **Cloud Builder VM**  đóng vai trò là "Bootstrap/Orchestration engine" để khởi tạo Management Domain ban đầu thông qua quy trình Bringup. 
Sau khi hoàn tất,  **SDDC Manager**  trở thành "Centralized Management Plane", điều phối toàn bộ vòng đời (Lifecycle Management) từ triển khai, cấu hình đến mở rộng các Workload Domains.

Dưới đây là danh mục các thành phần chủ chốt theo BOM (Build of Materials) VCF 5.2.1.1:
| Thành phần | Vai trò | Phiên bản hỗ trợ |
|------------|---------|--------|
| **Cloud Builder** | Orchestration & Bringup Management Domain | 5.2.1.1 (Build 24307856\) |
| **SDDC Manager** | Lifecycle Management & Workload Provisioning | 5.2.1.1 |
| **vCenter Server** | Quản lý tập trung tài nguyên Compute | vSphere 8.0 Update 3c |
| **NSX-T Manager** | Centralized Network & Security Control | 5.2.1.1 (Size:  **Medium** ) |
| **Nested ESXi** | Virtualized Compute Node | ESXi 8.0 Update 3c |  

Kiến trúc này tạo tiền đề vững chắc để thử nghiệm các tính năng vSAN ESA và NSX Overlay trong một môi trường được cô lập hoàn toàn.

#### 2\. Đặc tả Tài nguyên Vật lý (Physical Infrastructure Requirements)

Để đảm bảo hiệu suất cho các máy ảo lồng nhau, nền tảng vật lý phải chạy trên  **vSphere 7.0 trở lên** . 
Việc dự phòng tài nguyên là yếu tố tiên quyết để tránh hiện tượng nghẽn cổ chai khi vận hành các cluster ảo hóa bên trong.

##### Yêu cầu Tài nguyên Tối thiểu:

* **Compute:**  8-12 vCPU cores/threads và  **384 GB RAM** .  
* **Storage:**  Tối thiểu  **1.25 TB**  dung lượng SSD/NVMe.
* *Lưu ý: Nếu hạ tầng vật lý sử dụng vSAN, cần cấu hình "FakeSCSIReservations" để tránh lỗi khi tạo Disk Group cho Nested ESXi.*  
* **Tính năng Cluster:**  Phải bật  **DRS (Distributed Resource Scheduler)**  trên cluster vật lý để hỗ trợ việc tạo cấu trúc vApp và phân bổ tài nguyên động cho các Nested VMs.

##### Cấu hình Mạng Vật lý:

Môi trường yêu cầu tối thiểu một  **Routable Portgroup** . 
Để các host ESXi con có thể truyền tải lưu lượng mạng phức tạp, các thiết lập bảo mật trên Switch ảo vật lý phải được cấu hình như sau:

* **MAC Learning**  hoặc  **Promiscuous Mode** : Cho phép switch chấp nhận gói tin có địa chỉ MAC nguồn/đích khác nhau.  
* **Forged Transmits** : Đảm bảo các gói tin từ máy ảo bên trong Nested ESXi không bị chặn.Sự ổn định của lớp vật lý là nền tảng để triển khai Miền Quản trị bền vững.

#### 3\. Thiết kế Chi tiết Miền Quản trị (Management Domain \- vcf-m01)

Management Domain là trung tâm điều khiển của toàn bộ hệ thống. 
Thiết kế sử dụng cụm  **4 host ESXi**  để tuân thủ nguyên tắc  **N+1 redundancy** . 
Cấu hình này cho phép duy trì tính ổn định của vSAN cluster với mức chịu lỗi  **RAID-1 (FTT=1)**  ngay cả khi một host vật lý gặp sự cố.

##### Đặc tả Nested ESXi (vcf-m01-esx01 đến esx04):

|Thông số|Giá trị|Ghi chú |
|--------|-------|--------|
|vCPU / RAM|12 Cores / 96 GB|Đảm bảo hiệu suất cho SDDC Manager & NSX  
|Boot Disk|32 GB|  |  
|Caching Disk|4 GB|Bắt buộc dùng NVMe Controller  (cho vSAN ESA)|
|Capacity Disk|500 GB|Bắt buộc dùng NVMe Controller  (cho vSAN ESA)|

##### Thành phần Quản trị & IP Allocation:

* **Cloud Builder (vcf-m01-cb01):**  172.16.30.61.  
* **SDDC Manager (vcf-m01-sddcm01):**  172.16.30.62.  
* **vCenter Server (vcf-m01-vc01):**  172.16.30.67.  
* **NSX-T Manager VIP (vcf-m01-nsx01):**  172.16.30.68.  
* **NSX-T Node 1 (vcf-m01-nsx01a):**  172.16.30.69 (Cấu hình size:  **Medium** ).
* Việc áp dụng  **vSAN ESA (Express Storage Architecture)**  thay vì vSAN OSA truyền thống giúp tối ưu hóa throughput cho các database của vCenter và NSX-T.

#### 4\. Thiết kế Chi tiết Miền Khối lượng công việc (Workload Domain \- vcf-w01)

Workload Domain (WLD) là nơi vận hành các ứng dụng nghiệp vụ. 
Tài nguyên tại đây được tối ưu hóa (8 vCPU, 36GB RAM) để tiết kiệm tài nguyên vật lý nhưng vẫn đảm bảo đầy đủ các tính năng của NSX và vLCM.

##### Đặc tả tài nguyên WLD Hosts (vcf-w01-esx01 đến esx04):

|Hostname|IP Quản lý|vCPU|RAM|Lưu trữ|
|--------|----------|----|---|-------|
|vcf-w01-esx01|172.16.30.72|8|36 GB|250 GB Capacity| 
|vcf-w01-esx02|172.16.30.73|8|36 GB|250 GB Capacity| 
|vcf-w01-esx03|172.16.30.74|8|36 GB|250 GB Capacity|  
|vcf-w01-esx04|172.16.30.75|8|36 GB|250 GB Capacity|

##### Hạ tầng NSX-T trong Workload Domain:

Để đảm bảo khả năng chịu lỗi và mở rộng cho mạng SDN, WLD sử dụng một cluster NSX gồm 3 Node:

* **VIP:**  172.16.30.77.  
* **Nodes:**  .78 (Node 1), .79 (Node 2), .80 (Node 3).
* Quản lý vòng đời trong WLD được thực hiện qua  **vLCM Image**  với nhãn mặc định là  **"Management-Domain-ESXi-Personality"** , đảm bảo tính đồng nhất về driver và firmware giữa các host.

#### 5\. Quy hoạch Kiến trúc Mạng và Kết nối (Networking Architecture)

Việc sử dụng dải IP  **172.16.0.0/16**  cho phép phân tách logic hoàn hảo giữa mạng quản lý (/24) và mạng Overlay, giúp việc định tuyến (Routing) giữa các lớp trở nên tường minh.

##### Bảng phân bổ IP chi tiết:

|Thực thể|Dải IP / Gateway|Chức năng |
|--------|----------------|----------|
|Management|172.16.30.0/24|Quản lý host và appliances|
|vMotion|172.30.32.0/24|Di chuyển máy ảo nóng|
|vSAN|172.30.33.0/24|Lưu thông dữ liệu lưu trữ| 
|NSX TEP|172.30.34.0/24|Đường hầm Overlay (Geneve)|
|Cấu hình chung|Gateway: 172.16.1.53|DNS/NTP: 172.16.1.3|

**Lưu ý kỹ thuật:**  Sự đồng bộ giữa  **Forward/Reverse DNS**  và  **NTP**  là điều kiện tiên quyết. 
Hơn 90% lỗi "Bringup failure" xuất phát từ việc sai lệch thời gian hoặc không phân giải được FQDN của các thành phần SDDC.

#### 6\. Hướng dẫn Triển khai và Tự động hóa (Automation & Provisioning)

Tự động hóa bằng PowerShell/PowerCLI là phương pháp duy nhất để đảm bảo tính nhất quán của lab. 
Hệ thống hỗ trợ tính năng  **"License Later"** , cho phép vận hành toàn bộ giải pháp trong 60 ngày dùng thử mà không cần nhập key bản quyền ngay lập tức.

##### Các Scripts chủ chốt:

1. **vcf-automated-lab-deployment.ps1** : Thực hiện triển khai Nested ESXi, Cloud Builder và tự động kích hoạt Bringup Management Domain.  
2. **vcf-automated-workload-domain-deployment.ps1** : Tự động hóa việc commission host và dựng WLD.

##### Quản lý cấu hình JSON:

Người dùng cần phân biệt rõ hai định dạng file cấu hình để tránh lỗi API:

* **vcf-commission-host-ui.json** : Sử dụng khi upload thủ công qua giao diện SDDC Manager UI.  
* **vcf-commission-host-api.json** : Sử dụng cho các script tự động hóa gọi qua SDDC Manager API (đã bao gồm các ID hệ thống cần thiết thay vì tên hiển thị).

##### Kiểm tra Tiên quyết (Pre-requisites):

* Xác nhận các bản ghi DNS đã hoạt động cho tất cả IP trong bảng quy hoạch.  
* Đảm bảo file OVA Cloud Builder 5.2.1.1 và Nested ESXi 8.0u3c đúng checksum.  
* Kiểm tra tài nguyên vật lý đáp ứng mức 384GB RAM để tránh tình trạng vCenter bị treo trong quá trình khởi tạo.
* Việc tuân thủ nghiêm ngặt đặc tả thiết kế này đảm bảo một môi trường VCF chuẩn hóa, sẵn sàng cho các kịch bản R\&D và vận hành thực tế.


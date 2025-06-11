# Giới thiệu các khái niệm 

>>
Verge UCI là gì ? Nutanix HCI là gì ? vSphere Hypervisor là gì ? DATIUM HCI là gì ? HPC và GPU Workstation là gì ? K8s Cluster là gì ? Apache CloudStack là gì ? Mô hình và vị trí của từng mô hình là gì? So sánh giữa các mô hình hệ thống ?


Dưới đây là sơ đồ so sánh các mô hình hệ thống: **Verge UCI**, **Nutanix HCI**, **vSphere Hypervisor**, **DATIUM HCI**, **HPC & GPU Workstation**, **K8s Cluster**, và **Apache CloudStack**:

![Sơ đồ so sánh các mô hình hệ thống CNTT](blob:https://copilot.cloud.microsoft/9892849a-fa76-4235-9fa3-850ae2d170f1)

---

## 🧭 Giải thích từng mô hình

### 🔹 **Verge UCI (Ultraconverged Infrastructure)**
- **Vị trí**: On-Prem / Edge
- **Chức năng**: Tích hợp compute, storage, network, virtualization trong một hệ điều hành duy nhất.

### 🔸 **Nutanix HCI (Hyperconverged Infrastructure)**
- **Vị trí**: On-Prem / Hybrid
- **Chức năng**: Hạ tầng tích hợp với phần mềm quản lý Prism, hỗ trợ AHV hoặc VMware.

### 🔹 **vSphere Hypervisor**
- **Vị trí**: On-Prem
- **Chức năng**: ESXi hypervisor để chạy VM, quản lý qua vCenter.

### 🔹 **DATIUM HCI**
- **Vị trí**: On-Prem / Edge
- **Chức năng**: HCI tích hợp backup, DR, tối ưu lưu trữ.

### 🟣 **HPC & GPU Workstation**
- **Vị trí**: On-Prem / AI
- **Chức năng**: Xử lý tính toán cao, AI/ML, mô phỏng khoa học.

### 🔴 **K8s Cluster (Kubernetes)**
- **Vị trí**: Cloud-Native / Hybrid
- **Chức năng**: Điều phối container, microservices, tự động mở rộng.

### 🟤 **Apache CloudStack**
- **Vị trí**: Hybrid / Private Cloud
- **Chức năng**: Quản lý compute, storage, network đa hypervisor, đa vùng.

---

## 📊 So sánh tổng quan

| Tiêu chí | Verge UCI | Nutanix HCI | vSphere | DATIUM HCI | HPC/GPU | K8s Cluster | CloudStack |
|----------|-----------|-------------|---------|-------------|----------|--------------|-------------|
| **Tích hợp** | ✅ All-in-one | ✅ Compute + Storage | ⚠️ Phân lớp | ✅ Backup + DR | ❌ Chỉ compute | ❌ Chỉ orchestration | ✅ Quản lý cloud |
| **Chi phí** | ⭐ Rẻ | ❗ Cao | ❗ Cao | ⚠️ Trung bình | ❗ Cao | ✅ Miễn phí | ✅ Miễn phí |
| **Khả năng mở rộng** | ✅ Scale-out | ✅ Scale-out | ⚠️ Scale-up | ✅ Scale-out | ❌ Giới hạn | ✅ Rất tốt | ✅ Rất tốt |
| **Tương thích AI/Cloud** | ⚠️ Một phần | ✅ Có | ❌ Giới hạn | ⚠️ Một phần | ✅ Tốt | ✅ Tốt | ✅ Tốt |

---

# Giải pháp migration vSphere to Verge.io

>> Trong bộ phần mềm giải pháp và công nghệ hạ tầng phần cứng verge.io hãy cho tôi biết chi tiết licence nào có thể giúp migration vsphere drs, sdrs, ha, ft, proactiveha, vds, vss, nsx, vsan, vvolume sang hệ thống mô hình uci verge.io?

Để thực hiện migration từ hệ thống VMware vSphere (bao gồm các tính năng như DRS, SDRS, HA, FT, ProactiveHA, VDS, VSS, NSX, vSAN, vVol) sang mô hình UCI của Verge.io, bạn cần sử dụng **VergeOS** – nền tảng chính của Verge.io. Dưới đây là chi tiết về cách VergeOS hỗ trợ quá trình này và loại license phù hợp:

### 🧩 Khả năng Migration của VergeOS

VergeOS sử dụng **phương pháp hai giai đoạn** để thực hiện migration từ VMware:

1. **Giai đoạn 1: Backup VM từ VMware**
   - Kết nối với vCenter hoặc ESXi host.
   - Thực hiện backup toàn bộ VM sử dụng API của VMware và Change Block Tracking (CBT).
   - Hỗ trợ backup theo lịch trình linh hoạt (theo phút, giờ, ngày...).

2. **Giai đoạn 2: Import/Convert sang VM của VergeOS**
   - Quá trình chuyển đổi diễn ra nhanh chóng, có thể thực hiện hàng loạt VM trong vài ngày.
   - Hỗ trợ kiểm thử an toàn và mở rộng với công nghệ Virtual Data Center của VergeOS [1](https://www.verge.io/blog/vmwareexit/how-to-migrate-vmware-vms/).

### 🔑 Loại License Cần Thiết

Để sử dụng đầy đủ các tính năng migration và vận hành trong môi trường không có kết nối Internet (air-gapped), bạn cần:

- **VergeOS Standard hoặc Enterprise License**: Tùy theo quy mô và yêu cầu tính năng (như Virtual Data Center, quản lý mạng, lưu trữ phân tán...).
- **Airgap License** (nếu hệ thống không có kết nối Internet):
  - Yêu cầu tạo file yêu cầu license và gửi email đến đội ngũ Verge.io.
  - Sau khi xử lý, bạn sẽ nhận được file license để upload vào hệ thống VergeOS [2](https://docs.verge.io/knowledge-base/category/licensing/).

### 🧠 Các Tính Năng VMware Tương Đương trong VergeOS

| Tính năng VMware | Tương đương trong VergeOS |
|------------------|----------------------------|
| DRS, SDRS        | Quản lý tài nguyên động qua Virtual Data Center |
| HA, FT           | Tính năng tự động phục hồi và phân phối VM |
| ProactiveHA      | Giám sát và phản ứng theo trạng thái hệ thống |
| VDS, VSS         | Quản lý mạng ảo tích hợp trong VergeOS |
| NSX              | Tích hợp SDN và bảo mật mạng nội bộ |
| vSAN, vVol       | Lưu trữ phân tán và quản lý volume động |

---

# Verge.io Licensed

>> Miêu tả chi tiết từng bước khi có license enterprise của verge.io tôi phải dựng mới hệ thống verge trước? Sau đó backup bên vsphere sddc ? Và rồi clone, vmotion, open ovf tool hoặc convert qcow2 sang dạng vmx, vmdk sang qcow2 vav import vào verge.io server?

Dưới đây là **quy trình chi tiết từng bước** để thực hiện migration từ VMware vSphere SDDC sang hệ thống **VergeOS Enterprise** của Verge.io:

---

### 🧱 **Giai đoạn 1: Dựng mới hệ thống VergeOS**

1. **Chuẩn bị phần cứng**
   - Tối thiểu 1 node vật lý (khuyến nghị 3 node để tận dụng tính năng phân tán).
   - Kiểm tra tương thích phần cứng với VergeOS (CPU, RAM, NIC, ổ đĩa...).

2. **Tải và cài đặt VergeOS**
   - Tải ISO từ Verge.io.
   - Boot từ ISO và cài đặt trực tiếp lên node vật lý.
   - Cấu hình ban đầu: IP, tên node, mật khẩu quản trị.

3. **Kích hoạt license Enterprise**
   - Truy cập giao diện quản trị VergeOS.
   - Upload file license Enterprise (nếu là air-gapped, bạn cần gửi yêu cầu license offline).
   - Sau khi kích hoạt, bạn có thể tạo các Virtual Data Center (VDC) để phân vùng tài nguyên.

---

### 🔄 **Giai đoạn 2: Backup từ VMware vSphere SDDC**

1. **Cấu hình kết nối đến vCenter hoặc ESXi**
   - Trong giao diện VergeOS, cấu hình dịch vụ kết nối đến vCenter hoặc ESXi host.
   - Cung cấp thông tin đăng nhập và IP quản lý.

2. **Thực hiện backup VM**
   - VergeOS sử dụng API của VMware và **Change Block Tracking (CBT)** để backup.
   - Backup có thể là:
     - **Full backup** ban đầu.
     - **Incremental backup** sau đó (chỉ backup phần thay đổi).
   - Lên lịch backup theo phút, giờ, ngày tùy nhu cầu.

---

### 🔁 **Giai đoạn 3: Chuyển đổi và import VM**

Có 2 cách chính:

#### ✅ **Cách 1: Dùng tính năng “Import” của VergeOS**

- Sau khi backup hoàn tất, bạn có thể chọn **“Import”** VM trực tiếp từ bản backup.
- VergeOS sẽ tự động chuyển đổi định dạng và tạo VM tương ứng.
- Quá trình này diễn ra **trong vài giây** và có thể thực hiện hàng loạt.

#### 🔧 **Cách 2: Thủ công – Dùng OVF Tool hoặc chuyển đổi định dạng**

Nếu bạn muốn thực hiện thủ công hoặc không dùng tính năng backup:

1. **Export VM từ vSphere**
   - Dùng **OVF Tool** hoặc vSphere Client để export VM dưới dạng OVF + VMDK.

2. **Chuyển đổi định dạng**
   - Dùng công cụ như `qemu-img` để chuyển từ VMDK sang QCOW2:
     ```bash
     qemu-img convert -f vmdk -O qcow2 vm.vmdk vm.qcow2
     ```

3. **Import vào VergeOS**
   - Upload file QCOW2 vào VergeOS.
   - Tạo VM mới và gắn QCOW2 làm ổ đĩa chính.

---

### 🧪 **Giai đoạn 4: Kiểm thử và vận hành**

- Dùng tính năng **Virtual Data Center (VDC)** để kiểm thử VM đã import.
- Kiểm tra mạng, lưu trữ, hiệu năng.
- Khi ổn định, bạn có thể **chuyển toàn bộ workload** sang VergeOS.

---

# Các chức năng có trên vCenter có thể chuyển sang Verge.io?

>> Vậy thì tôi vẫn còn thắc mắc chưa rõ phần đã cấu hình vsphere drs, sdrs, vsan, ha, proactive ha, ft, evc, vss, vds, nsx, vaai, vasa hba trong vcenter và tích hợp với nsx-t thì làm thế nào có thể convert và chuyển đổi, dùng lại, cấu hình lại bên vergeos vì tôi chưa thấy công cụ, dịch vụ hoặc app nào quản lý các tính năng tương tụ bên verge.io mà bên vsphere chính là vcenter.

Câu hỏi của bạn rất xác đáng: VergeOS không có một công cụ trung tâm tương đương **vCenter** để quản lý toàn bộ các tính năng như DRS, SDRS, HA, FT, Proactive HA, EVC, VDS, VSS, NSX-T, VAAI, VASA, HBA... như trong hệ sinh thái VMware. Tuy nhiên, VergeOS tiếp cận theo một cách **khác biệt về kiến trúc** – gọi là **Ultraconverged Infrastructure (UCI)** – và tích hợp các chức năng này **trực tiếp trong một hệ điều hành trung tâm duy nhất** thay vì phân mảnh thành nhiều thành phần như VMware [1](https://www.verge.io/blog/virtualization/comparing-vmware-to-vergeos/).

Dưới đây là cách VergeOS xử lý hoặc thay thế các tính năng bạn nêu:

---

### 🔁 So sánh từng tính năng VMware với VergeOS

| **Tính năng VMware** | **Tình trạng trong VergeOS** | **Ghi chú** |
|----------------------|------------------------------|-------------|
| **DRS / SDRS**       | ✅ Có tương đương | VergeOS tự động phân phối tài nguyên VM trong Virtual Data Center (VDC) |
| **HA / FT**          | ✅ Có tương đương | VergeOS hỗ trợ tự động phục hồi VM khi node lỗi, không cần cấu hình phức tạp |
| **Proactive HA**     | ⚠️ Không có trực tiếp | Không có tính năng giám sát phần cứng chủ động như vCenter, nhưng có cảnh báo lỗi node |
| **EVC**              | ❌ Không hỗ trợ | VergeOS không có tính năng tương đương EVC (Enhanced vMotion Compatibility) |
| **VSS / VDS**        | ✅ Có tương đương | VergeOS tích hợp SDN nội bộ, quản lý mạng ảo qua giao diện đơn giản |
| **NSX-T**            | ⚠️ Một phần | Không có NSX-T, nhưng có SDN tích hợp, firewall nội bộ, NAT, VLAN |
| **vSAN / vVol**      | ✅ Có tương đương | VergeOS tích hợp lưu trữ phân tán, không cần cấu hình SAN riêng |
| **VAAI / VASA**      | ❌ Không hỗ trợ | Không có tích hợp với VAAI/VASA vì không dùng SAN truyền thống |
| **HBA / iSCSI**      | ⚠️ Hạn chế | VergeOS không yêu cầu HBA vì lưu trữ tích hợp, nhưng có thể mount iSCSI ngoài nếu cần |

---

### 🧠 Về quản lý trung tâm

- **Không có vCenter**: VergeOS không cần một công cụ như vCenter vì mọi thứ được tích hợp trong một giao diện duy nhất.
- **Không cần NSX Manager, vSAN Manager, hay VASA Provider**: Các chức năng này được tích hợp sẵn trong VergeOS.
- **Không cần cấu hình cluster riêng biệt**: VergeOS tự động nhận diện và phân phối tài nguyên giữa các node.

---

### 📌 Kết luận

Nếu bạn đang tìm cách **chuyển đổi nguyên trạng cấu hình vSphere sang VergeOS**, thì:
- **Không thể chuyển trực tiếp cấu hình như DRS rules, HA settings, NSX policies...**
- Bạn cần **thiết kế lại mô hình mạng, phân phối tài nguyên và bảo mật** trong VergeOS theo cách đơn giản hơn, vì nó không phân mảnh như VMware.

---

# Quá trình migrate từ VMware vSphere sang VergeOS: 

>> Vậy thì sẽ có một số hệ thống không có tương ứng ở vsphere có và verge.io thì không có. Giả sử tôi phải mua đầu tư mới verge.io đáp ứng sizing mới lớn hơn bao nhiêu? có dự phòng để nhận migration được vsphere sang? Và về tiết kiệm tái sử dụng thiết bị vsphere cũ sẽ có cách nào kiểm tra hoặc tính được các thiết bị vsphere kia cũng chuyển sang được verge.io những thiết bị nào thì không thể.

Để đảm bảo quá trình **migrate từ VMware vSphere sang VergeOS** diễn ra hiệu quả, bạn cần xem xét hai khía cạnh chính:

---

## 🧱 1. **Sizing hệ thống mới VergeOS**

Theo tài liệu chính thức từ Verge.io [1](https://docs.verge.io/implementation-guide/transition-from-vmware/) [2](https://www.verge.io/blog/vmwareexit/how-to-migrate-vmware-vms/), bạn nên thực hiện các bước sau:

### ✅ **Xác định tài nguyên cần migrate**
- Tổng số VM cần chuyển.
- Tổng dung lượng lưu trữ đang sử dụng (vSAN, vVol...).
- Tổng số vCPU, RAM đang dùng.
- Yêu cầu về hiệu năng (IOPS, băng thông mạng).

### 📊 **Tính toán hệ thống mới**
- **CPU**: Số lượng core cần thiết để chạy toàn bộ VM với hiệu năng tương đương hoặc cao hơn.
- **RAM**: Tổng RAM cần thiết + 20–30% dự phòng.
- **Storage**:
  - SSD/NVMe cho hiệu năng cao.
  - HDD cho lưu trữ archive hoặc snapshot.
  - Khuyến nghị: Không dùng HDD > 8TB nếu không phải môi trường archive [3](https://wiki.verge.io/public/reqs).

### 📡 **Mạng**
- NIC 10GbE hoặc cao hơn.
- VLAN hoặc SDN nếu cần phân vùng mạng nội bộ.

### 📦 **Dự phòng**
- Tối thiểu 3 node để tận dụng tính năng phân tán và HA.
- Có thể scale-out dễ dàng bằng cách thêm node.

---

## 🔁 2. **Tái sử dụng thiết bị VMware cũ**

### 🔍 **Cách kiểm tra khả năng tương thích phần cứng**

VergeOS có thể cài trực tiếp lên phần cứng cũ nếu đáp ứng các yêu cầu sau:

| Thành phần | Yêu cầu tối thiểu | Ghi chú |
|------------|-------------------|--------|
| CPU        | x86_64, hỗ trợ VT-x | Không hỗ trợ ARM |
| RAM        | ≥ 32GB / node      | Tùy theo số lượng VM |
| Storage    | SSD/NVMe khuyến nghị | HDD dùng cho archive |
| NIC        | Intel/Broadcom 1GbE/10GbE | Hỗ trợ VLAN, bonding |
| RAID/HBA   | Không yêu cầu RAID | VergeOS quản lý lưu trữ nội bộ |

### 🛠️ **Cách kiểm tra nhanh**
- Boot thử ISO VergeOS trên phần cứng cũ.
- Nếu khởi động thành công và nhận diện đầy đủ CPU, RAM, NIC, Storage → có thể dùng lại.
- Nếu không nhận diện NIC hoặc disk → cần thay thế phần cứng đó.

---

## 📌 Kết luận

- **Sizing hệ thống mới** cần dựa trên tổng tài nguyên đang dùng + dự phòng.
- **Thiết bị cũ** có thể tái sử dụng nếu tương thích phần cứng, giúp tiết kiệm chi phí.
- VergeOS không yêu cầu RAID, SAN, hay HBA phức tạp → đơn giản hóa triển khai.

---

# Bản chất của việc chuyển đổi cấu hình vCenter với các chức năng DRS, SDRS, HA, FT, EVC, vSAN, vSS, vDS, NSX sang VergeOS:

>> Trong các tính năng của vsphere nêu trên hầu hết là nằm trên vcenter vm appliance, nếu bên verge.io có tương đương hoặc không có , có một phần. thì khi chuyển đổi từ vcenter sang vergeos được hiểu là trực tiếp, gián tiếp , có sẵn ở cấu hình vergeos trên các node hay là phải dùng tool convert để chuyển vcenter appliance sang vm qcow2.

Bản chất của sự khác biệt giữa **kiến trúc phân lớp của VMware vSphere** (với vCenter là trung tâm điều phối) và **kiến trúc tích hợp của VergeOS**. Dưới đây là phân tích chi tiết:

---

## 🧠 1. **vCenter Appliance là gì trong vSphere?**

vCenter là một **VM appliance** chạy trên nền Photon OS, dùng để:
- Quản lý cluster, DRS, HA, FT, EVC.
- Quản lý mạng (VDS, VSS), lưu trữ (vSAN, vVol).
- Tích hợp với NSX-T, VASA, VAAI, HBA...
- Là trung tâm điều phối toàn bộ vSphere.

---

## 🔁 2. **Khi chuyển sang VergeOS, có cần migrate vCenter appliance không?**

**Không.** Bạn **không cần và không nên** migrate vCenter appliance sang VergeOS vì:

- VergeOS **không sử dụng vCenter** hay bất kỳ thành phần nào của VMware.
- Các tính năng như DRS, HA, lưu trữ, mạng... được **tích hợp sẵn trong VergeOS kernel** và giao diện quản trị.
- vCenter chỉ có ý nghĩa trong hệ sinh thái VMware.

---

## 🔄 3. **Vậy migration từ vSphere sang VergeOS là trực tiếp hay gián tiếp?**

| **Khía cạnh** | **Hình thức migration** | **Giải thích** |
|---------------|--------------------------|----------------|
| **VM workload** | ✅ **Trực tiếp hoặc gián tiếp** | Dùng backup API hoặc convert OVF/VMDK → QCOW2 |
| **Cấu hình vCenter (DRS, HA, NSX...)** | ❌ **Không chuyển được** | Không có công cụ nào chuyển cấu hình vCenter sang VergeOS |
| **vCenter appliance VM** | ❌ **Không cần chuyển** | Không còn giá trị trong môi trường VergeOS |

---

## 🛠️ 4. **Nếu vẫn muốn giữ lại vCenter appliance để tham chiếu?**

Bạn có thể:
- Export vCenter appliance dưới dạng OVF/VMDK.
- Convert sang QCOW2 bằng `qemu-img`.
- Import vào VergeOS như một VM bình thường (chỉ để tham khảo, không hoạt động quản lý).

Tuy nhiên, điều này **không mang lại lợi ích thực tế** vì vCenter không thể quản lý hạ tầng VergeOS.

---

## 📌 Kết luận

- VergeOS **không cần vCenter** – mọi tính năng được tích hợp sẵn.
- Migration là **gián tiếp về mặt cấu hình**, nhưng **trực tiếp về workload VM**.
- Không có công cụ nào chuyển đổi cấu hình DRS, HA, NSX... từ vCenter sang VergeOS.
- Bạn cần **thiết kế lại mô hình mạng, lưu trữ, HA** trong VergeOS theo cách riêng của nó.

---

# Phương án đầu tư khác hiệu quả hơn ?

>> Hãy so sánh cách migration từ vsphere sang verge.io (theo tôi thấy muốn migration thì phải đầu tư mới verge.io mới có đủ tài nguyên để di chuyển từ vSphere sang) so với chuyển lên CloudStack apache (nghĩa là dùng lại hạ tầng vSphere và build lênCloudStack hoặc open stack), nutanix hci, để khai thác sử dụng, cái nào hiệu quả kinh tế, đáp ứng với các công nghệ gốc nhiều và phù hợp với công nghệ mới sau chuyển đổi hơn.

Dưới đây là bảng **so sánh chi tiết** giữa các nền tảng khi thực hiện **migration từ VMware vSphere**: Verge.io, Apache CloudStack, OpenStack và Nutanix HCI – xét theo các tiêu chí: **hiệu quả kinh tế**, **tương thích công nghệ**, và **khả năng khai thác sau chuyển đổi**:

---

### 🔁 **1. So sánh tổng quan**

| Tiêu chí | **Verge.io** | **Apache CloudStack** | **OpenStack** | **Nutanix HCI** |
|----------|--------------|------------------------|----------------|------------------|
| **Chi phí đầu tư** | ⭐ Rẻ nhất (dùng lại phần cứng cũ) | ⭐ Miễn phí (open source) nhưng cần kỹ thuật cao | ⭐ Miễn phí nhưng triển khai phức tạp | ❗ Cao (phần cứng riêng, license) |
| **Tốc độ migration** | ⏱️ Rất nhanh (5s/100 VM) [1](https://www.verge.io/blog/vmwareexit/high-performance-vmware-migration/) | ⏱️ Trung bình (phụ thuộc công cụ) | ⏱️ Trung bình đến chậm | ⏱️ Nhanh nếu dùng Nutanix Move |
| **Tương thích VM gốc (VMDK, OVF)** | ✅ Có, hỗ trợ trực tiếp | ⚠️ Cần convert | ⚠️ Cần convert sang KVM/QCOW2 | ✅ Có công cụ hỗ trợ |
| **Tính năng tương đương vSphere** | ⚠️ Một phần (tích hợp sẵn) | ⚠️ Một phần (phụ thuộc plugin) | ✅ Có thể mở rộng đầy đủ | ✅ Tích hợp đầy đủ |
| **Khả năng mở rộng** | ✅ Dễ dàng (scale-out node) | ✅ Tốt (cloud-native) | ✅ Rất tốt (cloud-native) | ✅ Tốt (scale-out HCI) |
| **Yêu cầu kỹ thuật triển khai** | ⭐ Dễ nhất | ❗ Cao | ❗ Rất cao | ⭐ Trung bình |
| **Tái sử dụng phần cứng cũ** | ✅ Tốt nhất | ✅ Có thể | ✅ Có thể | ❌ Không (phải dùng phần cứng Nutanix) |
| **Tính mở, tránh vendor lock-in** | ✅ Có | ✅ Có | ✅ Rất cao | ❌ Không |

---

Dưới đây là biểu đồ radar so sánh **4 phương án migration từ vSphere** theo các tiêu chí: **chi phí đầu tư**, **khả năng tái sử dụng hạ tầng**, **tương thích công nghệ gốc (vSphere)**, và **khả năng thích ứng công nghệ mới**:

![Biểu đồ so sánh các phương án migration từ vSphere](blob:https://copilot.cloud.microsoft/9d8313e7-053f-4b40-b990-11c53b093bc3)

---

## 🧠 Giải thích các phương án

### 1. **Verge.io (đầu tư mới)**
- **Chi phí đầu tư**: Cao do cần dựng hạ tầng mới.
- **Tái sử dụng hạ tầng**: Thấp, chỉ dùng lại được phần cứng tương thích.
- **Tương thích vSphere**: Trung bình (chuyển đổi VM được nhưng không giữ cấu hình).
- **Thích ứng công nghệ mới**: Tốt (UCI tích hợp sẵn SDN, lưu trữ phân tán...).

### 2. **Apache CloudStack (dùng lại vSphere)**
- **Chi phí đầu tư**: Thấp (open source, tận dụng hạ tầng cũ).
- **Tái sử dụng hạ tầng**: Rất cao.
- **Tương thích vSphere**: Rất tốt (CloudStack hỗ trợ vSphere như một zone).
- **Thích ứng công nghệ mới**: Tốt (cloud-native, orchestration).

### 3. **OpenStack (dùng lại vSphere hoặc KVM)**
- **Chi phí đầu tư**: Trung bình (phức tạp hơn CloudStack).
- **Tái sử dụng hạ tầng**: Cao.
- **Tương thích vSphere**: Tốt nhưng cần plugin hoặc chuyển sang KVM.
- **Thích ứng công nghệ mới**: Rất cao (cloud-native, AI-ready, multi-cloud).

### 4. **Nutanix HCI**
- **Chi phí đầu tư**: Rất cao (phần cứng riêng, license).
- **Tái sử dụng hạ tầng**: Thấp (phải dùng phần cứng Nutanix).
- **Tương thích vSphere**: Trung bình (có thể chạy trên ESXi hoặc AHV).
- **Thích ứng công nghệ mới**: Tốt (HCI, hybrid cloud, AI-ready).

---

## 📌 Kết luận

| Mục tiêu | Phương án phù hợp |
|----------|-------------------|
| **Tiết kiệm chi phí, tận dụng hạ tầng cũ** | ✅ **Apache CloudStack** |
| **Chuyển đổi sang cloud-native mạnh mẽ** | ✅ **OpenStack** |
| **Tích hợp đơn giản, hiệu năng cao** | ✅ **Nutanix HCI** (nếu có ngân sách) |
| **Tối giản quản lý, triển khai nhanh** | ✅ **Verge.io** (nếu đầu tư mới toàn bộ) |

---

#  Phát triển xây dựng apache cloudstack trên nền vsphere 8.0u3:

>> Nếu tôi vẫn dùng vsphere 8.0u3 và phát triển xây dựng apache cloudstack thì nội dung so sánh trên viết lại như thế nào?

Nếu bạn vẫn tiếp tục sử dụng **VMware vSphere 8.0u3** nhưng muốn **xây dựng và phát triển Apache CloudStack** song song hoặc để thay thế dần, thì bảng so sánh sẽ cần được điều chỉnh để phản ánh **mô hình hybrid** và **khả năng tích hợp** giữa hai nền tảng. Dưới đây là phiên bản cập nhật:

---

## 🔁 So sánh: **vSphere 8.0u3 + Apache CloudStack**

| Tiêu chí | **vSphere 8.0u3** | **Apache CloudStack** | **Kết hợp / Hybrid** |
|----------|-------------------|------------------------|------------------------|
| **Chi phí bản quyền** | ❗ Cao (vCenter, vSAN, NSX...) | ✅ Miễn phí (open source) | ⚠️ Tăng nếu duy trì song song |
| **Tính năng quản lý** | ✅ Tập trung qua vCenter | ✅ Quản lý cloud-native | ⚠️ Cần tích hợp API hoặc dual control |
| **Khả năng mở rộng** | ⚠️ Hạn chế nếu không dùng vSAN | ✅ Rất tốt (multi-hypervisor, multi-zone) | ✅ Có thể mở rộng theo vùng |
| **Tương thích VM gốc** | ✅ Native (VMDK, OVF) | ⚠️ Cần convert sang KVM/QCOW2 | ⚠️ Phải thiết kế lại template |
| **Tích hợp mạng (NSX, SDN)** | ✅ NSX-T mạnh mẽ | ⚠️ Dùng plugin hoặc SDN ngoài | ⚠️ Không tương thích trực tiếp |
| **Khả năng tự động hóa** | ✅ vRealize, API | ✅ API, Ansible, Terraform | ✅ Có thể tích hợp |
| **Khả năng hybrid cloud** | ⚠️ Giới hạn nếu không dùng VMware Cloud | ✅ Native multi-cloud | ✅ Có thể dùng CloudStack làm orchestrator |
| **Yêu cầu kỹ thuật** | ⭐ Trung bình | ❗ Cao (Linux, KVM, networking) | ❗ Cao hơn nếu tích hợp song song |
| **Tái sử dụng phần cứng** | ✅ Có thể | ✅ Có thể | ✅ Tùy theo hypervisor |

---

## 📌 Kết luận theo mục tiêu

| Mục tiêu | Giải pháp phù hợp |
|----------|-------------------|
| **Duy trì ổn định, tận dụng đầu tư VMware** | Tiếp tục dùng **vSphere 8.0u3** |
| **Từng bước chuyển đổi sang cloud-native** | Xây dựng **Apache CloudStack** song song |
| **Tối ưu chi phí dài hạn, tránh vendor lock-in** | Dần chuyển workload sang **CloudStack + KVM** |
| **Tích hợp hybrid cloud, đa vùng** | Dùng **CloudStack làm orchestrator**, vSphere là 1 zone |

---

Dưới đây là sơ đồ kiến trúc **hybrid giữa VMware vSphere 8.0u3 và Apache CloudStack**:

![Sơ đồ kiến trúc hybrid giữa vSphere và CloudStack](data:image/png;base64,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F3rtESNGZPr06XnkkUfyu9/9Ltdcc01mzZpVer5169ZZsmRJfv/732fZsmXVju/QoUNGjRqVJJkyZUreeuutXHnllUmSBQsWZOTIkXn22Wfz8MMPp06dOvnOd75TirPz58/PzjvvnDfffDOjR4/OX//615x22mk1xtsXXngh/fv3zwEHHJBf/vKXqVPH/5QAAABAbbFFA8BKpk6dmmXLlmXzzTdf42NuvvnmLFq0KL/97W9LUfjqq6/O0KFDc/HFF2ejjTZa7Tleeuml3HvvvXnmmWey3XbbJUmuu+66dO/evTTmG9/4Rn784x/n0EMPzXe/+91su+222XXXXXP44Ydno402St26ddO8efMkSatWrarE6P3226/K61133XVp1apVXnzxxWy55Za55ZZb8s477+TZZ58tnWOzzTarNs+nn346Q4YMyY9+9KOceuqpa/w1AgAAAL4all0BrGTFytiysrI1PqaysjK9evWqsuK3f//++eSTTzJlypQ1Pke9evWy9dZblx7bfPPNq60Y/s///M+8/fbb+dWvfpUePXrkV7/6VTbffPM8//zzn3v+V155JYceemg22WSTNGnSJJ07d06SzJgxI0kyefLk9OnTpxR3azJjxowMHDgwZ555prgLAAAAawmBF2AlXbp0SVlZWSorK9f4mGXLlq0yCK94vE6dOtW2VVi8eHGVc6w8/vO0aNEiBxxwQH7605+msrIybdu2zWWXXfa5xwwdOjRz5szJb37zm0yYMKG0t+7HH3+cJGnUqNFqX3fDDTfMtttum9tuuy0ffPDBascDAAAAXz2BF2AlzZs3z6BBg/KLX/wiCxYsqPb83Llzqz3Wo0ePTJ48ucr48ePHp06dOunatWuS5XH0rbfeKj2/dOnSvPDCC6X73bt3z5IlS/LnP/+59NiUKVNqfL2V1a9fP5tuumnptevXr186/wpz5sxJZWVlzjzzzOy2227p3r173nvvvSrn6dmzZyZPnpx33313la/VqFGjjBkzJg0bNsygQYMyb968z50bAAAA8NUTeAE+45prrsnSpUuz7bbbZtSoUXn55ZdTWVmZq666Kttvv3218YcddlgaNmyYI444Ii+88EIeffTRnHTSSRk+fHhp/91dd901Y8eOzdixY/P3v/89xx9/fJV4261btwwePDjHHntsJkyYkIkTJ+aYY46psrJ2zJgxGTZsWMaMGZOXXnopU6ZMyWWXXZZ77rkne++9d5Jk4403TllZWcaMGZN33nkn8+fPT7NmzdKiRYv8+te/ztSpU/PII49k5MiRVd7DIYccktatW2efffbJ+PHj8+qrr2bUqFF5+umnq4xr3Lhxxo4dm3r16mWPPfbI/Pnzv6wvOwAAAPBPEHgBPqNz586ZNGlSBgwYkFNOOSVbbrlldt999zz88MP55S9/WW18eXl57r///rz77rvZZpttsv/++2e33XbL1VdfXRpz1FFH5Ygjjsjhhx+enXfeOZ07d86AAQOqnOeGG25Ihw4dsvPOO2fffffNcccdl1atWpWe79GjR8rLy3PKKaekd+/e+cY3vpE77rgj1157bYYPH54kadeuXc4777ycccYZ2WijjXLiiSemTp06ue222zJx4sRsueWW+eEPf5hLL720ymvXr18/DzzwQFq1apU999wzW221VS666KLUrVu32vtdf/31c++992bZsmXZc889a1zpDAAAAHw9ypZ9dlNIoHDaX94+M+fNTNuKtnlx5Iu1PZ1aN3nS5OzSb5dMnDgxffv2re3pwFpr0qRJ6devX8ZNHJfefXvX9nRq5HqGNfN1Xs+uS1hzK65N1wsAXyUreAEAAAAACkrgBQAAAAAoKIEXAAAAAKCgBF4AAAAAgIISeAEAAAAACkrgBfiMESNGpKysLN/97nerPXf88cenrKwsI0aM+PonBgAAAPAZAi9ADTp06JDbbrstixYtKj324Ycf5tZbb03Hjh1rcWZfnqVLl+aTTz6p7WnAV2bEiBHZZ599qjz2u9/9Lg0bNswll1ySk046KV26dKnx2JkzZ6Zu3bq56667kiRlZWUpKyvLM888U2XcRx99lBYtWqSsrCzjxo37QnNJknHjxqWsrCxz5879Im9tlXbZZZecfPLJqx131113ZdCgQWnZsmXKysoyefLkL+X1YU24Nmu2ePHinH766dlqq63SuHHjtG3bNocffnjefPPNL2UOAMC6S+AFqEHfvn3TsWPH0j8gk+VBpEOHDunTp0/psfvuuy877rhjmjZtmhYtWmTIkCF55ZVXSs9Pnz49ZWVlueuuuzJgwICUl5enV69eefrpp0tj5syZk0MOOSTt27dPeXl5ttpqq9x6661V5jNv3rwcdthhady4cdq0aZMrrrii2j8WP/7445x22mlp165dGjdunO22267KP2pvvPHGNG3aNGPGjEmPHj3SoEGDvPbaa1/iVw3Wbtdee20OO+ywXH311TnttNNy9NFHZ+rUqXniiSeqjb3xxhvTokWLDB06tPRYhw4dcsMNN1QZ9/vf/z7rr7/+Vz73L9uCBQvSv3//XHTRRbU9FXBt/n8LFy7MpEmTctZZZ2XSpEm566678tJLL+Xb3/52bU8NAFjLCbwAq3DkkUdW+Qfj9ddfn6OOOqrKmAULFmTkyJF59tln8/DDD6dOnTr5zne+U21l7E9+8pOceuqpmTx5crp27ZpDDjkkS5YsSbJ8ZXC/fv0yZsyYvPDCCznuuOMyfPjwTJgwoXT8yJEjM378+IwePToPPvhgnnjiiUyaNKnafMePH5/bbrstzz33XA444IAMHjw4L7/8cmnMwoULc+GFF+baa6/N3/72t7Rq1epL+3rB2uySSy7JiSeemFtuuSXHHHNMkqR3797p27dvrr/++mrjb7zxxhx++OFZb731So8dccQR1Vb2X3/99TniiCO+1LmOGjUqW2yxRRo0aJBOnTrlpz/9aZXnr7nmmnTp0iUNGzbMRhttlP333z/J8pWIjz32WK688srSqsbp06fX+BrDhw/P2WefnYEDB36pc4cvyrX5qQ022CAPPvhgDjzwwHTr1i3f+MY38vOf/zwTJ07MjBkzvtT3AgCsWwRegFUYPnx4nnzyyUyfPj2vvfZaxo8fn2HDhlUZs99++2XfffdNly5d0rt371x33XV5/vnn8+KLL1YZd+qpp2avvfZK165dc9555+W1117L1KlTkyTt2rXLqaeemt69e2eTTTbJSSedlEGDBuXOO+9Msnz17k033ZTLLrssu+22W7bccsvccMMNWbp0aen8r7zySm699dbceeed+eY3v5lNN900p556anbccccqkXrx4sW55pprssMOO6Rbt25p3LjxV/Xlg7XGGWeckQsuuCBjxozJfvvtV+W5o48+OnfeeWfmz59feuyxxx7L1KlTq/1Ap1+/funcuXNGjRqVJHn99dfz+OOPZ/jw4V/aXCdOnJgDDzwwBx98cJ5//vmce+65Oeuss3LjjTcmSf785z/n+9//fs4///xMmTIl9913X3baaackyZVXXpntt98+xx57bN5666289dZb6dChw5c2N/iyuTZX7/33309ZWVmaNm36pb0XAGDdU6+2JwCwtmrZsmX22muv3HTTTVm2bFn22muvtGzZssqYV155JWeddVaeeeaZzJ49u7Ryd8aMGdlyyy1L43r27Fm63aZNmyTJrFmzsvnmm2fp0qW56KKLcvvtt2fmzJn56KOP8tFHH5Xi66uvvprFixdn2223LZ1jgw02SLdu3Ur3J02alGXLlqVr165V5rdiD8IV6tevX2UusK67995788c//jEPP/xwdt1112rPH3rooTnllFNy55135sgjj0yyfOXf9ttvnx49elQbf+SRR+b666/PsGHDcsMNN2TPPffMhhtuuEZzGTNmTLVfGV/5BzVJcvnll2e33XbLWWedlSTp2rVrXnzxxVx66aUZMWJEZsyYkcaNG2fIkCGpqKjIxhtvXNo2ZoMNNkj9+vVTXl6e1q1br9GcoLa4Nlfvww8/zBlnnJFDDz00TZo0WePjAIB/PVbwAnyOo446KjfeeGNuuummaiuGkmTo0KGZM2dOfvOb32TChAmlbRU+/vjjKuNW/lXSsrKyJCnF4J/+9Ke54oorctppp+WRRx7J5MmTM2jQoNI5li1bVuW4FVY8vuJcdevWzcSJEzN58uTSn8rKylx55ZWlcY0aNap2HliX9ezZM506dcrZZ5+defPmVXu+adOm2XfffUu/Cj5v3ryMGjWqxus9SYYNG5ann346r776am688cZVjqvJgAEDqlyfkydPzrXXXltlTGVlZfr371/lsf79++fll1/O0qVLs/vuu2fjjTfOJptskuHDh+fmm2/OwoUL13gOsLZwbX6+xYsX5+CDD84nn3ySa6655p8+DwDwr0HgBfgcgwcPzscff5yPP/44gwYNqvLcnDlzUllZmTPPPDO77bZbunfvnvfee+8Lv8YTTzyRvffeO8OGDUuvXr2yySabVNk3d9NNN816662XP/3pT6XHPvjggypj+vTpk6VLl2bWrFnZbLPNqvyxko9/Ze3atctjjz2Wt956K4MHD64xJB199NF58skn8/LLL+f2229Pkhx00EE1nm/FhykeffTR+fDDD7PHHnus8VwaN25c7fps165dlTHLli373B/mVFRUZNKkSbn11lvTpk2bnH322enVq1fmzp27xvOAtYFrc9UWL16cAw88MNOmTcuDDz5o9S4AsFoCL8DnqFu3biorK1NZWZm6detWea5Zs2Zp0aJFfv3rX2fq1Kl55JFHMnLkyC/8GptttlkefPDBPPXUU6msrMy//du/5e233y49X1FRkSOOOCL//u//nkcffTR/+9vfctRRR6VOnTqlf2x27do1hx12WA4//PDcddddmTZtWp599tlcfPHFueeee/5vXwQouI4dO+axxx7LrFmz8q1vfSsffPBBlecHDBiQTTbZJDfeeGOuv/76HHjggamoqFjl+Y466qiMGzcuhx9+eLX/Xvi/6tGjR5588skqjz311FPp2rVr6bXq1auXgQMH5pJLLslzzz2X6dOn55FHHkmyfBuWz/5qOaytXJvVrYi7L7/8ch566KEq2ywBAKyKPXgBVmNVK2fq1KmT2267Ld///vez5ZZbplu3brnqqquyyy67fKHzn3XWWZk2bVoGDRqU8vLyHHfccdlnn33y/vvvl8Zcfvnl+e53v5shQ4akSZMmOe200/L666+nYcOGpTE33HBD/uM//iOnnHJKZs6cmRYtWmT77bfPnnvu+U+9b1iXtG/fPuPGjcuAAQPyrW99K/fff3822GCDJMu3PznyyCNz+eWX57333sull176uecaPHhw3nnnna9kVd0pp5ySbbbZJhdccEEOOuigPP3007n66qtLv6I9ZsyYvPrqq9lpp53SrFmz3HPPPfnkk09Ke3J36tQpEyZMyPTp07P++uunefPmqVOn+s/z33333cyYMSNvvvlmkmTKlClJktatW1v1z9fKtfmpJUuWZP/998+kSZMyZsyYLF26tPQD3+bNm6d+/fpf+vsCANYNAi/AZ6z4ROxV+cMf/lC6PXDgwLz44otVnl/5VzY7depU5X6yfF/BlR9r3rx5lXPWpKKiIjfffHPp/oIFC3LeeefluOOOKz223nrr5bzzzst5551X4zlGjBiRESNGfO7rwLpsxa+EDxgwILvvvnseeOCB0ifTjxgxIuecc066detWbZ/NzyorK6v2gYtflr59++aOO+7I2WefnQsuuCBt2rTJ+eefX7p2mzZtmrvuuivnnntuPvzww3Tp0iW33nprtthiiyTJqaeemiOOOCI9evTIokWLMm3atHTq1Kna64wePbr0wVVJcvDBBydJzjnnnJx77rlfyXuDVXFtLvfGG29k9OjRSZLevXtXee7RRx/9wj9ABgD+dZQt+2x5AAqn/eXtM3PezLStaJsXR764+gPWcZMnTc4u/XbJxIkT07dv39qezpfiL3/5S/7+979n2223zfvvv5/zzz8/48aNy9SpU7+yf8yy7ps0aVL69euXcRPHpXff3rU9nRqti9czfBW+zuvZdQlrbsW16XoB4KtkBS9AQVx22WWZMmVK6tevn379+uWJJ54QdwEAAOBfnMALUAB9+vTJxIkTa3saAAAAwFqm+qduAAAAAABQCAIvAAAAAEBBCbwAAAAAAAUl8AIAAAAAFJTACwAAAABQUAIvAAAAAEBBCbwAAAAAAAUl8AIAAAAAFJTACwAAAABQUAIvAAAAAEBBCbwAAAAAAAUl8AIAAAAAFJTACwAAAABQUAIvAAAAAEBBCbwAAAAAAAUl8AIAAAAAFJTACwAAAABQUAIvAAAAAEBBCbwAAAAAAAVVr7YnAPBVqaysrO0pwFqtSNdIkeYKtaE2rhHXJaye6wSAr4PAC6xzWrRskfLy8gwbNqy2pwJrvfLy8rRo2aK2p7FKrmdYc1/X9ey6hC+mvLw8LVu2rO1pALAOE3iBdU6Hjh0yoXJC5syeU9tTgbVei5Yt0qFjh9qexiq5nmHNfV3Xs+uSz7P//+6f2QtmZ8PGG+a+YffV9nTWCi1btkzHjh1rexoArMMEXmCd1KFjh7U6WgFrzvUMax/XJatSf1z9ZF5Sv6J++vbtW9vTAYB/CT5kDQAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAApK4AUAAAAAKCiBFwAAAACgoAReAAAAAICCEngBAAAAAAqqXm1PAPjyvD3/7fS4vEdtTwMAgH9Rb89/u7anAAD/cgReWId8suyTvDnvzdqeBgAAAABfE4EX1gGt129d21MAAIAS//8UAL4+ZcuWLVtW25MAAAAAAOCL8yFrAAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFACLwAAAABAQQm8AAAAAAAFJfACAAAAABSUwAsAAAAAUFD/D6UiZ7qucnUkAAAAAElFTkSuQmCC)

---

## 🧭 Giải thích sơ đồ

### 🔷 **VMware vSphere Zone**
- **vCenter** quản lý các **ESXi Host**.
- Các VM đang chạy trên nền tảng vSphere.
- Mạng quản lý và workload được phân tách rõ ràng.

### 🟩 **Apache CloudStack Zone**
- **CloudStack Manager** điều phối các **KVM Host**.
- Mỗi KVM host có thể chạy VM được tạo từ template QCOW2.
- CloudStack có thể quản lý nhiều zone, pod, cluster.

### 🔁 **Tầng tích hợp / Orchestration**
- Có thể dùng **API tích hợp** hoặc **dual orchestration** để điều phối workload giữa hai nền tảng.
- Một số công cụ có thể hỗ trợ như:
  - Terraform (multi-provider)
  - Ansible (multi-inventory)
  - CloudStack API + vSphere SDK

---

## 🛠️ Lộ trình chuyển đổi từng bước

### **Giai đoạn 1: Chuẩn bị**
1. Đánh giá hệ thống vSphere hiện tại (số lượng VM, tài nguyên, mạng).
2. Cài đặt CloudStack Manager và thiết lập zone KVM riêng biệt.
3. Chuẩn hóa template VM (QCOW2) để dùng cho CloudStack.

### **Giai đoạn 2: Triển khai song song**
4. Tạo các VM mới trên CloudStack để thử nghiệm.
5. Thiết lập mạng tương đương (VLAN, SDN, firewall).
6. Kiểm thử hiệu năng, HA, snapshot, backup.

### **Giai đoạn 3: Migration từng phần**
7. Dùng công cụ như `qemu-img` để convert VMDK → QCOW2.
8. Import VM vào CloudStack hoặc tạo mới từ template.
9. Chuyển dần workload không phụ thuộc vSphere sang CloudStack.

### **Giai đoạn 4: Tối ưu và mở rộng**
10. Tắt dần các ESXi host không còn cần thiết.
11. Tái sử dụng phần cứng cho KVM nếu tương thích.
12. Tích hợp giám sát, tự động hóa (Prometheus, Ansible...).

---


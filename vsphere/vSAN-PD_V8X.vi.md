### **Kế hoạch chi tiết các Mô-đun Thực hành Khóa học: VMware vSAN: Lập kế hoạch và triển khai [V8.x]**

**Thông tin chung:**
*   **Tên khóa học:** VMware vSAN: Lập kế hoạch và triển khai [V8.x]
*   **Thời lượng:** 3 ngày
*   **Đối tượng:** Quản trị viên VMware vSphere có kinh nghiệm (2+ năm), ưu tiên VCP-DCV 2023+.
*   **Mục tiêu tổng quát:** Cung cấp kiến thức, kỹ năng và công cụ để lập kế hoạch và triển khai các cụm VMware vSAN.

**Yêu cầu môi trường Lab (Chung cho cả khóa học):**
Mỗi học viên hoặc nhóm học viên sẽ có một môi trường vSphere Lab riêng biệt, bao gồm:
*   **VMware vCenter Server Appliance (VCSA):** Đã triển khai và cấu hình cơ bản, có ít nhất một trung tâm dữ liệu (Datacenter) và một cụm (Cluster) rỗng.
*   **VMware ESXi Hosts:** Tối thiểu 3 máy chủ ESXi (để triển khai cụm vSAN tiêu chuẩn) và thêm 2-3 máy chủ ESXi (cho cụm kéo dài/cụm 2 nút/máy chủ chứng nhân). Các máy chủ ESXi đã được cài đặt và thêm vào vCenter Server.
    *   Mỗi ESXi host cần có:
        *   Tối thiểu 2 vNIC vật lý (khuyên dùng 4+ vNIC để phân tách traffic).
        *   Đủ RAM (tối thiểu 8GB/host trong lab, khuyên 16GB+) và CPU.
        *   Thiết bị lưu trữ:
            *   Ít nhất 1 ổ đĩa SSD/NVMe nhỏ (tối thiểu 10GB, khuyên 20GB+) để làm Cache Tier.
            *   Ít nhất 1 ổ đĩa SSD/HDD lớn (tối thiểu 50GB, khuyên 100GB+) để làm Capacity Tier.
            *   (Đối với lab ảo hóa, có thể dùng vHDD của VM ESXi).
*   **Mạng:** Mạng Layer 2/3 đã được cấu hình với VLANs hoặc phân đoạn mạng rõ ràng cho các loại traffic (Management, vMotion, vSAN, VM Traffic).
*   **Giấy phép:** Giấy phép vSAN phù hợp (có thể là giấy phép đánh giá cho mục đích đào tạo).

---

### **Cấu trúc Mô-đun Thực hành theo ngày:**

#### **NGÀY 1: Giới thiệu, Lập kế hoạch và Chuẩn bị vSAN**

**Mục tiêu ngày 1:** Nắm vững các khái niệm cơ bản về vSAN, hiểu các yêu cầu phần cứng/mạng, và thực hiện các bước chuẩn bị ban đầu cho máy chủ và mạng để sẵn sàng triển khai vSAN.

---

**Mô-đun 1: Giới thiệu vSAN và Tổng quan kiến trúc**
*   **Thời lượng dự kiến:** 1.5 giờ (Lý thuyết: 1 giờ, Thực hành/Demo: 0.5 giờ)
*   **Mục tiêu thực hành:**
    *   Trình bày giao diện vSAN trong vSphere Client.
    *   Xác định các thành phần vSAN cơ bản (Disk Group, Cache/Capacity Tier) trên một cụm đã cấu hình (demo).
*   **Nội dung thực hành:**
    *   **Demo:** Điều hướng và xem tổng quan về vSAN trong vSphere Client trên một cụm vSAN đã tồn tại (nếu có môi trường demo sẵn).
    *   Xem trạng thái vSAN Health, Disk Groups, và dung lượng tổng thể.
    *   Thảo luận về cách các khái niệm lý thuyết (chẳng hạn như object, component) được ánh xạ vào giao diện người dùng.
*   **Yêu cầu phòng lab:** Môi trường vCenter Server có thể truy cập được.

---

**Mô-đun 2: Kiểm tra Yêu cầu và Khả năng tương thích vSAN**
*   **Thời lượng dự kiến:** 2 giờ (Lý thuyết: 0.5 giờ, Thực hành: 1.5 giờ)
*   **Mục tiêu thực hành:**
    *   Xác định và kiểm tra các yêu cầu phần cứng và phần mềm của vSAN.
    *   Sử dụng VMware Compatibility Guide (VCG) để kiểm tra tính tương thích của phần cứng.
    *   Kiểm tra cấu hình hiện tại của ESXi host và mạng.
*   **Nội dung thực hành:**
    *   **Thực hành 2.1: Kiểm tra HCL/VCG**
        *   Truy cập VMware Compatibility Guide (VCG) trực tuyến.
        *   Tìm kiếm và xác minh tính tương thích của các thành phần giả định (Controller, SSD, HDD) với vSAN phiên bản 8.x.
        *   Ghi lại các phiên bản firmware và driver khuyến nghị.
    *   **Thực hành 2.2: Kiểm tra cấu hình ESXi host**
        *   Đăng nhập vào từng ESXi host trong lab qua SSH hoặc DCUI.
        *   Kiểm tra thông tin phần cứng (CPU, RAM, NICs).
        *   Liệt kê các thiết bị lưu trữ vật lý và loại bus controller bằng lệnh `esxcli storage core device list`.
        *   Xác định các thiết bị flash và disk bằng cách kiểm tra *Is Local SSD* hoặc loại thiết bị.
    *   **Thực hành 2.3: Kiểm tra cấu hình mạng hiện có**
        *   Trong vSphere Client, kiểm tra cấu hình vSwitch/vDS trên các ESXi host.
        *   Xác minh các vmkernels hiện có và dịch vụ liên kết.
        *   Kiểm tra thiết lập Jumbo Frames (nếu có).
*   **Yêu cầu phòng lab:**
    *   Truy cập Internet để kiểm tra VCG.
    *   vCenter Server và các ESXi host đã được thêm vào.
    *   Truy cập SSH đến các ESXi host.

---

**Mô-đun 3: Thiết kế và Định cỡ cụm vSAN (Bài tập tình huống)**
*   **Thời lượng dự kiến:** 2.5 giờ (Lý thuyết: 1 giờ, Thực hành/Bài tập: 1.5 giờ)
*   **Mục tiêu thực hành:**
    *   Áp dụng các cân nhắc thiết kế vSAN được đề xuất.
    *   Thực hiện các hoạt động định cỡ dung lượng dựa trên yêu cầu ứng dụng.
    *   Thiết kế cấu hình máy chủ, mạng và miền lỗi cho một kịch bản cụ thể.
*   **Nội dung thực hành:**
    *   **Thực hành 3.1: Bài tập định cỡ vSAN**
        *   Giáo viên đưa ra một kịch bản kinh doanh (ví dụ: cần chạy 200 máy ảo với tổng dung lượng 10TB, IOPs 10.000, FTT=1).
        *   Sử dụng công cụ vSAN Sizer (hoặc bảng tính tương tự do giáo viên cung cấp/hướng dẫn) để tính toán:
            *   Số lượng ESXi host tối thiểu.
            *   Cấu hình Cache và Capacity Tier (dung lượng, số lượng thiết bị).
            *   Yêu cầu mạng (băng thông, số lượng NIC).
        *   **Thực hành 3.2: Thiết kế mạng vSAN**
            *   Vẽ sơ đồ mạng logic cho cụm vSAN đã định cỡ, bao gồm:
                *   Các vSwitch/vDS.
                *   Các VMkernel adapter cho vSAN, vMotion, Management.
                *   Phân chia port group/VLANs.
            *   Xác định các best practices áp dụng cho thiết kế này (ví dụ: NIC teaming, Jumbo Frames).
*   **Yêu cầu phòng lab:** Không cần trực tiếp cấu hình lab, nhưng yêu cầu truy cập Internet cho vSAN Sizer hoặc công cụ tương tự.

---

**Mô-đun 4: Chuẩn bị Máy chủ và Mạng cho vSAN**
*   **Thời lượng dự kiến:** 3 giờ (Lý thuyết: 0.5 giờ, Thực hành: 2.5 giờ)
*   **Mục tiêu thực hành:**
    *   Cấu hình VMkernel adapter cho lưu lượng vSAN trên các ESXi host.
    *   Xác định và chuẩn bị các thiết bị lưu trữ để sử dụng với vSAN (đánh dấu, bỏ đánh dấu).
    *   Kiểm tra lại các yêu cầu trước khi kích hoạt vSAN.
*   **Nội dung thực hành:**
    *   **Thực hành 4.1: Cấu hình mạng vSAN**
        *   Trên mỗi ESXi host trong cụm lab:
            *   Tạo một vSwitch/vDS Port Group mới (ví dụ: vSAN-Network).
            *   Tạo một VMkernel adapter mới (ví dụ: vmk4) và bật dịch vụ "vSAN traffic".
            *   Gán địa chỉ IP tĩnh cho VMkernel adapter này trong một subnet dành riêng cho vSAN.
            *   Đảm bảo khả năng kết nối giữa các VMkernel vSAN của các host bằng lệnh `vmkping`.
            *   Cấu hình Multi-NIC Teaming (nếu có nhiều NIC cho vSAN).
    *   **Thực hành 4.2: Chuẩn bị lưu trữ cho vSAN**
        *   Sử dụng vSphere Client hoặc ESXCLI:
            *   Xác định các thiết bị lưu trữ (SSD/HDD) sẽ dùng cho Cache và Capacity Tier trên từng ESXi host.
            *   Đảm bảo các thiết bị không có dữ liệu quan trọng hoặc đã được xóa sạch.
            *   **Tùy chọn nâng cao (nếu thời gian cho phép):** Sử dụng `esxcli storage core device set` để đánh dấu/bỏ đánh dấu thiết bị flash nếu cần thiết (mặc định vSAN tự động nhận diện).
            *   Kiểm tra chế độ của bộ điều khiển lưu trữ (Pass-through/RAID 0) bằng `esxcli storage core adapter list` và `esxcli storage core controller list`.
*   **Yêu cầu phòng lab:**
    *   vCenter Server và các ESXi host đã được thêm vào.
    *   Các ESXi host có các thiết bị lưu trữ chưa được sử dụng.
    *   Các dải IP đã chuẩn bị cho vSAN VMkernel.

---

#### **NGÀY 2: Triển khai và Quản lý cụm vSAN cơ bản**

**Mục tiêu ngày 2:** Triển khai thành công một cụm vSAN một trang web, cấu hình chính sách lưu trữ, và thực hiện các thao tác quản lý và bảo trì cơ bản.

---

**Mô-đun 5: Triển khai cụm vSAN một trang web**
*   **Thời lượng dự kiến:** 3.5 giờ (Lý thuyết: 0.5 giờ, Thực hành: 3 giờ)
*   **Mục tiêu thực hành:**
    *   Kích hoạt vSAN trên một cụm mới hoặc hiện có bằng Quickstart Wizard.
    *   Kích hoạt vSAN thủ công và tạo Disk Group.
    *   Xác minh trạng thái và dung lượng của kho dữ liệu vSAN.
*   **Nội dung thực hành:**
    *   **Thực hành 5.1: Triển khai vSAN bằng Quickstart Wizard**
        *   Tạo một cụm mới trong vCenter Server.
        *   Sử dụng tính năng "Quickstart" để:
            *   Thêm các ESXi host vào cụm (nếu chưa có).
            *   Cấu hình Network Settings cho vSAN (và vMotion nếu cần).
            *   Cấu hình Disk Claiming (tự động hoặc thủ công).
            *   Kích hoạt vSAN.
    *   **Thực hành 5.2: Kích hoạt vSAN thủ công và tạo Disk Group**
        *   (Nếu không dùng Quickstart hoặc để thực hành phương pháp khác)
        *   Trên một cụm đã có host, vào **Configure > vSAN > Services**.
        *   Bật vSAN Service.
        *   Trong phần **Disk Management**, tạo Disk Groups thủ công cho từng ESXi host:
            *   Chọn 1 thiết bị flash làm Cache Tier.
            *   Chọn các thiết bị còn lại làm Capacity Tier.
        *   Xác minh kho dữ liệu vSAN xuất hiện và dung lượng tổng thể.
    *   **Thực hành 5.3: Cấu hình và Quản lý giấy phép vSAN**
        *   Áp dụng giấy phép vSAN cho cụm.
        *   Xem các tính năng đã đăng ký.
*   **Yêu cầu phòng lab:** Cụm ESXi hosts đã được thêm vào vCenter, mạng vSAN đã cấu hình (từ Mô-đun 4), các thiết bị lưu trữ sẵn sàng.

---

**Mô-đun 6: Chính sách lưu trữ vSAN (Storage Policies)**
*   **Thời lượng dự kiến:** 2.5 giờ (Lý thuyết: 0.5 giờ, Thực hành: 2 giờ)
*   **Mục tiêu thực hành:**
    *   Hiểu các thành phần (object, component) và ảnh hưởng của chúng đến chính sách.
    *   Tạo và áp dụng các chính sách lưu trữ vSAN tùy chỉnh.
    *   Triển khai VM trên kho dữ liệu vSAN và gán chính sách.
    *   Thay đổi chính sách lưu trữ cho một VM đang chạy.
*   **Nội dung thực hành:**
    *   **Thực hành 6.1: Khám phá Object và Component**
        *   Sử dụng RVC hoặc vSphere Client để xem các vSAN object và component (ví dụ: `vsan.vm_objects_uuid_list`, `vsan.vm_object_info`).
        *   Giải thích mối quan hệ giữa số lượng host, FTT, FTM và số lượng component.
    *   **Thực hành 6.2: Tạo chính sách lưu trữ vSAN**
        *   Tạo các chính sách lưu trữ VM mới trong vSphere Client với các cấu hình khác nhau:
            *   FTT=1, FTM=RAID-1 (Mirroring)
            *   FTT=1, FTM=RAID-5/6 (Erasure Coding - nếu có đủ host, tối thiểu 4 host cho RAID-5)
            *   Cấu hình thêm các thuộc tính như Caching (Flash Read Cache Reservation), QoS (IOPS limit), Deduplication & Compression (nếu bật trên cụm).
    *   **Thực hành 6.3: Triển khai và Quản lý VM với chính sách vSAN**
        *   Tạo một máy ảo mới trên kho dữ liệu vSAN.
        *   Áp dụng chính sách lưu trữ mặc định, sau đó thay đổi sang chính sách tùy chỉnh đã tạo.
        *   Giám sát quá trình tuân thủ chính sách (compliance) và quá trình tái cấu hình (re-sync) của VM.
        *   Kiểm tra tình trạng tuân thủ của VM trong vSphere Client.
*   **Yêu cầu phòng lab:** Cụm vSAN đã được triển khai và hoạt động.

---

**Mô-đun 7: Vận hành, Bảo trì và Giám sát vSAN**
*   **Thời lượng dự kiến:** 2 giờ (Lý thuyết: 0.5 giờ, Thực hành: 1.5 giờ)
*   **Mục tiêu thực hành:**
    *   Sử dụng chế độ bảo trì ESXi và hiểu tác động của nó đến vSAN.
    *   Giám sát trạng thái vSAN Health và giải thích các cảnh báo.
    *   Hiểu các tùy chọn mã hóa vSAN.
*   **Nội dung thực hành:**
    *   **Thực hành 7.1: Sử dụng Chế độ bảo trì ESXi**
        *   Đặt một ESXi host vào chế độ bảo trì với các tùy chọn khác nhau (Full data migration, Ensure accessibility, No data migration).
        *   Quan sát tác động đến các component của VM trên host đó.
        *   Di chuyển VM ra khỏi host.
        *   Thoát chế độ bảo trì.
        *   **Tình huống:** Kéo ngắt kết nối mạng của một host trong chế độ bảo trì để mô phỏng lỗi và quan sát hành vi của vSAN.
    *   **Thực hành 7.2: Giám sát vSAN Health**
        *   Truy cập phần **vSAN Health** trong vSphere Client.
        *   Chạy các kiểm tra sức khỏe và giải thích các kết quả (nếu có cảnh báo, tìm hiểu nguyên nhân).
        *   **Tình huống:** Ngắt kết nối một đĩa Capacity Tier của một host và quan sát cảnh báo Health.
    *   **Thực hành 7.3: Thảo luận về Mã hóa vSAN**
        *   (Thực hành cấu hình mã hóa yêu cầu KMS và thời gian, nên tập trung vào thảo luận và demo giao diện nếu có).
        *   Giới thiệu giao diện cấu hình mã hóa vSAN trong vSphere Client.
        *   Thảo luận các yêu cầu (KMS) và lợi ích của mã hóa vSAN.
*   **Yêu cầu phòng lab:** Cụm vSAN đã được triển khai, có ít nhất một VM đang chạy.

---

#### **NGÀY 3: vSAN Nâng cao và Các kịch bản đặc biệt**

**Mục tiêu ngày 3:** Triển khai các cấu hình vSAN nâng cao như Stretched Clusters và Two-Node Clusters, cấu hình vSAN iSCSI Target, và củng cố kiến thức tổng thể.

---

**Mô-đun 8: Triển khai cụm vSAN Stretched Cluster**
*   **Thời lượng dự kiến:** 4 giờ (Lý thuyết: 1 giờ, Thực hành: 3 giờ)
*   **Mục tiêu thực hành:**
    *   Hiểu kiến trúc và các cân nhắc thiết kế cho Stretched Cluster.
    *   Triển khai và cấu hình một vSAN Stretched Cluster (thủ công hoặc Quickstart).
    *   Triển khai và cấu hình thiết bị vSAN Witness Appliance.
    *   Kiểm tra khả năng chịu lỗi và chuyển đổi dự phòng của Stretched Cluster.
*   **Nội dung thực hành:**
    *   **Thực hành 8.1: Chuẩn bị môi trường cho Stretched Cluster**
        *   Đảm bảo có đủ 5 ESXi hosts (2 site chính, 1 Witness).
        *   Cấu hình mạng cho 3 site riêng biệt (ví dụ: Site A, Site B, Witness Site), bao gồm network vSAN giữa các site (IP riêng biệt, latency/bandwidth giả định).
        *   Triển khai vSAN Witness Appliance (dưới dạng VM) và cấu hình mạng quản lý.
        *   Cấu hình VMkernel Adapter cho Witness Traffic trên Witness Appliance.
    *   **Thực hành 8.2: Triển khai Stretched Cluster**
        *   Sử dụng tính năng "Configure Stretched Cluster" trong vSphere Client:
            *   Gán các host cho Site A và Site B.
            *   Gán Witness Appliance.
            *   Cấu hình Preferred Fault Domain.
            *   Kích hoạt vSAN.
    *   **Thực hành 8.3: Kiểm tra và Quản lý Stretched Cluster**
        *   Di chuyển một VM giữa các site bằng vMotion.
        *   Giả lập lỗi tại một site (ví dụ: tắt 1 host ở site không ưu tiên) và quan sát khả năng chuyển đổi dự phòng của VM.
        *   Thay đổi Preferred Fault Domain.
        *   Thay đổi Witness Host (nếu có host Witness khác).
*   **Yêu cầu phòng lab:**
    *   Tối thiểu 5 ESXi hosts (có thể là ESXi VM lồng nhau).
    *   Witness Appliance VM đã được triển khai.
    *   Cấu hình mạng phù hợp cho 3 site (mạng vSAN, mạng quản lý, mạng witness).

---

**Mô-đun 9: Triển khai cụm vSAN Two-Node và vSAN iSCSI Target**
*   **Thời lượng dự kiến:** 3 giờ (Lý thuyết: 1 giờ, Thực hành: 2 giờ)
*   **Mục tiêu thực hành:**
    *   Hiểu kiến trúc và trường hợp sử dụng cho cụm Two-Node vSAN.
    *   Triển khai một cụm Two-Node vSAN với Witness Appliance dùng chung.
    *   Cấu hình vSAN iSCSI Target và kết nối từ một máy chủ client.
*   **Nội dung thực hành:**
    *   **Thực hành 9.1: Triển khai cụm Two-Node vSAN**
        *   (Sử dụng cụm vSAN mới hoặc chuyển đổi cụm hiện có thành 2 hosts và thêm Witness).
        *   Tạo một cụm vSAN chỉ với 2 ESXi hosts.
        *   Sử dụng Witness Appliance đã có (hoặc triển khai mới) và gán nó làm Witness cho cụm Two-Node.
        *   Cấu hình vSAN.
        *   **Tình huống:** Mô phỏng mất kết nối của một host và quan sát hành vi của VM.
    *   **Thực hành 9.2: Cấu hình vSAN iSCSI Target**
        *   Bật dịch vụ vSAN iSCSI Target Service trên cụm vSAN.
        *   Tạo một vSAN iSCSI Target.
        *   Tạo LUN (Logical Unit Number) và gán cho iSCSI Target.
        *   Từ một máy ảo Client (ví dụ: Windows Server), cấu hình iSCSI Initiator để kết nối đến vSAN iSCSI Target.
        *   Định dạng LUN và sử dụng nó làm ổ đĩa.
*   **Yêu cầu phòng lab:**
    *   Cụm vSAN với 2 ESXi hosts.
    *   Một Witness Appliance (có thể dùng chung với Stretched Cluster nếu lab đủ mạnh).
    *   Một máy ảo Client (Windows/Linux) trong mạng có thể truy cập vSAN iSCSI Target.

---

**Mô-đun 10: Tổng kết khóa học và Hỏi đáp**
*   **Thời lượng dự kiến:** 1 giờ
*   **Mục tiêu thực hành:**
    *   Củng cố các kiến thức và kỹ năng đã học.
    *   Giải đáp các câu hỏi còn lại.
    *   Xem xét các tài nguyên học tập bổ sung.
*   **Nội dung thực hành:**
    *   **Thảo luận nhóm:** Các thách thức trong quá trình triển khai, các tình huống thực tế thường gặp.
    *   **Tổng kết:** Ôn lại các mục tiêu đạt được và các tính năng chính của vSAN.
    *   **Hỏi & Đáp:** Giải đáp mọi thắc mắc của học viên.
    *   **Tài liệu tham khảo:** Giới thiệu các tài liệu, trang web, blog hữu ích cho vSAN.

---

**Lưu ý quan trọng:**

*   **Tính linh hoạt:** Thời lượng dự kiến có thể điều chỉnh tùy thuộc vào tốc độ và kinh nghiệm của học viên.
*   **Phòng Lab Ảo hóa:** Việc sử dụng ESXi lồng nhau (nested ESXi) là phổ biến trong môi trường đào tạo để tiết kiệm tài nguyên vật lý, nhưng cần đảm bảo hiệu suất đủ tốt.
*   **Bài tập tình huống:** Nên kết hợp các bài tập lý thuyết/thiết kế với các mô-đun thực hành để học viên có cái nhìn toàn diện từ lập kế hoạch đến triển khai.
*   **Hướng dẫn từng bước:** Mỗi mô-đun thực hành cần có tài liệu hướng dẫn từng bước chi tiết (Lab Guide) cho học viên.
*   **Troubleshooting:** Giáo viên nên chuẩn bị các tình huống troubleshooting nhỏ để học viên tự giải quyết, nâng cao kỹ năng xử lý sự cố.

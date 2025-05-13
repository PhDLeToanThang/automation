### **Phân tích chỉ số Reserved Failover CPU & Memory Capacity và Performance Degradation VMs Tolerate**  

Trong **vSphere HA Admission Control**, **Reserved failover CPU capacity** và **Reserved failover Memory capacity** giúp dự phòng tài nguyên để đảm bảo VM có thể **di chuyển sang ESXi Host còn lại** khi xảy ra lỗi. **Performance degradation VMs tolerate** (mức VM chịu suy giảm hiệu suất) xác định ngưỡng tài nguyên tối thiểu có thể chấp nhận được khi xảy ra sự cố.  

Công thức tính mức dự phòng phù hợp:  

 $\text{Failover Capacity} = \frac{\text{Số host dự phòng}}{\text{Tổng số host}} \times 100\%$

---

### **1. Cluster có 2 ESXi Host**
- Nếu **1 host bị lỗi**, toàn bộ VM phải chuyển sang **host còn lại**, nhưng tài nguyên bị **quá tải**, không đảm bảo tính ổn định.
- **Khả năng dự phòng tối thiểu cần thiết**: **50% CPU & RAM**
- **Performance degradation VMs tolerate**: **0%** (Không có khả năng chịu lỗi nếu 1 host bị lỗi).

---

### **2. Cluster có 3 ESXi Host**
- Nếu **1 host bị lỗi**, 2 host còn lại phải gánh VM từ host bị lỗi.
- **Dự phòng CPU & RAM**:  
  
  $\frac{1}{3}\times 100\% = 33.3\%$ -> 1/3 = 33.3%

- **Khuyến nghị**: **30-35% CPU & RAM**
- **Performance degradation VMs tolerate**: **~85%**, vì tài nguyên còn lại sẽ giảm đáng kể khi 1 host bị lỗi.

---

### **3. Cluster có 4 ESXi Host**
- Nếu **1 host bị lỗi**, còn lại **3 host** nên vẫn đảm bảo failover tốt.
- **Dự phòng CPU & RAM**:  
  
  $\frac{1}{4}\times 100\% = 25\%$ -> 1/4 = 25%
  
- **Khuyến nghị**: **25-30% CPU & RAM**
- **Performance degradation VMs tolerate**: **~93%** (chỉ suy giảm nhẹ hiệu suất).

---

### **4. Cluster có 24 ESXi Host**
- Nếu **1 host bị lỗi**, còn lại **23 host**, mức ảnh hưởng là **rất nhỏ**.
- **Dự phòng CPU & RAM**:  
  
  $\frac{1}{24}\times 100\% = 4.2\%$ -> 1/24 = 4.2%
  
- **Khuyến nghị**: **5-10% CPU & RAM**
- **Performance degradation VMs tolerate**: **~98%**, gần như không ảnh hưởng.

---

### **5. Cluster có 64 ESXi Host**
- Nếu **1 host bị lỗi**, còn lại **63 host**, mức ảnh hưởng cực nhỏ.
- **Dự phòng CPU & RAM**:  
  
  $\frac{1}{64}\times 100\% = 1.5\%$ -> 1/64 = 1.5%
  
- **Khuyến nghị**: **1-5% CPU & RAM**
- **Performance degradation VMs tolerate**: **~99.5%**, gần như không suy giảm hiệu suất.

---

### **Tóm tắt bảng phân tích**
| **Số ESXi Host** | **Failover Capacity khuyến nghị** | **Performance degradation VMs tolerate** | **Các mô hình Cluster Failover** |
|-----------------|---------------------------|----------------------------------|-----------------------------------|
| **2 Hosts**  | **50% CPU & RAM** | **0%** (không chịu lỗi nếu mất 1 host) | ORACLE RAC / MS-SQL Cluster Node / AD-DC Dedicate ... |
| **3 Hosts**  | **30-35% CPU & RAM** | **~85%** | vSphere DRS,SDRS,HA/Mô hình Active - Passive - Witness: vCenter HA ... | 
| **4 Hosts**  | **25-30% CPU & RAM** | **~93%** | VCF Management Domain / vSAN Witness / Nutanix HCI ... |
| **24 Hosts** | **5-10% CPU & RAM** | **~98%** | vSAN Enterprise Plus Domain ... |
| **64 Hosts** | **1-5% CPU & RAM** | **~99.5%** | Full Hosts a vSphere DRS Cluster |

---

### **Kết luận**
- **Cụm nhỏ (2-4 host)** cần **dự phòng tài nguyên cao hơn** để đảm bảo failover ổn định.
- **Cụm lớn (24-64 host)** có thể giảm mức **dự phòng** mà vẫn đảm bảo **hiệu suất cao**.
- **Performance degradation VMs tolerate** giúp đảm bảo rằng khi một host gặp lỗi, VM vẫn hoạt động ổn định mà **không bị suy giảm quá mức**.

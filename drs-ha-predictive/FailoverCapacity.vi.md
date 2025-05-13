>> Phân tích chỉ số Reserved failover CPU capacity = 25 - 30%, Reserved failover Memory capacity = 25 - 30%, nếu thực tế chỉ có 2 ESXi Host Cluster DRS thì chỉ số trên là bao nhiêu? thực tế có 3 ESXi Host?, 4 ESXi Host?, 24 ESXi Host? và 64 ESXi Host?

**Phân tích chỉ số Reserved Failover CPU & Memory Capacity theo số lượng ESXi Host**  

Trong **vSphere HA Admission Control**, chỉ số **Reserved Failover CPU Capacity** và **Reserved Failover Memory Capacity** giúp dự phòng tài nguyên để đảm bảo VM có thể **di chuyển sang các ESXi Host còn lại** khi xảy ra lỗi.  

Công thức chung để tính **% tài nguyên dự phòng**:  
\[
\text{Failover Capacity} = \frac{\text{Số lượng host bị lỗi dự phòng}}{\text{Tổng số host trong cluster}} \times 100\%
\]
Mức khuyến nghị thường là **25 - 30%**, nhưng cần điều chỉnh theo số lượng **ESXi Host** thực tế.

---

### **1. Cluster có 2 ESXi Host**  
- Nếu **1 host bị lỗi**, còn lại **1 host duy nhất**, điều này **không đảm bảo failover hiệu quả**.  
- Cần dự phòng **50% CPU & RAM** để đảm bảo VM có thể chạy trên host còn lại.  
- **Khuyến nghị:** **50% CPU & RAM**  

### **2. Cluster có 3 ESXi Host**  
- Nếu **1 host bị lỗi**, còn lại **2 host**, vẫn đảm bảo failover ổn định.  
- **Dự phòng hợp lý:**  
  \[
  \frac{1}{3} \times 100\% = 33.3\%
  \]
- **Khuyến nghị:** **30-35% CPU & RAM**  

### **3. Cluster có 4 ESXi Host**  
- Nếu **1 host bị lỗi**, còn lại **3 host**, hiệu suất vẫn ổn định.  
- **Dự phòng hợp lý:**  
  \[
  \frac{1}{4} \times 100\% = 25\%
  \]
- **Khuyến nghị:** **25-30% CPU & RAM**  

### **4. Cluster có 24 ESXi Host**  
- Nếu **1 host bị lỗi**, còn lại **23 host**, tác động rất thấp.  
- **Dự phòng hợp lý:**  
  \[
  \frac{1}{24} \times 100\% = 4.2\%
  \]
- **Khuyến nghị:** **5-10% CPU & RAM**  

### **5. Cluster có 64 ESXi Host**  
- Nếu **1 host bị lỗi**, còn lại **63 host**, mức ảnh hưởng gần như không đáng kể.  
- **Dự phòng hợp lý:**  
  \[
  \frac{1}{64} \times 100\% = 1.5\%
  \]
- **Khuyến nghị:** **1-5% CPU & RAM**  

---

### **Tóm tắt bảng phân tích**
| **Số ESXi Host** | **Failover Capacity khuyến nghị** | **Các mô hình Cluster Failover ** |
|------------------|-----------------------------------|
| **2 Hosts**      | **50% CPU & RAM**                 | ORACLE RAC / MS-SQL Cluster Node / AD-DC Dedicate ... |
| **3 Hosts**      | **30-35% CPU & RAM**              | vSphere DRS,SDRS,HA/Mô hình Active - Passive - Witness: vCenter HA ... | 
| **4 Hosts**      | **25-30% CPU & RAM**              | VCF Management Domain / vSAN Witness / Nutanix HCI ... |
| **24 Hosts**     | **5-10% CPU & RAM**               | vSAN Enterprise Plus Domain ... |
| **64 Hosts**     | **1-5% CPU & RAM**                | Full Hosts a vSphere DRS Cluster |

---

### **Kết luận**  
- Với **cụm nhỏ (2-4 host)** → cần dự phòng nhiều tài nguyên hơn (**25-50%**).  
- Với **cụm lớn (24-64 host)** → chỉ cần dự phòng **1-10%** vì mức ảnh hưởng từ 1 host bị lỗi là rất nhỏ.  
- **Cấu hình hợp lý giúp tối ưu hiệu suất** mà vẫn đảm bảo **khả năng failover của vSphere HA**.  
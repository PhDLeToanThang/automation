## Thông tin cơ bản về quản lý khối
* **Logical Volume Manger (LVM)** là phương pháp cho phép ấn định không gian đĩa cứng thành những **Logiccal Volume** khiến cho việc thay đổi kích thước trở nên dễ dàng hơn so với **partition**.
* Với ký thuật **LVM**, có thể thay đổi kích thước phân vùng mà không cần phải sửa lại table của OS. Điều này rất hữu ích với trường hợp đã sử dụng hết bộ nhớ trống của partition và muốn mở rộng dung lượng của nó.
* Vai trò của **LVM**: **LVM** là kỹ thuật quản lý việc thay đổi kích thước lưu trữ của ổ cứng:
    * Không để hệ thống bị gián đoạn hoạt động
    * Không làm hỏng dịch vụ
    * Có thể kết hợp cơ chế **hot Swapping**(Phương pháp thay thế nóng các thành phần bên trong máy tính)
* Mục đích:
    * Tạo 1 hoặc nhiều phân vùng logic hoặc phân vùng với toàn bộ đĩa cứng, Cho phép thay đổi kích thước khối
    * Quản lý trang đĩa cứng lớn( Large hard disk Farms ) bằng cách cho phép thêm và thay thế đĩa mà không bị ngừng hoạt động hoặc gián đoạn dịch vụ, kết hợp với trao đổi nóng(hot swap)
    * Trên hệ thống nhỏ (như laptop,pc), thay vì phải ước tính thời gian cài đặt, phân vùng có thể cần lớn đến mức nào, LVM cho phép hệ thống tệp dễ dàng thay đổi kích thước khi cần .
    * Thực hiện sao lưu nhất quán bằng cách tạo ra snapshot nhanh các khối cách hợp lý.
    * Mã hóa nhiều phân vùng vật lý bằng một mật khẩu
<a name="volbasic"></a>
## Các khối cơ bản của **LVM**(Logical Vulome Manager ) bao gồm:
* Physical Volumes: là những đĩa cứng vật lý hoặc phân vùng trên nó
* Volume groups: là một nhóm bao gồm các *Physical Volumes*.Có thể xem Volume group như một " ổ đĩa ảo".
* Logical volumes: có thể xem như là các "phân vùng ảo" bạn có thể thêm vào gỡ bỏ và thay đổi kích thước một cách nhanh chóng.*(/dev/sda1, /dev/sdb1, /dev/sdc1)*
<a name="thanhphan"></a>
## Các thành phần trong LVM
![Imgur](img/AyGOfPF.png)
### 1. Physical Drives - Hard drives
* Là các thiết bị lưu trữ dữ liệu có dạng: `/dev/sda`,`/dev/sdc2`,...
### 2. Partition 
* Là các phân vùng của **Hard Drives**, mỗi **Hard** có 4 **Partition** trong đó **Partition** gồm 2 loại là **primary partition** và **extended partition** :
* **Primary Partition** :
    * Là phân vùng chính, có thể `Boot`
    * Mỗi đĩa cứng có thể có tối đa 4 phân vùng này
* **Extended Partition** :
    * Là phân vùng mổ rộng chứa dữ liệu, trong nó có thể tạo các **logical partition** 
### 3. Physical Volume (PV)
* Là 1 tên gọi khác của **partition** trong kỹ thuật **LVM**, nó là những thành phần cơ bản được sử dụng bởi **LVM** 
* Một **Physical Volume** không thể mở rộng ra ngoài phạm vi 1 ổ đĩa
* có thể kết hợp nhiều **physical Volume** thành một **Volume Group**.
### 4. Volume group (VG)
![Imgur](img/HqF0FqA.png)
* Nhiều **Physical Volume** trên những ở đĩa khác nhau kết hợp lại thành 1 **Volume Group**
* **Volume Group** được dùng để tạo ra các **Logical Volume**, trong đó người dùng có thể tạo, thay đổi kích thước, Gỡ bỏ và sử dụng chúng
### 5. Logical Volume 
![Imgur](img/iyxo9Ri.png)
* **Volume Group** được chia nhỏ thành các **Logical Volume**,Mỗi **Logical Volume** có ý nghĩa tương tự 1 Partition. Nó được dùng cho các mount point và được format với những định dạng khác nhau như `ext2`, `ext3`, `ext4`, `xfs`, ...
* Khi dung lượng của **Physical Volume** được sử dụng hết ta có thể thêm ổ đĩa mới bổ sung cho **Volume Group** và do đó tăng được dung lượng của **Logical Volume**
### 6. File Systems (FS)

* Tổ chức và kiểm soát các tập tin
* Được lưu trữ trên ổ đĩa cho phép truy cập nhanh chóng và an toàn
* Sắp xếp dữ liệu trên đĩa cứng máy tính
* Quản lý vị trí vật lý của mọi thành phần dữ liệu

Mô tả thành mindmap:</br>![Imgur](img/YHlFEPp.png)
VD: 
* Có 4 ổ đĩa mỗi ổ `5GB` : được gọi là Hard drives
* Kết hợp thành 1 **Volume Group** `20GB`
* Sau đó có thể tạo ra 2 **Logical Volume** mỗi cái `10GB`
<a name="uunhuoc"></a>
## Ưu nhược điểm của LVM
### Ưu điểm
* Có thể gom nhiều đĩa cứng vật lý thành 1 đỉa ảo dung lượng lớn
* Có thể tạo ra các vùng dung lượng lớn tùy ý 
* Có thể thay đổi các vùng dung lượng đó dễ dàng, linh hoạt
### Nhược điểm
* Các bước thiết lập phức tạp, khó khăn hơn
* Càng gắn nhiều đĩa cứng và thiết lập càng nhiều **LVM** thì hệ thống thì hệ thống khởi động càng lâu
* Khả năng mất dữ liệu khi 1 trong các đĩa cứng vật lý bị hỏng
* Tiêu hao nhiều năng lượng không cần thiết
<a name="command"></a>
## Các lệnh trong LVM
* **Physical Volume**:
    * `pvcreate`:tạo **Physical Volume**
    * `pvdisplay`, `pvs`: xem **Physical Volume** đã tạo
    * `pvremove`: xóa **Phyysical Volume**
    * `pvchange`: Thay đổi thuộc tính của Physical volume
* **Volume Group**:
    * `vgcreate`: Tạo **Volume Group**
    * `vsdisplay`,`vgs`: xem **Volume Group** đã tạo
    * `vgremove` : xóa **Volume Group**
    * `vgextend` : tăng dung lượng của **Volume Group**
    * `vgreduce`: giảm dung lượng của **Volume Group**
* **Logical Volume**:
    * `lvcreate`: Tạo **Logical Volume**
    * `lvdisplay`, `lvs`: xem **Logical Volume** đã tạo
    * `lvremove`: xóa **Logical Volume**
    * `lvextend`: tăng dung lượng **Logical Volume**
    * `lvreduce`: giảm dung lượng **Logical Volume**

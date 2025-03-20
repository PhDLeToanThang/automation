# CEPH là gì?
* Là một nền tảng lưu trữ mã nguồn mở do software-defined
* triển khai  object storage trên một cụm máy tính phân tán duy nhất và cung cấp giao diện 3 trong 1 cho lưu trữ  **object-Storage**, **block-Storage** và **file**
    
Ceph là tương lai của lưu trữ; khi các hệ thống truyền thống không thể phân phối, Ceph được thiết kế để vượt trội. Tận dụng dữ liệu của bạn để đưa ra các quyết định kinh doanh tốt hơn và đạt được sự xuất sắc trong hoạt động thông qua phần mềm lưu trữ có thể mở rộng, thông minh, đáng tin cậy và có tính khả dụng cao. Ceph hỗ trợ Object Storage, khối và tệp, tất cả trong một hệ thống lưu trữ thống nhất.

Với khả năng thích ứng của Ceph, cụm của bạn sẽ sẵn sàng hỗ trợ tất cả các nhu cầu về ứng dụng và lưu trữ dữ liệu của bạn, cả hiện tại và trong tương lai, cho dù giải pháp của bạn là tại chỗ, trong đám mây công cộng hoặc riêng tư, hoặc vùng chứa gốc.
## Lợi ích của CEPH
* **Ceph mang lại hiệu suất**, độ tin cậy và tính linh hoạt hàng đầu trong ngành.
* **Ceph reliable** có thể sao lưu dữ liệu đáng tin cậy, lưu trữ linh hoạt và khả năng mở rộng nhanh chóng. Với Ceph, tổ chức của bạn có thể thúc đẩy việc ra quyết định dựa trên dữ liệu, giảm thiểu chi phí lưu trữ và xây dựng các cụm bền bỉ, linh hoạt.
* **Ceph scalable**Ceph làm việc với dữ liệu trên quy mô lớn trở thành một lựa chọn khả thi cho bất kỳ tổ chức nào, ở bất kỳ quy mô nào, trong bất kỳ ngành nào.

### Hiệu năng
* Ceph được thiết kế để duy trì hiệu suất cao, độ trễ thấp và không có thời gian chết. 
* Ceph chạy trên bất kỳ phần cứng nào, cho phép bạn toàn quyền kiểm soát các khả năng và dung lượng của cụm của bạn.

* **Thuật toán CRUSH** của Ceph cho phép dễ dàng tính toán vị trí của dữ liệu trong một cụm bởi bất kỳ máy khách nào thực hiện yêu cầu đọc/ghi, loại bỏ nhu cầu về central metadata server và tránh tắc nghẽn hiệu suất mà cách tiếp cận sẽ tạo ra.
    * **CRUSH (Controlled Replication Under Scalable Hashing)**: là một thuật toán dựa trên hash để tính toán cách thức và vị trí lưu trữ và truy xuất dữ liệu trong một cụm lưu trữ dựa trên đối tượng phân tán.
* **CRUSH MAP** có thể cấu hình cao, Ceph có thể phân phối dữ liệu đồng đều trong toàn một cụm, loại bỏ các vấn đề về hiệu suất nếu không sẽ xảy ra khi một số lượng nhỏ thiết bị lưu trữ kết thúc phục vụ tỷ lệ yêu cầu đọc/ghi không cân bằng.
* Thực hiện bảo trì cụm theo kế hoạch mà không bị gián đoạn dịch vụ, cho dù bạn cần hoán đổi ổ lưu trữ, thực hiện sửa chữa phần cứng hay tiến hành di chuyển dữ liệu quy mô lớn.
### Khả năng mở rộng

* Ceph thiết kế để phát triển theo cấp số nhân với dữ liệu, mở rộng liên tục cho các nhu cầu lưu trữ dữ liệu trong tương lai.

* Thêm hoặc xóa bộ nhớ vào cụm của bạn khi bạn cần và Ceph sẽ tự động và thông minh điều chỉnh việc phân phối dữ liệu của bạn, cho phép mở rộng quy mô hiệu quả theo yêu cầu mà không bị giới hạn bởi các hệ thống lưu trữ truyền thống.
* Ceph là mã nguồn mở, vì vậy bạn không bao giờ cần phải lo lắng về vấn đề cấp phép làm chậm khả năng mở rộng quy mô theo yêu cầu của bạn.
* Có thể mở rộng trên mọi thiết bị mà cách mà bạn muốn.
### Độ tin cậy & Quản lý
Dữ liệu phải được bảo vệ và luôn có sẵn, vì vậy Ceph tự động quản lý và điều chỉnh các cụm lưu trữ để giữ cho dữ liệu của bạn an toàn. Từ reduplication  và CRUSH maps, đến các daemon chuyên biệt, có sẵn các dự phòng để bảo vệ dữ liệu quý giá của bạn.
* Nếu hoạt động của bạn yêu cầu dữ liệu sẵn có cao, Ceph sẽ phân phối, cho phép sao chép dữ liệu trên các thiết bị, reack và thậm chí cả vị trí địa lý. Xây dựng một nhóm có thể tiếp tục hỗ trợ các hoạt động kinh doanh quan trọng của bạn ngay cả trong thời gian ngừng hoạt động ngoài kế hoạch, với Ceph.
* Khả năng '**tự phục hồi**' của Ceph cho phép nó nhanh chóng phản ứng với các lỗi phần cứng, nguồn hoặc kết nối. Ceph sẽ chủ động phân phối lại dữ liệu xung quanh cụm của bạn ngay khi có vấn đề phát sinh, bảo vệ chống mất dữ liệu trước khi bạn nhận thấy có vấn đề.
* Có thể định cấu hình đầy đủ, thường xuyên loại bỏ các thành phần nguy hiểm theo lịch trình giúp dữ liệu của bạn an toàn không bị hư hỏng. Bằng cách so sánh các bản sao của dữ liệu được sao chép, Ceph đảm bảo dữ liệu của bạn vẫn còn nguyên vẹn.

### Sự đổi mới
Là một nền tảng mã nguồn mở, Ceph thúc đẩy sự đổi mới toàn cầu thông qua sự hợp tác của những người giỏi nhất trong ngành, đón đầu nhu cầu dữ liệu và liên tục tìm kiếm những tiến bộ mới.
* Cho phép quản trị viên xác định một tập hợp các quy tắc rõ ràng về cách dữ liệu được phân phối khắp các cụm của họ, Ceph giảm tắc nghẽn và cung cấp độ tin cậy theo tiêu chuẩn hàng đầu trong ngành.
* Ceph là một dự án sống động, liên tục được kiểm tra, bảo trì và cập nhật bởi nhiều người tài năng nhất trong cộng đồng mã nguồn mở. Nhanh chóng phản ứng với sự thay đổi và luôn phát triển, Ceph duy trì vị trí của mình như một phương pháp tiên tiến đối với lưu trữ do phần mềm xác định.
* Nhận tất cả các lợi ích của lưu trữ object, file và block, được thống nhất thông qua RADOS, câu trả lời duy nhất của Ceph để quản lý các loại lưu trữ khác nhau trên quy mô lớn.
## Architectural 
Bất kỳ framework phân phối nào bạn yêu cầu, Ceph đều có thể được điều chỉnh và áp dụng cho phù hợp. Ceph cung cấp giải pháp lưu trữ dữ liệu linh hoạt, có thể mở rộng, đáng tin cậy và được phân phối thông minh, được xây dựng trên nền tảng thống nhất của RADOS (Cửa hàng đối tượng phân tán tự động đáng tin cậy). Bằng cách thao tác tất cả lưu trữ dưới dạng các đối tượng trong RADOS, Ceph có thể dễ dàng phân phối dữ liệu trong toàn bộ một cụm, ngay cả đối với các loại lưu trữ khối và tệp.

* **RADOS (Reliable Autonomic Distributed Object Store)**
* **RADOS Block Device (RBD)**
## Version 
* `x.0.z` - development versions
* `x.1.z` - release candidates (for test clusters, brave users)
* `x.2.z` - stable (bản phát hành ổn định) / sửa lỗi (dành cho người dùng)
* Ver:
    * `Old version`: <14.2.0 - End of life: 2021-06-01
    * `Đang duy trì`: 
        * `Octopus - 15.2.0`, Phát hành 20/03/2020 - 01/06/2023
        * `Pacific - 16.2.0`, Phát hành 31/03/2021 - 01/06/2023
    * `Phiên bản mới nhất`
        * `Quincy - 17.2.0`, Phát hành 19/04/2022 - 01/06/2024
### Object storage
Dịch vụ Object Storage Ceph RGW cung cấp khả năng tương thích API S3 hàng đầu trong ngành với một bộ tính năng bảo mật, phân cấp và khả năng tương tác mạnh mẽ. Các ứng dụng sử dụng Object Storage `S3` hoặc `Swift` có thể tận dụng khả năng mở rộng và hiệu suất của Ceph trong một trung tâm dữ liệu duy nhất hoặc liên kết nhiều cụm Ceph trên toàn cầu để tạo không gian tên lưu trữ toàn cầu với một tập hợp mở rộng các dịch vụ sao chép, di chuyển và dữ liệu khác.
### Thuộc tính matadata phong phú

Sử dụng các thuộc tính File metadata phong phú của bộ lưu trữ đối tượng trong Ceph để lưu trữ và truy xuất dữ liệu phi cấu trúc siêu hiệu quả:

* Tạo kho dữ liệu quy mô lớn, dễ dàng tìm kiếm và quản lý.
* Sử dụng phân tầng đám mây để giữ dữ liệu được truy cập thường xuyên trong cụm của bạn và chuyển dữ liệu ít được sử dụng sang nơi khác.
### Phân cấp bộ nhớ cache rõ ràng
Sử dụng các ổ đĩa solid state drives cực nhanh của bạn làm tầng bộ nhớ cache và các hard disk drives tiết kiệm làm tầng lưu trữ của bạn, có thể thực hiện được ngay trong Ceph.

* Thiết lập nhóm lưu trữ sao lưu, nhóm bộ nhớ cache, sau đó thiết lập các miền lỗi của bạn thông qua các quy tắc CRUSH.
* Kết hợp phân tầng bộ nhớ cache với mã hóa xóa để lưu trữ dữ liệu tiết kiệm hơn.

### Block storage
Ceph RBD (RADOS Block Device) block storage xếp các virtual disks lên các Object trong cụm lưu trữ Ceph, phân phối dữ liệu và khối lượng công việc trên tất cả các thiết bị có sẵn để có khả năng mở rộng và hiệu suất cực cao. RBD disk images có **thinly provisioned**, hỗ trợ cả read-only snapshots và bản sao có thể ghi và có thể được sao chép không đồng bộ tới các cụm Ceph từ xa trong các trung tâm dữ liệu khác để khôi phục hoặc sao lưu sau thảm họa, làm cho Ceph RBD trở thành lựa chọn hàng đầu để  block storage trong Public/Private cloud và các môi trường ảo hóa.
* **Cung cấp cơ sở hạ tầng block storage**: Các tính năng và lợi ích của Storage Area Network(SAN) thông thường bằng cách sử dụng Cổng iSCSI của Ceph, cổng này đưa ra `iSCSI target` có tính khả dụng cao để xuất RBD image dưới dạng đĩa SCSI.
* **Tích hợp với Kubernetes**: Cung cấp động RBD image để sao lưu các ổ Kubernetes, ánh xạ RBD image dưới dạng Block device. Bởi vì Ceph cuối cùng lưu trữ các Block device dưới dạng các đối tượng sọc ngang qua cụm của nó, bạn sẽ nhận được hiệu suất tốt hơn từ chúng so với một máy chủ độc lập!
* **Tạo cluster snapshots với RBD**: Hãy xem các liên kết bên dưới để biết thêm chi tiết về cách làm việc với ảnh chụp nhanh bằng Ceph RBD.
### File system
The Ceph File System (CephFS) là một hệ thống tệp phân tán mạnh mẽ, có đầy đủ tính năng tuân thủ POSIX như một dịch vụ với khả năng phản chiếu nhanh, hạn ngạch và đa cụm. Các tệp CephFS được phân chia dọc theo các đối tượng được Ceph lưu trữ để có quy mô và hiệu suất cực cao. Hệ thống Linux có thể gắn kết các hệ thống tệp CephFS nguyên bản, thông qua một máy khách dựa trên FUSE hoặc thông qua một cổng NFSv4.
#### File storage that scales
* File metadata tệp được lưu trữ trong nhóm RADOS riêng biệt với dữ liệu tệp và được phân phát qua một cụm Máy chủ File metadata (MDS) có thể thay đổi kích thước, có thể thay đổi quy mô khi cần để hỗ trợ khối lượng công việc File metadata.

* Bởi vì file system clients truy cập RADOS trực tiếp để đọc và ghi các khối dữ liệu tệp, khối lượng công việc có thể chia tỷ lệ tuyến tính với kích thước của kho lưu trữ đối tượng RADOS bên dưới, tránh sự cần thiết của cổng hoặc nhà môi giới trung gian I/O dữ liệu cho máy khách.
#### Xuất sang NFS

CephFS namespaces có thể được xuất qua giao thức NFS bằng máy chủ NFS-Ganesha NFS. Có thể chạy nhiều NFS với RGW, xuất các tài nguyên giống nhau hoặc khác nhau từ cụm.

## Thuật toán CRUSH

The CRUSH (Controlled Replication Under Scalable Hashing - Nhân rộng có kiểm soát theo phương pháp băm có thể mở rộng) giữ cho dữ liệu của tổ chức được an toàn và khả năng lưu trữ có thể mở rộng thông qua sao chép tự động. Sử dụng thuật toán CRUSH, máy khách Ceph và daemon Ceph OSD có thể theo dõi vị trí của các đối tượng lưu trữ, tránh các vấn đề vốn có đối với kiến ​​trúc phụ thuộc vào bảng tra cứu trung tâm.
## Reliable Autonomic Distributed Object Store (RADOS)
RADOS (Reliable Autonomic Distributed Object Store - Kho lưu trữ đối tượng phân tán tự động đáng tin cậy) tìm cách tận dụng trí thông minh của thiết bị để phân phối sự phức tạp xung quanh việc truy cập dữ liệu nhất quán, lưu trữ dự phòng, phát hiện lỗi và khôi phục lỗi trong các cụm bao gồm hàng nghìn thiết bị lưu trữ. RADOS được thiết kế cho các hệ thống lưu trữ ở quy mô petabyte: các hệ thống như vậy nhất thiết phải năng động khi chúng tăng dần và hợp đồng với việc triển khai bộ nhớ mới và ngừng hoạt động của các thiết bị cũ. RADOS đảm bảo rằng có một cái nhìn nhất quán về phân phối dữ liệu trong khi vẫn duy trì quyền truy cập đọc và ghi nhất quán vào các đối tượng dữ liệu.
















### {
III. Document: https://docs.ceph.com --> https://docs.ceph.com/en/reef/
0. Ceph Architecture:
Ceph uniquely delivers object, block, and file storage in one unified system. Ceph is highly reliable, easy to manage, and free. The power of Ceph can transform your company’s IT infrastructure and your ability to manage vast amounts of data. Ceph delivers extraordinary scalability–thousands of clients accessing petabytes to exabytes of data. A Ceph Node leverages commodity hardware and intelligent daemons, and a Ceph Storage Cluster accommodates large numbers of nodes, which communicate with each other to replicate and redistribute data dynamically.

Prerequisites:
- A VMware ESXi host running VMware vSphere Hypervisor (ESXi) 7.0U3 version or later.
- Deployed Ceph NVMe-oF gateway.
- Ceph cluster with NVMe-oF configuration.
- Subsystem defined in the gateway.
https://docs.ceph.com/en/reef/rbd/nvmeof-initiator-esx/


1. Ceph in Debian deployment with vsphere document guide 

2. How to Deploy a Ceph Storage to Bare Virtual Machines
https://blog.risingstack.com/ceph-storage-deployment-vm/

3. Ceph: Step by step guide to deploy Ceph clusters
https://medium.com/@arslankhanali/ceph-step-by-step-guide-to-deploy-ceph-clusters-c62e4167a298

4. Installing Ceph - There are multiple ways to install Ceph.
- Cephadm is a tool that can be used to install and manage a Ceph cluster.
https://docs.ceph.com/en/latest/install/

5. Using cephadm to Deploy a New Ceph Cluster
Cephadm creates a new Ceph cluster by bootstrapping a single host, expanding the cluster to encompass any additional hosts, and then deploying the needed services.
Requirements:
- Python 3 (cephadm Requires Python 3.6 or Late)
	_You can manually run cephadm with a particular version of Python by prefixing the command with your installed Python version. For example:_
		```
		python3.8 ./cephadm <arguments...>
		```
- Systemd
- Podman or Docker for running containers
- Time synchronization (such as Chrony or the legacy ntpd)
- LVM2 for provisioning storage devices
--> https://docs.ceph.com/en/latest/cephadm/install/ 

6. HOWTO: Ceph as Openstack nova-volumes/swift backend on Debian GNU/Linux wheezy
https://wiki.debian.org/OpenStackCephHowto

https://docs.ceph.com/en/reef/rbd/rbd-cloudstack/
}
###


11:43 am
how to setup step by step and deploy and configure ceph with NFS 4.0 protocol , ceph admin on debian 12 via command line terminal ?

https://www.google.com/search?q=how+to+setup+step+by+step+and+deploy+and+configure+ceph+with+NFS+4.0+protocol+%2C+ceph+admin+on+debian+12+via+command+line+terminal+%3F&sca_esv=b597786ab811f977&sxsrf=AHTn8zoQ8X8OPZn3mWtc1vK_WRK2qsa73A%3A1741235661128&source=hp&ei=zSXJZ_rcBM-Avr0PqNKG4Ao&iflsig=ACkRmUkAAAAAZ8kz3ULS3Wiiwbl-xJ5zhrlPXxlx1fR_&ved=0ahUKEwi697Go0PSLAxVPgK8BHSipAawQ4dUDCBg&uact=5&oq=how+to+setup+step+by+step+and+deploy+and+configure+ceph+with+NFS+4.0+protocol+%2C+ceph+admin+on+debian+12+via+command+line+terminal+%3F&gs_lp=Egdnd3Mtd2l6IoMBaG93IHRvIHNldHVwIHN0ZXAgYnkgc3RlcCBhbmQgZGVwbG95IGFuZCBjb25maWd1cmUgY2VwaCB3aXRoIE5GUyA0LjAgcHJvdG9jb2wgLCBjZXBoIGFkbWluIG9uIGRlYmlhbiAxMiB2aWEgY29tbWFuZCBsaW5lIHRlcm1pbmFsID8yBRAAGO8FMgUQABjvBTIFEAAY7wUyBRAAGO8FMgUQABjvBUi4swRQAFjFsQRwA3gAkAEHmAHoD6ABrKECqgEUMC43LjEuMy4wLjcuOS4xMS40LjG4AQPIAQD4AQGYAiSgAo67AcICBBAjGCfCAgcQABiABBgTwgIJEAAYgAQYExgKwgIIEAAYgAQYywHCAgoQABiABBgKGMsBwgIIEAAYFhgKGB7CAgYQABgWGB7CAgUQIRigAcICBRAhGJ8FmAMAkgcPMy42LjEuMy40LjUuOC42oAeQsQI&sclient=gws-wiz

Manual Deployment:
https://docs.ceph.com/en/reef/install/manual-deployment/

-----
11:50 am

Miêu tả chi tiết các bước cài , triển khai và cấu hìnhCeph đầy đủ với giao thức NFS 4.0 , Ceph admin trên nền Debian 12 bằng dòng lệnh


Để cài đặt, triển khai và cấu hình Ceph với giao thức NFS 4.0 và Ceph admin trên hệ điều hành Debian 12 bằng dòng lệnh, bạn cần thực hiện các bước sau:

Bước 1: Cài đặt Ceph trên Debian 12:
Cài đặt Ceph trên Debian 12 bằng dòng lệnh:
bash

Copy
sudo apt update
sudo apt install ceph
Cấu hình Ceph Cluster:
bash

Copy
ceph-deploy new {MONITOR_NODE}
ceph-deploy install {MONITOR_NODE}
ceph-deploy mon create-initial
Cài đặt và khởi động các OSD (Object Storage Daemon):
bash

Copy
ceph-deploy osd prepare {OSD_NODE}:/dev/sdX
ceph-deploy osd activate {OSD_NODE}:/dev/sdX
Bước 2: Cấu hình Ceph với NFS 4.0:
Cài đặt NFS-Ganesha trên Ceph Monitor node:
bash

Copy
sudo apt install nfs-ganesha
Cấu hình NFS-Ganesha với Ceph:
bash

Copy
sudo nano /etc/ganesha/ganesha.conf
Thêm cấu hình sau vào tệp cấu hình:

ini

Copy
EXPORT {
    Export_Id = 1;
    Path = /path/to/ceph/fs;
    Pseudo = /cephfs;
    Access_type = RW;
    Squash = no_root_squash;
    FSAL {
        Name = CEPH;
    }
}
Bước 3: Cấu hình Ceph admin trên Debian 12:
Tạo user Ceph admin:
bash

Copy
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring
sudo chmod +r /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow' /etc/ceph/ceph.client.admin.keyring
sudo ceph auth add client.admin -i /etc/ceph/ceph.client.admin.keyring
Thiết lập biến môi trường để sử dụng Ceph admin:
bash

Copy
export CEPH_CONF=/etc/ceph/ceph.conf
export CEPH_CLIENT_KEYRING=/etc/ceph/ceph.client.admin.keyring
Kiểm tra kết nối với Ceph Cluster:
bash

Copy
ceph -s
Sau khi hoàn thành các bước trên, bạn đã cài đặt, triển khai và cấu hình Ceph với giao thức NFS 4.0 và cấu hình Ceph admin trên Debian 12 bằng dòng lệnh thành công. Đảm bảo rằng bạn tuân thủ các hướng dẫn cụ thể và kiểm tra kỹ lưỡng trước khi triển khai trong môi trường sản xuất.
# Hướng dẫn mở rộng Storage cho VMware Cloud Foundation 5.2

## Tổng quan

VCF 5.2 hỗ trợ nhiều loại storage bên cạnh vSAN và vVols. Tài liệu này tập trung vào các giải pháp **Ceph** — một distributed storage mã nguồn mở, có thể tích hợp vào VCF qua các giao thức chuẩn (iSCSI, NFS, NVMe/TCP).

---

## 1. Kiến trúc Ceph

```
┌──────────────────────────────────────────────────┐
│                 Storage Interfaces                │
│   ┌──────────────┐  ┌──────────────┐  ┌───────┐  │
│   │    RBD       │  │   CephFS     │  │ RGW   │  │
│   │  (Block)     │  │   (File)     │  │ (S3)  │  │
│   └──────┬───────┘  └──────┬───────┘  └───┬───┘  │
│          └─────────────────┼───────────────┘       │
│                            ▼                       │
│                   ┌──────────────┐                 │
│                   │    RADOS     │                 │
│                   │ (Object Store)│                 │
│                   └──────────────┘                 │
└──────────────────────────────────────────────────┘
```

### 1.1. RBD (RADOS Block Device) — Block Storage

- **Bản chất**: Block device (giống ổ cứng ảo / LUN)
- **Access mode**: RWO (ReadWriteOnce)
- **Giao thức**: Native librbd, iSCSI gateway, NVMe/TCP
- **Use case**: VM disk (vSphere), Database (MySQL, PostgreSQL), container
- **Hiệu năng**: IOPS cao, latency thấp (không cần MDS)
- **Snapshot/Clone**: Hỗ trợ đầy đủ

### 1.2. CephFS — File Storage

- **Bản chất**: POSIX-compliant distributed filesystem
- **Access mode**: RWX (ReadWriteMany)
- **Yêu cầu**: Cần MDS (Metadata Server)
- **Use case**: Shared file storage, backup, AI/ML datasets, ISO templates
- **Hiệu năng**: Throughput tốt, latency cao hơn RBD do MDS overhead
- **Snapshot/Clone**: Có (per-directory)

### 1.3. RGW (RADOS Gateway) — Object Storage

- **Bản chất**: S3/Swift-compatible object storage
- **Use case**: Backup target, media storage, logs archive
- **Tích hợp VCF**: Qua S3 plugin hoặc ứng dụng bên ngoài

---

## 2. So sánh Licensing & Support

| Loại | License | Free? | Support | Ghi chú |
|------|---------|-------|---------|---------|
| **Upstream Ceph** | LGPL 2.1/3.0 | ✅ Hoàn toàn free | ❌ Community support | Tự vận hành, không SLA |
| **Rook** (CNCF Graduated) | Apache 2.0 | ✅ Hoàn toàn free | ❌ Community support | Operator quản lý Ceph trên K8s |
| **Red Hat Ceph Storage** | LGPL + Subscription | ⚠️ Code free | ✅ Cần subscription | Certified hardware, SLA, support |
| **SUSE Enterprise Storage** | LGPL + Subscription | ⚠️ Code free | ✅ Cần subscription | Tương tự Red Hat |

**Kết luận**: Có thể dùng Ceph **100% free** (LGPL). Chỉ trả tiền nếu cần **SLA support** từ Red Hat / SUSE.

---

## 3. Deployment Methods

### 3.1. Cephadm (Khuyên dùng cho bare-metal / VM)

Công cụ chính thức từ Ceph community, container-native (Podman/Docker), không cần Kubernetes.

```bash
# Bootstrap cluster (trên node đầu tiên)
cephadm bootstrap --mon-ip 10.0.0.10

# Thêm các node OSD khác
ceph orch host add node1 10.0.0.11
ceph orch host add node2 10.0.0.12
ceph orch host add node3 10.0.0.13

# Apply OSDs (tự động detect disk trống)
ceph orch apply osd --all-available-devices

# Tạo pool RBD
ceph osd pool create vcf-block 128
rbd pool init vcf-block

# Tạo CephFS
ceph fs volume create vcf-fs

# Export NFS-Ganesha
ceph auth get-or-create client.vcf mon 'allow r' osd 'allow rwx pool=vcf-block'
ceph orch apply nfs vcf-nfs vcf-fs
```

### 3.2. Rook (Trên Kubernetes)

Dùng cho môi trường đã chạy K8s (VCF Management Domain có thể chạy K8s workload).

```bash
# 1. Install Rook Operator
helm repo add rook-release https://charts.rook.io/release
helm install --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph

# 2. Tạo CephCluster
cat <<EOF | kubectl apply -f -
apiVersion: ceph.rook.io/v1
kind: CephCluster
metadata:
  name: vcf-ceph
  namespace: rook-ceph
spec:
  dataDirHostPath: /var/lib/rook
  mon:
    count: 3
    allowMultiplePerNode: false
  storage:
    useAllNodes: true
    useAllDevices: true
EOF

# 3. Tạo StorageClass RBD cho PVC
cat <<EOF | kubectl apply -f -
apiVersion: ceph.rook.io/v1
kind: CephBlockPool
metadata:
  name: vcf-replicapool
  namespace: rook-ceph
spec:
  replicated:
    size: 3
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: rook-ceph-block
provisioner: rook-ceph.rbd.csi.ceph.com
parameters:
  pool: vcf-replicapool
  clusterID: vcf-ceph
  csi.storage.k8s.io/fstor: xfs
EOF

# 4. Tạo Filesystem cho RWX
cat <<EOF | kubectl apply -f -
apiVersion: ceph.rook.io/v1
kind: CephFilesystem
metadata:
  name: vcf-fs
  namespace: rook-ceph
spec:
  metadataPool:
    replicated:
      size: 3
  dataPools:
    - replicated:
        size: 3
  preserveFilesystemOnDelete: true
  metadataServer:
    activeCount: 1
    activeStandby: true
EOF
```

### 3.3. So sánh Deployment Methods

| Phương pháp | Target | Orchestration | Yêu cầu | Độ phức tạp |
|-------------|--------|---------------|---------|-------------|
| **cephadm** | Bare-metal / VM | Container (Podman) | Linux hosts | Thấp |
| **Rook** | Kubernetes | K8s Operator | K8s cluster | Trung bình |
| **ceph-ansible** | Bare-metal / VM | Ansible | Ansible infra | Cao (legacy) |

---

## 4. Tích hợp Ceph vào VCF 5.2

### 4.1. Kiến trúc tích hợp

```
┌─────────────────────────────────────────────────────┐
│                  VCF 5.2 SDDC Manager                 │
├─────────────────────────────────────────────────────┤
│  Management Domain  │  VI Workload Domain             │
│  ┌───────────────┐  │  ┌───────────────┐              │
│  │ ESXi Cluster  │  │  │ ESXi Cluster  │              │
│  │ (vSAN/NFS/FC) │  │  │ (NFS/iSCSI)   │              │
│  └───────┬───────┘  │  └───────┬───────┘              │
└──────────┼──────────┴──────────┼──────────────────────┘
           │                     │
           │    ┌────────────────┘
           │    ▼
           │  ┌─────────────────────────────┐
           └──►        Ceph Cluster         │
              │  ┌──────┬──────┬──────┐     │
              │  │ OSD0 │ OSD1 │ OSD2 │     │
              │  └──────┴──────┴──────┘     │
              └─────────────────────────────┘
```

### 4.2. Các cách expose Ceph cho VCF

#### Cách 1: Ceph RBD → iSCSI Gateway → vSphere VMFS Datastore

```
Ceph RBD ──► iSCSI Gateway ──► ESXi iSCSI Adapter ──► VMFS Datastore
```

```bash
# Trên Ceph node, deploy iSCSI gateway
ceph orch apply iscsi vcf-iscsi \
  --placement="3 host1 host2 host3" \
  --pool=vcf-block \
  --trusted-ip-list="10.0.0.0/24"

# Trên vSphere:
# 1. Configure Software iSCSI Adapter
# 2. Add iSCSI target IP (gateway VIP)
# 3. Rescan & tạo VMFS datastore
```

**Vị trí trong VCF**: **Supplemental storage** (thêm thủ công qua vSphere Client, SDDC Manager không quản lý)

#### Cách 2: CephFS → NFS-Ganesha → vSphere NFS Datastore

```
CephFS ──► NFS-Ganesha ──► ESXi NFS Client ──► NFS Datastore
```

```bash
# Trên Ceph, deploy NFS-Ganesha
ceph orch apply nfs vcf-nfs vcf-fs

# Export path
ceph nfs export create vcf-nfs \
  --pseudo-path /vcf-storage \
  --squash no_root_squash \
  --nfs-referrals enabled

# Trên vSphere:
# 1. Add Datastore → NFS
# 2. Nhập NFS server IP & export path
# 3. Chọn NFS 3 (principal) hoặc NFS 4.1 (supplemental)
```

**Vị trí trong VCF**:
- **NFS v3**: Có thể làm **Principal storage** (via VCF Import Tool, brownfield)
- **NFS 4.1**: **Supplemental storage** (add qua vSphere Client)

#### Cách 3: Ceph RBD → NVMe/TCP → vSphere (NVMe over Fabrics)

Mới hơn, hiệu năng cao hơn iSCSI.

```bash
# Trên Ceph, bật NVMe/TCP gateway (cần Ceph Reef+)
ceph orch apply nvmeof vcf-nvmeof \
  --placement="2 host1 host2" \
  --pool=vcf-block \
  --port=4420
```

#### Cách 4: MinIO trên Ceph (Object Storage)

**MinIO** không thể làm datastore cho vSphere, nhưng có thể chạy như một VM trên VCF, dùng Ceph RGW hoặc Ceph RBD làm backend:

```
VCF VM ──► MinIO (S3) ──► Ceph RGW/RBD
```

Dùng cho: backup Veeam, logs, artifact storage.

---

## 5. Yêu cầu tối thiểu cho Ceph Production

| Thành phần | Minimum | Recommended |
|------------|---------|-------------|
| Nodes | 3 | 5+ |
| RAM/node | 8 GB | 16-32 GB |
| CPU/node | 4 cores | 8-16 cores |
| Disk/node | 1 raw disk | Multiple NVMe/SSD |
| Network | 1 Gbps | 10 Gbps+ |
| Monitor nodes | 3 | 3-5 |
| Replication | 2x | 3x |

---

## 6. Ma trận tương thích với VCF 5.2

| Phương pháp | Principal? | Supplemental? | SDDC quản lý? | VMware Support? |
|-------------|-----------|--------------|---------------|-----------------|
| **Ceph → iSCSI → VMFS** | ❌ | ✅ | ❌ | ⚠️ Không officially supported (tự chịu rủi ro) |
| **CephFS → NFS v3** | ✅ (brownfield only) | ✅ | ❌ | ⚠️ NFS được support, Ceph backend không |
| **CephFS → NFS v4.1** | ❌ | ✅ | ❌ | ⚠️ NFS được support, Ceph backend không |
| **Ceph RBD → NVMe/TCP** | ❌ | ✅ (vSphere 8+) | ❌ | ⚠️ Experimental |
| **Red Hat Ceph Storage → iSCSI** | ❌ | ✅ | ❌ | ✅ Có RH support, VMware support phần NFS/iSCSI |

> **Lưu ý quan trọng**: Nếu dùng Ceph làm backend, VMware support sẽ chỉ cover **giao thức** (NFS/iSCSI) — Ceph là unsupported stack. Broadcom không hỗ trợ vấn đề từ Ceph. Cần có đội ngũ tự vận hành Ceph (SRE/storage team).

---

## 7. Lựa chọn theo nhu cầu

| Nhu cầu | Giải pháp | Chi phí |
|---------|-----------|---------|
| Lab / POC, chi phí thấp | **Upstream Ceph + cephadm** + NFS/iSCSI | 0đ |
| Production, cần support | **Red Hat Ceph Storage** + NFS/iSCSI | Subscription |
| K8s-native, GitOps | **Rook** trên K8s + CSI drivers | 0đ |
| VM disk hiệu năng cao | **Ceph RBD → NVMe/TCP → vSphere** | 0đ (tự vận hành) |
| Shared backup storage | **CephFS → NFS → vSphere** | 0đ (tự vận hành) |

---

## 8. Tài liệu tham khảo

- [Ceph Documentation](https://docs.ceph.com/)
- [Rook Documentation](https://rook.io/docs/rook/latest/)
- [VCF 5.2 Storage Design](https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vcf-5-2-and-earlier/5-2/vcf-design-5-2/vcf-shared-storage-design.html)
- [Red Hat Ceph Storage](https://www.redhat.com/en/technologies/storage/ceph)
- [VMware Compatibility Guide](https://www.vmware.com/resources/compatibility/search.php)

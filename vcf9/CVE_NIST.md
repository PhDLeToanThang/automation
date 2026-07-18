>>>Tôi đang dùng VMware vSphere 8.0u3f, 9.0, 9.1, 7.0u3, SDDC 5.2 , NSX 4.0, SDDC 9.0, SDDC 9.1, GLPI itsm, 
GITHUB, GITEA, Keycloak SSO, SIEM ELK, AionUI, OpenCode, Graphify, PowerBI Desktop,
KNIME Data Analytic Platform Desktop, PowerBI Report Service Desktop, 
PowerBI Report Server, Microsoft MS-SQL Server và MS-SQL Analytics Server, và MS-SQL Report Server, 
Microsoft Office 2013, 2014, 2016, 2019, 2022, 2025, MSO365, 
Microsoft windows 10, 11, 12, 2012, 2016, 2019, 2022, 2025, IBM SPSS, 
Oracle DB RAC RMAN, MS Data Lake, MS SQL DWH, MS SQL Cluster Failover 2017, Apache BizSpark 2, 
Hadoop2, Hmail Server, Exchange Server 2016/2019/2022/2026, SharePoint Farm 2016/2019/2022, 
Bitdefender Gravity zone, Kaspersky server, MicroTrend, Veeam Backup Replicate Server v12, VeeamONE v13, 
Commvault, Data Domains; vậy bạn có thể chỉ dẫn chi tiết cách ứng dụng của các trang : 
Hệ thống CVE (Common Vulnerabilities and Exposures) do tổ chức phi lợi nhuận MITRE quản lý để định danh mọi lỗi hổng 
bảo mật trên thế giới. 
Bạn có thể tra cứu thông tin chi tiết qua hai trang chính thức sau: 
CVE Official Website https://www.cve.org, https://nvd.nist.gov/ : Cơ sở dữ liệu lỗ hổng,
lỗi phần mềm quốc gia của Mỹ. 
Hãy tìm cho tôi các vá lỗi, các đánh giá điểm số xác định mối nguy hại có thể với hệ thống của tôi.
Hãy thay toàn bộ lịch về 15:30 PM hàng ngày, 
hãy thực thi đoạn prompt trên và lưu ra file Documents\\itaudit\\[ngày hiện thời]_cve.md.

---

??? chat.qwwen.ai

hoặc Local Private AI: AionUI + OC:

--->

# Daily Security Report

**Date:** Monday, July 13, 2026 10:40
**System:** vSphere 8.0u3f | SDDC 5.2 | SDDC 9.0 | SDDC 9.1 | NSX 4.0 | GLPI | GitHub | Gitea | AionUI | OpenCode | Graphify | PowerBI Desktop | KNIME Desktop | PowerBI Report Server | MS-SQL Server | MS-SQL Analytics Server | MS-SQL Report Server

---

## 1. Current System Status

| Component | Your Version | Latest Patch | Status |
|-----------|-------------|--------------|--------|
| vCenter Server | 8.0u3f (build 24784735) | 8.0u3j (build 25429389) | :warning: Behind by ~11 months |
| ESXi | 8.0u3f (build 24784735) | 8.0u3j (build 25429389) | :warning: Behind by ~11 months |
| NSX | 4.0.x | 4.1.2.7+ | :warning: NSX 4.0 no longer patched |
| SDDC (Cloud Foundation) | 5.2 | 5.2 latest | Check required |
| SDDC (Cloud Foundation) | 9.0 | 9.0.2.0 EP2 | Check required |
| SDDC (Cloud Foundation) | 9.1 | 9.1.0.0 | :warning: VMSA-2026-0004 unpatched |
| GLPI | check your version | 11.0.8 / 10.0.26 | :warning: 16 flaws fixed in Jun 2026 |
| GitHub Enterprise Server | check your version | 3.22.x | Check required |
| Gitea | check your version | 1.26.2+ | Critical CVEs in < 1.25.5 |
| AionUI | check your version | 2.1.33 | No known CVEs |
| OpenCode | check your version | 1.1.10+ | :warning: CVE-2026-22812/22813 |
| Graphify | check your version | 2.1.0 | No known CVEs |
| PowerBI Desktop | check your version | Feb 2026 update | :warning: CVE-2026-21229 unpatched |
| KNIME Analytics Platform Desktop | check your version | 5.2.0+ | XSS sanitization default in 5.2.0 |
| PowerBI Report Server | check your version | 15.0.1120.113+ | :warning: CVE-2026-21229 unpatched |
| MS-SQL Server | check your version | SQL 2022 CU22+ / SQL 2025 CU4+ | :warning: Multiple EoP & SQLi CVEs |
| MS-SQL Analytics Server (SSAS) | check your version | SQL 2025 CU3+ | :warning: Part of SQL Server updates |
| MS-SQL Report Server (SSRS) | check your version | Latest CU | :warning: CVE-2020-0618 on CISA KEV |

---

## 2. How to Use CVE and NVD

### 2.1. CVE.org (https://www.cve.org)
- Managed by MITRE. Assigns unique IDs: CVE-YEAR-NUMBER (e.g. CVE-2024-37079)
- Search by keyword: product name, vendor name
- View: description, affected products, CNA (CVE Numbering Authority)

### 2.2. NVD (https://nvd.nist.gov)
- U.S. National Vulnerability Database by NIST
- CVSS Severity Scale:
  - Critical: 9.0-10.0
  - High: 7.0-8.9
  - Medium: 4.0-6.9
  - Low: 0.1-3.9
- How to search:
  1. Go to https://nvd.nist.gov/vuln/search
  2. Enter: product name + version
  3. Filter by Severity, CISA KEV (Known Exploited)
  4. Check References for vendor advisory links with patches
- Direct CVE lookup: https://nvd.nist.gov/vuln/detail/CVE-2024-XXXXX

### 2.3. Vendor Security Advisories
- Broadcom/VMware: https://support.broadcom.com/web/ecx/security-advisory
- Microsoft: https://msrc.microsoft.com/update-guide
- GLPI: https://github.com/glpi-project/glpi/security/advisories
- GitHub: https://docs.github.com/en/enterprise-server@latest/admin/release-notes
- Gitea: https://github.com/go-gitea/gitea/security/advisories
- KNIME: https://www.knime.com/security/advisories
- Microsoft SQL Server: https://msrc.microsoft.com/update-guide/vulnerability

---

## 3. CVEs Affecting Your System

### 3.1. vCenter Server (SDDC 5.2)

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2024-37079 | **9.8 Critical** | Heap-overflow in DCERPC -> unauthenticated RCE | vCenter < 8.0 U2d, SDDC 5.x | vCenter 8.0 U2d+ |
| CVE-2024-37080 | **9.8 Critical** | Heap-overflow in DCERPC -> remote RCE | vCenter < 8.0 U2d, SDDC 5.x | vCenter 8.0 U2d+ |
| CVE-2024-38812 | **9.8 Critical** | Heap-overflow DCERPC -> RCE | vCenter 8.0, SDDC 5.x | vCenter 8.0 U2d+ |
| CVE-2024-38813 | **7.5 High** | Privilege escalation -> root via DCERPC | vCenter 8.0, SDDC 5.x | vCenter 8.0 U2d+ |
| CVE-2025-41225 | **8.8 High** | Command execution via alarm script action | vCenter < 8.0 U3e | vCenter 8.0 U3e+ |
| CVE-2025-41250 | **8.5 High** | SMTP header injection in scheduled tasks | vCenter < 8.0 U3g | vCenter 8.0 U3g+ |

> :warning: **You are on vCenter 8.0u3f** which is vulnerable to all above CVEs. Upgrade to 8.0u3g/h/i/j immediately.

### 3.2. ESXi (vSphere 8.0)

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2024-37085 | **6.8 Medium** | AD authentication bypass (ESXi Admins group) - CISA KEV | ESXi 8.0 | ESXi 8.0 U3b+ |
| CVE-2025-22226 | **5.5 Medium** | OOB read in HGFS -> info disclosure - CISA KEV | ESXi 8.0 | ESXi 8.0 U3d+ |

### 3.3. NSX 4.0

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2025-41251 | **8.1 High** | Weak password recovery -> brute force (reported by NSA) | NSX 4.0.x-4.2.x | NSX 4.1.2.7+ |
| CVE-2025-41252 | **7.5 High** | Username enumeration (unauthenticated) | NSX 4.0.x-4.2.x | NSX 4.1.2.7+ |
| CVE-2025-22245 | **5.9 Medium** | Stored XSS on router port | NSX 4.0.x-4.2.x | NSX 4.2+ |

> :warning: **NSX 4.0.x no longer receives patches.** Upgrade to NSX 4.1.2.7 or 4.2.2.2+.

### 3.4. SDDC 9.0 / 9.1 (Cloud Foundation)

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2026-41722 | **8.0 High** | Stored XSS in Cloud Foundation Operations (create policies/views) | SDDC 9.0 < EP2, 9.1 | VMSA-2026-0004 |
| CVE-2026-41723 | **8.0 High** | Stored XSS in Cloud Foundation Operations | SDDC 9.0 < EP2, 9.1 | VMSA-2026-0004 |
| CVE-2026-41724 | **8.0 High** | Stored XSS in Cloud Foundation Operations | SDDC 9.0 < EP2, 9.1 | VMSA-2026-0004 |
| CVE-2026-22721 | **6.2 Medium** | Privilege escalation in Aria Ops via vCenter access | SDDC 9.0, 9.1 | VMSA-2026-0001 |
| CVE-2026-22719 | **8.1 High** | Command injection -> RCE during Aria Ops migration | SDDC 9.0, 9.1 | VMSA-2026-0001 |
| CVE-2026-22720 | **8.0 High** | Stored XSS in Aria Operations (custom benchmarks) | SDDC 9.0, 9.1 | VMSA-2026-0001 |

> :warning: **SDDC 9.0 needs EP2, SDDC 9.1 needs 9.1.0.0.** Apply VMSA-2026-0004 immediately.

### 3.5. GLPI (IT Asset Management)

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2025-24799 | **9.8 Critical** | Pre-auth SQL injection -> RCE via inventory | GLPI < 10.0.18 | 10.0.18+ |
| CVE-2025-24801 | **9.8 Critical** | Pre-auth SQL injection -> RCE (chained) | GLPI < 10.0.18 | 10.0.18+ |
| CVE-2026-26026 | **9.1 Critical** | Template injection by admin -> RCE | GLPI 11.0.0 < 11.0.6 | 11.0.6+ |
| CVE-2026-22248 | **8.1 High** | Authenticated malicious file upload -> code exec | GLPI 11.0.0 < 11.0.5 | 11.0.5+ |
| CVE-2025-66417 | **7.5 High** | Unauthenticated SQLi via inventory endpoint | GLPI 11.0.0 < 11.0.3 | 11.0.3+ |
| CVE-2026-26027 | **7.5 High** | Unauthenticated XSS via inventory endpoint | GLPI 11.0.0 < 11.0.6 | 11.0.6+ |
| CVE-2026-42317 | **N/A** | Authenticated arbitrary file deletion | GLPI 0.78 < 10.0.25/11.0.7 | 10.0.25+ / 11.0.7+ |

> :warning: **GLPI 11.0.8 and 10.0.26 just released (Jun 24, 2026) patching 16 flaws.** Upgrade immediately.

### 3.6. GitHub Enterprise Server

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2026-9312 | **9.2 Critical** | Pre-auth SSRF in upload endpoint -> access internal services | GHES < 3.22 | 3.17.17+ / 3.21.2+ |
| CVE-2026-0573 | **9.0 Critical** | URL redirect leaks Actions.ManageOrgs JWT -> potential RCE | GHES < 3.19.2 | 3.19.2+ |
| CVE-2026-3854 | **8.8 High** | RCE via git push option injection (delimiter injection in internal protocol) | GHES < 3.19.4 | 3.19.4+ |
| CVE-2025-11578 | **7.5 High** | Privilege escalation to root SSH via symlink escape in pre-receive hook | GHES < 3.19 | 3.14.20+ |
| CVE-2025-8447 | **7.0 High** | Cross-repo code retrieval via compare/diff without authorization | GHES < 3.18 | 3.14.17+ |
| CVE-2026-8606 | **N/A** | SSRF via package URL endpoint -> extract env variables | GHES < 3.21 | 3.17.17+ |

> :warning: **88% of GHES instances were unpatched at disclosure.** Update to latest 3.22.x.

### 3.7. Gitea (Self-hosted Git)

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2026-26292 | **9.8 Critical** | LFS push/sync mirror bypasses migration transport protection | Gitea < 1.25.5 | 1.25.5+ |
| CVE-2026-20896 | **9.8 Critical** | Docker auth bypass via X-WEBAUTH-USER header -> impersonate admin | Docker <=1.26.2 | 1.26.2+ (config) |
| CVE-2026-27771 | **Critical** | Container registry auth bypass -> pull private images unauthenticated | < 1.26.2 | 1.26.2+ |
| CVE-2026-26247 | **9.1 Critical** | OAuth2 PKCE challenge not persisted -> token exchange without verifier | < 1.25.5 | 1.25.5+ |
| CVE-2026-26232 | **9.1 Critical** | Allow edits from maintainers -> commit to repos user can only read | <= 1.26.1 | 1.26.2+ |
| CVE-2026-28737 | **8.7 High** | Stored XSS in 3D file viewer via glTF extensionsRequired field | < 1.26.0 | 1.26.0+ |

> :warning: **Gitea < 1.25.5 has multiple critical flaws.** Update to 1.26.2+.

### 3.8. AionUI

AionUI is a free, open-source 24/7 Cowork app (TypeScript/Electron). Latest v2.1.33.
- **No known CVEs** in the product itself.
- Security score: 5.2/10 (ReleasePort), 0 open CVEs.
- Runs AI agents locally with user approval for file operations.
- No critical security actions required.

### 3.9. OpenCode

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2026-22813 | **9.4 Critical** | XSS via markdown renderer - no DOMPurify/CSP, allows JS execution on localhost:4096 | < 1.1.10 | 1.1.10+ |
| CVE-2026-22812 | **8.8 High** | Unauthenticated HTTP server -> any local process can execute arbitrary shell commands | < 1.0.216 | 1.0.216+ |

> :warning: **OpenCode < 1.1.10 has critical XSS allowing arbitrary command execution.** Update to latest.

### 3.10. Graphify

Graphify is a local knowledge graph tool for AI coding assistants. Latest v2.1.0.
- **No known CVEs** - local dev tool with built-in security mitigations.
- Threat surface: SSRF (blocked), XSS (sanitized), path traversal (blocked), oversized downloads (capped at 50MB).
- No network listener during graph analysis (MCP server over stdio only).
- No critical security actions required.

### 3.11. PowerBI Desktop

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2026-21229 | **8.8 High** | Improper input validation -> RCE over network | Power BI (all editions) | Feb 2026 update |

> :warning: **CVE-2026-21229 affects Power BI Desktop, Service, and Report Server.** Apply Microsoft's Feb 2026 security update.

### 3.12. KNIME Analytics Platform Desktop

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2024-46938 | **6.1 Medium** | XSS in WebPortal output display (sanitization off by default) | < 5.2.0 | 5.2.0+ (sanitize on by default) |
| CVE-2022-31500 | **4.6 Medium** | Insecure filesystem permissions in Windows installer | < 4.6.0 | 4.6.0+ |
| CVE-2021-45096 | **4.7 Medium** | XXE via crafted .knwf workflow file | < 4.5.0 | 4.5.0+ |

> :warning: **KNIME Analytics Platform 5.2.0 enables XSS sanitization by default.** Upgrade to latest.

### 3.13. PowerBI Report Server

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2026-21229 | **8.0 High** | Improper input validation -> RCE over network (patch 15.0.1120.113) | All versions | Feb 2026 update |
| CVE-2024-43612 | **6.9 Medium** | Spoofing vulnerability | Power BI RS | Security update |
| CVE-2024-43481 | **6.5 Medium** | Spoofing vulnerability | Power BI RS | Security update |
| CVE-2021-41372 | **7.6 High** | XSS + CSRF via malicious PBIX template upload | Power BI RS | Security update |

> :warning: **Apply Microsoft's Feb 2026 security update for CVE-2026-21229.**

### 3.14. MS-SQL Server (Database Engine)

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2026-40370 | **8.8 High** | External control of file name/path -> authorized attacker code exec over network | SQL Server 2016-2025 | May 2026 GDR/CU update |
| CVE-2026-21262 | **8.8 High** | Improper access control -> EoP over network (publicly disclosed zero-day) | SQL Server 2025 < CU2 | Mar 2026 CU2 / GDR |
| CVE-2026-26115 | **8.8 High** | SQL injection -> authorized attacker EoP over network | SQL Server 2025 < CU2 | Mar 2026 CU2 / GDR |
| CVE-2026-26116 | **8.8 High** | SQL injection -> authorized attacker EoP over network | SQL Server 2025 < CU2 | Mar 2026 CU2 / GDR |
| CVE-2026-33120 | **8.8 High** | Untrusted pointer dereference -> code execution | SQL Server 2016-2025 | May 2026 update |
| CVE-2025-59499 | **8.8 High** | SQL injection -> authorized attacker EoP over network | SQL Server 2016-2022 | Nov 2025 GDR |
| CVE-2025-49717 | **8.5 High** | Heap-based buffer overflow -> RCE | SQL Server 2016-2025 | Jul 2025 update |
| CVE-2025-49719 | **7.5 High** | Improper input validation -> unauthenticated info disclosure over network | SQL Server 2016-2022 | Jul 2025 update |
| CVE-2026-20803 | **7.2 High** | Missing authentication for critical function -> EoP (debug/memory access) | SQL Server 2022/2025 | Jan 2026 GDR/CU |
| CVE-2026-32167 | **6.7 Medium** | SQL injection -> authorized attacker EoP locally | SQL Server 2016-2025 | May 2026 CU3 |
| CVE-2026-32176 | **6.7 Medium** | SQL injection -> authorized attacker EoP locally | SQL Server 2016-2025 | May 2026 CU3 |

> :warning: **SQL Server 2022/2025 has received multiple cumulative security updates in 2025-2026.** Apply the latest CU or GDR release.

### 3.15. MS-SQL Analytics Server (SSAS)

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2026-40370 | **8.8 High** | External control of file name/path -> code exec (affects Analysis Services) | SQL Server 2016-2025 SSAS | May 2026 update |
| CVE-2026-21262 | **8.8 High** | EoP vulnerability (affects Analysis Services) | SQL Server 2025 SSAS < CU2 | Mar 2026 CU2 / GDR |
| CVE-2026-33120 | **8.8 High** | Untrusted pointer dereference -> code exec (affects AS core engine) | SQL Server 2016-2025 SSAS | May 2026 update |
| CVE-2026-26115 | **8.8 High** | SQL injection -> EoP (affects AS internal queries) | SQL Server 2025 SSAS < CU2 | Mar 2026 CU2 / GDR |
| CVE-2025-49717 | **8.5 High** | Heap buffer overflow -> RCE (AS OLE DB provider stack) | SQL Server 2016-2025 SSAS | Jul 2025 update |
| CVE-2026-20803 | **7.2 High** | Missing authentication for critical function -> memory dumping | SQL Server 2022/2025 SSAS | Jan 2026 GDR/CU |
| KB5068407 (Nov 2025) | N/A | RLS + OLS + CLS security bypass fix in SSAS multi-role configs | SQL Server 2022 SSAS | Nov 2025 GDR |

> :warning: **SSAS shares the same update track as SQL Server Database Engine.** The latest SQL Server CU includes fixes for Analysis Services.

### 3.16. MS-SQL Report Server (SSRS)

| CVE | CVSS | Description | Affected | Patch |
|-----|------|-------------|----------|------|
| CVE-2020-0618 | **8.8 High** | Deserialization of untrusted data -> RCE with SYSTEM privileges (CISA KEV) | SSRS 2017+ | Security update (CISA BOD 22-01) |
| CVE-2021-41372 | **7.6 High** | XSS + CSRF via malicious PBIX template upload | Power BI RS | Security update |
| CVE-2024-43612 | **6.9 Medium** | Spoofing vulnerability | SSRS | Security update |
| CVE-2020-1044 | **6.5 Medium** | Security feature bypass (attachment upload validation bypass) | SSRS 2017/2019 | Security update |
| CVE-2024-43481 | **6.5 Medium** | Spoofing vulnerability | SSRS | Security update |
| KB5083245 (Apr 2026) | N/A | RCE fix via crafted report definition files (enhanced input validation + sandboxing) | SQL Server 2025 SSRS < CU3 | Apr 2026 CU3 |

> :warning: **CVE-2020-0618 is in CISA Known Exploited Vulnerabilities catalog.** Apply mitigations per vendor instructions immediately.

---

## 4. Latest VMware CVEs from NVD API
| CVE | CVSS | Severity | Description | Published |
|-----|------|----------|-------------|-----------|
| [CVE-2006-3547](https://nvd.nist.gov/vuln/detail/CVE-2006-3547) | 5.5 | MEDIUM | EMC VMware Player allows user-assisted attackers to cause a denial of service (unrecoverable applica... | 2006-07-13T00:05:00.000 |
| [CVE-2006-2481](https://nvd.nist.gov/vuln/detail/CVE-2006-2481) | N/A |  | VMware ESX Server 2.0.x before 2.0.2 and 2.x before 2.5.2 patch 4 stores authentication credentials ... | 2006-07-31T19:04:00.000 |
| [CVE-2006-3589](https://nvd.nist.gov/vuln/detail/CVE-2006-3589) | N/A |  | vmware-config.pl in VMware for Linux, ESX Server 2.x, and Infrastructure 3 does not check the return... | 2006-07-21T14:03:00.000 |
| [CVE-2006-2662](https://nvd.nist.gov/vuln/detail/CVE-2006-2662) | N/A |  | VMware Server before RC1 does not clear user credentials from memory after a console connection is m... | 2006-06-02T10:18:00.000 |
| [CVE-2005-3619](https://nvd.nist.gov/vuln/detail/CVE-2005-3619) | N/A |  | Cross-site scripting (XSS) vulnerability in the management interface for VMware ESX 2.5.x before 2.5... | 2005-12-31T05:00:00.000 |
| [CVE-2005-3620](https://nvd.nist.gov/vuln/detail/CVE-2005-3620) | N/A |  | The management interface for VMware ESX Server 2.0.x before 2.0.2 patch 1, 2.1.x before 2.1.3 patch ... | 2005-12-31T05:00:00.000 |
| [CVE-2005-4773](https://nvd.nist.gov/vuln/detail/CVE-2005-4773) | N/A |  | The configuration of VMware ESX Server 2.x, 2.0.x, 2.1.x, and 2.5.x allows local users to cause a de... | 2005-12-31T05:00:00.000 |
| [CVE-2006-5990](https://nvd.nist.gov/vuln/detail/CVE-2006-5990) | N/A |  | VMWare VirtualCenter client 2.x before 2.0.1 Patch 1 (Build 33643) and 1.4.x before 1.4.1 Patch 1 (B... | 2006-11-21T01:07:00.000 |
| [CVE-2007-1270](https://nvd.nist.gov/vuln/detail/CVE-2007-1270) | N/A |  | Double free vulnerability in VMware ESX Server 3.0.0 and 3.0.1 allows attackers to cause a denial of... | 2007-04-06T00:19:00.000 |
| [CVE-2007-1271](https://nvd.nist.gov/vuln/detail/CVE-2007-1271) | N/A |  | Buffer overflow in VMware ESX Server 3.0.0 and 3.0.1 might allow attackers to gain privileges or cau... | 2007-04-06T00:19:00.000 |
| [CVE-2007-1069](https://nvd.nist.gov/vuln/detail/CVE-2007-1069) | N/A |  | The memory management in VMware Workstation before 5.5.4 allows attackers to cause a denial of servi... | 2007-05-02T19:19:00.000 |
| [CVE-2007-1056](https://nvd.nist.gov/vuln/detail/CVE-2007-1056) | N/A |  | VMware Workstation 5.5.3 build 34685 does not provide per-user restrictions on certain privileged ac... | 2007-02-21T23:28:00.000 |
| [CVE-2006-6410](https://nvd.nist.gov/vuln/detail/CVE-2006-6410) | N/A |  | Buffer overflow in an ActiveX control in VMWare 5.5.1 allows local users to execute arbitrary code v... | 2006-12-10T02:28:00.000 |
| [CVE-2007-0832](https://nvd.nist.gov/vuln/detail/CVE-2007-0832) | N/A |  | VMware Workstation 5.5.3 34685 does not immediately change the availability of a shared clipboard wh... | 2007-02-07T22:28:00.000 |
| [CVE-2007-0833](https://nvd.nist.gov/vuln/detail/CVE-2007-0833) | N/A |  | VMware Workstation 5.5.3 34685, when the "Enable copy and paste to and from this virtual machine" op... | 2007-02-07T22:28:00.000 |
| [CVE-2003-0480](https://nvd.nist.gov/vuln/detail/CVE-2003-0480) | N/A |  | VMware Workstation 4.0 for Linux allows local users to overwrite arbitrary files and gain privileges... | 2003-08-07T04:00:00.000 |
| [CVE-2003-0631](https://nvd.nist.gov/vuln/detail/CVE-2003-0631) | N/A |  | VMware GSX Server 2.5.1 build 4968 and earlier, and Workstation 4.0 and earlier, allows local users ... | 2003-08-27T04:00:00.000 |
| [CVE-2003-0739](https://nvd.nist.gov/vuln/detail/CVE-2003-0739) | N/A |  | VMware Workstation 4.0.1 for Linux, build 5289 and earlier, allows local users to delete arbitrary f... | 2003-10-20T04:00:00.000 |
| [CVE-2002-0814](https://nvd.nist.gov/vuln/detail/CVE-2002-0814) | N/A |  | Buffer overflow in VMware Authorization Service for VMware GSX Server 2.0.0 build-2050 allows remote... | 2002-08-12T04:00:00.000 |
| [CVE-1999-0733](https://nvd.nist.gov/vuln/detail/CVE-1999-0733) | N/A |  | Buffer overflow in VMWare 1.0.1 for Linux via a long HOME environmental variable. | 1999-06-26T04:00:00.000 |
| [CVE-2000-0090](https://nvd.nist.gov/vuln/detail/CVE-2000-0090) | N/A |  | VMWare 1.1.2 allows local users to cause a denial of service via a symlink attack. | 2000-01-17T05:00:00.000 |
| [CVE-2001-1059](https://nvd.nist.gov/vuln/detail/CVE-2001-1059) | N/A |  | VMWare creates a temporary file vmware-log.USERNAME with insecure permissions, which allows local us... | 2001-07-30T04:00:00.000 |
| [CVE-2003-1291](https://nvd.nist.gov/vuln/detail/CVE-2003-1291) | N/A |  | VMware ESX Server 1.5.2 before Patch 4 allows local users to execute arbitrary programs as root via ... | 2003-12-31T05:00:00.000 |
| [CVE-2005-4459](https://nvd.nist.gov/vuln/detail/CVE-2005-4459) | N/A |  | Heap-based buffer overflow in the NAT networking components vmnat.exe and vmnet-natd in VMWare Works... | 2005-12-21T20:03:00.000 |
| [CVE-2005-4583](https://nvd.nist.gov/vuln/detail/CVE-2005-4583) | N/A |  | Unspecified vulnerability in the Management Interface in VMware ESX Server 2.x up to 2.5.x before 24... | 2005-12-29T11:03:00.000 |
| [CVE-2005-3618](https://nvd.nist.gov/vuln/detail/CVE-2005-3618) | N/A |  | Cross-site request forgery (CSRF) vulnerability in the management interface for VMware ESX Server 2.... | 2005-12-31T05:00:00.000 |
| [CVE-2005-4082](https://nvd.nist.gov/vuln/detail/CVE-2005-4082) | N/A |  | The dhcp.client program for QNX 4.25 vmware is setuid, possibly by default, which allows local users... | 2005-12-08T01:03:00.000 |
| [CVE-2004-2515](https://nvd.nist.gov/vuln/detail/CVE-2004-2515) | N/A |  | Format string vulnerability in VMware Workstation 4.5.2 build-8848, if running with elevated privile... | 2004-12-31T05:00:00.000 |
| [CVE-2005-0444](https://nvd.nist.gov/vuln/detail/CVE-2005-0444) | N/A |  | VMware before 4.5.2.8848-r5 searches for gdk-pixbuf shared libraries using a path that includes the ... | 2005-02-14T05:00:00.000 |
| [CVE-2005-2939](https://nvd.nist.gov/vuln/detail/CVE-2005-2939) | N/A |  | Unquoted Windows search path vulnerability in VMWare Workstation 5.0.0 build-13124 might allow local... | 2005-11-18T06:03:00.000 |

---

## 5. Recommended Action Plan

| Priority | Action | Reference |
|----------|--------|-----------|
| :red_circle: Critical | Upgrade vCenter 8.0u3f -> 8.0u3g/h/i/j | VMSA-2025-0014 |
| :red_circle: Critical | Upgrade NSX 4.0.x -> 4.1.2.7+ | VMSA-2025-0016 |
| :red_circle: Critical | Patch SDDC 9.0 -> EP2, SDDC 9.1 -> 9.1.0.0 | VMSA-2026-0004 |
| :red_circle: Critical | Update GLPI to 11.0.8+ (16 flaws fixed Jun 2026) | GLPI Security Advisories |
| :red_circle: Critical | Update Gitea to 1.26.2+ (multiple critical auth bypass CVEs) | Gitea Security Advisories |
| :red_circle: Critical | Update OpenCode to 1.1.10+ (CVE-2026-22813 XSS -> RCE) | GHSA-c83v-7274-4vgp |
| :red_circle: Critical | Update GitHub Enterprise Server to latest 3.22.x | GHES Release Notes |
| :yellow_circle: High | Upgrade ESXi 8.0u3f -> 8.0u3j | ESXi Patch Tracker |
| :yellow_circle: High | Apply PowerBI Feb 2026 security update (CVE-2026-21229 RCE) | MSRC Security Update |
| :yellow_circle: High | Update KNIME to 5.2.0+ (XSS sanitization default) | KNIME Security Advisories |
| :yellow_circle: High | Check CISA KEV catalog | cisa.gov/known-exploited-vulnerabilities-catalog |
| :green_circle: Medium | Monitor Broadcom advisories regularly | Broadcom Security Portal |
| :red_circle: Critical | Apply SQL Server 2025 CU3+/CU4+ (CVE-2026-40370/21262/26115/26116) | MSRC Security Update Guide |
| :red_circle: Critical | Patch SSRS for CVE-2020-0618 (CISA KEV, actively exploited) | MSRC CVE-2020-0618 |
| :yellow_circle: High | Update SQL Server 2022 to CU22+ GDR (CVE-2026-20803) | MSRC Security Update |
| :yellow_circle: High | Apply latest SSAS security updates (part of SQL Server CU) | MSRC Security Update Guide |
| :green_circle: Medium | Verify AionUI version (no known CVEs) | github.com/iOfficeAI/AionUi |
| :green_circle: Medium | Verify Graphify version (no known CVEs) | graphify.ai |

### Quick Reference Links
- CVE.org: https://www.cve.org
- NVD Search: https://nvd.nist.gov/vuln/search
- Broadcom Security: https://support.broadcom.com/web/ecx/security-advisory
- ESXi Patch History: https://esxi-patches.v-front.de/
- CISA KEV: https://www.cisa.gov/known-exploited-vulnerabilities-catalog
- Microsoft Security: https://msrc.microsoft.com/update-guide
- GLPI Advisories: https://github.com/glpi-project/glpi/security/advisories
- Gitea Advisories: https://github.com/go-gitea/gitea/security/advisories
- OpenCode Advisories: https://github.com/anomalyco/opencode/security/advisories
- KNIME Advisories: https://www.knime.com/security/advisories
- SQL Server Build List: https://aka.ms/sqlserverbuilds
- OpenCVE: https://app.opencve.io

---

*Generated: 2026-07-13 10:40*
*Data source: NVD NIST API, CVE MITRE, vendor security advisories*
*CVE system managed by MITRE. More info: https://www.cve.org | https://nvd.nist.gov*


# Repository:
*NFS 4, SMB, CIFS, Ceph, S3C, S3D for GitEA (Git On-prem for DevSecOps)*

## NFS 4 on Windows Server 2019 Std/DC:
1.1. Configure NFS Shared Folder. (Quick)
*For example on here, create a shared folder with Host based access permission.*
*On CUI Configuration, Set like follows.*

Step 1. Run PowerShell with Admin Privilege and Configure NFS Server:

```ps
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

# create NFS Shared Folder
PS C:\Users\Administrator> mkdir C:\NFSshare

    Directory: C:\


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         12/5/2024   4:42 PM                NFSshare

# set NFS Share
PS C:\Users\Administrator> New-NfsShare -Name "NFSshare01" `
-Path "C:\NFSshare" `
-EnableUnmappedAccess $True `
-Authentication Sys 

Name       Availability             Path
----       ------------             ----
NFSshare01 Standard (not clustered) C:\NFSshare

# grant Read/Write access permission to a Host 10.0.0.110
PS C:\Users\Administrator> Grant-NfsSharePermission -Name "NFSshare01" `
-ClientName "10.0.0.110" `
-ClientType "host" `
-Permission "readwrite" `
-AllowRootAccess $True 

# confirm settings
PS C:\Users\Administrator> Get-NfsShare -Name "NFSshare01" 

Name       Availability             Path
----       ------------             ----
NFSshare01 Standard (not clustered) C:\NFSshare

PS C:\Users\Administrator> Get-NfsSharePermission -Name "NFSshare01" 

Name       ClientName   Permission  AllowRootAccess
----       ----------   ----------  ---------------
NFSshare01 10.0.0.110   READ, WRITE True
NFSshare01 All Machines DENY ACCESS False
```
--
## 1.2. NFS Server : Configure NFS Shared Folder (GUI)
*On GUI Configuration, Set like follows.*

Step 2. Run Server Manager and Click [File and Storage Services].
[2]	Select [Shares] on the left pane and click [TASKS] - [New Share...].

[3]	On this example, select [NFS Share - Quick].

[4]	On this example, Configure a specific folder as shared one, so check a box [Type a custom path] and input the path for specific folder you'd like to set as shared folder.

[5]	Input Share Name, Local and Remote Share Path.

[6]	Specify authentication methods. On this example, set like follows.

[7]	Set the Share permissions. Click [Add...] button.

[8]	Specify the Hosts you'd like to grant access permissions.

[9]	Confirm settings and Click [Next] button.

[10]	This is the permission setting. Check the contents and add settings if you need.

[11]	Confirm selections and it's no ploblem, Click [Create] button.

[12]	After finishing creating, Click [Close] button.

[13]	NFS shared folder has been just configured.
--
## 1.3. NFS Server : Install NFS Client:
*Install NFS Client.
*On CUI Installation, Set like follows.

[1]	Run PowerShell with Admin Privilege and Install NFS Client.
```ps
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

# install NFS Client
PS C:\Users\Administrator> Install-WindowsFeature NFS-Client 

Success Restart Needed Exit Code      Feature Result
------- -------------- ---------      --------------
True    No             Success        {Client for NFS}
```
--
1.4. NFS Server : Install NFS Client (GUI)
*On GUI Installation, Set like follows.

[2]	Run Server Manager and Click [Add roles and features].

[3]	Click [Next] button.

[4]	Select [Role-based or feature-based installation].

[5]	Select a Host which you'd like to add services.

[6]	Click [Next] button.

[7]	Check a box [Client for NFS] and go Next

[8]	Click [Install] button.

[9]	After finishing Installation, click [Close] button.

--
## 1.5. NFS Server : Connection from NFS Client
*This is How to connect to NFS Server from NFS Client.
*On this example, connect to the NFS Share like this configuration from a Client.

[1]	Run PowerShell with Admin Privilege on the NFS Client that you set access permission to connect on NFS Server settings.

For the setting of the example of link above (Quick NFS Share), it's possible to mount and read/write with any user from the Hosts you added in access permission on the NFS server.

For mount commands, it's possbile to mount NFS Share with the command [C:\Windows\system32\mount.exe] that is installed by NFS Client installation, or also possible to use PowerShell Cmdlet [New-PSDrive] command.

On PowerShell by default, [mount] command is set Alias to [New-PSDrive] command, so if use [mount] command, specify full name of the filename [mount.exe].

```ps
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

# mount with [mount.exe] on Z drive
# syntax is the same with [mount] command on Linux
PS C:\Users\Serverworld> mount.exe 10.0.0.101:/nfsshare01 Z:\ 
Z: is now successfully connected to 10.0.0.101:/nfsshare01

The command completed successfully.

PS C:\Users\Serverworld> Get-PSDrive Z 

Name           Used (GB)     Free (GB) Provider      Root                            CurrentLocation
----           ---------     --------- --------      ----                            ---------------
Z                  13.37         85.85 FileSystem    \\10.0.0.101\nfsshare01

# verify reading and writing
PS C:\Users\Serverworld> echo "write test" > Z:\testfile.txt 
PS C:\Users\Serverworld> Get-Content Z:\testfile.txt 
write test

# for unmount, run like follows
PS C:\Users\Serverworld> umount.exe Z:\ 

Disconnecting           Z:      \\10.0.0.101\nfsshare01
The command completed successfully.

# mount with [New-PSDrive] on Z drive
PS C:\Users\Serverworld> New-PSDrive -Name Z -PSProvider FileSystem -Root "\\10.0.0.101\nfsshare01" 

Name           Used (GB)     Free (GB) Provider      Root                                                                 CurrentLocation
----           ---------     --------- --------      ----                                                                 ---------------
Z                                      FileSystem    \\10.0.0.101\nfsshare01

# unmount, run like follows
PS C:\Users\Serverworld> Remove-PSDrive Z 
```
--
## 1.6. NFS Server : Simple user mapping to Linux
If you want to set simple user mapping when using NFS between Windows and Linux in a non-Active Directory domain environment, configure as follows.

[1]	Check the user/group information on the Linux side.
```ts
root@dlp:~# cat /etc/passwd 

.....
.....
ubuntu:x:1000:1000:ubuntu:/home/ubuntu:/bin/bash
debian:x:1001:1001:,,,:/home/debian:/bin/bash
redhat:x:1002:1002:,,,:/home/redhat:/bin/bash

root@dlp:~# cat /etc/group 

.....
.....
users:x:100:debian,redhat
ubuntu:x:1000:
debian:x:1001:
redhat:x:1002:
```
[2]	On the Windows side, create a file for simple mapping.
```ps
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

PS C:\Users\Serverworld> New-Item C:\Windows\System32\drivers\etc\passwd 


    Directory: C:\Windows\System32\drivers\etc


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         12/5/2024   8:23 PM              0 passwd


PS C:\Users\Serverworld> New-Item C:\Windows\System32\drivers\etc\group 


    Directory: C:\Windows\System32\drivers\etc


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         12/5/2024   8:23 PM              0 group

# for example, map user winuser01 ⇔ debian
PS C:\Users\Serverworld> Add-Content C:\Windows\System32\drivers\etc\passwd `
"winuser01:x:1001:1001:debian::"

# for example, map user winuser02 ⇔ redhat
PS C:\Users\Serverworld> Add-Content C:\Windows\System32\drivers\etc\passwd `
"winuser02:x:1002:1002:redhat::"

# for example, map group BUILTIN\Users ⇔ users
PS C:\Users\Serverworld> Add-Content C:\Windows\System32\drivers\etc\group `
"BUILTIN\Users:x:100:users"

# for example, map group BUILTIN\Users ⇔ debian
PS C:\Users\Serverworld> Add-Content C:\Windows\System32\drivers\etc\group `
"BUILTIN\Users:x:1001:debian"

# for example, map group BUILTIN\Users ⇔ redhat
PS C:\Users\Serverworld> Add-Content C:\Windows\System32\drivers\etc\group `
"BUILTIN\Users:x:1002:redhat"
[3]	Set the access permission so that each user can access the folder.
# for Windows NFS servers, grant read and execute permissions to Everyone on the root folder of the NFS share
PS C:\Users\Serverworld> icacls C:\nfsshare01 /grant "Everyone:(NP)(RX)" 
processed file: C:\nfsshare01
Successfully processed 1 files; Failed processing 0 files


# whether the NFS server is Windows or Linux, create a dedicated folder that each user can access in advance

# Windows NFS server
# * winuser01 ⇔ debian can access
PS C:\Users\Serverworld> mkdir C:\nfsshare01\winuser01 
PS C:\Users\Serverworld> icacls C:\nfsshare01\winuser01 /setowner winuser01 
processed file: C:\nfsshare01\winuser01
Successfully processed 1 files; Failed processing 0 files
```

## Linux NFS server
* winuser02 ⇔ redhat can access

```ts
root@dlp:~# mkdir /home/nfsshare/redhat 
root@dlp:~# chown redhat:redhat /home/nfsshare/redhat 
```
[4]	Log in to the Linux client as the configured user and check the mapping to the Windows NFS server.
```debian
root@dlp:~# mount -t nfs 10.0.0.101:/nfsshare01 /mnt 
root@dlp:~# su - debian 

debian@dlp:~$ ll /mnt 
total 5
drwxr-xr-x  2 4294967294 4294967294   64 Dec  6 06:07 ./
drwxr-xr-x 23 root       root       4096 Apr 26  2024 ../
drwx------  2 debian     4294967294   64 Dec  6 06:07 winuser01/

debian@dlp:~$ echo test > /mnt/winuser01/testfile.txt 
debian@dlp:~$ ll /mnt/winuser01 
total 2
drwx------ 2 debian     4294967294 64 Dec  6 06:08 ./
drwxr-xr-x 2 4294967294 4294967294 64 Dec  6 06:07 ../
-rw-rw-r-- 1 debian     debian      5 Dec  6 06:08 testfile.txt
```
[5]	Sign in to a Windows client with the configured user and check the mapping to the Linux NFS server.
```ps
PS C:\Users\winuser02> mount.exe 10.0.0.30:/home/nfsshare Z:\ 
PS C:\Users\winuser02> Get-ChildItem Z:\ 
    Directory: Z:\
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         12/5/2024   9:51 PM                redhat
PS C:\Users\winuser02> Add-Content Z:\redhat\testfile.txt "test file" 
PS C:\Users\winuser02> Get-ChildItem Z:\redhat 

    Directory: Z:\redhat
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         12/5/2024  10:10 PM             11 testfile.txt

PS C:\Users\winuser02> ssh redhat@10.0.0.30 "ls -l /home/nfsshare/redhat" 
redhat@10.0.0.30's password:
total 4
-rw-r--r-- 1 redhat redhat 11 Dec  6 06:10 testfile.txt
```

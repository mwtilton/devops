# DEV vAPP  

## Fresh Template Install  
--Create VM in Vcloud  
--Change ETH adapter to VMXnet 3  
--Load with ISO (ex. Win 2016)  
--PowerOn  
--Run through `Datacenter 2016 (Desktop Experience)` installation process  
--Create administrator account  
--Login into new VM  
--Install Wmware tools  
`win + d:`  
`enter`  
--REBOOT  
--Remove VMware tools CD  
--Remove IE enhanced security  
--Set Temp IP information  

[ ] Add start-service for windows search to prepRebuild  
[ ] Add `Hidden` and `Extension` options from File/Folders to prepRebuild  
[ ] `Enable-PSremoting -force`  
[ ] Enable/Allow RDP  
[ ] Enable WinRM on server with firewall rules  
`COM+ Network Access (DCOM-In)`  
`remote Event Log Management (NP-In)`  
`remote Event Log Management (RPC)`  
`remote Event Log Management (RPC-EPMAP)`  

--Run Windows Updates before sysprep (1 restart)  
--disk cleanup wizard with system files selected  
--Sysprep to shutdown  
`Set-Location C:\Windows\System32\Sysprep`  
`.\sysprep.exe /generalize /oobe /shutdown`  
--Save Template  

# DEV vAPP Template  
[X] Change VCD to DNAT to new STATIC IP  
[X] BOOT ALL VM's Pre-Rebuild  
--DON'T POWER OFF THROUGH THE GUEST OS ANYMORE  

## DEV vAPP DC  
**DO NOT RUN FROM ISE**  
[X] Set Temp IP  
[X] Enable RDP  
[X] Run prepRebuild on DC  
[X] Add Nmap installation  
[X] Need sleep timer or something to open both pages at once, with ";"??  
[X] Install Nmap  
[X] REBOOT after prepRebuild installation  
[X] Continue prepRebuild on DC  
[X] Run prepDC  
[X] Needs to pull in all DSC modules  
[X] With corrected versions  
[X] Run BuildDC  
REBOOT  

## Run buildRemote  
**From DC**  
[ ] nmap [slow comprehensive scan] [the subnet]  
[ ] run buildRemote  
`C:\Windows\System32\Drivers\Etc\HOSTS`
`WINRM set winrm/config/client â€˜@{TrustedHosts="EOT-WEB"}â€™`  

## FileServer deployment  
**Only after DC is done and built**  
--Set Temp IP  
--Enable RDP  
--Set Firewall Settings  
--`Enable-PSremoting -Force` until new template is built out  
[ ] Create Folders then associate shares to them  
[ ] Change reboot param on buildFS to not reboot auto  

## APP Servers  
**ONLY AFTER YOU BUILD THE DC**  
--Set Temp IP  
--Enable RDP  
--Set Firewall Settings  
--`Enable-PSremoting -Force` until new template is built out  



# SAVE DEV vAPP BEFORE RDS integration testing  
--DEV Saved 9/25/18  

## RDS Deployment  
**After DC and all VMâ€™s are booted up and running**  
--prep RDS  
[ ] Fix prompt for Collection information  
--Setup script for server locations to app01/02/fileserver locations  
--UPD file location: \\fileserver01\Users$  
--UserGroups: democloud\Domain Admins  
Democloud\RD Users  

#### Setting up IIS/RDWeb  
--Need to setup password resets on RDweb  
https://social.technet.microsoft.com/wiki/contents/articles/10755.windows-server-2012-rds-enabling-the-rd-webaccess-expired-password-reset-option.aspx  
--Need to setup redirect to main RDweb page on https://democloud.website.com entry  

#### DSC Force Removal - For INTEGRATION TESTING  
--absent to all options  

### Features  
[ ] Need DSC for Volume activation Tools  

### Setup still needed for template  
[?] install O365 stuff here??? Or file server???  

# YK Main  

## YK-DC01 - Template  
Normal RDP  
Vmware Tools  
Updates as of Aug 2018  

--Need to hardset/configure IP addresses after bootup as well  
--Indexing setup  
--Git installed and devops pulled  

--Ran sysprep to shutdown  
--Installed git  
--auto delayed start for windows search  
--added repo  
--changed files  
--ran prep  
--ran build DC  
--Get-DSCConfigurationStatus  
**DO NOT OVERWRITE THIS**  
[ ] No activation  
[ ] Requires Rebuild  


## YK-SqlServer  
### SQL Install  
1.	Install SQL Server Express Edition 2017  
2.	Install media to folder %downloads%  
    a.	Select New SQL install  
    b.	Use Microsoft updates  
    c.	Instance: SQLExpress  
    d.	SQL server browser to automatic  
    e.	Setup SA account pw  
    f.	Install R  
    g.	Install Python  
    h.	Installation completion process  
3.	Install SQL SMS 17.8.1  
4.	Download setup file from internet redirect  

### SQL setup for Firewall  
Ports 1433 49172 TCP  
1434 UDP  

```$cred = get-credential```  
```Invoke-Sqlcmd -ServerInstance 10.1.1.5\sqlexpress -Database Tickets -Query "Select * from Tickets" -credential $cred```  

### Setup  
[ ] Need script to open up firewall to correct ports for SQL  

# DEV vAPP Rebuild  
## Pre- vAPP Rebuild  
--shutdown remote pcs  
--Full Power off in VCD  

## Post Power-On/Rebuild checks  
--RDP  
--Server Manager (Servers are up)  
--nmap [the subnet] â€“F -Pn  

# General Features  
[X] Need to lookup powershell options for indexing servers auto matically from DSC  
[ ] Cred check on buildS  
  -- Created Get-CredCheck function  
[ ] Remotely configure from DC or Push updates to servers  
[X] Add vscode default to setupGit and enforcing it as editor  
[X] Change prepGit to prep rebuild  
[ ] Upgrade all Modules to latest working versions  
[ ] Find Latest Versions for modules  
[ ] Firewall Rules for WinRM  
[ ] Disabled firewall rules after installation  
[ ] Add force module import to all  

# GPT HDD Failures  
`[-]Set HDD to "LSI Logic SAS"`  
`[-]Set HDD to "ParaVirtual"`  
`[-]Set HDD to "SATA"`  
`[-]converting GPT at installation`  
`[?]converting to GPT after installation with two disks and moving pagesys file`  
`[-]EFI Boot hass issues with select the virutal disk need to rebuild from scratch`  

# Notes for VCloud ENV setup  
[X] DNS in Org VDC Networks  
[X] Use static IP Pool and not manual  
[X] RDP gateway 3391 UDP  

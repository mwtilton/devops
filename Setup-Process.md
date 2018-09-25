#DEV vAPP  

##Fresh Template Install  
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
--Set Temp IP information  
[X] Run Windows Updates before sysprep (1 restart)  
--disk cleanup wizard with system files selected  
--Sysprep to shutdown  
`Set-Location C:\Windows\System32\Sysprep`  
`.\sysprep.exe /generalize /oobe /shutdown`  
--Save Template  

###DEV vAPP Template  
[ ] Enable RDP  
[ ] Install Git  
`Defaults v2.19.0`  
`Windows CLI`  
--Enable-PSremoting  
--Need to remove IE enhanced security  
[-] IP changes do not hold after Rebuild power on  
[-] Windows Search doesn't hold after rebuild  
[+] VMWare tools does hold after Rebuild  
[ ] CHECK ALL SLEEP/POWER RELATED SETTINGS  
--Run Disable Powersettings  
--BOOT ALL VM's Pre-Rebuild  
--DON'T POWER OFF THROUGH THE GUEST OS ANYMORE  

##DEV vAPP DC  
-- Set IP with 8.8.8.8 for initial DNS server  
-- Change VCD to DNAT to new STATIC IP  
[X] Enable RDP into BoX  
[X] Enable RDP Firewall settings  
--RDP into the box  
[-] CredSSIP Error  


[X] File/Folder Options  
[ ] Script to run this automatically -- add to prepRebuild  
`Hidden Folders`  
`File extensions`  
[X] Windows Search  
##DO NOT RUN FROM ISE  
--Run prepRebuild  

[X] Need to install Firefox  
[X] Set Firefox as default  
[X] pin Firefox to taskbar  

[?] Keeping DNS Zones to 3.168.192 but those are the same as the servers IP addresses...  

--Run prepDC  
--Run BuildDC  
REBOOT  

##FileServer deployment  
--Webconsole into fileserver01  
--Enable RDP  
--Run prepFileServer w/ update help –erroraction sil con  
--Run buildFileServer w/ ip information  
[ ] Create Folders then associate shares to them  
[ ] Change reboot param on buildFS to not reboot auto  

##APP Servers  
**ONLY AFTER YOU BUILD THE DC AND Fileserver**  
--Enable RDP  
--Run prepServer w/ update help –erroraction sil con  
--Run buildServer w/ ip information  


##RDS Deployment  
**After DC and all VM’s are booted up and running**  
--prep RDS  
[ ] Fix prompt for Collection information  
--Setup script for server locations to app01/02/fileserver locations  
--UPD file location: \\fileserver01\Users$  
--UserGroups: democloud\Domain Admins  
Democloud\RD Users  

####Setting up IIS/RDWeb  
--Need to setup password resets  
https://social.technet.microsoft.com/wiki/contents/articles/10755.windows-server-2012-rds-enabling-the-rd-webaccess-expired-password-reset-option.aspx  

####DSC Force Removal - For INTEGRATION TESTING  
--absent to all options  

###Features  
[ ] Need DSC for Volume activation Tools  


###Setup still needed for template  
[?] install O365 stuff here??? Or file server???  
[ ] Allowing indexing from files and contents on APP01  
[ ] Need to rebuild APP01 to fix IP address issues  
[ ] Rebuild/Check App01 for IP issues  



#YK Main  

##YK-DC01 – Template  
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


##YK-SqlServer  
###SQL Install  
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

###SQL setup for Firewall  
Ports 1433 49172 TCP  
1434 UDP  

```$cred = get-credential```  
```Invoke-Sqlcmd -ServerInstance 10.1.1.5\sqlexpress -Database Tickets -Query "Select * from Tickets" -credential $cred```  

###Setup  
[ ] Need script to open up firewall to correct ports for SQL  

#DEV vAPP Rebuild  
##Pre- vAPP Rebuild  
[ ] shutdown remote pcs  
[ ] Full Power off in VCD  

##Post Power-On/Rebuild checks  
--RDP  
--Server Manager (Servers are up)  
--nmap [the subnet] –F -Pn  

#General Features  
[ ] Need to lookup powershell options for indexing servers auto matically from DSC  
[ ] Cred check on buildS  
  -- Created Get-CredCheck function  
[ ] Remotely configure from DC or Push updates to servers  

#GPT HDD Failures  
`[-]Set HDD to "LSI Logic SAS"`  
`[-]Set HDD to "ParaVirtual"`  
`[-]Set HDD to "SATA"`  
`[-]converting GPT at installation`  
`[?]converting to GPT after installation with two disks and moving pagesys file`  
`[-]EFI Boot hass issues with select the virutal disk need to rebuild from scratch`  

#Notes for VCloud ENV setup  
[ ] DNS in Org VDC Networks  
[X] Use static IP Pool and not manual  
[X] RDP gateway 3391 UDP  
[ ] Add vscode default to setupGit and enforcing it as editor  
[X] Change prepGit to prep rebuild  

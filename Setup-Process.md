# What is DevOps  
Holder of all things DevOps related  
Authored by mwtilton  

#DEV vAPP  

##Fresh Template Install  
--Create VM in Vcloud  
--Load with ISO (ex. Win 2016)  
--Run through `Datacenter 2016 (Desktop Experience)` installation process  
--Create administrator account  
--Login into new VM  
--Install Wmware tools  
`win + d:`  
`enter`  

--Remove VMware tools CD  
--disk cleanup wizard  
[ ] Folder Options
`Hidden Folders`
`File extensions`
--Sysprep to shutdown  

###GPT HDD Failures  
`[-]Set HDD to "LSI Logic SAS"`  
`[-]Set HDD to "ParaVirtual"`  
`[-]Set HDD to "SATA"`  
`[-]converting GPT at installation`  
`[?]converting to GPT after installation with two disks and moving pagesys file`  
`[-]EFI Boot hass issues with select the virutal disk need to rebuild from scratch`  

##DEV vAPP DC  
X Set IP to 8.8.8.8 for initial DNS server  
X Need to remove IE enhanced security  
X Need to set folder options for admin user  
X Need to setup indexing  
X Need to install Firefox  
X Need to install Git  
X Make Github dir  
--Installed new git cred manager 2.19  
--Ran updates 8/29/18  

[?]REBOOT – Git doesn’t seem to take effect after install  
X Pull in Devops Git  
--Set build scripts to domain adherent setup status  
X xDNSServer*Zones  
[?] Keeping DNS Zones to 3.168.192 but those are the same as the servers IP addresses...  
X Uncomment out MyAccount  
X Set myaccount to personal account in all places  

--Run prepDC  
--Run BuildDC  
REBOOT  

###RDS Deployment  
**After DC and all VM’s are booted up and running**  
--prep RDS  
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


##APP Servers  
**ONLY AFTER YOU BUILD THE DC**  
--Run Prep server w/ update help –erroraction sil con  
--RunConfigureserver w/ ip information  

###Setup still needed for template  
[?] install O365 stuff here??? Or file server???  
[ ] Allowing indexing from files and contents on APP01  
[ ] Need to rebuild APP01 to fix IP address issues  
[ ] Rebuild/Check App01 for IP issues  

##FileServer deployment  
--Run prepFileServer w/ update help –erroraction sil con  
--Run buildFileServer w/ ip information  
[ ] Set up shares and ACL  




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
##Post Power-On/Rebuild checks  
--RDP  
--Server Manager (Servers are up)  
--nmap [the subnet] –F -Pn  

##prep-Rebuild  
--shutdown remote pcs  

#General Features
[ ] Need to lookup powershell options for indexing servers auto matically from DSC  
[ ] Cred check on buildS

#GPO Migration tool

##Requires
 1. v5.1 in Powershell
 2. Need Domain Admin rights access for these scripts to work and powershell v5.1

3. Need CSV file like this
   * Needs to be exact match Since it is a Regex search.
'''
\nSource,Destination,Type
\n"olddomain.local","newdomain.local","Domain"
\n"olddomain","newdomain","Domain"
\n"\\olddomain.local\","\\newdomain.local\","UNC"
\n"\\olddomain\","\\newdomain\","UNC"
'''
#Export Process
##On Template Domain
Run Call-DCExport.ps1
Run Call-FilesFoldersExport.ps1
Run Call-GPOExport.ps1

#Import Process
##On Import Domain
Run Call-DCImport.ps1
Run Call-FilesFoldersImport.ps1
Run Call-GPOImport.ps1

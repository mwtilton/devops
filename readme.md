#GPO Migration tool

##Requires
 1. v5.1 in Powershell
 2. Need Domain Admin rights access for these scripts to work and powershell v5.1

3. Need CSV file like this
    Needs to be exact match Since it is a Regex search.
'''
        Source,Destination,Type
        "olddomain.local","newdomain.local","Domain"
        "olddomain","newdomain","Domain"
        "\\olddomain.local\","\\newdomain.local\","UNC"
        "\\olddomain\","\\newdomain\","UNC"
'''

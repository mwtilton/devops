$OU = "Admin","Executive","HR","Marketing","Ops Manager","Service Accounts","Supervisor"
$ou | ForEach-Object {
    New-ADOrganizationalUnit -name $_ -Path "OU=DemoCloud,DC=democloud,DC=local"
}

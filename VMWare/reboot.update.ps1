$EsxCli = Get-EsxCli -VMHost 10.20.1.36 -V2
$FWRules = $EsxCli.network.firewall.ruleset
$FWArgs = $FWRules.set.CreateArgs()
$FWArgs.enabled = $True
$FWArgs.rulesetid = 'httpClient'
$FWRules.set.invoke($FWArgs)

$UpdateArgs = $EsxCli.software.profile.update.createargs()
$UpdateArgs.depot = 'https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml'
$UpdateArgs.profile = 'ESXi-5.5.0-20170904001-standard'
$EsxCli.software.profile.update.invoke($UpdateArgs)

$FWArgs.enabled = $False
$FWRules.set.invoke($FWArgs)
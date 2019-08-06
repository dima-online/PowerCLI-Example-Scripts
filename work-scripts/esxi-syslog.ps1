connect-viserver -Server vcenter.kazpost.kz 

foreach($esxi in (Get-Cluster -Name TEST | Get-VMHost )){
 
		Write-host "Processing on" $esxi
		#Set the Syslog Server
		$esxi | Get-AdvancedSetting -Name Syslog.global.logHost | Set-AdvancedSetting -Value "udp://syslog.kazpost.kz:514"  -Confirm:$false -WhatIf:$false
 
		#Restart the syslog service
		$esxcli = Get-EsxCli -VMHost $esxi
		$esxcli.system.syslog.reload()
 
		#Open firewall ports
		Get-VMHostFirewallException -Name "syslog" -VMHost $esxi | set-VMHostFirewallException -Enabled:$true
  }

Get-VM | Get-CDDrive | Where {$_.ISOPath -ne $null} | Set-CDDrive -NoMedia -Confirm:$false



  
connect-viserver -Server vcenter.kazpost.kz 
 
foreach($esxi in (Get-VMHost)){
  
#Configure NTP server
Add-VmHostNtpServer -VMHost $esxi -NtpServer "192.168.14.233"
Add-VmHostNtpServer -VMHost $esxi -NtpServer "172.16.0.24"
#Allow NTP queries outbound through the firewall
Get-VMHostFirewallException -VMHost $esxi | where {$_.Name -eq "NTP client"} | Set-VMHostFirewallException -Enabled:$true
#Start NTP client service and set to automatic
Get-VmHostService -VMHost $esxi | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService
Get-VmHostService -VMHost $esxi | Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "automatic"

}


connect-viserver -Server vcenter.kazpost.kz 

$hosts = @("172.30.73.239","172.30.73.9","esxshm2.kazpost.kz")
#$hosts = @("esxi26.kazpost.kz")

foreach ($hostname in $hosts) {
Write-host "Processing on" $hostname
Set-HTAwareMitigationSuppression -VMHostName $hostname -Enable

$esxi = Get-VMHost -Name $hostname
#Set the Syslog Server
$esxi | Get-AdvancedSetting -Name Syslog.global.logHost | Set-AdvancedSetting -Value "udp://syslog.kazpost.kz:514"  -Confirm:$false -WhatIf:$false

get-scsilun  -VMHost $esxi -LunType disk | where-object {$_.multipathpolicy -eq "Mostrecentlyused" -and $_.CapacityGB -gt 5000 } | Set-ScsiLun -MultipathPolicy "roundrobin"
get-scsilun  -VMHost $esxi -LunType disk | where-object {$_.multipathpolicy -eq "Fixed" -and $_.CapacityGB -gt 5000 } | Set-ScsiLun -MultipathPolicy "roundrobin"
 
#Restart the syslog service
$esxcli = Get-EsxCli -VMHost $esxi
$esxcli.system.syslog.reload()
 
#Open firewall ports
Get-VMHostFirewallException -Name "syslog" -VMHost $esxi | set-VMHostFirewallException -Enabled:$true
#Configure NTP server
Add-VmHostNtpServer -VMHost $esxi -NtpServer "192.168.14.233"
Add-VmHostNtpServer -VMHost $esxi -NtpServer "172.16.0.24"
#Allow NTP queries outbound through the firewall
Get-VMHostFirewallException -VMHost $esxi | where {$_.Name -eq "NTP client"} | Set-VMHostFirewallException -Enabled:$true
#Start NTP client service and set to automatic
Get-VmHostService -VMHost $esxi | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService  -Confirm:$false -WhatIf:$false
Get-VmHostService -VMHost $esxi | Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "automatic"

Get-VmHostService -VMHost $esxi | Where-Object {$_.key -eq "TSM-SSH"} | Stop-VMHostService  -Confirm:$false -WhatIf:$false
Get-VmHostService -VMHost $esxi | Where-Object {$_.key -eq "TSM-SSH"} | Set-VMHostService -policy Off  -Confirm:$false -WhatIf:$false
Get-VmHostService -VMHost $esxi | Where-Object {$_.key -eq "TSM"} | Stop-VMHostService  -Confirm:$false -WhatIf:$false
Get-VmHostService -VMHost $esxi | Where-Object {$_.key -eq "TSM"} | Set-VMHostService -policy Off  -Confirm:$false -WhatIf:$false
}

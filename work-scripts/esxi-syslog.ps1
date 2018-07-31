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
$esxi = Get-VMHost -name esxi54.kazpost.kz
 
		Write-host "Processing on" $esxi
		#Set the Syslog Server
		$esxi | Get-AdvancedSetting -Name Syslog.global.logHost | Set-AdvancedSetting -Value "udp://syslog.kazpost.kz:514"  -Confirm:$false -WhatIf:$false
 
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
Get-VmHostService -VMHost $esxi | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService
Get-VmHostService -VMHost $esxi | Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "automatic"

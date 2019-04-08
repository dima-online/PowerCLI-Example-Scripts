connect-viserver -Server vcenter.kazpost.kz
Get-VM -Name 'Win 2012 - Stefi' | Set-VM -MemoryMB 12288 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'CentOS 7 - sczabbix.kazpost.kz' | Set-VM -MemoryMB 8192 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'Win 2008 - Ib DB2' | Set-VM -MemoryMB 20480 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'OREL - Hyper_NewDB' | Set-VM -MemoryMB 12288 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'Win 2016 - CSFR' | Set-VM -MemoryMB 6144 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'CentOS 7 - WF-test2_APP' | Set-VM -MemoryMB 12288 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'Debian - GPS_new' | Set-VM -MemoryMB 28672 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'Win 2003 - CARDS' | Set-VM -MemoryMB 4096 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'CentOS - Postmarket_Clone' | Set-VM -MemoryMB 2048 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'Debian 8 - Splunk srv-app' | Set-VM -MemoryMB 4096 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'Win 2003 - MPService_CPILS' | Set-VM -MemoryMB 4096 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'RHEL - SEDXPLORE' | Set-VM -MemoryMB 4096 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'CentOS 7 - Grafan' | Set-VM -MemoryMB 3072 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'Win 2012 - PresentCent' | Set-VM -MemoryMB 7168 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'CentOS 7 - TechnoServ IDa' | Set-VM -MemoryMB 4096 -RunAsync   -Confirm:$false -WhatIf:$false
Get-VM -Name 'RHEL - SEAPP' | Set-VM -MemoryMB 15360 -RunAsync   -Confirm:$false -WhatIf:$false


$pathDev ="D:\PowerShell\vcenter\gitlab\work-scripts\"

set-location $pathDev

$manager = Import-CSV D:\PowerShell\vcenter\gitlab\work-scripts\cpu.csv

ForEach ($item in $manager){

	$Name = $item.Name
	$core = $item.core
	$cpu = $item.cpu

	Write-Host ".... processing $Name"
    $vm = Get-VM -Name $item.Name
	Write-Host ".... set Cores p/s to  $core"
	$spec=New-Object –Type VMware.Vim.VirtualMAchineConfigSpec –Property @{“NumCoresPerSocket” = $core}
	($vm).ExtensionData.ReconfigVM_Task($spec)
	Write-Host ".... set CPU Sockets to $cpu"
	$vm | Set-VM -numcpu $cpu -RunAsync   -Confirm:$false -WhatIf:$false
} 

$vms = Get-VM -Name 'RHEL - *'| Where-Object {$_.powerstate -eq 'PoweredOn'} |?{$_.Extensiondata.Summary.Guest.ToolsVersionStatus -like 'guestToolsNeedUpgrade'} | select name,@{N='tools vers';E={$_.ExtensionData.Config.Tools.ToolsVersion}},@{N='Tools Status';E={$_.Extensiondata.Summary.Guest.ToolsVersionStatus}} | select -expandproperty Name

foreach ($vm in $vms) {
    update-tools $vm -noreboot -RunAsync
}

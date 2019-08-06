cls
Connect-VIServer "vcenter.kazpost.kz"
$BASEHost = Get-VMHost -Name "172.30.73.87"


 foreach($NEWHost in (Get-VMHost -Location Blade)){
	Write-host "Processing on" $NEWHost

	$BASEHost |Get-VirtualSwitch -Name "vSwitch0" |Foreach {
    If (($NEWHost |Get-VirtualSwitch -Name $_.Name-ErrorAction SilentlyContinue)-eq $null){
       Write-Host "Creating Virtual Switch $($_.Name)"
       $NewSwitch = $NEWHost |Get-VirtualSwitch -Name "vSwitch0"
	   Write-Host $NewSwitch.Name	   
       $vSwitch = $_
    }
       $NewSwitch = $NEWHost |Get-VirtualSwitch -Name "vSwitch0"
	   Write-Host $NewSwitch.Name	   
       $vSwitch = $_

	$_ |Get-VirtualPortGroup |Foreach {
       If (($NEWHost |Get-VirtualPortGroup -Name $_.Name-ErrorAction SilentlyContinue)-eq $null){
           Write-Host "Creating Portgroup $($_.Name)"
           $NewPortGroup = $NEWHost |Get-VirtualSwitch -Name $vSwitch |New-VirtualPortGroup -Name $_.Name-VLanId $_.VLanID
        }
    }
	}

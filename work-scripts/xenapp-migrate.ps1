connect-viserver -Server vcenter.kazpost.kz 
foreach($cluster in Get-Cluster -Name esxi_OLD){
  foreach($rp in (Get-View -ViewType resourcepool -Property Name -Filter @{'Name'="^XenApp Pool"} -SearchRoot (Get-Cluster $cluster).Id )){
	  foreach($vm in (get-vm -Location $rp.Name)){
		Write-host "Processing on" $vm

		if ($vm.Powerstate -eq "PoweredOn" -And $toolsStatus -ne "toolsNotInstalled"){                                                                                                                                      

		Write-host "Proceeding with task to shutdown " $vm

		#Shutting down Guest
		Write-host "Shutting Down Guest on " $vm

		$vm | Shutdown-VMGuest -Confirm:$false -WhatIf:$false

		$loops = 0
		do {	             
			#Check the power status
			$Status = $vm.Powerstate		                        
			Start-Sleep -Seconds 12
			$loops = $loops + 1
			$vm = Get-VM -Name $vm.Name
		}until($vm.Powerstate -eq "PoweredOff" -Or $loops -gt 20)
		}    

		if ($vm.Powerstate -eq "PoweredOn"){                                                                                                                                      
		Write-host "Proceeding with task to PowerOFF " $vm
		$vm | Stop-VM -Confirm:$false -RunAsync  -WhatIf:$false
		$loops = 0
		do {	             
			#Check the power status
			$Status = $vm.Powerstate		                        
			Start-Sleep -Seconds 12
			$loops = $loops + 1
			$vm = Get-VM -Name $vm.Name
		}until($vm.Powerstate -eq "PoweredOff" -Or $loops -gt 5)
		}
		if ($vm.Powerstate -eq "PoweredOff"){
			Move-VM -VM $vm  -Destination "esxi12.kazpost.kz" -Confirm:$false -WhatIf:$false
			Start-VM -VM $vm -Confirm:$false -WhatIf:$false -RunAsync
		}
		}
    }
  }

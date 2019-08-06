connect-viserver -Server vcenter.kazpost.kz

$pathDev ="D:\PowerShell\vcenter\gitlab\work-scripts\"

set-location $pathDev

$manager = Import-CSV D:\PowerShell\vcenter\gitlab\work-scripts\manager.csv

ForEach ($item in $manager){

    $Name = $item.Name

    $Tag1 = $item.Responsible_manager
	$Tag2 = $item.importance
    $Tag3 = $item.influence
	$Tag4 = $item.Responsible_Division

	
    $vm = Get-VM -Name $Name
	$notes = $item.Descr
	Set-VM -VM $vm -Notes $notes -Confirm:$false 
	
    Get-TagAssignment -Entity $vm | where{$_.Tag.Category -eq 'Responsible manager'} | Remove-TagAssignment -Confirm:$false
    Get-TagAssignment -Entity $vm | where{$_.Tag.Category -eq 'importance'} | Remove-TagAssignment -Confirm:$false
    Get-TagAssignment -Entity $vm | where{$_.Tag.Category -eq 'influence'} | Remove-TagAssignment -Confirm:$false
    Get-TagAssignment -Entity $vm | where{$_.Tag.Category -eq 'Responsible Division'} | Remove-TagAssignment -Confirm:$false
	
    Write-Host ".... Assigning $Tag1 in Category Responsible_manager to $Name "
    New-TagAssignment -Entity $vm -Tag $Tag1
    Write-Host ".... Assigning $Tag2 in Category importance to $Name "
    New-TagAssignment -Entity $vm -Tag $Tag2
    Write-Host ".... Assigning $Tag3 in Category influence to $Name "
    New-TagAssignment -Entity $vm -Tag $Tag3
    Write-Host ".... Assigning $Tag4 in Category Responsible_Division to $Name "
    New-TagAssignment -Entity $vm -Tag $Tag4

} 

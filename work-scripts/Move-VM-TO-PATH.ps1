function Get-FolderByPath{

   param(

   [CmdletBinding()]

   [parameter(Mandatory = $true)]

   [System.String[]]${Path},

   [char]${Separator} = '/'

   )

   process{

   foreach($strPath in $Path){

   $root = Get-Folder -Name Datacenters

   $strPath.Split($Separator) | %{

   $root = Get-Inventory -Name $_ -Location $root -NoRecursion

   if((Get-Inventory -Location $root -NoRecursion | Select -ExpandProperty Name) -contains "vm"){

   $root = Get-Inventory -Name "vm" -Location $root -NoRecursion

   }

   }

   $root | where {$_ -is [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl]}|%{

   Get-Folder -Name $_.Name -Location $root.Parent -NoRecursion

   }

   }

   }

}

$folder = Get-FolderByPath -Path "ALMATY/QAZCLOUD/STEP1"
$vm = Get-VM -Name "CentOS - Postmarket_S1"
Move-VM -VM $vm  -Destination $vm.VMHost -InventoryLocation $folder
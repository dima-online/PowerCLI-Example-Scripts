connect-viserver -Server vcenter.kazpost.kz
$report = foreach($vm in Get-VM){

    foreach($ip in $vm.Guest.IPAddress){

        $obj = [ordered]@{

            Name = $vm.Name

            Host = $vm.VMHost.Name

            IP = $ip

        }

        New-Object PSObject -Property $obj

    }

}

$report | Sort-Object -Property {($_ | Get-Member -MemberType Properties).Count} -Descending | Export-Csv D:\machine_ip.csv -NoTypeInformation -UseCulture
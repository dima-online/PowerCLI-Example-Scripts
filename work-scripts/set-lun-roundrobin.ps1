get-vmhost -Location ALMATY | get-scsilun -LunType disk | where-object {$_.multipathpolicy -eq "Mostrecentlyused" -and $_.CapacityGB -gt 5000 } | Set-ScsiLun -MultipathPolicy "roundrobin"

get-vmhost -Location ALMATY | get-scsilun -LunType disk | where-object {$_.multipathpolicy -eq "Fixed" -and $_.CapacityGB -gt 5000 } | Set-ScsiLun -MultipathPolicy "roundrobin"

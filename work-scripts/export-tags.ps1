if (-not $DefaultVIServer.IsConnected) {

    Connect-VIServer "vcenter.kazpost.kz"

}

 

$tagCat = @()

$tagTab = @{}

 

foreach($tag in (Get-TagAssignment)){

    $tagCat += $tag.Tag.Category.Name

    $key = $tag.Entity.Name

    if($tagTab.ContainsKey($key)){

        $val = $tagTab.Item($key)

    }

    else{

        $val = @{}

    }

    $val.Add($tag.Tag.Category.Name,$tag.Tag.Name)

    $tagTab[$key] = $val

}

 

$tagCat = $tagCat | Sort-Object -Unique

 

$tags = foreach($row in ($tagTab.GetEnumerator() | Sort-Object -Property Key)){

    $VMName = $row.Key

    $VMNotes = Get-VM $VMName | Select-Object -ExpandProperty Notes

    $obj = New-Object PSObject -Property @{

        Name = $row.Key

    }

    $tagCat | %{

        $obj | Add-Member -Name $_ -Value $row.Value[$_] -MemberType NoteProperty

    }

    $obj | Add-Member -Name "Notes" -Value $VMNotes -MemberType NoteProperty

    $obj

}

 

$tags | Export-Csv tags.csv -NoTypeInformation -UseCulture

<#
   After converting USB org PDF file to TXT file using online converter ...
#>

$list = Get-Content -Encoding Utf8 -Path "usb_vids_080223.txt"

$obj = [ordered]@{}

foreach($line in $list.Split([System.Environment]::NewLine)){
   
    if(-not [string]::IsNullOrEmpty($line)){

        $matches = [regex]::Matches($line, '^((.*)(\s+)([0-9]{1,6}))$')   
        if($matches.Groups.Count -eq 5){

            $manufacturer = $matches.Groups[2].Value.Trim()
            $vid = [convert]::ToUInt32($matches.Groups[4].Value)

            #Write-Host -ForegroundColor Gray "[add] $manufacturer $vid"  

            if(-not $obj.PSobject.Properties.name.Contains($manufacturer)){
                $obj["$manufacturer"] = $vid 
            }else{
                Write-Host -ForegroundColor Yellow "[skip] $line"  
            }


        }else{
            Write-Host -ForegroundColor Red "[skip] $line"
        }

    }

} 

$obj | Sort-Object | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 -FilePath "usb_vids_080223.json"

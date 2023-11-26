Clear-Host


$global:vendors = $null;
function UpdateVendorssList(){
    Write-Host "[*] Please wait while updating USB vids..."
    $r = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/siliciium/USB_utils/main/usb_vids.json" -ContentType "text/plain;utf-8"
    $global:vendors = $r.Content | ConvertFrom-Json
}

function GetVendor($vid){
    $ret = $null;
    $vid = [convert]::ToUInt32($vid, 16)

    foreach($key in $global:vendors.PSObject.Properties){

        if($key.Value -eq $vid){
            $ret = $key.Name;
            break
        }

    }
    return $ret;
}

$devices = [ordered]@{}


function Main(){

    UpdateVendorssList
    #"-Class USB,HIDClass,MEDIA,Camera,Keyboard,SoftwareComponent"
    #"-Status Ok"
    #"-PresentOnly"

    Write-Host "[*] Please wait while getting Pnp Devices..."
    
    $z = 1
    Get-PnpDevice| ForEach-Object{
        $z++;
    }

    $n = 1
    Get-PnpDevice| ForEach-Object {
        #Write-Host $_.InstanceId 
        $k = $_.InstanceId.Replace("\", "+");
        Write-Host -NoNewLine $("`r[*] Get-PnpDeviceProperty: {0}/{1}" -f @($n, $z));
                
        $properties = Get-PnpDeviceProperty -InstanceId $_.InstanceId | Select -Property * | Where-Object {$_.KeyName -like "*DEVPKEY_Device_BusReportedDeviceDesc*" -or $_.KeyName -like "*DEVPKEY_Device_HardwareIds*"};

        if($properties.Count -eq 2){

           $device   = ($properties | Select -Property KeyName,Data | Where-Object {$_.KeyName -like "*DEVPKEY_Device_BusReportedDeviceDesc*"}).Data
           $vids_pids = ($properties | Select -Property KeyName,Data | Where-Object {$_.KeyName -like "*DEVPKEY_Device_HardwareIds*"}).Data

           $vids = [regex]::Match($vids_pids, '(VID_([A-F-0-9]{4}))')
           $pids = [regex]::Match($vids_pids, '(PID_([A-F-0-9]{4}))')

           if(($vids.Groups.Count -eq 3) -and ($pids.Groups.Count -eq 3)){               
               
                $_vid = ("0x{0}" -f @($vids.Groups[2].Value));
                $_pid = ("0x{0}" -f @($pids.Groups[2].Value));

                if([string]::IsNullOrEmpty($_.PNPClass)){
                    $_class = "";
                }else{
                    $_class = $_.PNPClass;
                }
                            
                $devices[$k] = @{ 
                    device       = $device;      
                    vid          = $_vid; 
                    pid          = $_pid; 
                    vendor       = (GetVendor -vid $_vid); 
                    class        = $_class; 
                    devid        = $_.PNPDeviceID; 
                    instance_id  = $_.InstanceId                       
                }

                #write-host -ForegroundColor yellow $k
                #$devices[$k]|Format-Table                              
               
           }
        }

        $n++
    }

    #Clear-Host
    Write-Host ([System.Environment]::NewLine*(4));

    $maxDevLen = 0;
    $devices.Keys | %{
        if($devices[$_].device.Length -gt $maxDevLen){
            $maxDevLen = $devices[$_].device.Length;
        }
    }
    if($maxDevLen -lt "DEVICE".Length){
        $maxDevLen = "DEVICE".Length
    }
    $maxVendorLen = 0;
    $devices.Keys | %{
        if($devices[$_].vendor.Length -gt $maxVendorLen){
            $maxVendorLen = $devices[$_].vendor.Length;
        }
    }
    if($maxVendorLen -lt "VENDOR".Length){
        $maxVendorLen = "VENDOR".Length
    }
    $maxClassLen = 0;
    $devices.Keys | %{
        if($devices[$_].class.Length -gt $maxClassLen){
            $maxClassLen = $devices[$_].class.Length;
        }
    }
    if($maxClassLen -lt "CLASS".Length){
        $maxClassLen = "CLASS".Length
    }
    

    $box_color = "Blue"

    if($devices.Keys.Count -gt 0){
    Write-Host -ForegroundColor $box_color ("┏{0}┳{1}┳{2}┳{3}┳{4}┓" -f @(([string]'━'*($maxDevLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxVendorLen+2)), ([string]'━'*($maxClassLen+2))))
    Write-Host -ForegroundColor $box_color ("┃ {0} ┃ VID    ┃ PID    ┃ {1} ┃ {2} ┃" -f @("DEVICE".PadRight($maxDevLen," "), "VENDOR".PadRight($maxVendorLen," "), "CLASS".PadRight($maxClassLen," ")))
    Write-Host -ForegroundColor $box_color ("┣{0}╋{1}╋{2}╋{3}╋{4}┫" -f @(([string]'━'*($maxDevLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxVendorLen+2)), ([string]'━'*($maxClassLen+2))))
    }

    $k = 1
    $devices.Keys | Sort-Object | %{
        Write-Host -NoNewline -ForegroundColor $box_color ("┃")
        Write-Host -NoNewline -ForegroundColor Yellow (" {0}" -f @($devices[$_].device.PadRight($maxDevLen," ")))
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃ ")
        Write-Host -NoNewline -ForegroundColor DarkRed ("{0}" -f @($devices[$_].vid))
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃ ")
        Write-Host -NoNewline -ForegroundColor DarkRed ("{0}" -f @($devices[$_].pid))    
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃")        
        Write-Host -NoNewline -ForegroundColor Gray (" {0}" -f @($devices[$_].vendor.PadRight($maxVendorLen," ")))
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃")
        Write-Host -NoNewline -ForegroundColor Gray (" {0}" -f @($devices[$_].class.PadRight($maxClassLen," ")))
        Write-Host -ForegroundColor $box_color (" ┃")

        if($k -ne $devices.Count){
            Write-Host -ForegroundColor $box_color ("┣{0}╋{1}╋{2}╋{3}╋{4}┫" -f @(([string]'━'*($maxDevLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxVendorLen+2)), ([string]'━'*($maxClassLen+2))))
        }else{
            Write-Host -ForegroundColor $box_color ("┗{0}┻{1}┻{2}┻{3}┻{4}┛" -f @(([string]'━'*($maxDevLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxVendorLen+2)), ([string]'━'*($maxClassLen+2))))
        }
        $k++
    }
    Write-Host ([System.Environment]::NewLine*(4));

}
Main

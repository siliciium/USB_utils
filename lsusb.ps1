Clear-Host


$global:manufacturers = $null;
function UpdateManufacturersList(){
    Write-Host "[*] Please wait while updating USB vids..."
    $r = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/siliciium/USB_utils/main/usb_vids.json" -ContentType "text/plain;utf-8"
    $global:manufacturers = $r.Content | ConvertFrom-Json
}

function GetManufacturer($vid){
    $ret = $null;
    $vid = [convert]::ToUInt32($vid, 16)

    foreach($key in $global:manufacturers.PSObject.Properties){

        if($key.Value -eq $vid){
            $ret = $key.Name;
            break
        }

    }
    return $ret;
}

$devices = [ordered]@{}


function Main(){

    UpdateManufacturersList
    #"-Class USB,HIDClass,MEDIA,Camera,Keyboard,SoftwareComponent"
    #"-Status Ok"

    Write-Host "[*] Please wait while getting Pnp Devices $classes..."
    $n = 1
    Get-PnpDevice -Class USB| ForEach-Object {  
    
        $obj = @{}
       
        $properties = Get-PnpDeviceProperty -InstanceId $_.InstanceId | Select -Property * | Where-Object {$_.KeyName -like "*DEVPKEY_Device_BusReportedDeviceDesc*" -or $_.KeyName -like "*DEVPKEY_Device_HardwareIds*"};
        $obj = @{}
        if($properties.Count -eq 2){
           #Write-Host ("{0}) {1}" -f @("$n".PadLeft(2,"0"), $_.InstanceId))

           $device   = ($properties | Select -Property KeyName,Data | Where-Object {$_.KeyName -like "*DEVPKEY_Device_BusReportedDeviceDesc*"}).Data #.Trim()
           $vids_pids = ($properties | Select -Property KeyName,Data | Where-Object {$_.KeyName -like "*DEVPKEY_Device_HardwareIds*"}).Data

           $vids = [regex]::Match($vids_pids, '(VID_([A-F-0-9]{4}))')
           $pids = [regex]::Match($vids_pids, '(PID_([A-F-0-9]{4}))')



           if(($vids.Groups.Count -eq 3) -and ($pids.Groups.Count -eq 3)){
               $obj.desc = $device
               $obj.vid = ("0x{0}" -f @($vids.Groups[2].Value))
               $obj.pid = ("0x{0}" -f @($pids.Groups[2].Value))
               $obj.manufacturer = GetManufacturer -vid $obj.vid
               $obj.class = $_.PNPClass
               $obj.serial = $_.PNPDeviceID
               $obj.instance_id = $_.InstanceId  

               #Write-Host ("{0}" -f @($obj.serial))         

               if($devices.PSobject.Properties.name -notmatch $obj.desc){                
                    $devices[$obj.desc] = @{ 
                        "vid" = $obj.vid ; 
                        "pid" = $obj.pid ; 
                        "manufacturer" = $obj.manufacturer; 
                        "class" = $obj.class; 
                        "serial" = $obj.serial; 
                        "instance_id" = $obj.instance_id 
                    }          
               }
           }
        }

    

        $n++
    }

    Clear-Host

    $maxKeyLen = 0;
    $devices.Keys | %{
        if($_.Length -gt $maxKeyLen){
            $maxKeyLen = $_.Length;
        }
    }
    if($maxKeyLen -lt "DEVICE".Length){
        $maxKeyLen = "DEVICE".Length
    }
    $maxManLen = 0;
    $devices.Keys | %{
        if($devices[$_].manufacturer.Length -gt $maxManLen){
            $maxManLen = $devices[$_].manufacturer.Length;
        }
    }
    if($maxManLen -lt "MANUFACTURER".Length){
        $maxManLen = "MANUFACTURER".Length
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

    $box_color = "White"

    if($devices.Keys.Count -gt 0){
    Write-Host -ForegroundColor $box_color ("┏{0}┳{1}┳{2}┳{3}┳{4}┓" -f @(([string]'━'*($maxKeyLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxManLen+2)), ([string]'━'*($maxClassLen+2))))
    Write-Host -ForegroundColor $box_color ("┃ {0} ┃ VID    ┃ PID    ┃ {1} ┃ {2} ┃" -f @("DEVICE".PadRight($maxKeyLen," "), "MANUFACTURER".PadRight($maxManLen," "), "CLASS".PadRight($maxClassLen," ")))
    Write-Host -ForegroundColor $box_color ("┣{0}╋{1}╋{2}╋{3}╋{4}┫" -f @(([string]'━'*($maxKeyLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxManLen+2)), ([string]'━'*($maxClassLen+2))))
    }

    $k = 1
    $devices.Keys | Sort-Object | %{
        Write-Host -NoNewline -ForegroundColor $box_color ("┃")
        Write-Host -NoNewline -ForegroundColor Yellow (" {0}" -f @($_.PadRight($maxKeyLen," ")))
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃ ")
        Write-Host -NoNewline -ForegroundColor DarkRed ("{0}" -f @($devices[$_].vid))
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃ ")
        Write-Host -NoNewline -ForegroundColor DarkRed ("{0}" -f @($devices[$_].pid))    
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃")        
        Write-Host -NoNewline -ForegroundColor Gray (" {0}" -f @($devices[$_].manufacturer.PadRight($maxManLen," ")))
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃")
        Write-Host -NoNewline -ForegroundColor DarkGray (" {0}" -f @($devices[$_].class.PadRight($maxClassLen," ")))
        Write-Host -ForegroundColor $box_color (" ┃")

        if($k -ne $devices.Count){
            Write-Host -ForegroundColor $box_color ("┣{0}╋{1}╋{2}╋{3}╋{4}┫" -f @(([string]'━'*($maxKeyLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxManLen+2)), ([string]'━'*($maxClassLen+2))))
        }else{
            Write-Host -ForegroundColor $box_color ("┗{0}┻{1}┻{2}┻{3}┻{4}┛" -f @(([string]'━'*($maxKeyLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxManLen+2)), ([string]'━'*($maxClassLen+2))))
        }
        $k++
    }

    <#
┏━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━┳━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━┓
┃ DEVICE             ┃ VID    ┃ PID    ┃ MANUFACTURER        ┃ CLASS ┃
┣━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━╋━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━┫
┃ Gaming Mouse ....  ┃ 0x046D ┃ 0x.... ┃ Logitech Inc.       ┃ USB   ┃
┗━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━┻━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━┛
    #>
}
Main
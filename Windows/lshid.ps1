Clear-Host
$signature = @'
[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern IntPtr CreateFileW(
      string filename,
      System.IO.FileAccess access,
      System.IO.FileShare share,
      IntPtr securityAttributes,
      System.IO.FileMode creationDisposition,
      uint flagsAndAttributes,
      IntPtr templateFile);
'@
$createFile = Add-Type -MemberDefinition $signature -Name 'K32CreateFile' -Namespace 'pinvoke' -PassThru

$signature = @"
[DllImport("kernel32.dll", SetLastError=true)]
public static extern bool CloseHandle(IntPtr hHandle);
"@
$CloseHandle = Add-Type -MemberDefinition $signature -Name 'K32CloseHandle' -Namespace 'pinvoke' -PassThru


$signature = @'
[DllImport("hid.dll", CharSet=CharSet.Auto, SetLastError=true)]
public static extern bool HidD_GetManufacturerString(
    IntPtr HidDeviceObject,
    System.Text.StringBuilder Buffer,
    Int32 BufferLength);
'@
$HidD_GetManufacturerString = Add-Type -MemberDefinition $signature -Name 'HIDHidD_GetManufacturerString' -Namespace 'pinvoke' -PassThru


$signature = @'
[DllImport("hid.dll", CharSet=CharSet.Auto, SetLastError=true)]
public static extern bool HidD_GetProductString(
    IntPtr HidDeviceObject,
    System.Text.StringBuilder Buffer,
    Int32 BufferLength);
'@
$HidD_GetProductString = Add-Type -MemberDefinition $signature -Name 'HIDHidD_GetProductString' -Namespace 'pinvoke' -PassThru


$signature = @'
[DllImport("hid.dll", CharSet=CharSet.Auto, SetLastError=true)]
public static extern bool HidD_GetSerialNumberString(
    IntPtr HidDeviceObject,
    System.Text.StringBuilder Buffer,
    Int32 BufferLength);
'@
$HidD_GetSerialNumberString = Add-Type -MemberDefinition $signature -Name 'HIDHidD_GetSerialNumberString' -Namespace 'pinvoke' -PassThru







$box_color = "Blue"
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

function Box($devices){
    Clear-Host
    

    #Write-Host ([System.Environment]::NewLine*(4));

    $maxProdLen = 0;
    $devices.Keys | %{
        if($devices[$_].product.Length -gt $maxProdLen){
            $maxProdLen = $devices[$_].product.Length;
        }
    }
    if($maxProdLen -lt "PRODUCT".Length){
        $maxProdLen = "PRODUCT".Length
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
    $maxManufLen = 0;
    $devices.Keys | %{
        if($devices[$_].manufacturer.Length -gt $maxManufLen){
            $maxManufLen = $devices[$_].manufacturer.Length;
        }
    }
    if($maxManufLen -lt "MANUFACTURER".Length){
        $maxManufLen = "MANUFACTURER".Length
    }
    $maxSerialLen = 0;
    $devices.Keys | %{
        if($devices[$_].manufacturer.Length -gt $maxManufLen){
            $maxSerialLen = $devices[$_].manufacturer.Length;
        }
    }
    if($maxSerialLen -lt "SERIALNUM".Length){
        $maxSerialLen = "SERIALNUM".Length
    }    

    if($devices.Keys.Count -gt 0){
    Write-Host -ForegroundColor $box_color ("┏{0}┳{1}┳{2}┳{3}┳{4}┳{5}┓" -f @(([string]'━'*($maxProdLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxVendorLen+2)), ([string]'━'*($maxManufLen+2)), ([string]'━'*($maxSerialLen+2))))
    Write-Host -ForegroundColor $box_color ("┃ {0} ┃ VID    ┃ PID    ┃ {1} ┃ {2} ┃ {3} ┃" -f @("PRODUCT".PadRight($maxProdLen," "), "VENDOR".PadRight($maxVendorLen," "), "MANUFACTURER".PadRight($maxManufLen," "), "SERIALNUM".PadRight($maxSerialLen," ")))
    Write-Host -ForegroundColor $box_color ("┣{0}╋{1}╋{2}╋{3}╋{4}╋{5}┫" -f @(([string]'━'*($maxProdLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxVendorLen+2)), ([string]'━'*($maxManufLen+2)), ([string]'━'*($maxSerialLen+2))))
    }

    $k = 1
    $devices.Keys | Sort-Object | %{
        Write-Host -NoNewline -ForegroundColor $box_color ("┃")
        Write-Host -NoNewline -ForegroundColor Yellow (" {0}" -f @($devices[$_].product.PadRight($maxProdLen," ")))
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃ ")
        Write-Host -NoNewline -ForegroundColor DarkRed ("{0}" -f @($devices[$_].vid))
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃ ")
        Write-Host -NoNewline -ForegroundColor DarkRed ("{0}" -f @($devices[$_].pid))    
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃")        
        Write-Host -NoNewline -ForegroundColor Gray (" {0}" -f @($devices[$_].vendor.PadRight($maxVendorLen," ")))
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃")
        Write-Host -NoNewline -ForegroundColor DarkGray (" {0}" -f @($devices[$_].manufacturer.PadRight($maxManufLen," ")))
        Write-Host -NoNewline -ForegroundColor $box_color (" ┃ ")
        Write-Host -NoNewline -ForegroundColor DarkGray ("{0}" -f @($devices[$_].serialnumber.PadRight($maxSerialLen," ")))
        Write-Host -ForegroundColor $box_color (" ┃")

        if($k -ne $devices.Count){
            Write-Host -ForegroundColor $box_color ("┣{0}╋{1}╋{2}╋{3}╋{4}╋{5}┫" -f @(([string]'━'*($maxProdLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxVendorLen+2)), ([string]'━'*($maxManufLen+2)), ([string]'━'*($maxSerialLen+2))))
        }else{
            Write-Host -ForegroundColor $box_color ("┗{0}┻{1}┻{2}┻{3}┻{4}┻{5}┛" -f @(([string]'━'*($maxProdLen+2)), ([string]'━'*(8)), ([string]'━'*(8)), ([string]'━'*($maxVendorLen+2)), ([string]'━'*($maxManufLen+2)), ([string]'━'*($maxSerialLen+2))))
        }
        $k++
    }

    #Write-Host ([System.Environment]::NewLine*(4));
}

function RealOutput($string_builder){
    for($n = 0; $n -lt $string_builder.Length; $n++){
                        
        $d += ("'{0}'," -f @($string_builder[$n]));
        
    }
    return $d.Substring(0, $d.Length-1);
}


function Interact(){
    $VendorId = [String]::Empty;
    while([string]::IsNullOrEmpty($VendorId)){
        Write-Host -NoNewline -ForegroundColor $box_color "Please enter device VID > "
        $VendorId = read-host
    }

    $ProductId = [String]::Empty;
    while([string]::IsNullOrEmpty($ProductId)){
        Write-Host -NoNewline -ForegroundColor $box_color "Please enter device PID > "
        $ProductId = read-host
    }

    return @{
        vid = $VendorId;
        pid = $ProductId;
    }
}

function LowByteFirst($vid_or_pid){
    $high = $vid_or_pid.Substring(2,2);
    $low = $vid_or_pid.Substring(4,2);
    return ("0x{0}, 0x{1}" -f @($low, $high));
}

function VSUB_Header($manufacturer, $product){

    Write-Host ([System.Environment]::NewLine*(1));    

    $obj = $null;
    
    while($null -eq $obj){

        $vid_pid = Interact

        $devices.Keys | %{

            if([string]::Equals($devices[$_].vid, $vid_pid.vid) -and [string]::Equals($devices[$_].pid, $vid_pid.pid)){
                $obj = $devices[$_];
                break;
            }
    
        }

        if($null -eq $obj){
            Write-Host -ForegroundColor Red ("Device vid:{0},pid:{1} not found !" -f @($vid_pid.vid, $vid_pid.pid));
        }

    }

    #$obj
    
    Write-Host ([System.Environment]::NewLine*(1));

    $h = @"
// usbdrv.h
...
#include "usbconfig.h"
#include "silicium.h"
...

// silicium.h
#ifdef USB_CFG_VENDOR_ID
#undef USB_CFG_VENDOR_ID
#endif
#ifdef USB_CFG_DEVICE_ID
#undef USB_CFG_DEVICE_ID
#endif
#ifdef USB_CFG_VENDOR_NAME
#undef USB_CFG_VENDOR_NAME
#endif
#ifdef USB_CFG_VENDOR_NAME_LEN
#undef USB_CFG_VENDOR_NAME_LEN
#endif
#ifdef USB_CFG_DEVICE_NAME
#undef USB_CFG_DEVICE_NAME
#endif
#ifdef USB_CFG_DEVICE_NAME_LEN
#undef USB_CFG_DEVICE_NAME_LEN
#endif

#define  USB_CFG_VENDOR_ID          {0}
#define  USB_CFG_DEVICE_ID          {1}

#define USB_CFG_VENDOR_NAME         {2}
#define USB_CFG_VENDOR_NAME_LEN     {3}
#define USB_CFG_DEVICE_NAME         {4}
#define USB_CFG_DEVICE_NAME_LEN     {5}

"@ -f @(
    (LowByteFirst -vid_or_pid $obj.vid), 
    (LowByteFirst -vid_or_pid $obj.pid), 
    $obj.omanufacturer, 
    $obj.omanufacturer.split(",").Length, 
    $obj.oproduct, 
    $obj.oproduct.split(",").Length
);

if($obj.oserialnumber.Length -ne 0){
    $h += @"

#ifdef USB_CFG_SERIAL_NUMBER
#undef USB_CFG_SERIAL_NUMBER
#endif
#define USB_CFG_SERIAL_NUMBER       {0}
#define USB_CFG_SERIAL_NUMBER_LEN   {1}
"@ -f @($obj.oserialnumber, $obj.oserialnumber.split(",").Length)
}else{
    $h += @"

/*#ifdef USB_CFG_SERIAL_NUMBER
#undef USB_CFG_SERIAL_NUMBER
#endif
#define USB_CFG_SERIAL_NUMBER       'N', 'o', 'n', 'e'
#define USB_CFG_SERIAL_NUMBER_LEN   0*/
"@
}

    Write-Host -ForegroundColor DarkGray $h;
}

$devices = [ordered]@{}

Function List{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$VUSB
    )
    Begin{}
    process {

        
        UpdateVendorssList
        #"-Class USB,HIDClass,MEDIA,Camera,Keyboard,SoftwareComponent"
        #"-Status Ok"
        #"-PresentOnly"

        Write-Host "[*] Please wait while getting Pnp Devices $classes..."
        $n = 1
        Get-PnpDevice -Class HIDClass -PresentOnly| ForEach-Object {
            #Write-Host $_.InstanceId 
            $k = $_.InstanceId.Replace("\", "+");
            
                    
            if(([string]$_.InstanceId).StartsWith("HID\VID_")){
                #Write-Host $_.InstanceId

                # \\?\hid...
                $DevicePath = ("\\.\hid#{0}#{{4d1e55b2-f16f-11cf-88cb-001111000030}}" -f @(([string]$_.InstanceId).Substring(4, ([string]$_.InstanceId).Length - 4).ToLower().Replace("\","#")));
                #Write-Host -ForegroundColor DarkGray $DevicePath
            
                try{

                    $hFile = $createFile[0]::CreateFileW($DevicePath, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read, [System.IntPtr]::Zero, [System.IO.FileMode]::Open, [System.UInt32]0x02000000, [System.IntPtr]::Zero);
                    #write-host "handle : $hFile"
                    if($hFile -ne -1){

                        [System.Text.StringBuilder]$manufacturer = [System.Text.StringBuilder]::new(127);
                        $ret = $HidD_GetManufacturerString::HidD_GetManufacturerString($hFile, $manufacturer, 127);                    
                        if(-not $ret){  $manufacturer=""; }else{ $omanufacturer = (RealOutput -string_builder $manufacturer) }
                        
                        $product = [System.Text.StringBuilder]::new(127);
                        $ret = $HidD_GetProductString::HidD_GetProductString($hFile, $product, 127); 
                        if(-not $ret){  $product=""; }else{ $oproduct = (RealOutput -string_builder $product) }

                        $serialnumber = [System.Text.StringBuilder]::new(127);
                        $ret = $HidD_GetSerialNumberString::HidD_GetSerialNumberString($hFile, $serialnumber, 127); 
                        if(-not $ret){ $serialnumber="N/A"; }else{ $oserialnumber = (RealOutput -string_builder $serialnumber) }                  

                        $bool = $CloseHandle[0]::CloseHandle($hFile);
                        if(-not $bool){ Write-host -ForegroundColor Red "Unable to close handle !"; }

                    }

                    $vids = [regex]::Match($_.InstanceId, '(VID_([A-F-0-9]{4}))');
                    $pids = [regex]::Match($_.InstanceId, '(PID_([A-F-0-9]{4}))');
                    
                    if(($vids.Groups.Count -eq 3) -and ($pids.Groups.Count -eq 3)){

                        $_vid = ("0x{0}" -f @($vids.Groups[2].Value));
                        $_pid = ("0x{0}" -f @($pids.Groups[2].Value));

                        $devices[$k] = @{ 
                            vid           = $_vid;
                            pid           = $_pid;
                            vendor        = (GetVendor -vid $_vid);
                            manufacturer  = ([string]$manufacturer); 
                            omanufacturer = ([string]$omanufacturer);
                            product       = ([string]$product);
                            oproduct      = ([string]$oproduct);
                            serialnumber  = ([string]$serialnumber);
                            oserialnumber = ([string]$oserialnumber);
                            class         = $_.PNPClass;
                            devicePath    = $DevicePath;
                        }

                    }
                    

                }catch{
                    Write-Host -ForegroundColor Red $_
                }
            }

            $n++
        }
        
        Box -devices $devices; 

        if($VUSB.IsPresent){
            VSUB_Header
        }

    }
    End{}



}
#List
List -VUSB

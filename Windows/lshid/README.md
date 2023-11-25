# List
```
┏━━━━━━━━━━━━━━━━━━━┳━━━━━━━━┳━━━━━━━━┳━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━┳━━━━━━━━━━━┓
┃ PRODUCT           ┃ VID    ┃ PID    ┃ VENDOR        ┃ MANUFACTURER ┃ SERIALNUM ┃
┣━━━━━━━━━━━━━━━━━━━╋━━━━━━━━╋━━━━━━━━╋━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━━━┫
┃ Gaming Mouse .... ┃ 0x046D ┃ 0x.... ┃ Logitech Inc. ┃ Logitech     ┃ N/A       ┃
┗━━━━━━━━━━━━━━━━━━━┻━━━━━━━━┻━━━━━━━━┻━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━┻━━━━━━━━━━━┛
```
# List -VUSB
```
┏━━━━━━━━━━━━━━━━━━━┳━━━━━━━━┳━━━━━━━━┳━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━┳━━━━━━━━━━━┓
┃ PRODUCT           ┃ VID    ┃ PID    ┃ VENDOR        ┃ MANUFACTURER ┃ SERIALNUM ┃
┣━━━━━━━━━━━━━━━━━━━╋━━━━━━━━╋━━━━━━━━╋━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━━━┫
┃ Gaming Mouse .... ┃ 0x046D ┃ 0x.... ┃ Logitech Inc. ┃ Logitech     ┃ N/A       ┃
┗━━━━━━━━━━━━━━━━━━━┻━━━━━━━━┻━━━━━━━━┻━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━┻━━━━━━━━━━━┛


Please enter device VID > 0x046D
Please enter device PID > 0x....


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

#define  USB_CFG_VENDOR_ID          0x6D, 0x04
#define  USB_CFG_DEVICE_ID          0x.., 0x..

#define USB_CFG_VENDOR_NAME         'L','o','g','i','t','e','c','h'
#define USB_CFG_VENDOR_NAME_LEN     8
#define USB_CFG_DEVICE_NAME         'G','a','m','i','n','g',' ','M','o','u','s','e',' ','.','.','.','.'
#define USB_CFG_DEVICE_NAME_LEN     17

/*#ifdef USB_CFG_DEVICE_NAME_LEN
#undef USB_CFG_DEVICE_NAME_LEN
#endif
#define USB_CFG_SERIAL_NUMBER       'N', 'o', 'n', 'e'
#define USB_CFG_SERIAL_NUMBER_LEN   0*/
```

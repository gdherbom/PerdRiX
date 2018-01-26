# Building Xenomai 3 for the Rapsberry Pi 3

This tutorial explains how to build a raspbian linux distribution with a Linux kernel pached with Realtime Xenomai RTOS.

This procedure was applied in this script to automate the build.

## Prerequisites

 * Hardware:
  * A raspberry Pi 3 board with a microSD (minimum 2GB size) and an Ethernet connection
  * A Linux computer for cross-compilation
 * Software:
  * An operating Linux (tested on Linux Mint 18.1 (similar to Ubuntu 16.04)) with the C build tools installed (gcc, g++, make, ...)

## Procedure

### First step: installing raspbian on the Pi3 board

It is quite easy and well described on the rapsberrypi.org fundation website:
https://www.raspberrypi.org/documentation/installation/installing-images/README.md

1. Download the "raspbian jessie lite" version. As Xenomai needs a compatible kernel, it is adviced to choose this archive: ***2017-04-10-raspbian-jessie-lite.zip***
http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-04-10/2017-04-10-raspbian-jessie-lite.zip

2. Copying the image to the SD card. Detailed instructions are described here: https://www.raspberrypi.org/documentation/installation/installing-images/linux.md. This comes down to the following command (replace the sdX by the device corresponding to your SD card):
```
dd bs=4M if=2017-04-10-raspbian-jessie-lite.img of=/dev/sdX status=progress conv=fsync
```

3. Some configuration stuff. In order to connect to the pi board via network:
 * mount the SD card on your computer (reconnecting the SD card in your computer may make the job automatically).
 * go to the /boot folder and put an empty file named ***ssh***
 * configure a static address for your Pi by editing the file ***/etc/dhcpcd.conf*** with the following content:

    ```
    interface eth0

    static ip_address=192.168.1.20/24
    static routers=192.168.1.42
    static domain_name_servers=192.168.1.42
    ```
We suppose that the IP address of the raspberry pi is ***192.168.1.20*** and the address of the computer is ***192.168.1.42***.

4. Unmount and unplug your SD card, put it in the raspberry pi. Switch it on, make the Ethernet connection between your computer and the Pi board. You might connect to the raspbian by ssh (default password is *raspberry*):
    ```
    ssh pi@192.168.1.20
    ```

At this point, you may have a working linux rapsberrypi board.

### Second step: patching the kernel with the Xenomai extension

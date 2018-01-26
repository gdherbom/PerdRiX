# Building Xenomai 3 for the Rapsberry Pi 3

This tutorial explains how to build a raspbian linux distribution with a Linux kernel pached with Realtime Xenomai RTOS.

This procedure was applied in this script to automate the build.

## Prerequisites

 * Hardware:
  * A raspberry Pi 3 board with a microSD (minimum 2GB size) and an Ethernet connection
  * A Linux computer for cross-compilation
 * Software:
  * An operating Linux (tested on Linux Mint 18.1 (similar to Ubuntu 16.04)) with the C build tools installed (gcc, g++, make, ...)
  ```
  sudo apt install make gcc g++ git ncurses-dev bc autoconf libtool
  ```
  * raspbian lite version of 2017-04-10

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

Now it's time to patch our kernel to add realtime capabilities.
The kernel version is 4.1.18 (result of **uname -a** command):
```
Linux raspberrypi 4.1.18-v7+ #846 SMP Thu Feb 25 14:22:53 GMT 2016 armv7l GNU/Linux
```

1. Installing the cross-compile toolchain, raspberry pi fundation explains how here:
https://www.raspberrypi.org/documentation/linux/kernel/building.md.
Get the source from git repository:

    ```
    sudo git clone https://github.com/raspberrypi/tools /opt/rpi3crosscompiletoolchain/tools
    ```
Then, add the toolchain to your PATH environment variable:
    ```
    echo PATH=\$PATH:/opt/rpi3crosscompiletoolchain/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin >> ~/.bashrc
    source ~/.bashrc
    ```
You can check in your terminal that the toolchain is correclty installed by launching the command **arm-linux-gnueabihf-gcc**. You may get an error *arm-linux-gnueabihf-gcc: fatal error: no input files
compilation terminated.* that's normal but if you read *command not found*, you have an installation issue.

2. Patching the kernel. Download the xenomai archive :  http://xenomai.org/downloads/xenomai/stable/xenomai-3.0.3.tar.bz2. Uncompress it and you will find the patch for the 4.1.18 kernel in this directory: **xenomai-3.0.3/kernel/cobalt/arch/arm/patches/**. After clone the linux repository provided by raspberry and patch it:
    ```
    git clone https://github.com/raspberrypi/linux.git -b rpi-4.1.y --depth 1
    cd xenomai-3.0.3
     ./scripts/prepare-kernel.sh --arch=arm --linux=../linux --ipipe=kernel/cobalt/arch/arm/patches/ipipe-core-4.1.18-arm-8.patch
    ```


3. cross-compiling the kernel.
    ```    
    cd ../linux
    time make -j 12 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

    time make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=INSTALL_MOD modules_install
    where INSTALL_MOD is the directory where to copy the modules

    time make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_DTBS_PATH=INSTALL_DTBS dtbs_install
    where INSTALL_DTBS is the directory where to copy the dtb files
    ```

Note that this guide presents a solution with the 4.1.18 kernel patch. A complete list of available patches can be found here: http://xenomai.org/downloads/ipipe/v4.x/arm/

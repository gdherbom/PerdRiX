#!/bin/sh

sudo apt install make gcc g++ git ncurses-dev bc autoconf libtool

mkdir -p /home/$USER/dev/rpi_xenomai
cd /home/$USER/dev/rpi_xenomai
wget http://xenomai.org/downloads/xenomai/stable/xenomai-3.0.3.tar.bz2
tar xjf xenomai-3.0.3.tar.bz2
git clone https://github.com/raspberrypi/linux.git -b rpi-4.1.y --depth 1
cd xenomai-3.0.3
./scripts/prepare-kernel.sh --arch=arm --linux=../linux --ipipe=kernel/cobalt/arch/arm/patches/ipipe-core-4.1.18-arm-8.patch
cd ../linux
time make -j 12 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
mkdir XENO_MODULES_INSTALL
mkdir XENO_DTBS_INSTALL
time make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=XENO_MODULES_INSTALL modules_install
time make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_DTBS_PATH=XENO_DTBS_INSTALL dtbs_install

tar cfv XENO_MODULES_INSTALL XENO_MODULES_INSTALL.tar
tar cfv XENO_DTBS_INSTALL XENO_DTBS_INSTALL.tar

echo "Kernel building finished "

# compile the xenomai filesystem

cd /home/$USER/dev/rpi_xenomai/xenomai-3.0.3
./configure --enable-smp --host=arm-linux-gnueabihf CFLAGS='-march=armv6' LDFLAGS='-march=armv6'
time make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j 12
mkdir XENOMAI_DIR
make DESTDIR=/home/$USER/dev/rpi_xenomai/xenomai-3.0.3/XENOMAI_DIR install
tar cfv XENOMAI_DIR/usr XENOMAI_DIR.tar

echo "================================================="
echo "xenomai filesystem building finished"
echo "now connect to the pi3 and copy with scp the files XENO_MODULES_INSTALL.tar, XENO_DTBS_INSTALL.tar, XENOMAI_DIR.tar and zImage"
echo "connect via ssh to the pi3 board and untar the 3 archive files respectively in:"
echo "   - XENO_MODULES_INSTALL.tar => /"
echo "   - XENO_DTBS_INSTALL.tar => /boot/dtbs/4.1.21-xenomai+"
echo "   - XENOMAI_DIR.tar => /usr"
echo "copy the zImage to /boot and rename it to kernel-xenomai-4.1.21.img"

echo "Edit the /boot/config.txt and add the 2 lines:"
echo "kernel=kernel-xenomai-4.1.21.img"
echo "device_tree=dtbs/4.1.21-xenomai+/bcm2710-rpi-3-b.dtb"

echo "Reboot your system and you may have a working realtime raspberry pi3 powered by Xenomai 3"

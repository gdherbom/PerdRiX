FROM ubuntu:xenial
MAINTAINER gerald.dherbomez@univ-lille.fr

## update the system and install the build tools
RUN apt-get update && apt -y dist-upgrade && apt -y install make gcc g++ git ncurses-dev bc autoconf libtool wget bzip2

## external volume in which we compile
VOLUME /opt/devel

WORKDIR /opt/devel/xenomai

## get the sources code
RUN git clone https://github.com/raspberrypi/tools --depth 1 /opt/rpi3crosscompiletoolchain/tools
RUN git clone https://github.com/raspberrypi/linux.git -b rpi-4.1.y --depth 1
RUN wget http://xenomai.org/downloads/xenomai/stable/xenomai-3.0.3.tar.bz2
RUN pwd && ls -al
RUN tar -xvf xenomai-3.0.3.tar.bz2
RUN cd xenomai-3.0.3 && ./scripts/prepare-kernel.sh --arch=arm --linux=../linux --ipipe=kernel/cobalt/arch/arm/patches/ipipe-core-4.1.18-arm-8.patch

## build the patched kernel 
RUN cd ../linux && time make -j 12 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

## build modules and DTB files
RUN mkdir XENO_MODULES_INSTALL
RUN mkdir XENO_DTBS_INSTALL
RUN time make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=XENO_MODULES_INSTALL modules_install
RUN time make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_DTBS_PATH=XENO_DTBS_INSTALL dtbs_install

# compile the xenomai filesystem
RUN cd ../xenomai-3.0.3
RUN ./configure --enable-smp --host=arm-linux-gnueabihf CFLAGS='-march=armv6' LDFLAGS='-march=armv6'
RUN time make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j 12

## add the tar process and instructions to put the files to the microSD. 

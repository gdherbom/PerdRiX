FROM ubuntu
MAINTAINER padr

RUN apt-get update && apt -y install make gcc g++ git ncurses-dev bc autoconf libtool
WORKDIR xenomai
RUN git clone https://github.com/raspberrypi/tools --depth 1 /opt/rpi3crosscompiletoolchain/tools
RUN git clone https://github.com/raspberrypi/linux.git -b rpi-4.1.y --depth 1
RUN apt-get -y install wget bzip2
RUN wget http://xenomai.org/downloads/xenomai/stable/xenomai-3.0.3.tar.bz2
RUN tar -xvf xenomai-3.0.3.tar.bz2
RUN cd xenomai-3.0.3 && ./scripts/prepare-kernel.sh --arch=arm --linux=../linux --ipipe=kernel/cobalt/arch/arm/patches/ipipe-core-4.1.18-arm-8.patch

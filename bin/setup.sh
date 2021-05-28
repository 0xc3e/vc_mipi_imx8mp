#/bin/bash
#
. ./configure.sh

CMD=$1

if [[ $CMD == "host" ]]; then
        sudo apt install -y bmap-tools

        mkdir -p $BUILD_DIR
        cd $BUILD_DIR

        wget -O gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz "https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz?revision=61c3be5d-5175-4db6-9030-b565aae9f766&la=en&hash=0A37024B42028A9616F56A51C2D20755C5EBBCD7"
        tar xvf gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz
        rm gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz

        rm -Rf $KERNEL_SOURCE
        git clone -b toradex_5.4-2.3.x-imx git://git.toradex.com/linux-toradex.git $KERNEL_SOURCE
        git clone git-iob-com@git.ideasonboard.com:toradex/linux.git

        cd $KERNEL_SOURCE
        git checkout fc386214b3bc1bfaacf684edfe939bd6e1deb31
        git apply ../linux/linux-5.4-2.3.x-imx/*.patch
fi
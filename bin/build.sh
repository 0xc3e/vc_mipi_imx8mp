#/bin/bash
#
. ./configure.sh

cd $KERNEL_SOURCE
make defconfig
make Image modules freescale/imx8mp-verdin-nonwifi-dahlia.dtb
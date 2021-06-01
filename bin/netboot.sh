#/bin/bash
#
. ./configure.sh

CMD=$1

if [[ $CMD == "b" ]]; then
        echo "Netboot boot.scr ..."
        sudo cp $SRC_DIR/boot.scr $TFTP_DIR/boot.scr
        ls -l $TFTP_DIR
fi

if [[ $CMD == "all" || $CMD == "k" ]]; then
        echo "Netboot kernel ..."
        sudo cp $KERNEL_SOURCE/arch/arm64/boot/Image.gz $TFTP_DIR
fi

if [[ $CMD == "all" || $CMD == "m" ]]; then
        echo "Netboot kernel modules ..."
        sudo tar xzvf $BUILD_DIR/modules.tar.gz -C $NFS_DIR
fi

if [[ $CMD == "all" || $CMD == "d" ]]; then
        echo "Netboot device tree ..."
        sudo cp $KERNEL_SOURCE/arch/arm64/boot/dts/freescale/imx8mp-verdin-nonwifi-dahlia.dtb $TFTP_DIR/imx8mp-verdin-wifi-dev.dtb
fi

if [[ $CMD == "recover" ]]; then
        sudo rm -Rf $NFS_DIR/*
        sudo cp -R $BUILD_DIR/backup/rootfs/* $NFS_DIR
        ls -l $NFS_DIR
fi 
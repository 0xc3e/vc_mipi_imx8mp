#/bin/bash
#
. config/configure.sh

CMD=$1

if [[ $CMD == "all" || $CMD == "k" ]]; then
        echo "Flash kernel ..."
        scp $KERNEL_SOURCE/arch/arm64/boot/Image.gz $TARGET_USER@$TARGET_IP:/boot
fi

if [[ $CMD == "all" || $CMD == "m" ]]; then
        echo "Flash kernel modules ..."
        scp $BUILD_DIR/modules.tar.gz $TARGET_USER@$TARGET_IP:/home/$TARGET_USER
        $TARGET_SHELL tar -xzvf modules.tar.gz -C /
        $TARGET_SHELL rm -f modules.tar.gz
fi

if [[ $CMD == "all" || $CMD == "d" ]]; then
        echo "Flash device tree ..."
        scp $KERNEL_SOURCE/arch/arm64/boot/dts/freescale/imx8mp-verdin-nonwifi-dahlia.dtb $TARGET_USER@$TARGET_IP:/boot/imx8mp-verdin-wifi-dev.dtb
fi

if [[ $CMD == "test" ]]; then
        echo "Flash test ..."
        $TARGET_SHELL mkdir -p /home/root/test

        scp $WORKING_DIR/test/* $TARGET_USER@$TARGET_IP:/home/root/test
        scp $BUILD_DIR/yavta/yavta $TARGET_USER@$TARGET_IP:/usr/bin
        scp $SRC_DIR/linux/scripts/* $TARGET_USER@$TARGET_IP:/home/root/test
fi
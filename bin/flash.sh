#/bin/bash
#
. ./configure.sh

CMD=$1

if [[ $CMD == "all" || $CMD == "k" ]]; then
        echo "Flash kernel ..."
        scp $KERNEL_SOURCE/arch/arm64/boot/Image $TARGET_USER@$TARGET_IP:/boot/Image.gz
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
        # scp $KERNEL_SOURCE/arch/arm64/boot/dts/freescale/imx8mp-verdin-wifi-dev.dtb $TARGET_USER@$TARGET_IP:/boot/imx8mp-verdin-wifi-dev.dtb
fi
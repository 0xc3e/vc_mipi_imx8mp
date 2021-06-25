#!/bin/bash

usage() {
	echo "Usage: $0 [options]"
	echo ""
	echo "Flash kernel image, modules, device tree, and test tools to the target."
	echo ""
	echo "Supported options:"
        echo "-a, --all                 Flash kernel image, modules and device tree"
        echo "-d, --dt                  Flash device tree"
        echo "-h, --help                Show this help text"
        echo "-k, --kernel              Flash kernel image"
        echo "-m, --modules             Flash kernel modules"
        echo "-t, --test                Flash test tools"
        echo "-y, --yavta               Flash yavta"
}

configure() {
        . config/configure.sh
}

flash_kernel() {
        echo "Flash kernel ..."
        scp $KERNEL_SOURCE/arch/arm64/boot/Image.gz $TARGET_USER@$TARGET_IP:/boot
}

flash_modules() {
        echo "Flash kernel modules ..."
        scp $BUILD_DIR/modules.tar.gz $TARGET_USER@$TARGET_IP:/home/$TARGET_USER
        $TARGET_SHELL tar -xzvf modules.tar.gz -C /
        $TARGET_SHELL rm -f modules.tar.gz
        $TARGET_SHELL rm -Rf /var/log
}

flash_device_tree() {
        echo "Flash device tree ..."
        scp $KERNEL_SOURCE/arch/arm64/boot/dts/freescale/imx8mp-verdin-nonwifi-dahlia.dtb $TARGET_USER@$TARGET_IP:/boot/imx8mp-verdin-wifi-dev.dtb
}

flash_test_tools() {
        echo "Flash test tools ..."
        $TARGET_SHELL mkdir -p /home/root/test

        scp $WORKING_DIR/test/* $TARGET_USER@$TARGET_IP:/home/root/test
        scp $SRC_DIR/linux/scripts/* $TARGET_USER@$TARGET_IP:/home/root/test
        if [[ -e $BUILD_DIR/yavta/yavta ]]; then
                scp $BUILD_DIR/yavta/yavta $TARGET_USER@$TARGET_IP:/usr/bin
        fi
}

flash_yavta() {
        echo "Flash yavta ..."
        scp $BUILD_DIR/yavta/yavta $TARGET_USER@$TARGET_IP:/usr/bin
}

while [ $# != 0 ] ; do
	option="$1"
	shift

	case "${option}" in
	-a|--all)
		configure
                flash_kernel
                flash_modules	
                flash_device_tree
                exit 0
		;;
        -d|--dt)
                configure
                flash_device_tree
                exit 0
		;;
	-h|--help)
		usage
		exit 0
		;;
	-k|--kernel)
		configure
		flash_kernel
                exit 0
		;;
        -m|--modules)
		configure
                flash_modules
                exit 0
		;;
        -t|--test)
		configure
                flash_test_tools		
                exit 0
		;;
        -y|--yavta)
		configure
                flash_yavta	
                exit 0
		;;
	*)
		echo "Unknown option ${option}"
		exit 1
		;;
	esac
done

usage
exit 1
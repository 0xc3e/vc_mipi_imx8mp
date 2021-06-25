#!/bin/bash

usage() {
	echo "Usage: $0 [options]"
	echo ""
	echo "Build kernel image, modules, device tree, u-boot script and test tools."
	echo ""
	echo "Supported options:"
        echo "-a, --all                 Build kernel image, modules and device tree"
	echo "-b, --boot                Build u-boot script"
        echo "-d, --dt                  Build device tree"
        echo "-h, --help                Show this help text"
        echo "-k, --kernel              Build kernel image"
        echo "-m, --modules             Build kernel modules"
        echo "-t, --test                Build test tools"
        echo "-y, --yavta               Build yavta"
}

configure() {
        . config/configure.sh
}

configure_kernel() {
        cd $KERNEL_SOURCE
        make toradex_defconfig
}

build_kernel() {
        echo "Build kernel ..."
        cd $KERNEL_SOURCE
        make -j$(nproc) Image.gz
}

build_modules() {
        echo "Build kernel modules ..."
        cd $KERNEL_SOURCE
        make -j$(nproc) modules 
}

create_modules() {
        rm -Rf $MODULES_DIR
        mkdir -p $MODULES_DIR
        export INSTALL_MOD_PATH=$MODULES_DIR
        make modules_install
        cd $MODULES_DIR
        echo Create module archive ...
        rm -f $BUILD_DIR/modules.tar.gz 
        tar -czf ../modules.tar.gz .
        rm -Rf $MODULES_DIR    
}

build_device_tree() {
        echo "Build device tree ..."
        cd $KERNEL_SOURCE
        make -j$(nproc) freescale/imx8mp-verdin-nonwifi-dahlia.dtb
}

build_uboot_script() {
        echo "Build u-boot script ..."
        cd $SRC_DIR/linux
        mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Distro Boot Script" -d boot.cmd boot.scr
}

build_test_tools() {
        echo "Build test tools ..."
        cd $WORKING_DIR/src/vcmipidemo/linux
        make clean
        make
        mkdir -p $WORKING_DIR/test
        mv -f vcmipidemo $WORKING_DIR/test
        mv -f vcimgnetsrv $WORKING_DIR/test
}

build_yavta() {
        echo "Build yavta ..."
        cd $BUILD_DIR/yavta
        make all
}

while [ $# != 0 ] ; do
	option="$1"
	shift

	case "${option}" in
	-a|--all)
		configure
                configure_kernel
                build_kernel
                build_modules	
                create_modules
                build_device_tree
                exit 0
		;;
      	-b|--boot)
		configure
                build_uboot_script	
                exit 0
		;;
        -d|--dt)
		configure
                configure_kernel
                build_device_tree
                exit 0
		;;
	-h|--help)
		usage
		exit 0
		;;
	-k|--kernel)
		configure
                configure_kernel
		build_kernel
                exit 0
		;;
        -m|--modules)
		configure
                configure_kernel
                build_modules
                create_modules
                exit 0
		;;
        -t|--test)
		configure
                build_test_tools		
                exit 0
		;;
        -y|--yavta)
		configure
                build_yavta	
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
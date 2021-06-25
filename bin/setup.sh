#!/bin/bash

usage() {
	echo "Usage: $0 [options]"
	echo ""
	echo "Setup host and target for development and testing."
	echo ""
	echo "Supported options:"
	echo "-h, --help                Show this help text"
        echo "-k, --kernel              Setup/Reset kernel sources"
        echo "-o, --host                Installs some system tools, the toolchain and kernel sources"
        echo "-y, --yavta               Setup yavta sources"
        echo "    --imx296              Patches device tree files to activate the sony imx296/imx296c driver"
        echo "    --imx327              Patches device tree files to activate the sony imx327c driver"
}

configure() {
        . config/configure.sh
}

install_system_tools() {
        echo "Setup system tools."
        sudo apt update
        sudo apt install -y bc build-essential git libncurses5-dev lzop perl libssl-dev
        sudo apt install -y flex bison
        sudo apt install -y gcc-aarch64-linux-gnu
        sudo apt install -y device-tree-compiler
        sudo apt install -y bmap-tools
        sudo apt install -y u-boot-tools
}

setup_toolchain() {
        echo "Setup tool chain."
        mkdir -p $BUILD_DIR
        cd $BUILD_DIR
        rm -Rf gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu
        wget -O gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz "https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz?revision=61c3be5d-5175-4db6-9030-b565aae9f766&la=en&hash=0A37024B42028A9616F56A51C2D20755C5EBBCD7"
        tar xvf gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz
        rm gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz
}

setup_kernel() {
        echo "Setup kernel sources."
        mkdir -p $BUILD_DIR
        cd $BUILD_DIR
        rm -Rf $KERNEL_SOURCE
        git clone -b toradex_5.4-2.3.x-imx git://git.toradex.com/linux-toradex.git $KERNEL_SOURCE
        cd $KERNEL_SOURCE
        git checkout bb33b94f1466399a995a0d052dca7b9224e3bd45
        git apply $SRC_DIR/linux/patch1/*.patch
        git apply $SRC_DIR/linux/patch2/*.patch
}

setup_yavta() {
        echo "Setup yavta sources."
        mkdir -p $BUILD_DIR
        cd $BUILD_DIR
        rm -Rf yavta
        git clone git://git.ideasonboard.org/yavta.git
        cd yavta
        git checkout 65f740aa1758531fd810339bc1b7d1d33666e28a
}

patch_kernel_imx296() {
        echo "Patching device tree for sony imx296/imx296c driver."
        cd $KERNEL_SOURCE
        git apply $SRC_DIR/linux/patch1/0302-arm64-dts-imx8mp-verdin-Switch-to-IMX296-camera-modu.patch
}

patch_kernel_imx327() {
        echo "Patching device tree for sony imx327 driver."
        cd $KERNEL_SOURCE
        git apply -R $SRC_DIR/linux/patch1/0302-arm64-dts-imx8mp-verdin-Switch-to-IMX296-camera-modu.patch
}

while [ $# != 0 ] ; do
	option="$1"
	shift

	case "${option}" in
	-h|--help)
		usage
		exit 0
		;;
	-k|--kernel)
		configure
		setup_kernel
                exit 0
		;;
	-o|--host)
		configure
                install_system_tools
                setup_toolchain
		setup_kernel
                exit 0
		;;
        -y|--yavta)
		configure
		setup_yavta
                exit 0
		;;
       	--imx296)
		configure
		patch_kernel_imx296
                exit 0
		;;
       	--imx327)
		configure
		patch_kernel_imx327
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
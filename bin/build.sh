#/bin/bash
#
. ./configure.sh

CMD=$1

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

if [[ $CMD == "b" ]]; then
        cd $SRC_DIR
        mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Distro Boot Script" -d boot.cmd boot.scr
        exit 0
fi

if [[ $CMD == "y" ]]; then
        cd $BUILD_DIR/yavta
        make all
        exit 0
fi

cd $KERNEL_SOURCE
make defconfig

if [[ $CMD == "all" || $CMD == "k" ]]; then
        echo "Build kernel ..."
        cd $KERNEL_SOURCE
        make -j$(nproc) Image.gz
fi        
        
if [[ $CMD == "all" || $CMD == "m" ]]; then
        echo "Build kernel modules ..."
        make -j$(nproc) modules 
        create_modules
fi

if [[ $CMD == "all" || $CMD == "d" ]]; then
        echo "Build device tree ..."
        cd $KERNEL_SOURCE
        make -j$(nproc) freescale/imx8mp-verdin-nonwifi-dahlia.dtb
fi
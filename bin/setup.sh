#/bin/bash
#
. config/configure.sh

CMD=$1

if [[ $CMD == "host" ]]; then
        sudo apt install -y bmap-tools
        sudo apt install -y u-boot-tools

        mkdir -p $BUILD_DIR
        cd $BUILD_DIR

        rm -Rf gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu
        wget -O gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz "https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz?revision=61c3be5d-5175-4db6-9030-b565aae9f766&la=en&hash=0A37024B42028A9616F56A51C2D20755C5EBBCD7"
        tar xvf gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz
        rm gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz

        cd $BUILD_DIR
        rm -Rf linux
        git clone git-iob-com@git.ideasonboard.com:toradex/linux.git
        cd linux
        git checkout de253e624badb22f32b9e276c4f2b58ce56de24b

        cd $BUILD_DIR
        rm -Rf yavta
        git clone git://git.ideasonboard.org/yavta.git
        cd yavta
        git checkout 65f740aa1758531fd810339bc1b7d1d33666e28a
fi

if [[ $CMD == "host" || $CMD == "kernel" ]]; then
        cd $BUILD_DIR
        rm -Rf $KERNEL_SOURCE
        git clone -b toradex_5.4-2.3.x-imx git://git.toradex.com/linux-toradex.git $KERNEL_SOURCE
        cd $KERNEL_SOURCE
        git checkout bb33b94f1466399a995a0d052dca7b9224e3bd45

        git apply ../linux/linux-5.4-2.3.x-imx/*.patch
        git apply ../../src/linux/linux-5.4-2.3.x-imx/*.patch
fi

# /boot/overlays.txt
# fdt_overlays=verdin-imx8mp_lt8912_overlay.dtbo

# setenv vidargs video=HDMI-A-1:1280x720-16@60D video=HDMI-A-2:1280x720-16@60D
# saveenv

# rm -R /var/log
# mkdir /var/log

# systemctl disable wayland-app-launch.service

# git diff arch/arm64/boot/dts/freescale/imx8mp-verdin-dahlia.dtsi
# git diff arch/arm64/boot/dts/freescale/imx8mp.dtsi


if [[ $CMD == "296" ]]; then
        cd $KERNEL_SOURCE
        git apply ../linux/linux-5.4-2.3.x-imx/0302-arm64-dts-imx8mp-verdin-Switch-to-IMX296-camera-modu.patch
fi

if [[ $CMD == "327" ]]; then
        cd $KERNEL_SOURCE
        git apply -R ../linux/linux-5.4-2.3.x-imx/0302-arm64-dts-imx8mp-verdin-Switch-to-IMX296-camera-modu.patch
fi

if [[ $CMD == "netboot" ]]; then
        echo "Setup netboot ..."

        # /etc/dhcp/dhcpd.conf
        #
        # subnet 192.168.10.0 netmask 255.255.255.0 {
        #         default-lease-time              86400;
        #         max-lease-time                  86400;
        #         option broadcast-address        192.168.10.255;
        #         option domain-name              "toradex.net";
        #         option domain-name-servers      ns1.example.org;
        #         option ip-forwarding            on;
        #         option routers                  192.168.10.1;
        #         option subnet-mask              255.255.255.0;
        #         interface                       enx98fc84ee15d7;
        #         range                           192.168.10.32 192.168.10.254;
        # }
        # #MAC address dependent IP assignment, used for the colibri target device
        # host eval {
        #         filename                        "Image.gz";
        #         fixed-address                   192.168.10.2;
        #         hardware ethernet               00:14:2d:10:00:00;
        #         next-server                     192.168.10.1;
        #         option host-name                "verdin-imx8mp";
        #         option root-path                "/srv/nfs/imx8mp,v4,tcp,clientaddr=0.0.0.0";
        # }

        # U-Boot
        #
        # setenv devtype dhcp
        # setenv boot_devtype tftp
        # setenv root_devtype nfs-dhcp
        # saveenv

        # U-Boot
        #
        # setenv devtype mmc
        # setenv boot_devtype mmc
        # setenv root_devtype mmc
        # saveenv
fi
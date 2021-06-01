#/bin/bash
#
. ./configure.sh

CMD=$1

if [[ $CMD == "host" ]]; then
        sudo apt install -y bmap-tools
        sudo apt install -y u-boot-tools

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

        # build/linux-toradex/drivers/staging/media/imx/imx8-common.h
        #define MXC_MIPI_CSI2_VC0_PAD_SINK		0
        #define MXC_MIPI_CSI2_VC1_PAD_SINK		1
        #define MXC_MIPI_CSI2_VC2_PAD_SINK		2
        #define MXC_MIPI_CSI2_VC3_PAD_SINK		3
        
        #define MXC_MIPI_CSI2_VC0_PAD_SOURCE		4
        #define MXC_MIPI_CSI2_VC1_PAD_SOURCE		5
        #define MXC_MIPI_CSI2_VC2_PAD_SOURCE		6
        #define MXC_MIPI_CSI2_VC3_PAD_SOURCE		7
        #define MXC_MIPI_CSI2_VCX_PADS_NUM		8

        # build/linux-toradex/arch/arm64/configs/defconfig
        # CONFIG_VIDEO_IMX290=y
        # CONFIG_VIDEO_VC_MIPI=y
        # Added many other options from defconfig from laurant
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
fi
#/bin/bash
#

WORKING_DIR=$(dirname $PWD)
BIN_DIR=$WORKING_DIR/bin

SRC_DIR=$WORKING_DIR/src
BUILD_DIR=$WORKING_DIR/build

DOWNLOADS_DIR=$BUILD_DIR/downloads
KERNEL_SOURCE=$BUILD_DIR/linux-toradex
MODULES_DIR=$BUILD_DIR/modules
TFTP_DIR=/srv/tftp/imx8mp
NFS_DIR=/srv/nfs/imx8mp

TEZI_RECOVER_URL=https://artifacts.toradex.com/artifactory/tezi-oe-prerelease-frankfurt/dunfell-5.x.y/nightly/37/verdin-imx8mp/tezi/tezi-run/oedeploy
TEZI_RECOVER=Verdin-iMX8MP_ToradexEasyInstaller_5.3.0-devel-20210616+build.37

RECOVERY2_DIR=$BUILD_DIR/recovery
TEZI_RECOVER2_URL=https://artifacts.toradex.com:443/artifactory/tdxref-oe-prod-frankfurt/dunfell-5.x.y/release/7/verdin-imx8mp/tdx-xwayland/tdx-reference-multimedia-image/oedeploy

export CROSS_COMPILE=aarch64-none-linux-gnu-
export PATH=$BUILD_DIR/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/:$PATH
export DTC_FLAGS="-@"
export ARCH=arm64

TTY=/dev/ttyUSB3

TARGET_IP=192.168.2.38
TARGET_NAME=verdin-imx8mp
TARGET_USER=root
TARGET_SHELL="ssh $TARGET_USER@$TARGET_IP"
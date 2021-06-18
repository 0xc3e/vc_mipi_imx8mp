#/bin/bash
#
. config/configure.sh

CMD=$1

set -x

BACKUP_DIR=$BUILD_DIR/backup

mkdir -p $BACKUP_DIR
cd $BACKUP_DIR

#scp $TARGET_USER@$TARGET_IP:/boot/Image.gz $BACKUP_DIR
#scp $TARGET_USER@$TARGET_IP:/boot/imx8mp-verdin-wifi-dev.dtb $BACKUP_DIR

mkdir -p rootfs
cd rootfs
sudo cp -R /media/peter/root/* .

cd ..
mkdir -p boot
cd boot
sudo cp -R /media/peter/BOOT/* .
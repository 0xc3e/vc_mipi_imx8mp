#/bin/bash
#
. configure.sh

CMD=$1

if [[ ! -d $RECOVERY_DIR ]]; then
        sudo apt install -y bmap-tools
        
        mkdir -p $RECOVERY_DIR
        cd $RECOVERY_DIR
        wget $TEZI_RECOVER_URL/imx-boot
        wget $TEZI_RECOVER_URL/Verdin-iMX8MP_Reference-Multimedia-Image.rootfs.wic.bmap
        wget $TEZI_RECOVER_URL/Verdin-iMX8MP_Reference-Multimedia-Image.rootfs.wic.gz
fi

cd $RECOVERY_DIR
uuu -t 600 imx-boot

fuser -k $TTY
echo $'\cc' > $TTY
echo "ums 0 mmc 2" > $TTY
while read -n1 -r char < $TTY; do
        if [[ $char == "/" ]]; then
                echo "Ready"
                break
        fi
done 

echo "Wait for 5 seconds ..."
sleep 5

sudo umount /media/$USERNAME/BOOT
sudo umount /media/$USERNAME/root
cd $RECOVERY_DIR
sudo bmaptool copy --bmap Verdin-iMX8MP_Reference-Multimedia-Image.rootfs.wic.bmap Verdin-iMX8MP_Reference-Multimedia-Image.rootfs.wic.gz /dev/sdb
sync

echo "Reboot the device ..."
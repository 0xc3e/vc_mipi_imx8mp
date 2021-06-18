#/bin/bash
#
. config/configure.sh

CMD=$1

if [[ ! -d $RECOVERY2_DIR ]]; then
        sudo apt install -y bmap-tools
        
        mkdir -p $RECOVERY2_DIR
        cd $RECOVERY2_DIR
        wget $TEZI_RECOVER2_URL/imx-boot
        wget $TEZI_RECOVER2_URL/Verdin-iMX8MP_Reference-Multimedia-Image.rootfs.wic.bmap
        wget $TEZI_RECOVER2_URL/Verdin-iMX8MP_Reference-Multimedia-Image.rootfs.wic.gz
fi

cd $RECOVERY2_DIR
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
cd $RECOVERY2_DIR
sudo bmaptool copy --bmap Verdin-iMX8MP_Reference-Multimedia-Image.rootfs.wic.bmap Verdin-iMX8MP_Reference-Multimedia-Image.rootfs.wic.gz /dev/sdb
sync

echo "Reboot the device ..."
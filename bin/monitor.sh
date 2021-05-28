# /bin/bash
#

TTY=/dev/ttyUSB3
fuser -k $TTY
screen -a $TTY 115200
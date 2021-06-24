#!/bin/sh

set -e

media_dev=/dev/media0
sensor="imx290 2-001a"

usage() {
	echo "Usage: $0 [options]"
	echo ""
	echo "Capture frames from the IMX327 sensor on the i.MX8MP."
	echo ""
	echo "Supported options:"
	echo "-g, --gain value          Set the sensor gain in 0.3dB increments (0 to 240)"
	echo "-h, --help                Show this help text"
	echo "-x, --exposure value      Set the sensor exposure time in line units (1 to 1123)"
}

exposure=
gain=

while [ $# != 0 ] ; do
	option="$1"
	shift

	case "${option}" in
	-g|--gain)
		gain="$1"
		shift
		;;
	-h|--help)
		usage
		exit 0
		;;
	-x|--exposure)
		exposure="$1"
		shift
		;;
	*)
		echo "Unknown option ${option}"
		exit 1
		;;
	esac
done

if [ ! -f /sys/kernel/debug/debug_enabled ] ; then
	mount -t debugfs none /sys/kernel/debug
fi

code="SRGGB10_1X10"
format="SRGGB10"
size="1920x1080"
isi_src_pad=6

mediactl="media-ctl -d ${media_dev}"

${mediactl} -r

${mediactl} -l "'${sensor}':0 -> 'imx7-mipi-csis.0':0 [1]"
${mediactl} -l "'imx7-mipi-csis.0':1 -> 'mxc_isi.0':0 [1]"
${mediactl} -l "'mxc_isi.0':${isi_src_pad} -> 'mxc_isi.0.capture':0 [1]"

${mediactl} -V "'${sensor}':0 [fmt:${code}/${size}]"
${mediactl} -V "'imx7-mipi-csis.0':1 [fmt:${code}/${size}]"
${mediactl} -V "'mxc_isi.0':${isi_src_pad} [fmt:${code}/${size}]"

./test/vcmipidemo -afx6 -w '120 185 165' -s ${exposure} -g ${gain}
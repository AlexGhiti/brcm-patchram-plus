#!/bin/bash

enable_bluetooth()
{
	# We only support the VisionFive board for now
	if ! grep -q '^StarFive VisionFive V1$' /proc/device-tree/model; then
		exit 0
	fi

	gpioset 0 35=0
	sleep 1
	gpioset 0 35=1

	# Load the modules
	modprobe hci_uart

	# Send the firmware
	brcm_patchram_plus --enable_hci --no2bytes --tosleep 200000 --baudrate 115200 --patchram /lib/firmware/brcm/BCM43430A1.starfive,visionfive-v1.hcd /dev/ttyS1 &
}

enable_bluetooth

# Wait for the controller to appear
for ((j = 0 ; j < 30 ; j++)); do
	hciconfig dev
	if [[ "$?" == "0" ]]; then
		break
	fi
	sleep 1
done

hciconfig dev | grep "UP"
if [[ "$?" == "0" ]]; then
	exit 0
fi

exit 1

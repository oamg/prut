#!/bin/sh -xe

if [ "${TMT_REBOOT_COUNT}" = "0" ]; then
    tmt-reboot -t 3600
else
    echo "Successfully rebooted"
fi

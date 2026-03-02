# EAPgrade

* [What?](#what)
* [Why?](#why)
* [Why EAPHammer?](#why_eaphammer)
* [Installation](#installation)
* [Usage](#usage)
* [My hardware](#my_hardware)
* [Disclaimer](#disclaimer)
* [Acknowledgements](#acknowledgements)

## What? <a name="what" />

EAPgrade is a simple Bash script that upgrades your fresh Pi OS installation so that it launches WPA/WPA2-MGT fake AP attacks automatically after booting. In order to do so, it makes use of Gabriel Ryan's [EAPHammer](https://github.com/s0lst1c3/eaphammer) as a service. It also provides SSH access to manage your Pi OS from the local network, and excludes the wlan interface in use from `NetworkManager.service` so that it doesn't interfere with the execution of EAPHammer.

Bear in mind that you need a Wi-Fi card that supports Master mode for this attack to work. Also there are chances that the attack won't work if your Pi OS services have been modified since installation.

## Why? <a name="why" />

As I struggled a bit while setting up my Raspberry Pi + battery Wi-Fi hacking kit for WPA/WPA2-MGT, especially before finding out that my DHCP client daemon was launching `wpa_supplicant.service` unless `nohook wpa_supplicant` was specified, I thought of easing this process up to anyone interested in doing the same.

## Why EAPHammer? <a name="why_eaphammer" />

Ease of use and effectiveness, it's a great tool and one of the few that implements the GTC downgrade attack presented at [DefCon 21](https://www.youtube.com/watch?v=-uqTqJwTFyU&feature=youtu.be&t=22m34s) to capture plaintext credentials. It also implements a wide variety of different attacks, you can check its documentation at the [EAPHammer Wiki](https://github.com/s0lst1c3/eaphammer/wiki).

I'm aware of other tools such as [hostapd-mana](https://github.com/sensepost/hostapd-mana) supporting more EAP types, but EAPHammer is my favourite so far. One problem I've experienced though is EAPHammer not logging all its activity to the default log file when Pi OS is disconnected from power without stopping the attack properly, that's why I'm redirecting stdout and stderr to `/opt/eaphammer/logs/hostapd-eaphammer.raw`.

I've also experienced some weird instability bugs after running the fake AP for a somewhat long period of time, so I added a watchdog service in charge of restarting the whole attack if certain errors are detected.

## Installation <a name="installation" />

```bash
git clone 'https://github.com/mamatb/EAPgrade.git'
bash './EAPgrade/EAPgrade.sh'
```
## Usage <a name="usage" />

As the script says after installation:
```
[+] done, now the WPA/WPA2-MGT fake AP attack should launch automatically after booting. Recommended next steps:
    - modify the credentials to access the fake AP network @ "/opt/eaphammer/db/phase2.accounts"
    - modify EAPHammer parameters like the target ESSID @ "/opt/eaphammer/eaphammer.sh"
    - delete "/opt/eaphammer/certs/server/*", "/opt/eaphammer/certs/ca/*" and "/opt/eaphammer/certs/active/*";
      then generate your own target certificate with "python3 /opt/eaphammer/eaphammer --cert-wizard"
    - check for captured credentials after each attack @ "/opt/eaphammer/logs/hostapd-eaphammer.raw"
```
You can SSH your Pi OS at 10.0.0.1 after accessing the fake AP network using the credentials at `/opt/eaphammer/db/phase2.accounts`. Sometimes dnsmasq won't properly serve an IP address for whatever reason, using a static IP has worked for me in these cases.

## My hardware <a name="my_hardware" />

*  Raspberry Pi Zero 2 W, 4 CPU cores and 512MB of memory
*  10000mAh power bank, enough juice to power the Pi Zero 2 W for ~12 hours
*  Panda Wireless PAU07, a dual-band USB Wi-Fi card with the RT5572 chipset
*  Termius app to check the attack progress through SSH using a smartphone

## Disclaimer <a name="disclaimer" />

Please note that launching fake AP attacks can be pretty noisy in certain environments, especially if using [KARMA/MANA](https://github.com/s0lst1c3/eaphammer/wiki/XI.-Using-Karma).

## Acknowledgements <a name="acknowledgements" />

* [Gabriel Ryan a.k.a. s0lst1c3](https://github.com/s0lst1c3) for his tool [EAPHammer](https://github.com/s0lst1c3/eaphammer).
* [OscarAkaElvis](https://github.com/OscarAkaElvis) for the Wi-Fi card recommendation. He also runs a Wi-Fi hacking suite called [airgeddon](https://github.com/v1s1t0r1sh3r3/airgeddon) that you should check out if interested in Wi-Fi hacking.


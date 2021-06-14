# EAPgrade

What?
-----

EAPgrade is a simple Bash script that upgrades your fresh Raspbian installation so that it launches WPA/WPA2-MGT fake AP attacks automatically after booting. In order to do so, it makes use of Gabriel Ryan's [EAPHammer](https://github.com/s0lst1c3/eaphammer) as a service. It also provides SSH access to administrate your Raspbian without needing to plug in keyboard and display, and disables a couple of services so that they don't interfere with the execution of EAPHammer.

Bear in mind that you need a Wi-Fi card that supports Master mode for this attack to work. Also there are chances that the attack won't work if your Raspbian services have been modified since installation.

Why?
----

As I struggled a bit while setting up my Raspberry Pi + battery Wi-Fi hacking kit for WPA/WPA2-MGT, especially before finding out that my DHCP client daemon was launching `wpa_supplicant.service` unless `nohook wpa_supplicant` was specified, I thought of easing this process up to anyone interested in doing the same.

Why EAPHammer?
--------------

Ease of use and effectiveness, it's a great tool and one of the few that implements the GTC downgrade attack presented at [DefCon 21](https://www.youtube.com/watch?v=-uqTqJwTFyU&feature=youtu.be&t=22m34s) to capture plaintext credentials. It also implements a wide variety of different attacks, you can check its detailed documentation at the [EAPHammer Wiki](https://github.com/s0lst1c3/eaphammer/wiki).

I'm aware of other tools such as [hostapd-mana](https://github.com/sensepost/hostapd-mana) supporting more EAP types, but EAPHammer is my favourite so far. One problem I've experienced though is EAPHammer not logging all its activity to the default log file when disconnected from power instead of properly stopping the attack, that's why I'm redirecting stdout and stderr to `/opt/eaphammer/logs/hostapd-eaphammer.raw`.

Also I've experienced some weird instability bugs after running the fake AP for a somewhat long period of time, so decided to add a watchdog service in charge of restarting the whole attack if certain errors are detected.

Installation
------------

    git clone 'https://github.com/mamatb/eapgrade.git'
    bash ./eapgrade/EAPgrade.sh

Usage
-----

As the script says upon installation:

    INFO - done! The WPA/WPA2-MGT fake AP attack should launch automatically after booting now, raw logs will be located at "/opt/eaphammer/logs/hostapd-eaphammer.raw". Next steps:
           Modify user and password to access the fake AP network at "/opt/eaphammer/db/phase2.accounts"
           Modify the ESSID at "/opt/eaphammer/eaphammer.sh" so that it matches your target network
           Delete "/opt/eaphammer/certs/server/*", "/opt/eaphammer/certs/ca/*" and "/opt/eaphammer/certs/active/*"; and generate your own targeted certs by "python3 /opt/eaphammer/eaphammer --cert-wizard" (may need to install some Python 3 modules)

You can SSH your Raspbian at 10.0.0.1 after accessing your fake AP network using the credentials at `/opt/eaphammer/db/phase2.accounts`. Sometimes dnsmasq won't properly serve an IP address for whatever reason, using a static IP has worked for me in these cases.

My hardware
-----------

*  Raspberry Pi 4. Way overkill for this setup, no need to have 4 cores to run fake APs.
*  Xiaomi Mi Power Bank 2S 10000mAh. Portable battery with enough juice to power up the Raspberry Pi 4 for ~8 hours.
*  USB 802.11n Wi-Fi card with RT3070 chipset. Although the wireless card included in the Raspberry Pi 4 supports Master mode, extra range it's a nice to have.
*  [Termux](https://termux.com/) Android app to check the attack progress through SSH using a smartphone.

Disclaimer
----------

No "Academic Purposes Only" bullshit in here, however please note that launching fake APs can be pretty noisy in certain environments, especially if using [KARMA/MANA](https://github.com/s0lst1c3/eaphammer/wiki/XI.-Using-Karma). So hack responsibly or something like that.

Acknowledgements
----------------

[Gabriel Ryan a.k.a. s0lst1c3](https://github.com/s0lst1c3) for his tool [EAPHammer](https://github.com/s0lst1c3/eaphammer).

[OscarAkaElvis](https://github.com/OscarAkaElvis) for the ninja Wi-Fi card recommendation. He also runs a wireless hacking suite called [airgeddon](https://github.com/v1s1t0r1sh3r3/airgeddon) that you should definitely check out if interested in Wi-Fi hacking.

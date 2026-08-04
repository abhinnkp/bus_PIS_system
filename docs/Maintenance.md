# Maintenance Guide

This guide details routine maintenance tasks for the ABDOS appliance.

## 1. Updating the Display URL
To change what the kiosk displays:
1.  Connect via SSH.
2.  Edit the configuration: `sudo nano /boot/firmware/abdos.conf`
3.  Change the `URL` parameter.
4.  Restart the kiosk service: `sudo systemctl restart abdos-kiosk.service`
5.  *(Alternatively, power cycle the device).*

## 2. System Updates
As an appliance, the OS is designed to be static. However, critical security updates may be required.
1.  Connect via SSH.
2.  Stop the kiosk to free up RAM (especially on Pi Zero W): `sudo systemctl stop abdos-kiosk.service`
3.  Run updates: `sudo apt update && sudo apt upgrade -y`
4.  Reboot: `sudo reboot`

*Warning: Unattended `apt` upgrades are disabled to prevent the system from breaking unexpectedly or wearing out the SD card during peak hours.*

## 3. Changing the Splash Screen
1.  Connect via SSH.
2.  Upload your new PNG image (e.g., via SCP) to the Pi.
3.  Copy it to the boot partition: `sudo cp my-new-splash.png /boot/firmware/splash.png`
4.  Update `abdos.conf` if the filename is different: `SPLASH_IMAGE=/boot/firmware/my-new-splash.png`
5.  Reboot.

## 4. Hardware Replacement
If a Raspberry Pi hardware unit fails:
1.  Remove the SD card from the failed unit.
2.  Insert it into the new, identical Raspberry Pi unit.
3.  Power it on. The configuration is tied to the SD card, so it will resume normal operation immediately.

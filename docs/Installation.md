# Installation Guide

This guide describes how to install ABDOS onto a fresh Raspberry Pi.

## Prerequisites
1.  A microSD card (8GB minimum recommended).
2.  Raspberry Pi Imager tool.
3.  A target Raspberry Pi (Zero W, 2, or 3).

## Step 1: Flash the OS
1.  Open Raspberry Pi Imager.
2.  Select **OS** -> **Raspberry Pi OS (other)** -> **Raspberry Pi OS Lite (32-bit)** (Bookworm).
3.  Select your SD card.
4.  Open the **Advanced Options** (gear icon or `Ctrl+Shift+X`):
    *   Enable SSH (use password authentication or public key).
    *   Set a username and password (e.g., `pi` / `raspberry`).
    *   Configure your Wi-Fi (optional, but needed if no Ethernet is available to download the installer).
5.  Write the image to the SD card.

## Step 2: Transfer the Installer
Boot the Raspberry Pi and connect via SSH.
Transfer the ABDOS repository to the Pi:
```bash
git clone https://github.com/your-repo/abdos.git
cd abdos/installer
```
*(Alternatively, copy the files via SCP/SFTP).*

## Step 3: Run the Installer
Execute the installation script with root privileges:
```bash
sudo ./install.sh
```
The script will download required packages, configure the system, and set up the kiosk services.

## Step 4: Configure and Reboot
Before rebooting, verify your configuration file:
```bash
sudo nano /boot/firmware/abdos.conf
```
Update the `URL` parameter to your desired dashboard.

Reboot the system:
```bash
sudo reboot
```
The Pi will now boot silently, display the splash screen, and launch Chromium.

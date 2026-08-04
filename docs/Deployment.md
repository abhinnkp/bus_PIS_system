# Deployment Guide

This guide outlines the process for deploying ABDOS devices at scale in a production environment (e.g., bus stations, depots).

## 1. Golden Image Creation (Optional for V1)
While the standard installation involves running a script on a fresh Pi OS, deploying 50+ screens requires a "Golden Image."
1.  Follow the `Installation.md` guide on a single Pi.
2.  Do *not* configure network-specific settings in `abdos.conf` yet. Set a placeholder URL.
3.  Power down the Pi.
4.  Remove the SD card and use `dd` or a cloning tool to create an `.img` file from the card.
5.  Flash this Golden Image to all deployment SD cards.

## 2. Offline Provisioning
Because `abdos.conf` resides on the FAT32 `/boot/firmware` partition, it can be configured before the SD card is ever placed in the target Pi.
1.  Insert the flashed SD card into a Windows or Mac computer.
2.  Open the `boot` drive.
3.  Open `abdos.conf` in a text editor (e.g., Notepad++, VSCode).
4.  Set the specific `HOSTNAME`, `URL`, and `WIFI` credentials for that specific physical location.
5.  Save the file and eject the card.

## 3. Physical Installation
1.  Insert the configured SD card into the Raspberry Pi.
2.  Connect the HDMI display.
3.  Connect Ethernet (if applicable).
4.  Connect power.
5.  The system requires no human interaction to boot and display the configured URL.

## 4. Acceptance Testing on Site
Refer to `AcceptanceTest.md` for the checklist the on-site technician should perform (e.g., verifying fullscreen, no cursor, correct URL, handling power cycles).

#!/usr/bin/env bash

set -e

/usr/bin/pacman -Sy --noconfirm networkmanager
/usr/bin/systemctl enable NetworkManager.service
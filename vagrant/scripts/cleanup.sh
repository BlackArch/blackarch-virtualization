#!/usr/bin/env bash

set -e

/usr/bin/paccache -rk0
/usr/bin/pacman -Rcns --noconfirm gptfdisk
/usr/bin/pacman -Scc --noconfirm
rm /tmp/yaourt-* -Rf

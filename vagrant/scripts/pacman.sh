#!/usr/bin/env bash

set -e

/usr/bin/pacman-db-upgrade
/usr/bin/sync
/usr/bin/pacman -Syu
#!/usr/bin/env bash

set -e

TERM=${TERM:-xterm}
export TERM

export GNUPGHOME=${HOME}/.gnupg/
curl https://www.blackarch.org/strap.sh | bash
NUMPKGS=$(/usr/bin/yaourt -Ss blackarch | /usr/bin/grep -v "^    " | /usr/bin/wc -l)
echo "$NUMPKGS" BlackArch packages available.

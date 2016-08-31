#!/usr/bin/env bash

set -e

# Zero out the free space to save space in the final image:
/usr/bin/dd if=/dev/zero of=/EMPTY bs=1M || true # because we run -e, but this is *meant* to fail
/usr/bin/rm -f /EMPTY

# Sync to ensure that the delete completes before this moves on.
for i in {1..3} ; do
  /usr/bin/sync
done
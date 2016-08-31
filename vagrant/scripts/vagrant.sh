#!/usr/bin/env bash

set -e

/usr/bin/mkdir -pm 700 /home/vagrant/.ssh
/usr/bin/curl -k --output /home/vagrant/.ssh/authorized_keys --location https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
/usr/bin/chmod 0600 /home/vagrant/.ssh/authorized_keys
/usr/bin/chown -R vagrant /home/vagrant/.ssh
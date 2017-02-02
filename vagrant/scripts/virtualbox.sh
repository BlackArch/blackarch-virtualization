#!/usr/bin/env bash

set -e

DISK='/dev/sda'
FQDN='blackarch.vm'
KEYMAP='us'
LANGUAGE='en_US.UTF-8'
PASSWORD=$(/usr/bin/openssl passwd -crypt 'vagrant')
Green='\e[0;32m'
Reset='\e[0m'

function msg ()
{
    echo -e "${Green}[+] $*${Reset}"
}

CONFIG_SCRIPT='/usr/local/bin/arch-config.sh'
ROOT_PARTITION="${DISK}1"
TARGET_DIR='/mnt'

msg "clearing partition table on ${DISK}"
/usr/bin/sgdisk --zap ${DISK}

msg "destroying magic strings and signatures on ${DISK}"
/usr/bin/dd if=/dev/zero of=${DISK} bs=512 count=2048
/usr/bin/wipefs --all ${DISK}

msg "creating /root partition on ${DISK}"
/usr/bin/sgdisk --new=1:0:0 ${DISK}

msg "setting ${DISK} bootable"
/usr/bin/sgdisk ${DISK} --attributes=1:set:2

msg "creating /root filesystem (ext4)"
# https://www.youtube.com/watch?v=isHYr-5VH-Q
/usr/bin/mkfs.ext4 -O '^64bit' -m 0 -F -L root ${ROOT_PARTITION}

msg "mounting ${ROOT_PARTITION} to ${TARGET_DIR}"
/usr/bin/mount -o noatime,errors=remount-ro ${ROOT_PARTITION} ${TARGET_DIR}

msg "bootstrapping base installation"
/usr/bin/pacstrap ${TARGET_DIR} base base-devel
/usr/bin/arch-chroot ${TARGET_DIR} pacman -S --noconfirm gptfdisk openssh syslinux

msg "configuring and installing syslinux"
/usr/bin/arch-chroot ${TARGET_DIR} syslinux-install_update -i -a -m
/usr/bin/sed -i 's/sda3/sda1/' "${TARGET_DIR}/boot/syslinux/syslinux.cfg"
/usr/bin/sed -i 's/TIMEOUT 50/TIMEOUT 10/' "${TARGET_DIR}/boot/syslinux/syslinux.cfg"

msg "generating the filesystem table"
/usr/bin/genfstab -p ${TARGET_DIR} >> "${TARGET_DIR}/etc/fstab"

msg "generating the system configuration script"
/usr/bin/install --mode=0755 /dev/null "${TARGET_DIR}${CONFIG_SCRIPT}"

cat <<-EOF > "${TARGET_DIR}${CONFIG_SCRIPT}"
  #!/usr/bin/env bash

  set -e

	echo '${FQDN}' > /etc/hostname
	/usr/bin/hwclock --systohc --utc
	echo 'KEYMAP=${KEYMAP}' > /etc/vconsole.conf
	/usr/bin/sed -i 's/#${LANGUAGE}/${LANGUAGE}/' /etc/locale.gen
	/usr/bin/locale-gen
	echo 'LANG=${LANGUAGE}' > /etc/locale.conf
	/usr/bin/mkinitcpio -p linux
	/usr/bin/usermod --password ${PASSWORD} root

	# https://wiki.archlinux.org/index.php/Network_Configuration#Device_names
	/usr/bin/ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
	/usr/bin/ln -s '/usr/lib/systemd/system/dhcpcd@.service' '/etc/systemd/system/multi-user.target.wants/dhcpcd@eth0.service'
	/usr/bin/sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
	/usr/bin/sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
	/usr/bin/systemctl enable sshd.service

	# VirtualBox Guest Additions
	/usr/bin/pacman -S --noconfirm virtualbox-guest-modules-arch
        /usr/bin/pacman -S --noconfirm virtualbox-guest-utils-nox

  # Vagrant-specific configuration
	/usr/bin/groupadd vagrant
	/usr/bin/useradd --password ${PASSWORD} --comment 'Vagrant User' --create-home --gid users --groups vagrant vagrant
  echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_vagrant
	echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_vagrant
	/usr/bin/chmod 0440 /etc/sudoers.d/10_vagrant
EOF

msg "entering chroot and configuring system"
/usr/bin/arch-chroot ${TARGET_DIR} ${CONFIG_SCRIPT}
rm "${TARGET_DIR}${CONFIG_SCRIPT}"

msg "installation complete!"
/usr/bin/sleep 3
/usr/bin/sync
/usr/bin/umount ${TARGET_DIR}
/usr/bin/systemctl reboot

#!/usr/bin/bash
set -ex

base() {
	chroot $HELIXCORE/rootfs /bin/bash -c "apt update && apt full-upgrade -y"
	chroot $HELIXCORE/rootfs /bin/bash -c 'apt install -y --no-install-recommends linux-image-arm64 systemd systemd-resolved grub-efi-arm64 grub2-common bash coreutils util-linux network-manager iwd locales console-setup
	cat > /etc/default/grub <<EOF
	GRUB_DEFAULT=0
	GRUB_TIMEOUT=5
	GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS2,1500000"
	GRUB_TERMINAL=serial
	GRUB_SERIAL_COMMAND="serial --speed=1500000 --unit=0 --word=8 --parity=no --stop=1"
	EOF
	mkdir -p /boot/efi
	grub-install --target=arm64-efi --efi-directory=/boot/efi --removable
	update-grub
	'
}

graphic() {
	chroot $HELIXCORE/rootfs /bin/bash -c "apt install -y xorg xwayland plasma-desktop sddm kwin-wayland plasma-nm plasma-pa kde-config-gtk-style firefox-esr konsole"
	chroot $HELIXCORE/rootfs /bin/bash -c "systemctl enable sddm"
}

full() {
	base()
	graphic()
}

live() {
	full()
	chroot $HELIXCORE/rootfs /bin/bash -c '
	echo "HelixCore" > /etc/os-release
	echo "HelixCore" > /etc/hostname
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
	locale-gen
	update-locale LANG=en_US.UTF-8
	'
}


if [ $(whoami) != "root" ] then
	echo -e "\e[91mYou must run as Root!\e[0m"
	exit 1
fi

$1()


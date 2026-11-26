#!/bin/sh
# Mount core virtual filesystems during early dinit boot.
set -e

PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

mountpoint -q /proc || mount -t proc -o nosuid,noexec,nodev proc /proc
mountpoint -q /sys  || mount -t sysfs -o nosuid,noexec,nodev sysfs /sys
mountpoint -q /dev  || mount -t devtmpfs -o mode=0755,nosuid devtmpfs /dev
mkdir -p /dev/pts /dev/shm /run /tmp /var/log /var/tmp
mountpoint -q /dev/pts || mount -t devpts -o gid=5,mode=620,noexec,nosuid devpts /dev/pts
mountpoint -q /dev/shm || mount -t tmpfs -o mode=1777,nosuid,nodev tmpfs /dev/shm
mountpoint -q /run     || mount -t tmpfs -o mode=0755,nosuid,nodev tmpfs /run
chmod 1777 /tmp /var/tmp

if [ -d /sys/firmware/efi/efivars ]; then
	command -v modprobe >/dev/null 2>&1 && modprobe efivarfs 2>/dev/null || true
	mountpoint -q /sys/firmware/efi/efivars || mount -t efivarfs efivarfs /sys/firmware/efi/efivars 2>/dev/null || true
fi

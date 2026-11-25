#!/bin/sh
# Mount/unmount local filesystems from /etc/fstab.
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

case "${1:-start}" in
	start)
		if [ -f /etc/fstab ]; then
			fsck -A -T -C -a >/dev/null 2>&1 || true
			mount -a -t nosysfs,noproc,nodevtmpfs 2>/dev/null || mount -a || true
		fi
		swapon -a 2>/dev/null || true
		[ -x /sbin/ldconfig ] && /sbin/ldconfig 2>/dev/null || true
		touch /run/utmp 2>/dev/null || true
		;;
	stop)
		sync
		swapoff -a 2>/dev/null || true
		if mountpoint -q /sys/firmware/efi/efivars 2>/dev/null; then
			umount /sys/firmware/efi/efivars 2>/dev/null || true
		fi
		umount -a -r -t nosysfs,noproc,nodevtmpfs,notmpfs 2>/dev/null || true
		mount -o remount,ro / 2>/dev/null || true
		sync
		;;
esac

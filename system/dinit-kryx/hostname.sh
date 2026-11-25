#!/bin/sh
# Apply system hostname from /etc/hostname or CRUX /etc/rc.conf.
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

HNAME=""
if [ -r /etc/hostname ]; then
	HNAME="$(head -n 1 /etc/hostname | tr -d ' \t\r\n')"
fi
if [ -z "$HNAME" ] && [ -r /etc/rc.conf ]; then
	HNAME="$(awk -F= '/^HOSTNAME=/{gsub(/["'\'' \t\r]/,"",$2); print $2; exit}' /etc/rc.conf)"
fi
[ -z "$HNAME" ] && HNAME="kryx"

if [ -w /proc/sys/kernel/hostname ]; then
	printf '%s\n' "$HNAME" > /proc/sys/kernel/hostname
elif command -v hostname >/dev/null 2>&1; then
	hostname "$HNAME"
fi

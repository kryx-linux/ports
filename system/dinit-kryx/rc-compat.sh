#!/bin/sh
# CRUX /etc/rc.conf + /etc/rc.d/* compatibility bridge for dinit.
# Starts/stops any service listed in /etc/rc.conf SERVICES=(...) that is NOT
# already natively enabled under /etc/dinit.d/boot.d/.
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

ACTION="${1:-start}"
[ -r /etc/rc.conf ] || exit 0

# Parse SERVICES=(a b c) safely without sourcing arbitrary shell code.
SVCS="$(awk '
	/^SERVICES=\(/ {
		sub(/^SERVICES=\(/, "")
		sub(/\).*/, "")
		print
		exit
	}
' /etc/rc.conf)"

[ -z "$SVCS" ] && exit 0

should_skip() {
	case "$1" in
		""|lo) return 0 ;;
	esac
	# Skip if natively enabled in dinit boot.d
	[ -e "/etc/dinit.d/boot.d/$1" ] && return 0
	return 1
}

if [ "$ACTION" = "start" ]; then
	for svc in $SVCS; do
		should_skip "$svc" && continue
		if [ -x "/etc/rc.d/$svc" ]; then
			"/etc/rc.d/$svc" start || true
		fi
	done
	if [ -x /etc/rc.local ]; then
		/etc/rc.local || true
	fi
elif [ "$ACTION" = "stop" ]; then
	# Stop in reverse order
	REV=""
	for svc in $SVCS; do
		REV="$svc $REV"
	done
	for svc in $REV; do
		should_skip "$svc" && continue
		if [ -x "/etc/rc.d/$svc" ]; then
			"/etc/rc.d/$svc" stop || true
		fi
	done
fi

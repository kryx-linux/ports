# When booted with dinit as PID 1, prepend dinit's non-conflicting
# reboot/poweroff/halt/shutdown shims ahead of /sbin so standard commands
# trigger a clean dinit DAG shutdown and ACPI/EFI reset.
if [ -r /proc/1/comm ] && [ "$(cat /proc/1/comm 2>/dev/null)" = "dinit" ]; then
	case ":$PATH:" in
		*:/usr/libexec/dinit-kryx/bin:*) ;;
		*) export PATH="/usr/libexec/dinit-kryx/bin:$PATH" ;;
	esac
fi

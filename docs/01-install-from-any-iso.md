# Module 01: Installing KryX Linux from Any Live ISO

Because `kpm` and `gports` are static Go binaries (`CGO_ENABLED=0`), you can bootstrap KryX Linux from **any** x86_64 live Linux ISO (CRUX ISO, Arch ISO, Debian/Fedora/Alpine live USB).

## Step 1: Partition & Mount Your Target Disk
```bash
# Example UEFI GPT layout (adjust /dev/nvme0n1 or /dev/sda to your disk!)
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

mount /dev/sda2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
```

## Step 2: Fetch Static `kpm` + Setup Scripts (from Any Live ISO)
If you are NOT already on a KryX ISO, download the static `kpm` binary and setup scripts:
```bash
# If on a CRUX/KryX image, /usr/bin/kpm, setup, setup-repo, setup-chroot are already installed.
# On any other live ISO, copy or install kpm + scripts into /usr/bin:
chmod +x /usr/bin/kpm /usr/bin/setup /usr/bin/setup-repo /usr/bin/setup-chroot
```

## Step 3: Bootstrap with `setup`
Choose a profile:
- `minimal` — barebones rootfs + `kpm` + `gports`
- `base` — bootable minimal Linux system + kernel + networking
- `devel` — `base` + full C/C++/Go build toolchain ready to compile any port out of the box

```bash
setup --root /mnt --profile base --hostname mykryx --timezone UTC
```

*(Prefer manual control? Run `setup-repo --root /mnt`, then `kpm --root /mnt install --deps <pkgs...>` directly!)*

## Step 4: Chroot & Finalize
```bash
setup-chroot /mnt
```
Inside the chroot:
```bash
blkid                     # Find disk UUIDs and update /etc/fstab
passwd                    # Set root password
kpm doctor                 # Verify PATH, pkgdb, CA certs, config, and index
```
Install your preferred bootloader (GRUB, systemd-boot, or Limine), `exit` the chroot (`setup-chroot` automatically unmounts `/dev`, `/proc`, `/sys`, `/run`), and reboot!

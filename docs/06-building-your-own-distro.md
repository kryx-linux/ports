# Module 06: Building Your Own Distro & ISO

Everything in KryX is composable so you can build your own Linux distribution or live ISO in a reproducible pipeline.

## Step 1: Create Your Custom Distro Rootfs
Using `setup` + `kpm --root`:
```bash
mkdir -p ./iso-rootfs
sudo setup \
  --root ./iso-rootfs \
  --profile base \
  --extra "vim tmux git" \
  --hostname mydistro \
  --yes
```

## Step 2: Customize Inside `setup-chroot`
```bash
sudo setup-chroot ./iso-rootfs /bin/bash -c '
  kpm doctor
  gports -u
  # Add custom configs, services, users, or build custom ports via `kpm build .`
'
```

## Step 3: Ship Your Own Binary Repo & Signing Key
1. Generate your distro's Ed25519 release key:
   ```bash
   kpm key gen --out mydistro-release --comment "MyDistro Official"
   ```
2. Install `mydistro-release.pub` into `./iso-rootfs/etc/kpm/keys.d/`.
3. Point `./iso-rootfs/etc/kpm.ini` to your `[repo.mydistro]` section (with `verify_signature = true`) plus `[repo.kryx]` as a secondary fallback repo!
4. Pack `./iso-rootfs` into a SquashFS image (`mksquashfs`), pair it with your `kernel` package's `vmlinuz` + initramfs, and generate a hybrid UEFI/BIOS ISO with `xorriso` (coming next week in the dedicated `iso` project!).

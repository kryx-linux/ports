# Module 02: Mastering `kpm` — Multi-Repo, Upgrades, Doctor & Keyring

## Daily Commands
```bash
kpm sync                       # Sync all configured binary repos
kpm search ripgrep             # Search binaries, ports, and installed packages
kpm install --deps ripgrep     # Binary-first install with runtime dependencies
kpm update                     # Upgrade installed packages (alias: kpm upgrade)
kpm update --dry-run           # Preview available upgrades
kpm list                       # List installed packages
kpm list --diff                # Compare installed vs binary/port versions
kpm remove ripgrep             # Clean CRUX-compatible removal
```

## Multi-Repository & Multi-Ports Setup (`/etc/kpm.ini`)
You can stack multiple binary repos and multiple local ports trees in priority order (first wins):

```ini
[paths]
ports_dir = /usr/ports, /srv/my-local-ports
collections = rolling, core, opt, xorg, contrib
keys_dir = /etc/kpm/keys.d

[repo.rolling]
repository = kryx-linux/ports
tag = rolling-x86_64
verify_signature = true

[repo.custom]
index_url = https://my-server.example/kryx/index.json
```

## Health Checks & Fixing Shadowed `/sbin/kpm` (`hash -r`)
CRUX's `PATH` puts `/sbin` before `/usr/bin`. If an older install left `/sbin/kpm` behind, it shadows `/usr/bin/kpm`. Run:

```bash
kpm doctor
```
If `kpm doctor` flags a legacy copy:
```bash
sudo make clean-legacy    # or: sudo rm -f /sbin/kpm /sbin/kpm-index /sbin/kryx-src
hash -r                   # Clears bash's cached command path lookup
```

## Cryptographic Signing & Key Rotation (Never Lose Access!)
`kpm` verifies `index.json.sig` natively in Go using Ed25519 keys stored in `/etc/kpm/keys.d/*.pub` (accepts both `kpm key gen` keys and standard OpenSSH `ssh-ed25519` public keys):

```bash
kpm key gen --out kryx-release --comment "kryx-official"
kpm key trust kryx-release.pub --name kryx-official
kpm key list
kpm sync --verify
```

**What if you move repositories and lose your old private signing key?**
1. Generate a new keypair (`kpm key gen --out kryx-2027`).
2. Publish `kryx-2027.pub` and its `SHA256:...` fingerprint on your new repository/website.
3. Users explicitly trust the new key and revoke the old one:
   ```bash
   kpm key trust https://new-repo.example/kryx-2027.pub --name kryx-2027
   kpm key revoke kryx-old
   kpm sync --verify
   ```
   *(For one-time bootstrap during migration: `kpm sync --allow-untrusted`.)*

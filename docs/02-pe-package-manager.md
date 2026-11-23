# Module 02: Mastering `pe` — Multi-Repo, Upgrades, Doctor & Keyring

## Daily Commands
```bash
pe sync                       # Sync all configured binary repos
pe search ripgrep             # Search binaries, ports, and installed packages
pe install --deps ripgrep     # Binary-first install with runtime dependencies
pe update                     # Upgrade installed packages (alias: pe upgrade)
pe update --dry-run           # Preview available upgrades
pe list                       # List installed packages
pe list --diff                # Compare installed vs binary/port versions
pe remove ripgrep             # Clean CRUX-compatible removal
```

## Multi-Repository & Multi-Ports Setup (`/etc/pe.ini`)
You can stack multiple binary repos and multiple local ports trees in priority order (first wins):

```ini
[paths]
ports_dir = /usr/ports, /srv/my-local-ports
collections = rolling, core, opt, xorg, contrib
keys_dir = /etc/pe/keys.d

[repo.rolling]
repository = kryx-linux/ports
tag = rolling-x86_64
verify_signature = true

[repo.custom]
index_url = https://my-server.example/kryx/index.json
```

## Health Checks & Fixing Shadowed `/sbin/pe` (`hash -r`)
CRUX's `PATH` puts `/sbin` before `/usr/bin`. If an older install left `/sbin/pe` behind, it shadows `/usr/bin/pe`. Run:

```bash
pe doctor
```
If `pe doctor` flags a legacy copy:
```bash
sudo make clean-legacy    # or: sudo rm -f /sbin/pe /sbin/pe-index /sbin/kryx-src
hash -r                   # Clears bash's cached command path lookup
```

## Cryptographic Signing & Key Rotation (Never Lose Access!)
`pe` verifies `index.json.sig` natively in Go using Ed25519 keys stored in `/etc/pe/keys.d/*.pub` (accepts both `pe key gen` keys and standard OpenSSH `ssh-ed25519` public keys):

```bash
pe key gen --out kryx-release --comment "kryx-official"
pe key trust kryx-release.pub --name kryx-official
pe key list
pe sync --verify
```

**What if you move repositories and lose your old private signing key?**
1. Generate a new keypair (`pe key gen --out kryx-2027`).
2. Publish `kryx-2027.pub` and its `SHA256:...` fingerprint on your new repository/website.
3. Users explicitly trust the new key and revoke the old one:
   ```bash
   pe key trust https://new-repo.example/kryx-2027.pub --name kryx-2027
   pe key revoke kryx-old
   pe sync --verify
   ```
   *(For one-time bootstrap during migration: `pe sync --allow-untrusted`.)*

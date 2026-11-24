# CONTRIBUTING_PACKAGES(7) — KryX Linux Pkgfile Authoring & Maintenance Guide

## NAME

**CONTRIBUTING_PACKAGES** — real-world specification and checklist for creating, testing, and maintaining CRUX/KryX Linux `Pkgfile` recipes with `kpm(8)`, `kryx-src(8)`, and `gports(8)`.

---

## SYNOPSIS

```text
<collection>/<pkgname>/
├── Pkgfile          # Required: metadata headers, variables, and build()
├── .footprint       # Expected installed file tree (checked by kpm build / kryx-src)
├── .md5sum          # Source checksums (generated via pkgmk -um or md5sum)
├── .nostrip         # Optional: regex patterns excluded from ELF stripping
└── <local files>    # Optional patches, configs, init scripts listed in source=()
```

Alternatively, **Nix-like embedded packaging** is supported directly inside any upstream project repository:

```text
my-project/
├── Pkgfile          # or .kryx/Pkgfile
└── ...source code...
```

Build directly with:
```bash
kpm build .
kpm build https://github.com/org/my-project@v1.2.0
kryx-src pkg --from-git https://github.com/org/my-project@main
```

---

## PKGFILE ANATOMY

```bash
# Description: Short one-line summary (no trailing period, no package name prefix)
# URL:         https://upstream.example.org/
# Maintainer:  Your Name, you at example dot org
# Depends on:  glibc openssl
# Make depends on: go cmake ninja

name=example
version=1.2.3
release=1
source=(https://upstream.example.org/releases/$name-$version.tar.xz
        fix-build.patch)

build() {
	cd "$name-$version"
	patch -p1 -i "$SRC/fix-build.patch"

	./configure --prefix=/usr
	make
	make DESTDIR="$PKG" install
}
```

### Header Rules

| Header | Required | Purpose |
| :--- | :---: | :--- |
| `# Description:` | Yes | Single-line summary used by `kpm search`, `gports -s`, and `index.json`. |
| `# URL:` | Yes | Upstream homepage URL. |
| `# Maintainer:` | Yes | Maintainer contact (obfuscated email optional). |
| `# Depends on:` | When needed | **Runtime** dependencies installed by `kpm install --deps` and also satisfied during builds. |
| `# Make depends on:` | Optional | **Build-time-only** dependencies (compilers, generators like `go`, `cmake`, `bison`). Backward-compatible with stock CRUX (ignored by `pkgmk`); satisfied binary-first by `kpm build --deps --sync` / `kryx-src pkg --deps` and **excluded** from runtime `depends` in `index.json`. Aliases: `# Make depends:`, `# Makedepends:`, `# Build depends on:`. |

### Directory Naming Rule (Critical)

The directory basename **should match** `name=` inside `Pkgfile`:
- Good: `rolling/kernel/Pkgfile` with `name=kernel` (or `rolling/linux-6.18/Pkgfile` with `name=linux-6.18`).
- Avoid: `rolling/linux-6.18/Pkgfile` declaring `name=kernel`. While `kpm` and `kryx-src` resolve mismatches safely via the canonical registry, `kryx-src lint` warns on them because stock CRUX tools expect `basename(dir) == name`.

---

## ENVIRONMENT VARIABLES PROVIDED TO `build()`

`kpm build` and `kryx-src pkg` export CRUX `pkgmk`-compatible variables:

- `$SRC` — unpacked source directory (`<work_dir>/<name>/src`)
- `$PKG` — staging rootfs directory archived into `.pkg.tar.zst` (`<work_dir>/<name>/pkg`)
- `$PKGMK_ROOT` — directory containing `Pkgfile` (useful for Nix-like repo builds!)
- `$JOBS`, `$CFLAGS`, `$CXXFLAGS`, `$LDFLAGS`, `$MAKEFLAGS` — from `/etc/kpm.ini`

---

## COMMON PACKAGING PATTERNS & PITFALLS

### 1. Go Packages (Static, Offline-Friendly)
```bash
# Make depends on: go
build() {
	cd "$name-$version"
	export CGO_ENABLED=0 GOOS=linux GOARCH=amd64
	export GOCACHE="${PKGMK_WORK_DIR:-$SRC}/gocache"
	export GOMODCACHE="${PKGMK_WORK_DIR:-$SRC}/gomodcache"
	go build -mod=vendor -trimpath -ldflags="-s -w" -o "$name" ./cmd/"$name"
	install -Dm755 "$name" "$PKG/usr/bin/$name"
}
```

### 2. Linux Kernel Packages
Always unset userspace compiler flags before invoking Kbuild, and remove broken `$SRC` symlinks:
```bash
unset CFLAGS CXXFLAGS LDFLAGS
make olddefconfig
make -j"$(nproc)" bzImage modules
make INSTALL_MOD_PATH="$PKG" INSTALL_MOD_STRIP=1 modules_install
rm -f "$PKG"/lib/modules/*/build "$PKG"/lib/modules/*/source
```

### 3. Prebuilt Binaries / Non-Strippable Files (e.g., `zig`, Go binaries)
Add a `.nostrip` file listing regex patterns to skip ELF stripping (or disable stripping for fragile toolchains).

### 4. Config Files Under `/etc`
Never assume user edits in `/etc` should be overwritten on upgrade; `/etc/pkgadd.conf` protects `^etc/.*$` with `UPGRADE ... NO` and stages incoming files in `/var/lib/pkg/rejected/`.

---

## LOCAL LINT, BUILD & VERIFICATION WORKFLOW

1. **Lint your port (checks headers, dir/name alignment, deps, cycles):**
   ```bash
   kryx-src lint --ports /usr/ports rolling/myport
   ```
2. **Build with binary-first runtime + make dependencies:**
   ```bash
   kpm build --deps --sync --update-footprint rolling/myport
   ```
3. **Verify clean footprint & archive contents:**
   ```bash
   kpm list --files /var/cache/kpm/packages/myport#1.2.3-1.pkg.tar.zst
   ```
4. **Test install in a temporary root (zero risk to host `/`):**
   ```bash
   mkdir -p /tmp/testroot/var/lib/pkg
   kpm --root /tmp/testroot install /var/cache/kpm/packages/myport#1.2.3-1.pkg.tar.zst
   ```
5. **Run CI test via GitHub Actions:**
   - Open **Actions → Build Packages with kryx-src (Matrix) and Publish Rolling Repo**.
   - Set `port_path` to `rolling/myport` (or multiple space-separated ports, capped by `max_ports`).
   - Enable `build_deps: true` to satisfy `# Make depends on:` from existing binaries automatically.

---

## RELEASE SIGNING & KEY ROTATION

- Maintainers sign `index.json` using an Ed25519 private key (`KRYX_SIGNING_KEY` secret in CI or `kryx-src sign --key release.key --file index.json`).
- Public keys (`*.pub`, either `kryx-ed25519` or standard OpenSSH `ssh-ed25519`) live in `/etc/kpm/keys.d/`.
- **Always keep an offline backup keypair.** If a repository moves and the old private key is lost, generate a new key (`kpm key gen`), publish the `.pub` + SHA-256 fingerprint, and instruct users to run `kpm key trust <new.pub>` (and `kpm key revoke <old-id>`).

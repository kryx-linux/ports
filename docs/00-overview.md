# Module 00: KryX Linux Zero-to-Hero — Philosophy & Architecture

Welcome to the KryX Linux Zero-to-Hero course!

## The Core Philosophy (Minimal by Default, Ready Out of the Box)
KryX Linux is built on CRUX Linux's simple, transparent foundation (`/var/lib/pkg/db`, `Pkgfile`, zero daemon bloat) with a modern **binary-first + source-ready** workflow:

1. **Minimal out of the box:** A fresh KryX installation includes only what you ask for (`minimal`, `base`, or `devel`). No bloated desktops or unwanted background services.
2. **Binary-first when you want speed:** `kpm install --deps <pkg>` downloads SHA-256 verified (and optionally Ed25519 signed) prebuilt `.pkg.tar.zst` archives.
3. **Source-ready when you want control:** Whenever you want to compile from source, `kpm build --deps --sync <pkg>` or `kryx-src pkg` works out of the box—automatically installing `# Make depends on:` from prebuilt binaries instead of compiling toolchains from scratch.

## The Four Static Go Tools
| Tool | Role |
| :--- | :--- |
| **`kpm`** | Binary-first package manager (`sync`, `install`, `update`/`upgrade`, `build`, `search`, `list`, `remove`, `doctor`, `key`). |
| **`gports`** | Zero-shell-out pure-Go ports syncer (`git`, `rsync`, `httpup`, `tarball`) + local `list`/`diff`/`search`. |
| **`kryx-src`** | Unified `xbps-src`-style source builder, linter, topological matrix planner, and release stager/signer. |
| **`setup` / `setup-chroot` / `setup-repo`** | Distro bootstrap tools that install KryX from *any* live Linux ISO (CRUX, Arch, Debian, Fedora). |

## Course Roadmap
- [01 — Installing KryX from Any Live ISO](01-install-from-any-iso.md)
- [02 — Mastering `kpm`: Multi-Repo, Upgrades, Doctor & Keys](02-kpm-package-manager.md)
- [03 — Managing Ports with `gports` & Overlays](03-gports-and-overlays.md)
- [04 — Packaging with `Pkgfile`, Make Depends & Nix-Like Repos](04-packaging-and-pkgfile.md)
- [05 — Automated CI & Matrix Builds with `kryx-src`](05-kryx-src-and-ci.md)
- [06 — Building Your Own Distro & ISO](06-building-your-own-distro.md)

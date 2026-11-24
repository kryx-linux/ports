# Module 04: Packaging with `Pkgfile`, Make Depends & Nix-Like Repos

See [CONTRIBUTING_PACKAGES.md](../CONTRIBUTING_PACKAGES.md) for the complete man-page-style reference.

## 1. Runtime vs. Build-Only Dependencies
Use `# Depends on:` for runtime libraries/tools and `# Make depends on:` for build-only tools (like `go`, `cmake`, `meson`, `bison`):

```bash
# Description: My fast Go CLI tool
# URL:         https://github.com/you/mytool
# Maintainer:  You
# Depends on:  glibc
# Make depends on: go

name=mytool
version=1.0.0
release=1
source=(https://github.com/you/$name/archive/v$version.tar.gz)

build() {
	cd "$name-$version"
	CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o "$name" .
	install -Dm755 "$name" "$PKG/usr/bin/$name"
}
```

When you run:
```bash
kpm build --deps --sync mytool
```
- `kpm` installs `go` **from the binary repo** (skipping `go`'s own build deps!).
- The published binary package for `mytool` only lists `depends: ["glibc"]` — end-users installing `mytool` never pull in the Go compiler!
- Stock CRUX `pkgmk` ignores `# Make depends on:`, keeping 100% backward compatibility.

## 2. Nix-Like Embedded `Pkgfile` Inside Any Source Repo
Just like Nix's `flake.nix`, you can put a `Pkgfile` (or `.kryx/Pkgfile`) right inside your application's Git repository and build it without copying recipes into `/usr/ports`:

```bash
# Inside your project directory:
kpm build . --deps --install

# Or directly from GitHub:
kpm build https://github.com/you/mytool@v1.0.0 --deps --install
kryx-src pkg --from-git https://github.com/you/mytool@main --out-dir ./dist
```

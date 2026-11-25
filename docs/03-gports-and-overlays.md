# Module 03: Managing Ports with `gports` & KryX Overlays

`gports` is a standalone, static, **zero-shell-out** pure-Go replacement for CRUX's `ports(8)` utility. It speaks `git`, `rsync`, `httpup`, and `tarball` natively without requiring external `git`, `rsync`, `curl`, or `tar` binaries.

## How to Maintain KryX Ports Without Forking All of CRUX
Don't fork 1,800+ upstream CRUX packages. Use the **overlay model**:

1. Sync upstream CRUX collections (`core`, `opt`, `xorg`, `contrib`, `compat-32`) AND KryX's first-party collections (`pkg-tools`, `kernel`, `system`) in `/etc/ports/sources.list`:
   ```text
   git kryx      https://github.com/kryx-linux/ports.git
   git core      https://github.com/kryx-linux/core.git
   git opt       https://github.com/kryx-linux/opt.git
   git xorg      https://github.com/kryx-linux/xorg.git
   git contrib   https://github.com/kryx-linux/contrib.git
   git compat-32 https://github.com/kryx-linux/compat-32.git
   ```
2. Put KryX's first-party collections **first** in `/etc/kpm.ini`:
   ```ini
   collections = pkg-tools, kernel, system, core, opt, xorg, contrib, compat-32
   ```
3. Any package you place in `pkg-tools/`, `kernel/`, or `system/` automatically overrides stock CRUX while all other packages come seamlessly from CRUX!
4. Add personal or third-party collections as drop-in files under `/etc/gports/sources.list.d/*.list` (for example using `rsync` or `httpup`) so package upgrades never touch them.

## Essential `gports` Commands
```bash
gports check            # Lint sources.list + pre-flight DNS/TCP check
gports -u               # Concurrently sync all collections (pure Go)
gports -u -j 2 core opt # Sync specific collections with 2 workers
gports status           # Show collection protocols, paths, and Git HEAD SHAs
gports -l               # List local ports (<collection>/<port>)
gports -d               # Diff local ports against installed kpm DB (/var/lib/pkg/db)
gports -s kernel        # Fast local search across port names & descriptions
```

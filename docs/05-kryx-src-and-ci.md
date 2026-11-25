# Module 05: Automated CI & Matrix Builds with `kryx-src`

`kryx-src` is KryX's unified `xbps-src`-style source machine (built alongside `kpm` and `kpm-index`).

## Local Maintainer Workflow
```bash
# 1. Lint ports before pushing (catches dir!=name, missing deps, cycles)
kryx-src lint --ports /usr/ports system

# 2. Preview topological wave plan for CI
kryx-src plan --ports /usr/ports --max-ports 20 system

# 3. Build cleanly into an isolated work root
kryx-src pkg \
  --ports /usr/ports \
  --work-root /tmp/kryx-work \
  --out-dir ./dist/packages \
  --deps --sync-index --force \
  kpm-tools/kpm system/dinit system/dinit-kryx

# 4. Stage index.json + GitHub-safe upload copies + Ed25519 signature
kryx-src stage --packages ./dist/packages --ports /usr/ports --index ./dist/index.json --upload-dir ./dist/upload
kryx-src sign --key ~/.keys/kryx-release.key --file ./dist/index.json
```

## How the GitHub Actions Matrix Workflow Stays Fast & Safe
In `.github/workflows/build-publish.yml`:
1. **`prepare`**: Checks out `port_repo` (with recursive submodules) and bundles `port-src.tar`.
2. **`plan`**: Runs `kryx-src plan --max-ports 20 --chunk-size 1` to generate a bounded, wave-ordered JSON matrix (respecting GitHub public-repo limits: 20 concurrent Linux jobs, 6h/job).
3. **`build` (`strategy.matrix`, `max-parallel: 6`, `fail-fast: false`)**: Each package compiles in its own container with a full 6-hour budget and uploads its `.pkg.tar.zst` artifact.
4. **`publish` (single serialized job)**: Downloads every successful matrix artifact, runs `kryx-src stage`, uploads assets, runs `kryx-src rewrite-urls`, signs `index.json` (when `secrets.KRYX_SIGNING_KEY` is set), and uploads `index.json` (+ `index.json.sig`) **once atomically** with zero race conditions.

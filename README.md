# qemu-cli

![Version](https://img.shields.io/badge/Version-1.4.1-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20v2.10.*-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/qemu-cli?style=flat-square)](https://github.com/cloudgen/qemu-cli)

**qemu-cli** is a POSIX `/bin/sh` program that installs QEMU on this computer, keeps four guest image families, and starts, stops, runs a command in, or opens a shell in a QEMU guest this tool already recorded. In this program a **container** is that guest. It is not a Docker, Podman, or LXC container.

On a **terminal**, no arguments opens a numbered list. A **pipe**, or a quiet or json run with no arguments, still **places this CLI** and does not install QEMU. The program people install is the single file `src/qemu-cli`.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Person using this CLI on their own account | `qemu-cli` then `2` |
| The other role | Administrator package install of QEMU on Linux | `qemu-cli setup` when this process is already the administrator |
| Not this | Docker, Podman, or LXC | Those are other tools |

| Includes | Excludes |
|----------|----------|
| QEMU setup, four image families, start / stop / execute / shell | A ninth menu language |
| Self-install, version-check, self-update, self-uninstall, about | Calling `sudo` from this program |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Install the CLI | Copies the program into your user bin (`~/.local/bin`) | `curl -fsSL https://raw.githubusercontent.com/cloudgen/qemu-cli/main/src/qemu-cli \| sh` |
| Install QEMU | Installs the distro packages, or reports that QEMU is already available | `qemu-cli setup` |
| See where it lives | `about` prints install status and the cache folder | `qemu-cli about` |

Runtime version (one official copy): `VERSION="1.4.1"` in `src/qemu-cli`. Install channel (one official copy): `SCRIPT_URL` composed from `REPO_USER` / `REPO_NAME` / `SCRIPT_RELPATH` (default `src/qemu-cli`, full URL `https://raw.githubusercontent.com/cloudgen/qemu-cli/main/src/qemu-cli`). Defensive design: **[CIAO](https://github.com/cloudgen/ciao) v2.10.*** (aligned on **v2.10.2**; Caution • Intentional • Anti-fragile • Over-engineered / Over-protect) with agent contract [CIAO-Lite](https://github.com/cloudgen/ciao-lite).

## Features

- Defensive design under **CIAO v2.10.*** and CIAO-Lite — Protection Zones, centralized `out_*`, fail-closed install integrity
- Single-file script for direct execution and online install (`curl | sh` / `wget`)
- User vs global install paths (`~/.local/bin` **0700** / `/usr/local/bin` **0755**)
- **Empty command line:** on a terminal, a numbered list (**1** setup, **2** images, **3** containers, **6** language, **8** self-management, **9** Exit). Under a pipe, or with quiet/json, self-install-ensure (not help)
- **Eight menu languages:** English, 繁體中文, Español, Français, Deutsch, 简体中文, 日本語, 한국어. Saved at `~/.local/qemu-cli/language`. `QEMU_CLI_LANG` covers one run and does not write that file
- **Checkout copy:** `./src/qemu-cli self-install` copies the running file when `$0` is the script (no download). A pipe (`curl … | sh`) still downloads from the channel
- Centralized output (`out_*`) with `--quiet`, `--json`, `--debug`
- Self-update / version-check against `SCRIPT_URL`
- **Scratch is per login and per process.** `about` prints **Cache folder used**, **preferred**, **1st fallback**, and **2nd fallback** when this computer has one. Linux uses `/dev/shm/cache/cache-<app>-<login>-<pid>`, then `/tmp/cache/...`, then `~/.cache/cache-<app>-<pid>`. Git Bash uses `/tmp/cache/...`, then `~/AppData/Local/Temp/cache-<app>-<pid>`. Mac uses `/tmp/cache/...`, then `~/Library/Caches/cache-<app>-<pid>`, then `~/cache/cache-<app>-<pid>`. A skipped folder is silent. Durable data for this login stays `~/.local/qemu-cli`. The cache-folder labels stay English when the menu language changes
- **Automatic checksum (SHA-256):** default install/self-update fetches `${SCRIPT_URL}.sha256` itself (no env pin); human mode is designed to show companion **link**, expected **value**, and **result**; mismatch aborts; missing sidecar warns and continues
- **Optional strict pin:** `CHECKSUM` env for out-of-band / CI freeze only (secondary—not required for normal install)
- **QEMU:** `setup` on Debian and derivatives, Red Hat, CentOS, Rocky Linux, Fedora, Alpine, and macOS Homebrew. Linux package install runs only when this process is already the administrator. Image families are Ubuntu, Rocky Linux, Alpine, and busybox

## Quick Installation

### Online (recommended)

**Per-user (non-root):**

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgen/qemu-cli/main/src/qemu-cli | sh
```

**System-wide (this process is already the administrator):**

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgen/qemu-cli/main/src/qemu-cli | sh
```

Run that second form from an administrator shell. This program does not call `sudo`.

Then verify:

```sh
qemu-cli about
```

On a terminal, `qemu-cli` with no arguments shows the same list as `qemu-cli menu`. The short name is bold. The explanation is italic and light gray. These transcripts leave the color codes out. The English choose-prompt has one trailing space.

```text
[INFO] **qemu-cli**(*1.4.1*) — QEMU setup, images, and containers
1. **setup**: *install QEMU on this computer*
2. **images**: *Ubuntu, Rocky Linux, Alpine, busybox*
3. **containers**: *start, stop, execute, or enter a shell*
6. **language**: *display language for this menu*
8. **self-management**: *this CLI install, version, update, uninstall*
9. Exit
Choice: 
```

Choosing **2** opens:

```text
[INFO] **qemu-cli**(*1.4.1*) — images
21. **ubuntu**: *manage the Ubuntu image*
22. **rocky**: *manage the Rocky Linux image*
23. **alpine**: *manage the Alpine image*
24. **busybox**: *manage the busybox image*
0. Back
Choice: 
```

Choosing **21** opens:

```text
[INFO] **qemu-cli**(*1.4.1*) — images ubuntu
211. **create**: *create this image*
212. **show**: *show this image record*
213. **remove**: *delete this image*
0. Back
Choice: 
```

Choosing **3** opens:

```text
[INFO] **qemu-cli**(*1.4.1*) — containers
31. **create**: *new container from a managed image*
32. **open**: *numbered list of existing containers*
0. Back
Choice: 
```

Choosing **32** when none exist yet:

```text
[INFO] **qemu-cli**(*1.4.1*) — containers
[INFO] No containers exist yet.
0. Back
Choice: 
```

After a container named `web` exists, **32** lists `1. web`. Choosing that number opens:

```text
[INFO] **qemu-cli**(*1.4.1*) — containers web
321. **start**: *boot this container*
322. **stop**: *stop this container*
323. **execute**: *run one command inside*
324. **shell**: *enter a shell in this container*
325. **remove**: *delete this container*
0. Back
Choice: 
```

Choosing **6** opens:

```text
[INFO] **qemu-cli**(*1.4.1*) — language
61. **English**: *use English for this menu*
62. **繁體中文**: *use Traditional Chinese for this menu*
63. **Español**: *use Spanish for this menu*
64. **Français**: *use French for this menu*
65. **Deutsch**: *use German for this menu*
66. **简体中文**: *use Simplified Chinese for this menu*
67. **日本語**: *use Japanese for this menu*
68. **한국어**: *use Korean for this menu*
0. Back
Choice: 
```

Choosing **8** opens:

```text
[INFO] **qemu-cli**(*1.4.1*) — self-management
82. **version**: *show current version*
83. **about**: *show detailed diagnostics*
84. **version-check**: *compare local vs remote version*
85. **self-update**: *update qemu-cli to a newer remote version*
86. **self-uninstall**: *remove qemu-cli*
87. **self-install**: *place this CLI only (copy when $0 is a script; download when piped)*
0. Back
Choice: 
```

**9** leaves. **0** steps back. A wrong number reprints that list. A finished command returns to the first list. **4**, **5**, and **7** are unused. **81** is not printed.

### Prerequisites

- POSIX-compatible `sh`, standard core utilities
- `curl` or `wget` for network install/update of this CLI
- `sha256sum` for integrity checks (required when digests are verified)
- For `setup`: the distro package tool named above, and on Linux an administrator process. macOS uses Homebrew as this login
- For image create: network access to the vendor host named by `qemu-cli help`, plus `qemu-img` after setup. Busybox also needs a local static busybox and `QEMU_CLI_KERNEL`

## Usage

```sh
qemu-cli                  # terminal: numbered list; pipe/quiet/json: self-install-ensure
qemu-cli menu             # same numbered list (help when not a terminal)
qemu-cli main             # same as menu
qemu-cli help
qemu-cli about
qemu-cli version
qemu-cli self-install     # place this CLI (copy when $0 is the script)
qemu-cli install          # alias of self-install; does not install QEMU
qemu-cli setup            # install QEMU on this computer
qemu-cli image list
qemu-cli image create ubuntu
qemu-cli container list
qemu-cli container create --name web --image ubuntu
qemu-cli container start web
qemu-cli container stop web
qemu-cli container execute web -- uname -a
qemu-cli container shell web
qemu-cli version-check
qemu-cli self-update
qemu-cli self-uninstall
```

### Global options

| Flag | Meaning |
|------|---------|
| `--quiet` / `-q` | Suppress non-error human chatter (errors and warnings still shown) |
| `--json` | Machine-readable JSON (forces quiet human output) |
| `--debug` | Extra diagnostics on stderr when supported |
| `--force` | Force reinstall, skip a yes/no question, or allow a downgrade where implemented |

### Environment

| Variable | Purpose |
|----------|---------|
| `REPO_USER` | GitHub owner (default `cloudgen`); used to compose default `SCRIPT_URL` |
| `REPO_NAME` | GitHub repo name (default `qemu-cli`); used to compose default `SCRIPT_URL` |
| `SCRIPT_RELPATH` | Path of the installable file in the repo (default `src/qemu-cli`); used to compose default `SCRIPT_URL` |
| `SCRIPT_URL` | Install-script URL (default `https://raw.githubusercontent.com/cloudgen/qemu-cli/main/src/qemu-cli`) |
| `APP_NAME` | Override app name (default `qemu-cli`) |
| `QEMU_CLI_LANG` | One-run menu language (`en`, `zh-Hant`, `es`, `fr`, `de`, `zh-Hans`, `ja`, `ko`). Does not write the language file |
| `QEMU_CLI_UBUNTU_RELEASE` | Ubuntu release override, digits and dots only |
| `QEMU_CLI_ROCKY_RELEASE` | Rocky Linux release override |
| `QEMU_CLI_ALPINE_RELEASE` | Alpine release override |
| `QEMU_CLI_KERNEL` | Kernel path for the busybox image |

`CHECKSUM` is an optional **install-path runtime** pin for CI/freeze (not shown in `help` / `about`). Empty default uses automatic `${SCRIPT_URL}.sha256`.

The cache folder for this run is chosen by `util_resolve_storage` and exported as `TMPDIR`. Durable data stays `~/.local/qemu-cli` (images, containers, and the `language` file). Inspect with `qemu-cli about` or `qemu-cli about --json` (`cache_used`, `cache_preferred`, `cache_fallback`, `cache_fallback_2`, `persistence_storage`, plus `qemu_present`, `qemu_bin`, `host_os_family`, `image_dir`, `container_dir`, `kvm_usable`).

## Examples

Show diagnostics (works before or after install):

```sh
./src/qemu-cli about
```

Quiet install from a local checkout (copies this file; no download):

```sh
./src/qemu-cli self-install --quiet
```

JSON version for automation:

```sh
qemu-cli version --json
```

JSON about (includes install status, storage fields, and QEMU fields; no `CHECKSUM`):

```sh
qemu-cli about --json
```

List image families without downloading:

```sh
qemu-cli image list
```

Regenerate the companion digest after every script change:

```sh
sha256sum ./src/qemu-cli | cut -d' ' -f1 > src/qemu-cli.sha256
```

Release trees include:

```text
src/qemu-cli           # installable script
src/qemu-cli.sha256    # bare SHA-256 hex of that file (companion digest)
```

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Linux (POSIX `/bin/sh`) | Supported primary target. `setup` uses apt, dnf/yum, or apk when this process is the administrator |
| macOS | `setup` uses Homebrew as this login |
| Alpine | `setup` uses `apk` when this process is the administrator |
| Termux, Git Bash, Windows cmd | The CLI can run. `setup` refuses. It does not wrap apt, dnf, apk, brew, or sudo |

## Related Projects

| Project | Relationship |
|---------|----------------|
| [cloudgen/ciao](https://github.com/cloudgen/ciao) | CIAO defensive programming principles — this product targets **v2.10.*** (currently **v2.10.2**) |
| [cloudgen/ciao-lite](https://github.com/cloudgen/ciao-lite) | Agent-facing CIAO-Lite contract (Simplicity but Safety) |

## Contributing

- Keep changes **surgical**; do not rewrite the whole script for small fixes.
- Respect **CIAO v2.10.*** Protection Zones and intentional defensive checks — do not “simplify” them away.
- After editing `src/qemu-cli`, regenerate `src/qemu-cli.sha256` (see Examples).
- Align user-facing docs with Config SSOTs (`VERSION`, `SCRIPT_URL`, checksum, storage behavior).
- Product rules live under `docs/requirements/` (registry `docs/requirements/index.md`).
- Run the CI suite before opening a PR: `./tests/run.sh` (details in [`tests/README.md`](./tests/README.md)).

## License

MIT License — see [`LICENSE.md`](./LICENSE.md).

Security reporting: see [`SECURITY.md`](./SECURITY.md). Maintainer contact email is the **author-email** on the Copyright line in `LICENSE.md` (not a second SSOT).

## Last Update

2026-09-30 — **1.4.1**: qemu-cli. Numbered menu **1** / **2** / **3** / **6** / **8** / **9**, eight languages, QEMU setup and the four image families. Channel `https://raw.githubusercontent.com/cloudgen/qemu-cli/main/src/qemu-cli`.

2026-09-27 — **1.4.0**: The cache folder is per login and per process. Skipping a folder is silent.

2026-09-27 — **1.3.2**: On a terminal, no arguments opens the numbered menu. Item **8** is self-management (**82–87**).

# Requirements index

**Product:** qemu-cli (POSIX `/bin/sh` CLI: QEMU setup, four image families, and QEMU guests, plus Type 0 self-install of this CLI)  
**Workspace state:** Specialized product law (not blank genesis); **software-development** class; one Active domain requirement.  
**Disk honesty:** ship unit is `src/qemu-cli` (`VERSION="1.4.1"`) plus `src/qemu-cli.sha256`. Bootstrap `src/selfmanaged` remains and is not this product's ship unit. Channel defaults in the ship unit are `cloudgen` / `qemu-cli`. Git remote is `git@github.com:cloudgen/qemu-cli.git`.  
**Updated:** 2026-09-30

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack (posix-sh; QEMU packages owned by domain) | class | Active | `requirement-class-software-dev.md` | 2026-09-30 |
| requirement-domain-qemu | QEMU setup, image families (Ubuntu, Rocky Linux, Alpine, busybox), container start/stop/execute/shell | domain | Active | `requirement-domain-qemu.md` | 2026-09-30 |
| requirement-shell-automatic-checksum | Automatic companion-digest integrity (transparent link/value/result; CHECKSUM not help/about) | shell | Active | `requirement-shell-automatic-checksum.md` | 2026-09-30 |
| requirement-shell-cli-default-interaction | Numbered TTY menu: **1** setup, **2** images, **3** containers, **6** language, **8** self-management, **9** Exit | shell | Active (1.2.0) | `requirement-shell-cli-default-interaction.md` | 2026-09-30 |
| requirement-shell-cli-interface | Shell CLI interface (commands, flags, dispatch, modes) | shell | Active | `requirement-shell-cli-interface.md` | 2026-09-30 |
| requirement-shell-cli-language | Eight menu languages (en, zh-Hant, es, fr, de, zh-Hans, ja, ko); front **6** / **61–68**; `QEMU_CLI_LANG` | shell | Active (1.0.0) | `requirement-shell-cli-language.md` | 2026-09-30 |
| requirement-shell-cli-self-install | CLI self-place (`self-install`; script `$0` copy; dest 0755/0700). Does not install QEMU | shell | Active | `requirement-shell-cli-self-install.md` | 2026-09-30 |
| requirement-shell-cli-storage | Cache folder per login and process (Linux shm → tmp → `~/.cache`; Git Bash tmp → AppData; Mac tmp → Library/Caches → `~/cache`) and persistence `${HOME}/.local/${APP_NAME}` plus the `language` leaf; silent tier miss | shell | Active (1.4.2) | `requirement-shell-cli-storage.md` | 2026-09-30 |
| requirement-shell-cli-zero-arguments | Empty argv: TTY numbered menu; off-TTY Type O install-ensure | shell | Active | `requirement-shell-cli-zero-arguments.md` | 2026-09-30 |
| requirement-shell-idempotency | Shell idempotency / re-run safety for ensure-style ops (QEMU re-runs owned by the domain requirement) | shell | Active | `requirement-shell-idempotency.md` | 2026-09-30 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / `curl\|sh` behavior (menu on a TTY; domain prompts do not hang) | shell | Active | `requirement-shell-interactive-vs-noninteractive.md` | 2026-09-30 |
| requirement-shell-modular-function-design | Single-file modular function design (prefixes, zones; domain prefix `qemu_`) | shell | Active | `requirement-shell-modular-function-design.md` | 2026-09-30 |
| requirement-shell-output-requirements | Central `out_*` output SSOT (stdout/stderr, modes; `@key` raw nested JSON) | shell | Active | `requirement-shell-output-requirements.md` | 2026-09-06 |
| requirement-shell-script-coding | POSIX `/bin/sh` coding-style specialize-in home (without it, portable lessons arrive raw) | shell | Active | `requirement-shell-script-coding.md` | 2026-09-30 |
| requirement-shell-self-management | Self-management lifecycle (version-check, update, uninstall, about). Channel default `cloudgen` / `qemu-cli` | shell | Active | `requirement-shell-self-management.md` | 2026-09-30 |

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for qemu-cli.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files (or future registered ones) — never `template-*` / `skill-*` as behavioral authority.  
4. This versioned surface lists **requirement rows only** — do not dump templates / skills / terminologies / incidents path inventories here (git-surface; INC-20260712-005).  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Registry discipline (summary only):** invent no paths; same-change file+row; empty registry valid at genesis; this file stays **requirement rows only** (no harness tree dumps).  
7. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md` (this registry includes it).

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.

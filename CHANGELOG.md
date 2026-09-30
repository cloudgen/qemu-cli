# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.4.1] - 2026-09-30

### Added

- Product name **qemu-cli**. The ship unit is `src/qemu-cli` (companion `src/qemu-cli.sha256`). Bootstrap `src/selfmanaged` stays in the tree and is not this product
- `setup` installs QEMU on Debian and derivatives, Red Hat, CentOS, Rocky Linux, Fedora, Alpine, and macOS. A normal Linux login that is not the administrator is told to re-run as the administrator. This program does not call `sudo`
- Image families Ubuntu, Rocky Linux, Alpine, and busybox, and QEMU guests this tool owns (the product word is container): list, create, start, stop, execute, shell, remove
- On a terminal, no arguments opens the numbered menu: **1** setup, **2** images, **3** containers, **6** language, **8** self-management, **9** Exit
- Eight menu languages: English, 繁體中文, Español, Français, Deutsch, 简体中文, 日本語, 한국어. The choice is saved at `~/.local/qemu-cli/language`. `QEMU_CLI_LANG` covers one run and does not write that file

### Changed

- Channel defaults are `cloudgen` / `qemu-cli`. Install URL `https://raw.githubusercontent.com/cloudgen/qemu-cli/main/src/qemu-cli`
- Cache environment names are `QEMU_CLI_CACHE_HOST` and `QEMU_CLI_CACHE_SKIP`
- `prompt_ask` assigns `PROMPT_ASK_VALUE` in the current shell

## [1.4.0] - 2026-09-27

### Added

- Cache folder is per login and per process. Linux: `/dev/shm/cache/cache-<app>-<login>-<pid>`, then `/tmp/cache/...`, then `~/.cache/cache-<app>-<pid>`. Git Bash: `/tmp/cache/...`, then `~/AppData/Local/Temp/cache-<app>-<pid>`. Mac: `/tmp/cache/...`, then `~/Library/Caches/cache-<app>-<pid>`, then `~/cache/cache-<app>-<pid>`
- `about` prints **Cache folder used**, **preferred**, **1st fallback**, and **2nd fallback** when this computer has one
- Durable data for this login is `~/.local/selfmanaged` (no login suffix and no process id)
- Law: `requirement-shell-cli-storage` **1.4.0**. Suite **TP-STOR-04**

### Changed

- Skipping a cache folder prints no warning and no error. An error is only when every folder for this computer failed
- Scratch files inside the cache folder use `mktemp` names. The directory name carries the process id; the file name does not
- `about` no longer labels scratch **Storage (effective)** / **Storage (fallback)**

## [1.3.2] - 2026-09-27

### Added

- On a terminal, `selfmanaged` with no arguments (and `selfmanaged menu` / `main`) opens a numbered list
- Item **8** is **self-management**. Under it: **82** version, **83** about, **84** version-check, **85** self-update, **86** self-uninstall, **87** self-install, **0** Back
- **9** leaves. A wrong number reprints that list. A finished command returns to the first list
- Short names are bold. Explanations are italic and light gray

### Changed

- A pipe, quiet, or json run with no arguments still places the program (or says it is already installed)
- **81** install stays unused. This program has no separate payload install

## [1.3.1] - 2026-09-27

### Changed

- The installable file is `src/selfmanaged`, with companion `src/selfmanaged.sha256` beside it
- The curl install link is `https://raw.githubusercontent.com/cloudgen/selfmanaged/main/src/selfmanaged`
- `SCRIPT_URL` is composed from `REPO_USER`, `REPO_NAME`, and `SCRIPT_RELPATH` (default `src/${APP_NAME}`)
- `help` lists `SCRIPT_RELPATH`
- Copies already installed from the previous raw path need this new one-liner. `self-update` on **1.3.0** still requests `.../main/selfmanaged`, which is no longer published

### Security

- Regenerated `src/selfmanaged.sha256` for **1.3.1**

## [1.3.0] - 2026-09-17

### Added

- Named CLI place verb **`self-install`** (`inst_self_install`). When process `$0` is the script (not `/bin/sh` / `/bin/bash` / …), place **copies that file** and does not download. Interpreter `$0` (`curl | sh`) still downloads with companion digest.
- Dest mode on place: **0755** global, **0700** local (no `chmod +x` **0711** trap).
- Product law `requirement-shell-cli-self-install.md`. Suite **TP-SI-01** .. **TP-SI-08** (including no `chmod +x` and isolated `GLOBAL_BIN` **0755**).
- Specializee dest-mode contract: B **MUST** keep `inst_cli_dest_mode` and **MUST NOT** restore `chmod +x` (global **0711** → `/bin/sh: Permission denied` for other logins).

### Changed

- Product version SSOT bumped to **`1.3.0`** (ship unit, README badge, SECURITY, companion digest).
- Empty argv / TTY yes / quiet / json first-shot call `inst_self_install` instead of download-always `inst_perform_install`.
- `install` is a **compatibility alias** of `self-install` (this product has no payload).
- Help lists `self-install` first.

## [1.2.4] - 2026-09-06

### Added

- Active coding-style law `requirement-shell-script-coding.md` (specialize-in home; class residual no longer Gap).
- Suite lock-in **TP-JSON-RAW-01** / **TP-CLI-12**: `out_json` `@key` inserts raw nested JSON (closes SM-PLAN-01).
- **TP-CS-01**: ship unit has no `util_sudo` / command-position `sudo`.
- Related shell requirements: section **Under command line for normal user only** (Termux / Git Bash / Windows cmd — Type 1/2 unused).

### Changed

- Product version SSOT bumped to **`1.2.4`** (ship unit, README badge, SECURITY, companion digest).
- Product README Description uses people-first voice (install for yourself; empty command line = install-ensure). Help `DESCRIPTION` no longer leads with Type 0.

### Fixed

- Previous-incident lock-in: `out_json` `@key` capability had no suite assertion (L-JSON-RAW-01 / SM-PLAN-01).

## [1.2.3] - 2026-09-02

### Fixed

- **SM-BUG-01:** `inst_maybe_install` under quiet/JSON now calls `inst_perform_install` and returns its status (no fake success skip). Prompt helpers consume process `TTY`.

### Changed

- Product version SSOT bumped to **`1.2.3`** (ship unit, README badge, SECURITY, companion digest).
- Every registered requirement now has a **§1.1 Human-facing** block (who / what happens / what you type).
- First-install helper law: under quiet/JSON, `inst_maybe_install` **must place** the program (same as empty-argv Case A).

### Added

- Review report `reviews/reports/2026-09-02-bug-inst-maybe-install-quiet-json-skip.md`; lesson `L-INST-MAYBE-01`; test-plan row `TP-INST-MAYBE-01` / **TP-LC-10**.
- `.gitignore` entries for harness transfer safety backups (`.h1-backup-*` / `.h2-backup-*` / `.harness-*-bak-*`).

## [1.2.2] - 2026-08-11

### Added

- **Specializee contract** (bootstrap A → specialized B) in product law:
  - Empty argv stays Type O install-ensure; domain setup uses explicit verbs (`requirement-shell-cli-zero-arguments` v1.2.0).
  - Channel / identity / `out_*` / root host-mutation / help order / REQ retarget hygiene (`requirement-shell-cli-interface` v1.1.0).
  - Domain prefix + temporary output-shim note (`requirement-shell-modular-function-design`); `@key` nested JSON specializee note (`requirement-shell-output-requirements`).
- **Ship-unit injection anchors** in `./selfmanaged`: `DOMAIN_HELP_ROWS`, `DOMAIN_ABOUT_FIELDS`, `DOMAIN_DISPATCH_FLAGS`, `DOMAIN_DISPATCH_COMMANDS`, `DOMAIN_DISPATCH_ROUTES`.
- **CI test isolation:** `ci_isolated_env` exports isolated `GLOBAL_BIN` so host `/usr/local/bin/selfmanaged` cannot shadow install lifecycle tests (port from gitlab-nginx specialize lesson).
- Living **revision plan:** `reviews/revision-plan.md` (items 1–3 closed in 1.2.2; residual backlog).

### Changed

- Product version SSOT bumped to **`1.2.2`** (ship unit, README badge, SECURITY, companion digest).
- Requirements Implementation Notes Version SSOT aligned to **1.2.2** (`requirement-class-software-dev`, `requirement-shell-self-management`); registry header date refreshed.
- Reviews residual: report baseline `PASS=102`; `L-REQ-CIAO-URL-01` / SM-REV-05 lesson recorded.

## [1.2.1] - 2026-07-19

### Changed

- Product version SSOT bumped to **`1.2.1`**:
  - Runtime: `VERSION="1.2.1"` in `./selfmanaged`.
  - Docs: README Version badge + runtime SSOT prose + Last Update; [`SECURITY.md`](./SECURITY.md) supported versions (`1.2.1` current).
  - Requirements: class law `requirement-class-software-dev.md` registered; shell REQs CIAO v2.10.2 principle renumber; DoD on storage + automatic-checksum; registry inventory **1 class + 9 shell**.
- Companion digest **`selfmanaged.sha256`** regenerated (bare 64-char hex of `./selfmanaged`).

### Added

- Software-development **class requirement** (`requirement-class-software-dev.md`) + registry Area `class`.
- Product review report `reviews/reports/2026-07-19-selfmanaged-product-review.md` (baseline PASS=102).

### Fixed

- Requirements hygiene from review: class gate, CIAO principle numbering, definition-of-done gaps, git-identity / SSH profile pre-git reporting (harness).

## [1.2.0] - 2026-07-16

### Changed

- Product version SSOT bumped to **`1.2.0`**:
  - Runtime: `VERSION="1.2.0"` in `./selfmanaged` (and matching defaults in `app_about` / `app_version`).
  - Docs: README Version badge + runtime SSOT prose + Features / Environment / Examples for storage + Last Update; [`SECURITY.md`](./SECURITY.md) supported versions (`1.2.0` current) and isolation/trust notes; [`AGENTS.md`](./AGENTS.md) + `docs/README.md` nine-REQ inventory; [`tests/README.md`](./tests/README.md) about storage coverage.
  - Requirements Implementation Notes: CLI interface + self-management document live product version `1.2.0`.
- Companion digest **`selfmanaged.sha256`** regenerated (bare 64-char hex of `./selfmanaged`).

### Added

- **CLI storage resolve** as product law and ship-unit wire:
  - `requirement-shell-cli-storage.md` (Active) + registry row (nine shell REQs total).
  - `util_resolve_storage` creates chosen tier root fail-closed; `app_main` exports `EFFECTIVE_STORAGE_DIR` + `TMPDIR`; `about` human/JSON expose `effective_storage` / `storage_dir`.
  - Tests: about storage fields, isolation under app name + user, directory exists after resolve.
- Origin-A lock-in from reviews (APP_NAME hard-assign, footer cites live REQs only, `out_json` `@key` raw nested support).

### Fixed

- Storage resolver previously dead / unused from main (SM-STOR-01 class) — wired and covered by suite.

## [1.1.0] - 2026-07-14

### Changed

- Product version SSOT bumped to **`1.1.0`**:
  - Runtime: `VERSION="1.1.0"` in `./selfmanaged` (and matching defaults in `app_about` / `app_version`).
  - Docs: README Version badge + runtime SSOT prose + Last Update; [`SECURITY.md`](./SECURITY.md) supported versions (`1.1.0` current).
  - Requirements Implementation Notes: CLI interface + self-management document live product version `1.1.0`.
- Philosophy alignment upgraded to **[CIAO](https://github.com/cloudgen/ciao) v2.10.*** (aligned on **v2.10.2**; previously documented on the 2.9.x line) — README badge, Related Projects, and Contributing call out the 2.10.* target with CIAO-Lite.
- CI tests read product version from the ship unit (`PRODUCT_VERSION` in `tests/helpers.sh`) instead of hardcoding `1.0.0`, so version bumps no longer break CLI / lifecycle assertions or the downgrade-sed path.
- Companion digest **`selfmanaged.sha256`** kept as **bare 64-char hex** of `./selfmanaged` (publisher format; install still first-field-parses `hash  file` lines if present).
- Product ship-unit header/footer: Type 0 bootstrap wording only (foreign product / reverse-lineage claims removed).

### Fixed

- Incomplete version-identity package after the 1.1.0 runtime bump (docs, SECURITY, REQ notes, and tests aligned together).
- Downgrade lifecycle tests failed when `VERSION` was no longer `1.0.0` because channel aging used a frozen sed pattern; tests now rewrite the live `PRODUCT_VERSION`.

## [1.0.0] - 2026-07-13

### Added

- CI test suite under `tests/` (`./tests/run.sh`) and GitHub Actions workflow (`.github/workflows/ci.yml`): CLI surface, companion digest, isolated install lifecycle against a local HTTP channel, uninstall fail-closed, optional `CHECKSUM` pin match/mismatch.
- Initial public baseline of the `selfmanaged` POSIX `/bin/sh` CLI (Type 0 self-management surface).
- Commands: install, version-check, self-update, self-uninstall, about, help, version.
- Centralized `out_*` output SSOT with quiet / JSON / debug modes.
- Online install integrity via **automatic** companion `selfmanaged.sha256` (primary) and optional secondary `CHECKSUM` pin.
- Project requirements under `docs/requirements/` for automatic-checksum (transparent link/value/result), CLI interface, **CLI zero-arguments (Type O)**, output, self-management, modular design, idempotency, and interactive vs non-interactive behavior.
- Portable template `template-automatic-checksum.md` for automatic companion-digest + transparency pattern.
- Root `.gitignore` (docs requirements tracked; agent harness docs and build/temp artifacts ignored).
- Product root [`LICENSE.md`](./LICENSE.md) (MIT) with author-email SSOT on the Copyright line.
- Product root [`SECURITY.md`](./SECURITY.md): vulnerability reporting contact (from LICENSE), supported versions, and Security Design Principles (CIAO).

### Changed

- Product version SSOT set to `1.0.0` for first-commit baseline (`VERSION="1.0.0"`).
- Product [`README.md`](./README.md) rewritten to the product header kit and mandatory section order (Features → Quick Installation → Usage → Examples → Platform Compatibility → Related Projects → Contributing → License → Last Update).
- README identity triad: **selfmanaged** / Shell script bootstrap for self Installation & Maintenance / **1.0.0**; Stars banner for `cloudgen/selfmanaged`.

### Fixed

- Empty argv (**Type O** install-ensure): when already installed (local or global), one-liner / zero-arg reports **already installed** success instead of dumping **help**; `--force` only for deliberate reinstall. Product law: `requirement-shell-cli-zero-arguments`. Tests cover Case A failure, Case B local, and Case C global empty-argv paths.
- Requirements Implementation Notes aligned to product **VERSION `1.0.0`** (removed stale `1.0.0-dev` SSOT text in CLI interface + self-management REQs).
- `version` command routes through `app_version` (single path; JSON `app` + `version` fields preserved).
- `path_add_*` / uninstall PATH cleanup use **`USER_BIN`** (not hardcoded `~/.local/bin` only).
- `version-check` / `self-update` remote fetch via `util_fetch_remote_version` (**curl or wget**).
- SHA-256 via `util_sha256_file` (**sha256sum → shasum → openssl**) for install integrity on Linux/macOS toolchains.
- `out_json` / `out_json_error` escape all string fields (type, message, keys, values, codes).
- `help` Environment lists **`REPO_USER` / `REPO_NAME` / `SCRIPT_URL`** (still omits `CHECKSUM`).
- `util_resolve_storage` third fallback is set -u safe (XDG cache / per-user isolation); `util_get_install_bin_path` wired into uninstall path selection; stale “git-sync” / “RuoYi” comments cleaned.
- `version-check --json` now emits proper key/value fields (`local_version`, `remote_version`, `is_latest`) instead of mis-ordering `out_json` arguments so keys landed in `message`.
- Under `set -u`, resolve/default `HOME` before `USER_BIN` so `env -u HOME` no longer aborts every command (INC-20260713-001 P0).
- Zero-arg auto-install (`curl | sh` / not-installed empty argv) propagates install failure exit status instead of always `exit 0`.
- Automatic companion checksum path sets verified success (`INST_AUTO_CHECKSUM_OK` → `downloaded_checksum_ok`) and prints companion link, expected/actual SHA-256, and PASS/FAIL result in human mode (requirement-shell-automatic-checksum transparency).
- CI suite expanded: strict `ver_check` JSON keys, `env -u HOME`, zero-arg non-zero exit, self-update already-latest, human integrity transparency, downgrade refuse/`--force`.
- `self-uninstall --json` (and quiet/non-TTY without `--force`) no longer emits fake success JSON `"Uninstall cancelled by user."`; it fail-closes with `out_json_error` / `code=confirm_required` and a clear `--force` requirement (binary left in place). Interactive TTY cancel still says cancelled by user.
- Product `README.md` install docs aligned with Config channel SSOT: simple literal online one-liners (`curl -fsSL https://raw.githubusercontent.com/cloudgen/selfmanaged/main/selfmanaged | sh` and elevated shape); **automatic SHA-256** sidecar verification documented from install code (match/mismatch/missing outcomes); no toy hosts; hollow license stub removed.
- Progressive disclosure for newcomers: primary one-liners first; integrity table visible; optional pin and digest regeneration under Examples (INC-20260712-004 class).
- Integrity docs (README + write-readme skill) lead with automatic companion fetch; ban same-origin `CHECKSUM=$(curl …sha256)` as “highest assurance” (INC-20260713-003 partial remediation).
- `CHECKSUM` treated as install-path runtime pin only: removed from `help` Environment; requirements/templates forbid listing it in `help`/`about`.
- Install channel Config: `REPO_USER` / `REPO_NAME` compose default `SCRIPT_URL` as raw GitHub content URL (`https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/main/${APP_NAME}`); header comment and product docs aligned.
- Agent process docs (`skill-write-readme`, `skill-commit-check`, online-install template/term/checklist, no-hardcode policy) require Config-channel → simple README one-liner and forbid 404 veto on pre-publish projects.

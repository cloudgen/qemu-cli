**file**: docs/requirements/requirement-shell-cli-interface.md  
**Status**: Active (Version 1.3.0)  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **POSIX shell CLI interface** of qemu-cli: command surface, privilege typing, global flags, dispatcher behavior, output modes, and interactive vs non-interactive rules.

It keeps Type 0 self-management of this CLI (`self-install`, `version`, `about`, `version-check`, `self-update`, `self-uninstall`). QEMU setup, images, and containers are domain commands owned by `requirement-domain-qemu.md` and listed here so every routed verb has two homes. There is **no** Type 2 dedicated system account.

**Scope:** User-facing command names, flags, dispatch, privilege labels, and mode contracts.  
**Out of scope (own requirements when specialized):** Online-install checksum mechanics detail, self-management safety beyond the command surface, shell coding style, full output-function catalog (cited, not re-owned).

### 1.1 Human-facing

**In one sentence:** This file is the word list: `setup`, `image`, and `container` change QEMU guests, while `self-install`, `version`, and `self-update` only look after this program.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | The person who types the command | `qemu-cli help` · `qemu-cli setup` |
| The other role | Empty argv (place this CLI) and lifecycle safety | `requirement-shell-cli-zero-arguments.md` · `requirement-shell-self-management.md` |
| Not this file | Image files, package tables, `out_*` internals | `requirement-domain-qemu.md` |

| Includes | Excludes |
|----------|----------|
| Command names, flags, “unknown command” fail | Re-owning the QEMU package table or image JSON |
| Empty-argv **row** pointing at the zero-arguments file | A dedicated system account |

| Surface | What you open | What for |
|---------|---------------|----------|
| `qemu-cli help` | Command | QEMU verbs and self-management verbs in separate sections |
| `./src/qemu-cli` | Program file | Dispatcher |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See the words | Help lists setup, image, container, and the self-management verbs. An unknown word is an error. | `qemu-cli help` |
| Ask for JSON | Same verbs; structured objects; no human banners. | `qemu-cli --json version` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Command surface (portable shape)

Every CIAO-Lite shell CLI **MUST** expose a documented command set. Commands **MUST** map to exactly one privilege type. Unclassified commands are incomplete design.

| Category | Privilege | Meaning | Portable examples |
|----------|-----------|---------|-------------------|
| **Type 0 – Self-management / CLI lifecycle** | Invoking user (no elevation required for user-owned install) | Manage the CLI binary and diagnostics | `version`, `about`, `help`, `version-check`, `self-update`, `self-uninstall`, `menu`, `main` |
| **Type 0 – Install CLI binary** | Invoking user (root → global path; non-root → user path) | First-time or explicit placement of the CLI | `self-install` (canonical); `install` alias; empty argv **Type O install-ensure** — `requirement-shell-cli-zero-arguments.md` · `requirement-shell-cli-self-install.md` |
| **Type 0 – Guest and image files** | Invoking user | Image records and QEMU processes under persistence | `image`, `container` — behavior `requirement-domain-qemu.md` |
| **Type 1 – Host QEMU packages** | Already user id 0 on Linux when packages must change; this login when QEMU is already on `PATH` or when macOS Homebrew installs as this login | Install QEMU on this computer | `setup` — `requirement-domain-qemu.md`. **No** `sudo` wrap |
| **Type 2 – Dedicated system user** | Not used | No dedicated account | none |

**Execution rules (core):**

1. Type 0 commands **MUST** run as the invoker without requiring a dedicated system user.
2. Type 1 (when added later) **MUST** use controlled internal escalation; normal users **MUST NOT** be forced to manually prefix every privileged sub-step as a permanent UX rule.
3. Type 2 (when added later) **MUST** run as the dedicated system user (context switch if needed). Mixing Type 1 host bootstrap with Type 2 app toolchain in one command is forbidden (see incident policy under system-user / three-layer privilege terms).
4. Privilege type for each command **MUST** be documented in help and in this requirement’s Implementation Notes.

### 2.2 Global flags (portable)

| Flag | Env / state | Behavior |
|------|-------------|----------|
| `--quiet`, `-q` | `QUIET=1` | Suppress non-error human output; errors and fatal paths still visible |
| `--json` | `JSON=1` (implies quiet) | Machine-readable structured output; no human banner text |
| `--debug` | `DEBUG=1` | Extra diagnostics when designed (must not break JSON purity on stdout) |
| `--force` | Force/reinstall policy vars | Skip safe confirms or force reinstall only where documented; never silent security bypass |

Additional flags **MAY** be added only when documented here (or a superseding requirement) and wired in the dispatcher.

### 2.3 Dispatcher and entry rules (portable)

1. **Single entry:** A single main dispatcher (e.g. `app_main`) **MUST** parse global flags and route commands.
2. **Unknown command:** **MUST** fail loudly with a clear error and pointer to `help` (via output SSOT).
3. **Zero-arg split:** Interactive empty argv (`TTY=1`, not quiet, not json) **MUST** open the numbered menu (`requirement-shell-cli-default-interaction.md`). Non-interactive / quiet / json empty argv **MUST** mean CLI self-install-ensure (not help, not the menu). Already installed on that path → success no-op (“already installed”), not help and not blind reinstall. How (copy vs download, dest mode): `requirement-shell-cli-self-install.md`. Full empty-argv matrix: `requirement-shell-cli-zero-arguments.md`.
4. **Idempotent install skip:** Self-install **MUST** no-op when already installed unless force/reinstall policy is set.
5. **No raw user I/O:** User-facing messages **MUST** go through the centralized `out_*` system (see output template/term).

### 2.4 Output and mode contracts (portable)

| Mode | Contract |
|------|----------|
| Human (default TTY) | Prefixed messages via `out_*`; colors only when TTY and not quiet/json |
| Quiet | Suppress info/success/plain noise; still show errors / fatal |
| JSON | Force quiet; emit structured JSON via `out_json` / `out_json_error`; no mixed human lines on success path |
| Non-interactive | Never hang on prompts; use safe defaults or `--force`/env policy |

Destructive Type 0 actions (e.g. uninstall) **MUST** confirm when interactive unless force policy is set; non-interactive **MUST NOT** block on stdin.

### 2.5 Help surface (portable)

`help` **MUST** list:

- Usage line  
- Every supported command with one-line purpose  
- Privilege category (at least Type 0 vs elevated vs system-user when those exist)  
- Global flags  

In JSON mode, help **MUST NOT** dump long human text; return a short structured success/note object instead.

**Recommended help section order** (specializee-friendly; Type 0 bootstrap uses Type 0 first):

1. Title / short description  
2. Usage  
3. **Type 0 self-management** commands  
4. **Domain commands** — `setup`, `image`, `container` and the subcommands in the table below (`requirement-domain-qemu.md`)  
5. Global options  
6. Environment / channel vars (never `CHECKSUM` on help)

Ship-unit injection anchors (comments in `./src/qemu-cli`): `DOMAIN_HELP_ROWS`, `DOMAIN_ABOUT_FIELDS`, `DOMAIN_DISPATCH_FLAGS`, `DOMAIN_DISPATCH_COMMANDS`, `DOMAIN_DISPATCH_ROUTES`.

### 2.5.1 Specializee contract (bootstrap origin → specialized B)

When specializing product **B** from this bootstrap (**A → B only**):

| Concern | MUST | MUST NOT |
|---------|------|----------|
| **Channel** | B Config defaults `REPO_USER` / `REPO_NAME` / `SCRIPT_URL` for **B’s** product channel | Point B’s default channel at A’s raw URL (or A at B’s) without explicit user order |
| **Identity** | `APP_NAME` is `qemu-cli` | Leave the bootstrap donor name as `APP_NAME` |
| **Output** | All domain user/machine messages via `out_*` (temporary shims → `out_*` OK) | Parallel `echo`/`printf` banners or a second JSON family as product UI |
| **Host-mutating domain** | Privilege gate (**root** / designed escalation) **before** any host mutation on **every** path (interactive **and** non-interactive) | Non-interactive “success” after partial host writes as non-root |
| **Dispatch** | Single `app_main`; add domain verbs in the same parse pass as Type 0 | Drop Type 0 routes while claiming same architecture as A |
| **Help / about** | Keep Type 0 rows; add domain rows/fields at the injection anchors | Replace help entirely with domain-only text |
| **Requirements retarget** | Rewrite product identity only; keep CIAO / peer URLs (`github.com/cloudgen/ciao`, …) | Bulk `sed` org renames that break philosophy links |
| **Domain law** | After domain extend: one Active `requirement-domain-*` with four pillars | Domain law only on A; reverse-copy B domain onto A |
| **Global dest mode** | Keep `inst_cli_dest_mode`; `${GLOBAL_BIN}/B` **0755** so other logins can open the shebang | `chmod +x` on mktemp (**0711**); treat USER_BIN-only as dest-mode proof |

### 2.6 Implementation Notes (this project)

| Item | Value for qemu-cli |
|------|------------------------|
| **Product / binary name** | `qemu-cli` (`APP_NAME`, default `qemu-cli`) |
| **Primary executable (law)** | `src/qemu-cli` (POSIX `/bin/sh`, single-file for `curl \| sh`) |
| **Primary executable** | `src/qemu-cli` (POSIX `/bin/sh`). Bootstrap `src/selfmanaged` remains and is not this ship unit |
| **Dispatcher** | `app_main` (always invoked at end of script: `app_main "$@"` — no `${0##*/}` / APP_NAME basename gate; required for `curl \| sh`) |
| **Output SSOT** | `out_text` + wrappers (`out_info`, `out_success`, `out_warn`, `out_error`, `out_die`, `out_plain`, `out_json`, …) |
| **Version SSOT** | `VERSION` default `1.4.1` (script header / config block: `VERSION="1.4.1"`) |
| **Install paths** | Global: `GLOBAL_BIN` default `/usr/local/bin`; User: `USER_BIN` default `${HOME}/.local/bin` |
| **Remote channel env (help surface)** | `REPO_USER` default `cloudgen`. `REPO_NAME` default `qemu-cli`. `SCRIPT_RELPATH` default `src/qemu-cli`. `SCRIPT_URL` default `https://raw.githubusercontent.com/cloudgen/qemu-cli/main/src/qemu-cli`. An operator may override any of those. If `SCRIPT_URL` is unset, download, `version-check`, and `self-update` fail closed. Copy-from-script `$0` does not use this channel. **MUST NOT** use the bootstrap donor repository as this product's home. `help` **MUST** list `REPO_USER`, `REPO_NAME`, `SCRIPT_RELPATH`, and `SCRIPT_URL`, and **MUST NOT** list `CHECKSUM`. `about` **MUST NOT** list `CHECKSUM`. |
| **Type 1** | `setup` only — `requirement-domain-qemu.md`. No `sudo` |
| **Type 2 / dedicated system user** | **Not used** |

#### Supported commands (normative for this project)

| Command | Type | Handler (current) | Required behavior |
|---------|------|-------------------|-------------------|
| *(no args — empty argv)* | Type 0 | `app_main` → `app_default` or `inst_self_install` | **Interactive:** numbered menu. **Non-interactive / quiet / json:** Type O CLI self-install-ensure (not help). See `requirement-shell-cli-zero-arguments.md` · `requirement-shell-cli-default-interaction.md` |
| `self-install` | Type 0 | `inst_self_install` | Place **this CLI** (copy when `$0` is a script; download when piped). Dest **0700** local / **0755** global. Dual mention: `requirement-shell-cli-self-install.md`. Sample: `qemu-cli self-install` |
| `install` | Type 0 | `inst_self_install` | **Alias of `self-install`**. Places this CLI only. It does **not** install QEMU. Sample: `qemu-cli install` |
| `setup` | Type 1 when Linux packages must change; Type 0 when QEMU is already on `PATH` or macOS Homebrew runs as this login | `qemu_setup` | Install QEMU for this computer. Dual mention: `requirement-domain-qemu.md`. Sample: `qemu-cli setup` |
| `image` | Type 0 | `qemu_image_list` / `qemu_image_create` / `qemu_image_show` / `qemu_image_remove` | Subcommands `list`, `create`, `show`, `remove`. Families `ubuntu`, `rocky`, `alpine`, `busybox`. Samples: `qemu-cli image list` · `qemu-cli image create ubuntu` · `qemu-cli image show alpine` · `qemu-cli image remove busybox --force` |
| `container` | Type 0 | `qemu_container_list` / `qemu_container_create` / `qemu_container_start` / `qemu_container_stop` / `qemu_container_execute` / `qemu_container_shell` / `qemu_container_remove` | Subcommands `list`, `create`, `start`, `stop`, `execute`, `shell`, `remove`. Samples: `qemu-cli container list` · `qemu-cli container create --name web --image ubuntu` · `qemu-cli container start web` · `qemu-cli container stop web` · `qemu-cli container execute web -- uname -a` · `qemu-cli container shell web` · `qemu-cli container remove web --force` |
| `version` | Type 0 | `app_main` / `app_version` | Print local version; JSON object when `--json` |
| `about` | Type 0 | `app_about` | Diagnostics: install presence, global/local paths, user, shell, TTY; **Cache folder used**, **preferred**, **1st fallback**, **2nd fallback** when this host has one; **Persistence storage** `${HOME}/.local/${APP_NAME}` (`requirement-shell-cli-storage`); domain fields `qemu_present`, `qemu_bin`, `host_os_family`, `image_dir`, `container_dir`, `kvm_usable`; JSON when `--json`; **no `CHECKSUM` field**. The about title follows the menu language. The cache-folder labels stay English (`requirement-shell-cli-language.md`) |
| `version-check` | Type 0 | `ver_check` | Compare local vs remote `VERSION` from `SCRIPT_URL`; fail clearly if URL unset/unreachable |
| `self-update` | Type 0 | `inst_self_update` | Fetch remote version; reinstall when policy allows; reuse install primitives |
| `self-uninstall` | Type 0 | `inst_self_uninstall` | Remove managed binary; PATH cleanup only if `~/.local/bin` empty (user installs) |
| `help` | Type 0 | `app_help` | Full usage in human mode; short JSON note in JSON mode. **QEMU** section and **self-management** section are separate. Environment lists channel vars only — **not** `CHECKSUM`. No test-purpose section (this product has none) |
| `menu` | Type 0 | `app_default` | Numbered list on a TTY (front **1** / **2** / **3** / **6** / **8** / **9**). Off a TTY: help. `language` is not an argv verb. Sample: `qemu-cli menu` |
| `main` | Type 0 | `app_default` | Alias of `menu` |

#### Global flags (normative wiring for this project)

| Flag | Required wiring |
|------|-----------------|
| `--quiet`, `-q` | Set `QUIET=1` in `app_main` |
| `--json` | Set `JSON=1` and `QUIET=1` in `app_main` |
| `--debug` | Set `DEBUG=1` in `app_main` |
| `--force` | Parsed by `app_main` → `FORCE=1` and `FORCE_REINSTALL=1`; used by CLI reinstall, self-update (incl. deliberate downgrade), uninstall confirm skip, `setup` reinstall, and image/container remove confirm skip |

#### Dispatcher acceptance criteria (this project)

1. Unknown token after flag parse → `out_die` with pointer to `qemu-cli help`.  
2. Zero-arg off a TTY, or quiet, or json → CLI self-install-ensure (not `setup`, not help). Already installed → already-installed success. Failures non-zero. Zero-arg on a TTY opens the numbered menu.  
3. Command routing table in `app_main` **must** include every row in the command table above.  
4. Help text **must** stay aligned with that table (no orphan commands, no listed-but-unrouted commands).  
5. User-facing strings **must not** use raw `echo`/`printf` outside the `out_*` system (protected low-level helpers excepted only if already CIAO-marked and not for general messages).

#### Explicitly out of scope

- Type 2 dedicated system user, Docker, Podman, and LXC  
- Any host package other than the QEMU set in `requirement-domain-qemu.md`  
- Image families other than Ubuntu, Rocky Linux, Alpine, and busybox  

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): Unknown commands fail loud; force and prompts gate destructive ops; quiet/json never hide fatal errors incorrectly.  
- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Every command has one privilege type, one handler, and documented flags.  
- **CIAO Principle 3 – Anti-fragile** (https://github.com/cloudgen/ciao): Works under TTY, `curl | sh`, quiet, and JSON; root vs user install paths.  
- **CIAO Principle 5 – Single Source of Output** and **Principle 14 – Security & Traceability** (https://github.com/cloudgen/ciao): Central `out_*`; JSON/human separation.  
- **CIAO Principle 6 – Single Point of Entry** (https://github.com/cloudgen/ciao): `app_main` is the dispatcher SSOT.  
- **CIAO Principle 10 – Least-Privilege User** (https://github.com/cloudgen/ciao): Type 0 default for CLI self-care; no invented system-user requirement for binary lifecycle.  
- **CIAO Principle 16 – Interactive vs Non-Interactive** (https://github.com/cloudgen/ciao): No hang in non-interactive; prompts only when appropriate.  
- **CIAO Principle 4 (O) / Principle 20 – Over-protect / Protect Against AI & Human Modification** (https://github.com/cloudgen/ciao): Protection Rule below blocks privilege and UX regressions.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail loud on bad input; never silent wrong privilege context.  
- **Intentional:** Command table + help + dispatcher stay synchronized.  
- **Anti-fragile:** Per-user and global install; network/remote optional until `SCRIPT_URL` set.  
- **Over-protect:** Do not collapse Type 0/1/2, remove JSON quiet contract, or reintroduce raw output for user messages.  
- **SSOT:** `APP_NAME` / `VERSION` / flags at config defaults; output via `out_*`; dispatch via `app_main`.  
- **Idempotency:** Already-installed install path is a no-op unless force reinstall.  
- **Respect old working logic:** Surgical changes only; preserve Protection Zones and battle-tested install/self-management helpers unless explicitly redesigning.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Remove or rename the normative Type 0 commands without updating this requirement and help together.  
2. Add Type 1 or Type 2 commands that mix host bootstrap with app toolchain in a single privileged install (three-layer privilege: Type 0 tool self-management must stay separate from Type 1 host bootstrap and Type 2 system-user app ops).  
3. Force manual `sudo` as the only UX for every elevated sub-step when internal escalation is the designed pattern (when Type 1 is introduced).  
4. Bypass `out_*` with raw user-facing `echo`/`printf` for normal messages.  
5. Break the contract that `--json` implies quiet and machine-oriented output.  
6. Drop zero-arg install-ensure for the classic `curl | sh` path (including already-installed success no-op) without an explicit requirement change (`requirement-shell-cli-zero-arguments.md`).  
7. Document flags in help that the dispatcher does not parse (or leave `--force` documented-only).  
8. Invent a dedicated system user as mandatory for Type 0 CLI self-management without a specialized architecture requirement.

**Violating this rule is a critical CLI interface regression.**

---

## 5. Definition of done (CLI interface)

This requirement is satisfied for the qemu-cli shell CLI when all of the following hold:

1. Every command in §2.6 is routed and documented.  
2. Global flags in §2.6 are parsed and honored.  
3. Output modes match §2.4 (including JSON purity).  
4. Install privilege paths remain invoker-based (root/global vs user/local).  
5. No Type 1/2 surface claims exist without matching specialized requirements.  
6. Protection Rule items are not violated in code or docs.  
7. Traceability: implementation changes cite this file path / key `requirement-shell-cli-interface`.

---

## Under command line for normal user only

This product may run on Termux, Git Bash, Windows cmd, or the same class (this login only).

**This requirement:** on that class, `setup` stays in the command list and **MUST** fail closed as `requirement-domain-qemu.md` states. Dispatch **MUST NOT** enable a dedicated system account. **MUST NOT** recommend `sudo curl | sh`. Git Bash and Windows cmd **MUST NOT** invoke Termux `pkg`.

| MUST | MUST NOT |
|------|----------|
| Keep self-management as this login | Enable a dedicated system account |
| Keep `setup` visible and failing closed | Wrap `sudo` / `apt` / `dnf` / `apk` / `brew` on that class |

---

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-domain-qemu.md` | Dual mention of `setup`, `image`, `container` |
| `docs/requirements/requirement-shell-cli-default-interaction.md` | Numbered menu |
| `docs/requirements/requirement-shell-self-management.md` | Lifecycle command semantics |
| `docs/requirements/requirement-shell-output-requirements.md` | Output SSOT and channels |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | TTY / automation mode behavior |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv install-ensure (not installed / local / global) |
| `docs/requirements/requirement-shell-cli-self-install.md` | Dual mention `self-install`; `$0` copy vs download; dest 0755/0700 |
| `docs/requirements/requirement-shell-idempotency.md` | Re-run safety for ensure ops |
| `docs/requirements/requirement-shell-modular-function-design.md` | Prefix ownership (`app_`, `inst_`, `out_*`) |
| `docs/requirements/index.md` | Registry SSOT |
| `./src/qemu-cli` | Implementation under test |

---

**Last Updated**: 2026-09-30  
**Owner**: qemu-cli project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; CIAO Principles 1, 2, 3, 5, 6, 10, 16, 4, 20 (v2.10.2) (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).

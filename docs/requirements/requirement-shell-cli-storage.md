**file**: docs/requirements/requirement-shell-cli-storage.md  
**Status**: Active (Version 1.4.2 – language leaf beside the image and container trees)  
**Area**: shell  
**Key**: `requirement-shell-cli-storage`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **shell CLI storage** of qemu-cli. **Storage** means **two** classes:

| Class | Role | Survives reboot |
|-------|------|-----------------|
| **Cache folder** | Volatile scratch / temps / staging | No (shm/tmp) or maybe (home fallback) |
| **Persistence storage** | Durable per-login app data | Yes (under this login’s `$HOME`) |

It owns path **shapes**, central resolvers, `app_main` wire, and about diagnostics for both classes.

The preferred cache is **not** a ram-drive **project** tree (`/dev/shm/qemu-cli` or `/dev/shm/qemu-cli-<login>`). It lives under `/dev/shm/cache/` (Linux) or `/tmp/cache/` (Git Bash and Mac). The leaf is **per login and per process** so two logins never share one cache directory.

Sibling reference for this shape: grok-cli `requirement-shell-cli-storage` **1.4.0**. This file is the qemu-cli law. It does not copy grok-cli deposit paths or auth leaves.

---

### 1.1 Human-facing

Scratch goes in a cache folder. Durable data for this login goes under persistence storage. A skipped cache folder is silent.

| You | Another role | Not this |
|-----|--------------|----------|
| Let the program pick the cache folder and the persistence directory | Another login gets a different leaf | A shared dump that mixes two logins; treating `~/.local/bin` as data |

**Includes:** cache resolver, persistence resolver, about fields. **Excludes:** where the program binary is installed.

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See the cache folder | about names the folder in use, the preferred folder, each fallback this computer has, and persistence storage. A skipped folder prints nothing | `qemu-cli about` / `qemu-cli --json about` |

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Two storage classes (mandatory split)

Volatile leaf (shared parents `/dev/shm` and `/tmp`): `cache-${APP_NAME}-${login}-$$`.  
Home leaf (already per login): `cache-${APP_NAME}-$$`.  
`$$` is **this process id**. `${login}` is `id -un` as one path segment. **MUST NOT** hardcode an app name, a login name, or a process id in those leaves.

| Host | Preferred | 1st fallback | 2nd fallback |
|------|-----------|--------------|--------------|
| Linux (and Termux, and any host that is not Git Bash or Mac) | `/dev/shm/cache/cache-${APP_NAME}-${login}-$$` | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/.cache/cache-${APP_NAME}-$$` |
| Git Bash (`MSYSTEM`, or `uname -s` `MINGW*` / `MSYS*`) | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/AppData/Local/Temp/cache-${APP_NAME}-$$` | none |
| Mac (`uname -s` `Darwin`) | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/Library/Caches/cache-${APP_NAME}-$$` | `${HOME}/cache/cache-${APP_NAME}-$$` |

| Class | Helper |
|-------|--------|
| Cache folder (preferred) | `util_preferred_cache_dir` |
| Cache folder (1st fallback) | `util_fallback_cache_dir` |
| Cache folder (2nd fallback) | `util_fallback2_cache_dir` (empty on Git Bash) |
| Persistence storage | `util_persistent_storage_dir` → `${HOME}/.local/${APP_NAME}` |

Live chosen **cache** root: `util_resolve_storage` (stdout).  
Live **persistence** root: `util_resolve_persistent_storage` (stdout; create-before-return).

On Termux/Android, the chosen cache folder (including `/tmp` and `/dev/shm`) **MAY** be **`noexec`**. Termux uses the **Linux** chain. The cache folder is scratch **only**. **MUST NOT** run a downloaded program from that folder.

**Silent fallback.** Choosing a later tier **MUST NOT** print a warning or an error. **MUST NOT** say that a fallback happened. An error is allowed only when **every** tier for this host failed to be created.

**MUST NOT** mix these with:

| Forbidden as this product’s storage | Why |
|-------------------------------------|-----|
| `${HOME}/.local/bin` / `USER_BIN` | Install binary directory |
| `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${USERNAME}` | Looks like a ram-drive project folder |
| `XDG_CACHE_HOME` or an env override of the chain | The chain above is the law |
| A login suffix or `$$` on persistence | Persistence stays `${HOME}/.local/${APP_NAME}` |

### 2.2 Single cache resolver SSOT

1. **MUST** keep **one** authoritative cache-resolve helper: **`util_resolve_storage`**.  
2. New code that needs a product scratch/cache **root** **MUST** call `util_resolve_storage` (or `mktemp` / `util_mktemp` under a path it returned).  
3. Resolver **MUST** print the chosen directory path on **stdout** for `$(util_resolve_storage)` capture.  
4. User-visible failure about cache **MUST** use Output SSOT (`out_die`).

### 2.3 Live cache resolve priority

Walk this host’s chain in order. First directory that can be created **and** is writable wins. The chain is the table in §2.1.

**Parent:** for `/dev/shm/cache` and `/tmp/cache` the resolver **MUST** create that parent (prefer mode **1777** when creating) so each login can add its own leaf. The **leaf** **MUST** be mode **0700**.

**Create before return:** for the **chosen** leaf, the resolver **MUST** create it, confirm it is **writable**, then print the path. If create/write fails → try the next tier **with no message**. If none work → **MUST** fail closed. **MUST NOT** return a path without creating it. **MUST NOT** `out_die` because one earlier tier failed while a later tier is still untried.

### 2.4 Cache isolation

1. Cache leaves **MUST** include **`cache-${APP_NAME}`**.  
2. Volatile leaves (`/dev/shm/cache` and `/tmp/cache`) **MUST** be `cache-${APP_NAME}-${login}-$$`. Home leaves **MUST** be `cache-${APP_NAME}-$$` (no login segment).  
3. **MUST NOT** use one shared world-writable directory for all logins.  
4. Live product **MUST** export `TMPDIR=${EFFECTIVE_STORAGE_DIR}` so `mktemp` inherits the isolated **cache** root.  
5. Scratch **files** inside the cache directory **MUST** use **`util_mktemp`** (or `mktemp` with an `XXXXXX` template). **MUST NOT** use a predictable `$$` file name.

### 2.5 Persistence storage

1. Persistence **MUST** be **`${HOME}/.local/${APP_NAME}`**.  
2. **`util_persistent_storage_dir`** **MUST** print that path. **`util_resolve_persistent_storage`** **MUST** `mkdir -p` it, confirm it is writable, then print it (fail closed).  
3. **MUST NOT** use `${HOME}/.local/bin` as persistence.  
4. **MUST NOT** store scratch in persistence when a cache root is available.  
5. Persistence **MUST NOT** include a login suffix or `$$`.
6. The menu language file is `${HOME}/.local/${APP_NAME}/language` (one line, mode **0600**). It is not a cache file. Codes and load rules are `requirement-shell-cli-language.md`.

### 2.6 Wire and diagnostics

| Surface | Requirement |
|---------|-------------|
| `app_main` | Resolve once early: `EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)`; `PERSISTENT_STORAGE_DIR=$(util_resolve_persistent_storage)`; export `EFFECTIVE_STORAGE_DIR`, `STORAGE_DIR` (the 1st fallback path), `PERSISTENT_STORAGE_DIR`, `TMPDIR` (`TMPDIR` = cache root) |
| `app_about` human | **MUST** print **`Cache folder used:`** then the live directory; **`Cache folder (preferred):`** then this host’s preferred path; **`Cache folder (1st fallback):`** then the 1st fallback; **`Cache folder (2nd fallback):`** only when this host has a 2nd fallback; **`Persistence storage:`** then `${HOME}/.local/${APP_NAME}`. **MUST NOT** label those lines **Storage (effective)** or **Storage (fallback)**. **MUST NOT** warn or error when the used directory is a fallback |
| `app_about` JSON | **MUST** include `cache_used`, `cache_preferred`, `cache_fallback` (1st), `cache_fallback_2` (2nd, empty string when the host has none), `persistence_storage`, and the live chosen cache root as `effective_storage` (same value as `cache_used`; `storage_dir` = 1st fallback). **MUST NOT** include `CHECKSUM` |

`Cache folder used` is the tier that was created. When the preferred tier is the one used, the used line and the preferred line are the same path. When a fallback is used, the used line is that fallback path and the preferred line still shows the preferred path.

Linux `about` lines (`$$` is this process, not a fixed number):

```
[INFO] Cache folder used: /dev/shm/cache/cache-${APP_NAME}-${login}-$$
[INFO] Cache folder (preferred): /dev/shm/cache/cache-${APP_NAME}-${login}-$$
[INFO] Cache folder (1st fallback): /tmp/cache/cache-${APP_NAME}-${login}-$$
[INFO] Cache folder (2nd fallback): ${HOME}/.cache/cache-${APP_NAME}-$$
[INFO] Persistence storage: ${HOME}/.local/${APP_NAME}
```

Git Bash omits the 2nd fallback line:

```
[INFO] Cache folder used: /tmp/cache/cache-${APP_NAME}-${login}-$$
[INFO] Cache folder (preferred): /tmp/cache/cache-${APP_NAME}-${login}-$$
[INFO] Cache folder (1st fallback): ${HOME}/AppData/Local/Temp/cache-${APP_NAME}-$$
[INFO] Persistence storage: ${HOME}/.local/${APP_NAME}
```

Mac prints preferred under `/tmp/cache/`, 1st fallback under `${HOME}/Library/Caches/`, and 2nd fallback under `${HOME}/cache/`.

### 2.7 Implementation Notes (this project)

| Item | Live value |
|------|------------|
| **Product / binary** | `qemu-cli` |
| **Cache resolver** | `util_resolve_storage` in `src/qemu-cli` |
| **Linux preferred** | `/dev/shm/cache/cache-${APP_NAME}-${login}-$$` |
| **Linux 1st / 2nd** | `/tmp/cache/cache-${APP_NAME}-${login}-$$` then `${HOME}/.cache/cache-${APP_NAME}-$$` |
| **Git Bash** | `/tmp/cache/cache-${APP_NAME}-${login}-$$` then `${HOME}/AppData/Local/Temp/cache-${APP_NAME}-$$` |
| **Mac** | `/tmp/cache/cache-${APP_NAME}-${login}-$$` then `${HOME}/Library/Caches/cache-${APP_NAME}-$$` then `${HOME}/cache/cache-${APP_NAME}-$$` |
| **Persistence** | `${HOME}/.local/qemu-cli` |
| **Persistence resolver** | `util_resolve_persistent_storage` |
| **Scratch files** | `util_mktemp` (mktemp `XXXXXX` under the cache folder) |
| **Test-purpose host** | `QEMU_CLI_CACHE_HOST=linux\|gitbash\|mac` (not an operator setting). The ship unit reads that name |
| **Test-purpose skip** | `QEMU_CLI_CACHE_SKIP=preferred` skips tier 1 with no message. The ship unit reads that name |
| **Image and container trees** | Under the persistence root. Filenames and JSON bodies are owned by `requirement-domain-qemu.md` |
| **Language leaf** | `${HOME}/.local/qemu-cli/language` |
| **Call sites** | `app_main`, `app_about`, `app_lang_load`, `app_lang_save` |
| **Tests** | `tests/test_cli.sh` — **TP-STOR-01** .. **TP-STOR-04** |

### 2.8 Why This Requirement Exists (CIAO)

- **Caution:** Two logins must not share one scratch directory.  
- **Intentional:** Storage is a cache folder **and** persistence storage; about says both.  
- **Anti-fragile:** A missing higher folder still works, and the miss is silent.  
- **Over-protect:** Do not collapse the chain into one shared dump.

---

## Under command line for normal user only

This product may run on Termux, Git Bash, Windows cmd, or the same class (this login only).

**This requirement:** cache and persistence stay under this login. **MUST NOT** create world-writable shared dumps or `/etc` destinations because storage failed. Git Bash and Windows cmd **MUST NOT** invoke Termux `pkg`.

| MUST | MUST NOT |
|------|----------|
| Isolated scratch for this login | Elevate to “fix” a missing `/dev/shm` or `/tmp` |

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Volatile cache first, home cache last for scratch.  
- Persistence is `${HOME}/.local/${APP_NAME}`, not `~/.local/bin`.  
- Isolation before convenience.  
- Create the chosen leaf before returning it.  
- The cache path is distinct from a ram-drive project folder.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Restore `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${USERNAME}` as the preferred cache.  
2. Label about cache lines **Storage (effective)** / **Storage (fallback)**. The labels are **Cache folder used**, **Cache folder (preferred)**, **Cache folder (1st fallback)**, **Cache folder (2nd fallback)** when that host has one.  
3. Drop persistence storage from this requirement or from `about`.  
4. Use `${HOME}/.local/bin` as persistence.  
5. Replace the cache fallback chain with a shared world-writable dump, with `XDG_CACHE_HOME`, or with one leaf shared by every login.  
6. Scatter hard-coded `/tmp/qemu-cli` roots outside the cache resolver.  
7. Leave the resolvers with no call sites while claiming storage is product law.  
8. Echo a tier path without creating it.  
9. Use predictable `$$` scratch **file** names. The cache **directory** itself includes `$$`.  
10. Warn or error only because a higher cache tier was skipped.  
11. Drop `${login}` or `$$` from a volatile cache leaf, or put the login on a home leaf.  
12. Run a program from the cache folder on Termux.  
13. Put a login suffix or `$$` on `${HOME}/.local/${APP_NAME}`.

**Violating this rule is a critical cache isolation regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Exactly one authoritative cache resolver creates and returns the cache root |
| AC-2 | Linux preferred leaf is `/dev/shm/cache/cache-${APP_NAME}-${login}-$$` when that directory is usable. Git Bash and Mac preferred leaf is `/tmp/cache/cache-${APP_NAME}-${login}-$$` |
| AC-3 | `app_main` sets `EFFECTIVE_STORAGE_DIR` / `TMPDIR` / `PERSISTENT_STORAGE_DIR` early |
| AC-4 | `about` human prints Cache folder used, preferred, 1st fallback, 2nd fallback when present, and Persistence storage; JSON has `cache_used` / `cache_preferred` / `cache_fallback` / `cache_fallback_2` / `persistence_storage` |
| AC-5 | Scratch files use `util_mktemp` / `mktemp` XXXXXX; the cache directory name may include `$$`; scratch file names must not |
| AC-6 | Live cache path is not `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${USERNAME}` |
| AC-7 | Persistence path is `${HOME}/.local/${APP_NAME}` and the directory exists after resolve |
| AC-8 | Skipping a cache tier prints no warning and no error. Git Bash has no 2nd fallback. Mac 2nd fallback is `${HOME}/cache/cache-${APP_NAME}-$$` |
| AC-9 | The cache leaf mode is **0700** |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | About fields |
| `requirement-shell-output-requirements` | `out_die` / `out_json` |
| `requirement-shell-self-management` | about lifecycle |
| `requirement-shell-modular-function-design` | `util_*` ownership |
| `docs/requirements/index.md` | Registry |

---

## 7. Definition of done

Storage work for qemu-cli is **not done** if any acceptance criterion above fails, or if `tests/test_cli.sh` does not cover the about fields, the host chains, the silent skip, and persistence.

---

**Last Updated**: 2026-09-30  
**Owner**: qemu-cli project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; sibling grok-cli storage law 1.4.0 (shape only); CIAO Principles (v2.10.2); CIAO-Lite.

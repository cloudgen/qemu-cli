# Test plan — qemu-cli

Maps **baseline coverage** and **finding lock-in (TP-*)** to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Product law:** qemu-cli. The suite entry runs `src/qemu-cli` (version `1.4.1`). Baseline **have** rows were retargeted to that file. Domain rows below are **have** only where an assertion ran.  
**Last update:** 2026-09-30 (suite PASS=253 FAIL=0 SKIP=1; the skip is **TP-QEMU-01** because `qemu-img` or a system emulator was not on `PATH`)

Status: **have** = automated today · **TODO** = needed · **n/a** = not applicable / product choice

---

## Baseline coverage (Type 0)

| Area | Coverage | Evidence |
|------|----------|----------|
| Syntax | have | `sh -n selfmanaged` |
| Companion digest matches ship unit | have | `selfmanaged.sha256` check in suite |
| version / help / about human + JSON | have | `tests/test_cli.sh` |
| help must not list CHECKSUM | have | test_cli |
| about must not include CHECKSUM | have | test_cli |
| about cache folder fields | **have** | cache_used / preferred / fallbacks / persistence_storage |
| Storage isolation / dir exists | **have** | test_cli after SM-STOR wire |
| Unknown command fail-closed | have | test_cli |
| quiet / env -u HOME | have | test_cli |
| Zero-arg Type O paths | have | test_cli + lifecycle |
| self-uninstall --json without --force | have | confirm_required |
| Install / re-install idempotent | have | test_install_lifecycle |
| version-check / self-update / checksum / downgrade | have | lifecycle |
| GLOBAL_BIN isolate under multi-install hosts | **have** | `ci_isolated_env` (1.2.2) |

**Baseline result (2026-07-16 origin fix):** PASS=102 FAIL=0 SKIP=0  
**Baseline re-run (2026-07-19 product review):** PASS=102 FAIL=0 SKIP=0  
**Baseline re-run (2026-08-11 1.2.2):** PASS=102 FAIL=0 SKIP=0  
**Baseline re-run (2026-09-02 1.2.3):** PASS=108 FAIL=0 SKIP=0  
**Baseline re-run (2026-09-06 1.2.4):** PASS=117 FAIL=0 SKIP=0  
**Baseline re-run (2026-09-27 1.3.2):** PASS=164 FAIL=0 SKIP=0  
**Baseline re-run (2026-09-27 1.4.0):** PASS=198 FAIL=0 SKIP=0

---

## Finding-linked TP rows

| TP-ID | Related finding / lesson | Intent | Status | Target / notes |
|-------|--------------------------|--------|--------|----------------|
| TP-STOR-01 | SM-STOR-01, L-STOR-01 | Storage resolver invoked; root exists | **have** | test_cli about + dir exists |
| TP-STOR-02 | SM-STOR-02 | Product law documents storage | **have** | requirement-shell-cli-storage.md |
| TP-STOR-03 | SM-TEST-01 | Isolation: path under APP_NAME + user | **have** | test_cli isolation |
| TP-STOR-04 | requirement-shell-cli-storage 1.4.0 | Per-login per-process cache leaf, silent skip, Git Bash/Mac chains, persistence, mode 0700 | **have** | `tests/test_cli.sh` |
| TP-HYG-01 | SM-HYG-01 | Companion `*.tmp` not present | **have** | removed; gitignore `*.tmp` |
| TP-ID-01 | SM-ID-01 | `APP_NAME="…"` hard-assign | **have** | static + extractors |
| TP-OUT-01 | SM-OUT-01 | about JSON storage fields | **have** | test_cli |
| TP-CSUM-01 | SM-SEC-01, L-CSUM-01 | help/about never advertise CHECKSUM | **have** | test_cli |
| TP-BOOT-01 | L-BOOT-01 | Always reach app_main under pipe | **have** | Indirect via zero-arg |
| TP-UNIN-01 | L-UNIN-01 | self-uninstall --json no force → confirm_required | **have** | test_cli + lifecycle |
| TP-SETU-01 | L-SETU-01 | env -u HOME still works | **have** | test_cli |
| TP-CITE-TERM-01 | L-CITE-TERM-01 | Bootstrap footer cites requirements | **have** | static fix |
| TP-JSON-RAW-01 / TP-CLI-12 | L-JSON-RAW-01, SM-PLAN-01 | `out_json` `@key` raw nested | **have** | `tests/test_cli.sh` — unquoted array/object; string keys stay quoted; JSON=0 no-op |
| TP-CS-01 | coding-style REQ | No `util_sudo` / command-position `sudo` | **have** | `tests/test_cli.sh` static |
| TP-ISO-GLOBAL-01 | SM-REV-01 / gitlab-nginx specialize | Isolated GLOBAL_BIN for lifecycle | **have** | helpers + lifecycle/cli env |
| TP-INST-MAYBE-01 / TP-LC-10 | SM-BUG-01, L-INST-MAYBE-01 | Not installed + QUIET/JSON **through `inst_maybe_install`** must place or fail closed (not `return 0` skip) | **have** | `tests/test_install_lifecycle.sh` |
| TP-SI-01 | shell-cli-self-install | `self-install` with script `$0` copies; dead `SCRIPT_URL` still places | **have** | `tests/test_cli.sh` |
| TP-SI-02 | shell-cli-self-install | Local dest mode **0700** | **have** | `tests/test_cli.sh` |
| TP-SI-03 | shell-cli-self-install | NI empty argv is self-install (copy), not help | **have** | `tests/test_cli.sh` |
| TP-SI-04 | shell-cli-self-install | Interpreter `$0` (`sh -s`) uses channel download | **have** | `tests/test_cli.sh` |
| TP-SI-05 | shell-cli-self-install | Second `self-install` already-installed no-op | **have** | `tests/test_cli.sh` |
| TP-SI-06 | shell-cli-self-install | Help lists `self-install` | **have** | `tests/test_cli.sh` |
| TP-SI-07 | L-DEST-0711-01 | No live `chmod +x`; `inst_cli_dest_mode` names 0755/0700 | **have** | `tests/test_cli.sh` |
| TP-SI-08 | L-DEST-0711-01 | Isolated GLOBAL_BIN dest **0755**; leftover **0711** healed | **have** | `tests/test_cli.sh` |
| TP-CLI-17 | default-interaction | TTY menu: bold short, italic gray explain, italic version; `menu --json` on a TTY still draws the list | **have** | `tests/test_cli.sh` |
| TP-CLI-19 | default-interaction | Bad pick reprints the front board and does not die as unknown argv | **have** | `tests/test_cli.sh` |
| TP-CLI-21 | default-interaction | Finished **82** redisplays the front board | **have** | `tests/test_cli.sh` |
| TP-CLI-22 | default-interaction | Self-management lists **87** and omits **81**; off-TTY `menu` is help | **have** | `tests/test_cli.sh` |
| TP-QEMU-01 | requirement-domain-qemu | `setup` no-op when QEMU is already on `PATH` | automated, skipped when `qemu-img` or a system emulator is absent | `tests/test_cli.sh` |
| TP-QEMU-02 | requirement-domain-qemu | Linux non-root `setup` fails and names the administrator | **have** | `tests/test_cli.sh` |
| TP-QEMU-03 | requirement-domain-qemu | normal-user-only class refuses package install | **have** | `tests/test_cli.sh` |
| TP-QEMU-04 | requirement-domain-qemu | `image list` is only the four families | **have** | `tests/test_cli.sh` |
| TP-QEMU-05 | requirement-domain-qemu | second `image create` does not re-download | **have** | `tests/test_cli.sh` |
| TP-QEMU-06 | requirement-domain-qemu | `image remove` fails while a container uses it | **have** | `tests/test_cli.sh` |
| TP-QEMU-07 | requirement-domain-qemu | container data picker is 1..N | **have** | `tests/test_cli.sh` |
| TP-QEMU-08 | requirement-domain-qemu | second start and second stop of a real guest | **TODO** | `tests/test_cli.sh` |
| TP-QEMU-09 | requirement-domain-qemu | `execute` on a stopped container fails | **have** | `tests/test_cli.sh` |
| TP-QEMU-10 | requirement-domain-qemu | `shell` off a terminal fails and does not hang | **have** | `tests/test_cli.sh` |
| TP-QEMU-11 | requirement-domain-qemu | menu rows **1**, **21**, **31**, **321–325** | **have** | `tests/test_cli.sh` |
| TP-QEMU-12 | requirement-domain-qemu | image and container JSON samples match the domain requirement | **TODO** | `tests/test_cli.sh` |
| TP-QEMU-13 | requirement-domain-qemu | non-interactive create with no name does not prompt | **have** | `tests/test_cli.sh` |
| TP-QEMU-14 | requirement-domain-qemu | JSON output has no private key material | **have** | `tests/test_cli.sh` |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or documented static fix for cite/ID).  
3. Domain proof is required. Mark a **TP-QEMU-*** row **have** only when `tests/test_cli.sh` asserts it. **TP-QEMU-01** stays skipped until `qemu-img` and a system emulator are on `PATH`. **TP-QEMU-08** and **TP-QEMU-12** stay **TODO**. Do not delete the baseline **have** rows.  

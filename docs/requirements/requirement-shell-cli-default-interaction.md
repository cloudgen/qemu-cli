**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 1.2.0)  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered)

## 1. Purpose

This requirement is the project Single Source of Truth for the **numbered terminal menu** of qemu-cli.

On a real terminal, typing only `qemu-cli` (or `qemu-cli menu` / `qemu-cli main`) shows a numbered list. **1** installs QEMU. **2** opens the four image families. **3** opens existing containers. **6** opens the language board (**61–68**). **8** opens self-management **82–87**. **9** leaves. A pipe, a quiet run, or a json run with no arguments still places the CLI and does not open this list. The words on the boards are `requirement-shell-cli-language.md`.

What each domain row does is `requirement-domain-qemu.md`. This file owns when the list appears, the numbers, how a row is drawn, what a bad pick does, and what happens after a command finishes.

**Out of scope:** How place/copy/download works (`requirement-shell-cli-self-install.md`); the non-interactive empty-argv place matrix (`requirement-shell-cli-zero-arguments.md`); the full `out_*` catalog (`requirement-shell-output-requirements.md`).

### 1.1 Human-facing

**In one sentence:** At a terminal, `qemu-cli` shows a numbered board: **1** installs QEMU, **2** lists Ubuntu, Rocky Linux, Alpine, and busybox, **3** lists existing containers, **6** chooses the menu language, and **8** is self-management.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | A person at a terminal | `qemu-cli` then `2` then `21` |
| The other role | A pipe or a script with no one to answer | `curl -fsSL ${SCRIPT_URL} \| sh` |
| Not this file | Package names, image files, checksum math | `requirement-domain-qemu.md` |

| Includes | Excludes |
|----------|----------|
| Front **1**, **2**, **3**, **6**, **8**, **9**; image **21–24**; container **31**, **32**, **321–325**; language **61–68** | Lifecycle verbs on the front board |
| Bold short name and italic gray explain on a terminal | A second menu look |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the list | Front board, then leave | `qemu-cli` then `9` |
| Pick an image | Open **2**, then **21–24** | `qemu-cli` then `2` |
| Pick a container | Open **3**, then **32**, then a name's number | `qemu-cli` then `3` |
| Check or update the CLI | Open **8**, then **82–87** | `qemu-cli` then `8` |
| Choose a language | Open **6**, then **61–68** | `qemu-cli` then `6` |
| Step back | Return to the previous board | `0` |

---

## 2. Core Rules (Mandatory)

### 2.1 When the list appears

qemu-cli has a zero-argument requirement. That file owns empty argv. This file owns the numbered list.

| Situation | What runs |
|-----------|-----------|
| Empty argv, `TTY=1`, `JSON=0`, `QUIET=0` | This menu (`app_default`) |
| Empty argv, no TTY, or `JSON=1`, or `QUIET=1` | `inst_self_install` (not this menu, not help, not `setup`) |
| `menu` or `main` on a TTY | This menu. `--json` and `--quiet` are ignored while the list is drawn |
| `menu` or `main` off a TTY | `app_help` (JSON help when `--json`) |

1. The choice **MUST** be read in the current shell. **MUST NOT** capture a `read` helper with `$()` or backticks.  
2. A failed `read` (EOF) **MUST** leave the current layer without spinning. On the front board that leaves the program. On every other board that returns to the parent board.  
3. **MUST NOT** hang when there is no terminal.

### 2.2 Front board

The front board **MUST NOT** print Back.

| # | Token | Label |
|---|-------|-------|
| *(header)* | — | `**qemu-cli**(*version*) — QEMU setup, images, and containers` |
| **1** | `setup` | `setup: install QEMU on this computer` |
| **2** | `images` | `images: Ubuntu, Rocky Linux, Alpine, busybox` |
| **3** | `containers` | `containers: start, stop, execute, or enter a shell` |
| **6** | `language` | `language: display language for this menu` |
| **8** | `self-management` | `self-management: this CLI install, version, update, uninstall` |
| **9** | Exit | leave the program |

1. **9**, `exit`, `quit`, or an empty line on the front board **MUST** return 0.  
2. **1** or `setup` **MUST** run `qemu_setup`, then the front board **MUST** show again.  
3. **2** or `images` **MUST** open the image board. **3** or `containers` **MUST** open the container board. **6** or `language` **MUST** open the language board. **8** or `self-management` **MUST** open the self-management board. Category shorts in the saved language are also accepted. Those shorts are `requirement-shell-cli-language.md`.  
4. A typed leaf that is listed under **8** (`version`, `about`, `version-check`, `self-update`, `self-uninstall`, `self-install`) **MAY** run from the front prompt, then the front board **MUST** show again.  
5. `install` is not a listed row (**81** is reserved). Typing it here is a bad pick. `help`, `menu`, and `main` **MUST NOT** be rows.  
6. Numbers **4**, **5**, and **7** are unused. They are bad picks. Do not compact the board to remove the gaps. **6** is the language board.

### 2.3 Image board (parent 2)

| # | Token | Label |
|---|-------|-------|
| *(header)* | — | `**qemu-cli**(*version*) — images` |
| **21** | `ubuntu` | `ubuntu: manage the Ubuntu image` |
| **22** | `rocky` | `rocky: manage the Rocky Linux image` |
| **23** | `alpine` | `alpine: manage the Alpine image` |
| **24** | `busybox` | `busybox: manage the busybox image` |
| **0** | Back | return to the front board |

Each of **21–24** opens an action board. Children keep the parent digits:

| Parent | Create | Show | Remove |
|--------|--------|------|--------|
| **21** | **211** `create` | **212** `show` | **213** `remove` |
| **22** | **221** `create` | **222** `show` | **223** `remove` |
| **23** | **231** `create` | **232** `show` | **233** `remove` |
| **24** | **241** `create` | **242** `show` | **243** `remove` |

Each action board header names the family. **0** returns to the image board. A finished create, show, or remove returns to the **front** board.

### 2.4 Container boards (parent 3)

| # | Token | Label |
|---|-------|-------|
| *(header)* | — | `**qemu-cli**(*version*) — containers` |
| **31** | `create` | `create: new container from a managed image` |
| **32** | `open` | `open: numbered list of existing containers` |
| **0** | Back | return to the front board |

**31** runs create (guided fields on a terminal), then the front board shows again.

**32** opens a data picker. Numbers **1..N** are local to that list: one existing container per number, in name order. **0** returns to the container board. When N is 0, the only accepted choice is **0**, and the board says no containers exist yet. A data-picker number **MUST NOT** be accepted on the front board.

After a container is picked, the action board is:

| # | Token | Label |
|---|-------|-------|
| **321** | `start` | `start: boot this container` |
| **322** | `stop` | `stop: stop this container` |
| **323** | `execute` | `execute: run one command inside` |
| **324** | `shell` | `shell: enter a shell in this container` |
| **325** | `remove` | `remove: delete this container` |
| **0** | Back | return to the data picker |

A finished **321–325** returns to the **front** board. The picked name is the operand. Handlers are the `qemu_container_*` functions in `requirement-domain-qemu.md`.

### 2.5 Self-management board (parent 8)

Online script-alone place of this CLI. **81** `install` stays reserved and **MUST NOT** be printed. Do not renumber the rows that remain.

| # | Token | Label |
|---|-------|-------|
| *(header)* | — | `**qemu-cli**(*version*) — self-management` |
| **82** | `version` | `version: show current version` |
| **83** | `about` | `about: show detailed diagnostics` |
| **84** | `version-check` | `version-check: compare local vs remote version` |
| **85** | `self-update` | `self-update: update qemu-cli to a newer remote version` |
| **86** | `self-uninstall` | `self-uninstall: remove qemu-cli` |
| **87** | `self-install` | `self-install: place this CLI only (copy when $0 is a script; download when piped)` |
| **0** | Back | return to the front board |

1. **0**, `back`, or an empty line **MUST** return to the front board and **MUST NOT** run a verb.  
2. A listed number or its token **MUST** run that handler, then the **front** board **MUST** show again. **MUST NOT** stay on this board after a finished command. **MUST NOT** leave the program because the command finished.  
3. **9** is not a row on this board. It is a bad pick here.

### 2.6 Look

1. Header **MUST** be live `APP_NAME(VERSION)`: bold name, italic version, then the board title, printed with `out_info`.  
2. Each command row **MUST** be `N. short: explain` via `out_menu_choice`. The number is plain. On a TTY the short name **MUST** be bold (SGR **1**) and the explain **MUST** be italic and light gray (SGR **3** + **37**). Off a TTY the same words are plain.  
3. Exit and Back have no explain.  
4. **MUST NOT** draw the explain unstyled on a TTY. **MUST NOT** use a second color scheme.

### 2.7 Bad pick

An unused number, an unknown name, or a hidden reserved number (**81**, and **9** on any board except the front) **MUST** `out_error`, name the pick, reprint **this** layer, and read again. **MUST NOT** `out_die`. **MUST NOT** treat the pick as an unknown argv command. **MUST NOT** jump to the parent board on a bad pick.

### 2.8 Hierarchy

| # | Parent | Token | Runs |
|---|--------|-------|------|
| **1** | front | `setup` | `qemu_setup` |
| **2** | front | `images` | image board |
| **3** | front | `containers` | container board |
| **6** | front | `language` | language board `app_cmd_menu_language` |
| **61–68** | **6** | language code | `app_lang_save` for that code, then the front board |
| **8** | front | `self-management` | self-management board |
| **9** | front | Exit | leave |
| **21–24** | **2** | family | that family's action board |
| **211–243** | **21–24** | create / show / remove | `qemu_image_*` for that family |
| **31** | **3** | `create` | `qemu_container_create` |
| **32** | **3** | `open` | data picker **1..N** |
| **321–325** | picked container | start / stop / execute / shell / remove | `qemu_container_*` |
| **82–87** | **8** | lifecycle | existing `app_` / `inst_` / `ver_` handlers |
| **0** | every board except front | Back | parent board |

### 2.9 Implementation Notes

| Item | Value |
|------|--------|
| **Product** | qemu-cli |
| **Ship unit (law)** | `src/qemu-cli` |
| **Ship unit** | `src/qemu-cli` (`VERSION="1.4.1"`). `app_default` is a one-line wrapper of `app_cmd_menu` |
| **Handlers** | `app_cmd_menu`, `app_cmd_menu_images`, `app_cmd_menu_containers`, `app_cmd_menu_picker`, `app_cmd_menu_self`, `app_cmd_menu_language` |
| **Choose-prompt** | English source string `Choice: ` (one trailing space). Other codes are `requirement-shell-cli-language.md` |
| **81** | Reserved and not printed. No hidden-row sentence |
| **Bootstrap file** | `src/selfmanaged` stays the untouched Type 0 parent. It is not this product's menu |

### 2.10 Why this requirement exists (CIAO)

- **Caution:** A pipe never waits on the list, and a pipe does not install QEMU.  
- **Intentional:** **1** is setup, **2** is images, **3** is containers, **6** is language, **8** is self-management, **87** is place-this-CLI.  
- **Anti-fragile:** A wrong number reprints that board. A finished command returns to the front board.  
- **Over-protect:** Lifecycle verbs stay off the front board. **81** is not reused. **8** is not renumbered.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Non-interactive empty argv stays CLI place.  
- **Intentional:** One numbering card for every board.  
- **Anti-fragile:** Back and Exit are different. Data-picker numbers stay on their own list.  
- **Over-protect:** Do not compact hidden **81** or the unused numbers **4**, **5**, and **7**.

---

## 4. Protection Rule (Sacred)

**Future assistants MUST NOT**:

1. Open this menu for empty argv when there is no TTY, or when `JSON=1`, or when `QUIET=1`.  
2. Put `install`, `version`, `about`, `version-check`, `self-update`, `self-uninstall`, `self-install`, `help`, or `menu` on the front board.  
3. Print **81**, or renumber **82–87** because **81** is hidden.  
4. Number children of **8** as **91–94** or restart an image or container action list at **1** (the data picker under **32** is the only **1..N** list).  
5. `out_die` on a bad menu pick.  
6. Stay on a side board after a command finishes.  
7. Put a Back row on the front board.  
8. Draw a TTY explain without italic light gray, or a TTY short name without bold.  
9. Read the choice with `$()` around a helper that calls `read`.  
10. Drop **1**, **2**, **3**, or **6** to make the front board look like the bootstrap menu.

---

## Under command line for normal user only

When the product detects Termux, Git Bash, Windows cmd, or the same class:

**This requirement:** the numbered rows still appear. **1** / `setup` **MUST** follow `requirement-domain-qemu.md` and fail closed before any package command. The menu **MUST NOT** grow a `sudo` row.

---

## 5. Definition of done

| ID | Where | Status |
|----|-------|--------|
| **TP-CLI-17** | `tests/test_cli.sh` | have (TTY row is bold short + italic gray explain; header nametag) — re-check when the header text changes |
| **TP-CLI-19** | `tests/test_cli.sh` | have (bad pick reprints this layer; process stays up) |
| **TP-CLI-21** | `tests/test_cli.sh` | have (finished **82** redisplays the front board) |
| **TP-CLI-22** | `tests/test_cli.sh` | have (off-TTY `menu` is help; **8** lists **87** and omits **81**) |
| **TP-QEMU-11** | `tests/test_cli.sh` | have — front **1**, **2**, **3**, **6** and image/container child numbers, including **21**, **31**, **321–325**, and the absence of **81** |

---

## 6. Related artifacts

| Artifact | Relationship |
|----------|----------------|
| `docs/requirements/requirement-domain-qemu.md` | What **1**, **2**, and **3** do |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv: interactive menu, otherwise place |
| `docs/requirements/requirement-shell-cli-interface.md` | `menu` / `main` on the command table |
| `docs/requirements/requirement-shell-cli-self-install.md` | What **87** / `self-install` does |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_menu_choice` / `out_text` |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | No hang off a TTY |
| `docs/requirements/requirement-shell-cli-language.md` | Codes, copy, samples |
| `src/qemu-cli` | Ship unit |

---

**Last Updated**: 2026-09-30  
**Owner**: qemu-cli project maintainers  
**Alignment:** requirement-domain-qemu · requirement-shell-cli-zero-arguments · requirement-shell-cli-interface · requirement-shell-cli-self-install · requirement-shell-output-requirements · CIAO / CIAO-Lite

**file**: docs/requirements/requirement-shell-cli-language.md
**Status**: Active (Version 1.0.0)
**Area**: shell
**Key**: `requirement-shell-cli-language`
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the product law for **menu language** on qemu-cli. The closed set is eight codes: English, Traditional Chinese, Spanish, French, German, Simplified Chinese, Japanese, and Korean. A ninth code is out of scope for this version.

This file owns the codes, the saved line, the words the numbered menu prints, the human headings of `help` and `about`, a worked sample of the front board and of those openings in each code, and the translation tables for the lines those samples do not show on every board.

Which row is **6**, which children are **61** through **68**, Back, Exit, and the current-shell choice stay owned by `requirement-shell-cli-default-interaction.md`. The persistence directory stays owned by `requirement-shell-cli-storage.md`. Domain verbs stay owned by `requirement-domain-qemu.md`.

### 1.1 Human-facing

**In one sentence:** Menu **6** chooses English, 繁體中文, Español, Français, Deutsch, 简体中文, 日本語, or 한국어 for the numbered menu and for the headings of `help` and `about`, and the next run opens in that language.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Pick a language on the menu | `qemu-cli` then `6` then `62` |
| The other role | A script that must not wait | `qemu-cli image list` |
| Not this file | What `setup` installs, and what a guest prints | `requirement-domain-qemu.md` |

| Includes | Excludes |
|----------|----------|
| Eight codes; front **6** / **61–68**; menu copy; human headings of `help` and `about` | A ninth code; translating command output, JSON about fields, or the version one-liner |
| File `${HOME}/.local/${APP_NAME}/language` | Putting that file in the cache folder |

| Surface | What you open | What for |
|---------|---------------|----------|
| `qemu-cli` on a terminal | Front row **6** | The language board |
| `${HOME}/.local/qemu-cli/language` | One line, mode 0600 | The saved code |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Keep English | Missing, empty, or unrecognized file stays English and is not rewritten | `qemu-cli` then `9` |
| Save Traditional Chinese | **62** writes `zh-Hant` and the front board comes back in that language | `qemu-cli` then `6` then `62` |
| Try a language for one run | `QEMU_CLI_LANG` wins for this process and does not write the file | `QEMU_CLI_LANG=ja qemu-cli menu` |

## 2. Core Rules / Requirements (Mandatory)

**Claimed:** yes. Default language is English so an existing menu test keeps matching English words. The other seven codes are the operator's choice, stored for the next run. This version has **eight** codes. **MUST NOT** add a ninth code without a new revision of this file.

### 2.1 Languages

| Code | Name on the language board | Number | Default |
|------|----------------------------|--------|---------|
| `en` | English | **61** | yes |
| `zh-Hant` | 繁體中文 | **62** | no |
| `es` | Español | **63** | no |
| `fr` | Français | **64** | no |
| `de` | Deutsch | **65** | no |
| `zh-Hans` | 简体中文 | **66** | no |
| `ja` | 日本語 | **67** | no |
| `ko` | 한국어 | **68** | no |

**MUST** accept only these eight codes. **MUST** treat a missing file, an empty file, or any other first line as English for this process. **MUST NOT** rewrite a file whose first line is not one of these codes.

The short names **English**, **繁體中文**, **Español**, **Français**, **Deutsch**, **简体中文**, **日本語**, and **한국어** are the same words in every language.

### 2.2 Where the choice is stored

1. The leaf is `${HOME}/.local/${APP_NAME}/language`, inside the persistence directory from `requirement-shell-cli-storage.md`. **MUST NOT** put it in the cache folder.
2. The file is one line, one of the eight codes, then a newline. Mode **0600**. A trailing CR is ignored. Only the first line is used.
3. `app_lang_load` sets `APP_LANG` once, at the start of `app_main`, after persistence is resolved and before the zero-cli-verb split. Human `help`, human `about`, and the menu all see that value. **MUST NOT** call it again in that same process. `app_cmd_menu` does not call it.
4. When `QEMU_CLI_LANG` is one of those eight codes, that value wins over the file at process start. It does not write the file. A menu pick still writes the file and sets `APP_LANG` for the rest of that process. **MUST NOT** honor `SSHD_CLI_LANG`.
5. `app_lang_save` writes the line and sets `APP_LANG` only after the write succeeds. A code outside the eight returns failure and leaves `APP_LANG` unchanged.
6. `language` is not an argv verb.

### 2.3 Menu numbers

Front **6** opens `app_cmd_menu_language`. **61** saves `en`. **62** saves `zh-Hant`. **63** saves `es`. **64** saves `fr`. **65** saves `de`. **66** saves `zh-Hans`. **67** saves `ja`. **68** saves `ko`. Each is a valid leaf: an info line names the language, then the front board redisplays in that language. **0** / empty / EOF is Back and does not write the file. An invalid choice warns and reprints this board.

Typed tokens on the front board that open it: `language`, `語言`, `语言`, `idioma`, `langue`, `Sprache`, `sprache`, `言語`, `언어`.

The language board accepts:

| Row | Typed tokens |
|-----|----------------|
| **61** | `english`, `en`, `English` |
| **62** | `traditional-chinese`, `zh-hant`, `zh-Hant`, `繁體中文` |
| **63** | `spanish`, `es`, `Español`, `español` |
| **64** | `french`, `fr`, `Français`, `français` |
| **65** | `german`, `de`, `Deutsch`, `deutsch` |
| **66** | `simplified-chinese`, `zh-hans`, `zh-Hans`, `简体中文` |
| **67** | `japanese`, `ja`, `日本語` |
| **68** | `korean`, `ko`, `한국어` |

The front board also accepts the displayed category short for setup, images, containers, and self-management (the table in §2.4.2). French images uses the same short as English (`images`). German containers uses `Container` with a capital C, which is a different token from English `containers`.

Row **6** is numbered on every host, including Termux, Git Bash, and Windows cmd. It is not a hide cause. Row **81** stays unprinted. This product does not print a hidden-row sentence for **81**.

### 2.4 What follows the saved language

**MUST** follow `APP_LANG` on these boards: front, images, image-family actions, containers, the existing-container picker, the container action board, language, and self-management. That covers the layer title, the category shorts, every long description, Back, Exit, the choose-prompt, the unknown-choice warn, and the empty-container line on the picker.

**MUST** keep each leaf short as the English verb in every language: `create`, `show`, `remove`, `start`, `stop`, `execute`, `shell`, `version`, `about`, `version-check`, `self-update`, `self-uninstall`, `self-install`, `ubuntu`, `rocky`, `alpine`, `busybox`. Category shorts translate. Endonyms stay the same words.

**MUST** follow `APP_LANG` on human `help` and human `about` **headings**: Usage, the self-management heading, the QEMU heading, Global Options, Environment, and the about title. The command token, the flag, the path, and the env name stay the Latin spelling. The sentences under those headings stay English. JSON about keys and values stay English. The argv `version` one-liner stays English. Operational command output stays English, including `qemu-cli container list` when no container exists (`No containers exist yet.`). The menu picker uses the translated `none_yet` line instead.

These English about labels stay the English words in every language: `Cache folder used:`, `Cache folder (preferred):`, `Cache folder (1st fallback):`, `Cache folder (2nd fallback):`, `Persistence storage:`.

Three sentences contain the letters r, e, a, d in a row. They stay as English literals inside `app_help` and `app_about`, not inside `app_menu_text`:

- `Help text available in human-readable mode. Run without --json.`
- `Machine-readable JSON (implies --quiet)`
- `Machine-readable output`

`app_menu_text` prints the chosen string. The caller passes it to `out_*`. A command substitution of `app_menu_text` is legal. A command substitution of `prompt_ask`, `prompt_yes_no`, or any choice helper is forbidden. The comment that names the choice builtin sits **above** `app_menu_text`, not inside it. The body of `app_menu_text` **MUST NOT** contain those four letters in a row.

The English unknown line is `Not a menu choice '@@'. Type a listed number or a listed command name.` The ship unit substitutes the pick with `${var%%@@*}` and `${var#*@@}`. **MUST NOT** use `printf` percent substitution or `sed` for that token.

After a successful save, the info line is printed in the new language (`saved_line` in §2.4.2). A failed write warns in the language that was current before the failure (`save_failed`), leaves `APP_LANG` unchanged, and still returns to the front board.

The English choose-prompt source string is `Choice: ` with one trailing space. **MUST NOT** replace it with a longer English sentence.

### 2.4.1 Worked samples

These fences are the live words with terminal ink written as markdown: **bold** short, *italic* long. The version token is the live `VERSION` (`1.4.1`). The choose-prompt fences keep the source string, including a trailing space when that string has one. **MUST NOT** invent a line the ship unit does not print. Deeper boards keep the English verb as the leaf short. Their longs are §2.4.2.

English language board (the endonym shorts are the same words after every save; the longs follow `APP_LANG` and are in the table):

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

English (`en`), the default, front board:

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

Opening of human `help` and human `about` in that language. Command rows stay the English spelling. The cache-folder labels stay the English words:

```text
[INFO] qemu-cli — QEMU setup, images, and containers
POSIX /bin/sh program that installs QEMU, keeps Ubuntu, Rocky Linux, Alpine, and busybox images, and starts, stops, and enters the guests it owns.

[INFO] Usage:
  qemu-cli [command] [options]

[INFO] Self-Management (Type 0 - any user):
  self-install         Place qemu-cli (copy when $0 is this file; pipe downloads; 0755 global / 0700 local)

[INFO] QEMU:
  setup                Install QEMU on this computer

[INFO] Global Options:
  --json               Machine-readable JSON (implies --quiet)

[INFO] Environment:

[INFO] === qemu-cli 1.4.1 - About / Diagnostics ===
```

Traditional Chinese (`zh-Hant`), after **62**:

```text
[INFO] **qemu-cli**(*1.4.1*) — QEMU 安裝、映像與容器
1. **設定**: *在這台電腦安裝 QEMU*
2. **映像**: *Ubuntu、Rocky Linux、Alpine、busybox*
3. **容器**: *啟動、停止、執行，或進入殼層*
6. **語言**: *這個選單的顯示語言*
8. **自我管理**: *這個 CLI 的安裝、版本、更新、移除*
9. 離開
請選擇：
```

Opening of human `help` and human `about` in that language. Command rows stay the English spelling. The cache-folder labels stay the English words:

```text
[INFO] qemu-cli — QEMU setup, images, and containers
POSIX /bin/sh program that installs QEMU, keeps Ubuntu, Rocky Linux, Alpine, and busybox images, and starts, stops, and enters the guests it owns.

[INFO] 用法：
  qemu-cli [command] [options]

[INFO] 自我管理（任何使用者）：
  self-install         Place qemu-cli (copy when $0 is this file; pipe downloads; 0755 global / 0700 local)

[INFO] QEMU：
  setup                Install QEMU on this computer

[INFO] 全域選項：
  --json               Machine-readable JSON (implies --quiet)

[INFO] 環境：

[INFO] === qemu-cli 1.4.1 - 關於 / 診斷 ===
```

Spanish (`es`), after **63**:

```text
[INFO] **qemu-cli**(*1.4.1*) — instalación de QEMU, imágenes y contenedores
1. **configuración**: *instalar QEMU en este equipo*
2. **imágenes**: *Ubuntu, Rocky Linux, Alpine, busybox*
3. **contenedores**: *iniciar, detener, ejecutar o entrar en un shell*
6. **idioma**: *idioma de este menú*
8. **autogestión**: *instalación, versión, actualización y desinstalación de este CLI*
9. Salir
Elección: 
```

Opening of human `help` and human `about` in that language. Command rows stay the English spelling. The cache-folder labels stay the English words:

```text
[INFO] qemu-cli — QEMU setup, images, and containers
POSIX /bin/sh program that installs QEMU, keeps Ubuntu, Rocky Linux, Alpine, and busybox images, and starts, stops, and enters the guests it owns.

[INFO] Uso:
  qemu-cli [command] [options]

[INFO] Autogestión (cualquier usuario):
  self-install         Place qemu-cli (copy when $0 is this file; pipe downloads; 0755 global / 0700 local)

[INFO] QEMU:
  setup                Install QEMU on this computer

[INFO] Opciones globales:
  --json               Machine-readable JSON (implies --quiet)

[INFO] Entorno:

[INFO] === qemu-cli 1.4.1 - Acerca de / Diagnóstico ===
```

French (`fr`), after **64**:

```text
[INFO] **qemu-cli**(*1.4.1*) — installation de QEMU, images et conteneurs
1. **configuration**: *installer QEMU sur cet ordinateur*
2. **images**: *Ubuntu, Rocky Linux, Alpine, busybox*
3. **conteneurs**: *démarrer, arrêter, exécuter ou entrer dans un shell*
6. **langue**: *langue d'affichage de ce menu*
8. **autogestion**: *installation, version, mise à jour et retrait de ce CLI*
9. Quitter
Choix : 
```

Opening of human `help` and human `about` in that language. Command rows stay the English spelling. The cache-folder labels stay the English words:

```text
[INFO] qemu-cli — QEMU setup, images, and containers
POSIX /bin/sh program that installs QEMU, keeps Ubuntu, Rocky Linux, Alpine, and busybox images, and starts, stops, and enters the guests it owns.

[INFO] Utilisation :
  qemu-cli [command] [options]

[INFO] Autogestion (tout utilisateur) :
  self-install         Place qemu-cli (copy when $0 is this file; pipe downloads; 0755 global / 0700 local)

[INFO] QEMU :
  setup                Install QEMU on this computer

[INFO] Options globales :
  --json               Machine-readable JSON (implies --quiet)

[INFO] Environnement :

[INFO] === qemu-cli 1.4.1 - À propos / Diagnostic ===
```

German (`de`), after **65**:

```text
[INFO] **qemu-cli**(*1.4.1*) — QEMU-Einrichtung, Abbilder und Container
1. **Einrichtung**: *QEMU auf diesem Computer installieren*
2. **Abbilder**: *Ubuntu, Rocky Linux, Alpine, busybox*
3. **Container**: *starten, stoppen, ausführen oder eine Shell öffnen*
6. **Sprache**: *Anzeigesprache dieses Menüs*
8. **Selbstverwaltung**: *Installation, Version, Aktualisierung und Entfernen dieses CLI*
9. Beenden
Auswahl: 
```

Opening of human `help` and human `about` in that language. Command rows stay the English spelling. The cache-folder labels stay the English words:

```text
[INFO] qemu-cli — QEMU setup, images, and containers
POSIX /bin/sh program that installs QEMU, keeps Ubuntu, Rocky Linux, Alpine, and busybox images, and starts, stops, and enters the guests it owns.

[INFO] Verwendung:
  qemu-cli [command] [options]

[INFO] Selbstverwaltung (jeder Benutzer):
  self-install         Place qemu-cli (copy when $0 is this file; pipe downloads; 0755 global / 0700 local)

[INFO] QEMU:
  setup                Install QEMU on this computer

[INFO] Globale Optionen:
  --json               Machine-readable JSON (implies --quiet)

[INFO] Umgebung:

[INFO] === qemu-cli 1.4.1 - Über / Diagnose ===
```

Simplified Chinese (`zh-Hans`), after **66**:

```text
[INFO] **qemu-cli**(*1.4.1*) — QEMU 安装、映像与容器
1. **设置**: *在这台电脑安装 QEMU*
2. **映像**: *Ubuntu、Rocky Linux、Alpine、busybox*
3. **容器**: *启动、停止、执行，或进入壳层*
6. **语言**: *这个菜单的显示语言*
8. **自我管理**: *这个 CLI 的安装、版本、更新、移除*
9. 离开
请选择：
```

Opening of human `help` and human `about` in that language. Command rows stay the English spelling. The cache-folder labels stay the English words:

```text
[INFO] qemu-cli — QEMU setup, images, and containers
POSIX /bin/sh program that installs QEMU, keeps Ubuntu, Rocky Linux, Alpine, and busybox images, and starts, stops, and enters the guests it owns.

[INFO] 用法：
  qemu-cli [command] [options]

[INFO] 自我管理（任何使用者）：
  self-install         Place qemu-cli (copy when $0 is this file; pipe downloads; 0755 global / 0700 local)

[INFO] QEMU：
  setup                Install QEMU on this computer

[INFO] 全局选项：
  --json               Machine-readable JSON (implies --quiet)

[INFO] 环境：

[INFO] === qemu-cli 1.4.1 - 关于 / 诊断 ===
```

Japanese (`ja`), after **67**:

```text
[INFO] **qemu-cli**(*1.4.1*) — QEMU の導入、イメージ、コンテナ
1. **セットアップ**: *このコンピュータに QEMU を導入する*
2. **イメージ**: *Ubuntu、Rocky Linux、Alpine、busybox*
3. **コンテナ**: *起動、停止、実行、またはシェルに入る*
6. **言語**: *このメニューの表示言語*
8. **自己管理**: *この CLI のインストール、バージョン、更新、削除*
9. 終了
選択: 
```

Opening of human `help` and human `about` in that language. Command rows stay the English spelling. The cache-folder labels stay the English words:

```text
[INFO] qemu-cli — QEMU setup, images, and containers
POSIX /bin/sh program that installs QEMU, keeps Ubuntu, Rocky Linux, Alpine, and busybox images, and starts, stops, and enters the guests it owns.

[INFO] 使い方:
  qemu-cli [command] [options]

[INFO] 自己管理（どの利用者でも）：
  self-install         Place qemu-cli (copy when $0 is this file; pipe downloads; 0755 global / 0700 local)

[INFO] QEMU：
  setup                Install QEMU on this computer

[INFO] 全体オプション：
  --json               Machine-readable JSON (implies --quiet)

[INFO] 環境：

[INFO] === qemu-cli 1.4.1 - 概要 / 診断 ===
```

Korean (`ko`), after **68**:

```text
[INFO] **qemu-cli**(*1.4.1*) — QEMU 설치, 이미지, 컨테이너
1. **설정**: *이 컴퓨터에 QEMU 설치*
2. **이미지**: *Ubuntu, Rocky Linux, Alpine, busybox*
3. **컨테이너**: *시작, 중지, 실행 또는 셸 들어가기*
6. **언어**: *이 메뉴의 표시 언어*
8. **자기관리**: *이 CLI의 설치, 버전, 업데이트, 제거*
9. 종료
선택: 
```

Opening of human `help` and human `about` in that language. Command rows stay the English spelling. The cache-folder labels stay the English words:

```text
[INFO] qemu-cli — QEMU setup, images, and containers
POSIX /bin/sh program that installs QEMU, keeps Ubuntu, Rocky Linux, Alpine, and busybox images, and starts, stops, and enters the guests it owns.

[INFO] 사용법:
  qemu-cli [command] [options]

[INFO] 자기관리 (아무 사용자):
  self-install         Place qemu-cli (copy when $0 is this file; pipe downloads; 0755 global / 0700 local)

[INFO] QEMU:
  setup                Install QEMU on this computer

[INFO] 전역 옵션:
  --json               Machine-readable JSON (implies --quiet)

[INFO] 환경:

[INFO] === qemu-cli 1.4.1 - 개요 / 진단 ===
```


### 2.4.2 Translation tables

Every cell is a string `app_menu_text` prints for that key and code. A missing key prints the key. The `@@` token in `unknown_choice` is replaced with the rejected pick.

#### Front category shorts and longs

| Key | en | zh-Hant | es | fr | de | zh-Hans | ja | ko |
|-----|---|---|---|---|---|---|---|---|
| `cat_setup` | setup | 設定 | configuración | configuration | Einrichtung | 设置 | セットアップ | 설정 |
| `front_setup_long` | install QEMU on this computer | 在這台電腦安裝 QEMU | instalar QEMU en este equipo | installer QEMU sur cet ordinateur | QEMU auf diesem Computer installieren | 在这台电脑安装 QEMU | このコンピュータに QEMU を導入する | 이 컴퓨터에 QEMU 설치 |
| `cat_images` | images | 映像 | imágenes | images | Abbilder | 映像 | イメージ | 이미지 |
| `front_images_long` | Ubuntu, Rocky Linux, Alpine, busybox | Ubuntu、Rocky Linux、Alpine、busybox | Ubuntu, Rocky Linux, Alpine, busybox | Ubuntu, Rocky Linux, Alpine, busybox | Ubuntu, Rocky Linux, Alpine, busybox | Ubuntu、Rocky Linux、Alpine、busybox | Ubuntu、Rocky Linux、Alpine、busybox | Ubuntu, Rocky Linux, Alpine, busybox |
| `cat_containers` | containers | 容器 | contenedores | conteneurs | Container | 容器 | コンテナ | 컨테이너 |
| `front_containers_long` | start, stop, execute, or enter a shell | 啟動、停止、執行，或進入殼層 | iniciar, detener, ejecutar o entrar en un shell | démarrer, arrêter, exécuter ou entrer dans un shell | starten, stoppen, ausführen oder eine Shell öffnen | 启动、停止、执行，或进入壳层 | 起動、停止、実行、またはシェルに入る | 시작, 중지, 실행 또는 셸 들어가기 |
| `cat_language` | language | 語言 | idioma | langue | Sprache | 语言 | 言語 | 언어 |
| `front_language_long` | display language for this menu | 這個選單的顯示語言 | idioma de este menú | langue d'affichage de ce menu | Anzeigesprache dieses Menüs | 这个菜单的显示语言 | このメニューの表示言語 | 이 메뉴의 표시 언어 |
| `cat_self` | self-management | 自我管理 | autogestión | autogestion | Selbstverwaltung | 自我管理 | 自己管理 | 자기관리 |
| `front_self_long` | this CLI install, version, update, uninstall | 這個 CLI 的安裝、版本、更新、移除 | instalación, versión, actualización y desinstalación de este CLI | installation, version, mise à jour et retrait de ce CLI | Installation, Version, Aktualisierung und Entfernen dieses CLI | 这个 CLI 的安装、版本、更新、移除 | この CLI のインストール、バージョン、更新、削除 | 이 CLI의 설치, 버전, 업데이트, 제거 |
| `header_front` | QEMU setup, images, and containers | QEMU 安裝、映像與容器 | instalación de QEMU, imágenes y contenedores | installation de QEMU, images et conteneurs | QEMU-Einrichtung, Abbilder und Container | QEMU 安装、映像与容器 | QEMU の導入、イメージ、コンテナ | QEMU 설치, 이미지, 컨테이너 |

#### Board titles

| Key | en | zh-Hant | es | fr | de | zh-Hans | ja | ko |
|-----|---|---|---|---|---|---|---|---|
| `header_images` | images | 映像 | imágenes | images | Abbilder | 映像 | イメージ | 이미지 |
| `header_containers` | containers | 容器 | contenedores | conteneurs | Container | 容器 | コンテナ | 컨테이너 |
| `header_language` | language | 語言 | idioma | langue | Sprache | 语言 | 言語 | 언어 |
| `header_self` | self-management | 自我管理 | autogestión | autogestion | Selbstverwaltung | 自我管理 | 自己管理 | 자기관리 |

#### Chrome

| Key | en | zh-Hant | es | fr | de | zh-Hans | ja | ko |
|-----|---|---|---|---|---|---|---|---|
| `choose_prompt` | Choice:  | 請選擇： | Elección:  | Choix :  | Auswahl:  | 请选择： | 選択:  | 선택:  |
| `unknown_choice` | Not a menu choice '@@'. Type a listed number or a listed command name. | 不是選單選項「@@」。請輸入列出的號碼或指令名稱。 | No es una opción de menú '@@'. Escriba un número listado o un nombre de comando listado. | Pas un choix de menu '@@'. Saisissez un numéro listé ou un nom de commande listé. | Keine Menüauswahl '@@'. Eine gelistete Nummer oder einen gelisteten Befehlsnamen eingeben. | 不是菜单选项「@@」。请输入列出的号码或命令名称。 | メニューの選択ではありません '@@'。一覧の番号かコマンド名を入力してください。 | 메뉴 선택이 아닙니다 '@@'. 나열된 번호나 명령 이름을 입력하세요. |
| `back_word` | Back | 返回 | Atrás | Retour | Zurück | 返回 | 戻る | 뒤로 |
| `exit_word` | Exit | 離開 | Salir | Quitter | Beenden | 离开 | 終了 | 종료 |
| `saved_line` | Menu language is English | 選單語言是繁體中文 | El idioma del menú es español | La langue du menu est le français | Die Menüsprache ist Deutsch | 菜单语言是简体中文 | メニューの言語は日本語 | 메뉴 언어는 한국어 |
| `save_failed` | Could not save the menu language | 無法儲存選單語言 | No se pudo guardar el idioma del menú | Impossible d'enregistrer la langue du menu | Die Menüsprache konnte nicht gespeichert werden | 无法保存菜单语言 | メニューの言語を保存できませんでした | 메뉴 언어를 저장하지 못했습니다 |

#### Language board longs

| Key | en | zh-Hant | es | fr | de | zh-Hans | ja | ko |
|-----|---|---|---|---|---|---|---|---|
| `lang_en_long` | use English for this menu | 這個選單使用英文 | usar inglés en este menú | utiliser l'anglais pour ce menu | Englisch für dieses Menü verwenden | 这个菜单使用英文 | このメニューで英語を使う | 이 메뉴에서 영어 사용 |
| `lang_zh_hant_long` | use Traditional Chinese for this menu | 這個選單使用繁體中文 | usar chino tradicional en este menú | utiliser le chinois traditionnel pour ce menu | Traditionelles Chinesisch für dieses Menü verwenden | 这个菜单使用繁体中文 | このメニューで繁体字中国語を使う | 이 메뉴에서 번체 중국어 사용 |
| `lang_es_long` | use Spanish for this menu | 這個選單使用西班牙文 | usar español en este menú | utiliser l'espagnol pour ce menu | Spanisch für dieses Menü verwenden | 这个菜单使用西班牙文 | このメニューでスペイン語を使う | 이 메뉴에서 스페인어 사용 |
| `lang_fr_long` | use French for this menu | 這個選單使用法文 | usar francés en este menú | utiliser le français pour ce menu | Französisch für dieses Menü verwenden | 这个菜单使用法文 | このメニューでフランス語を使う | 이 메뉴에서 프랑스어 사용 |
| `lang_de_long` | use German for this menu | 這個選單使用德文 | usar alemán en este menú | utiliser l'allemand pour ce menu | Deutsch für dieses Menü verwenden | 这个菜单使用德文 | このメニューでドイツ語を使う | 이 메뉴에서 독일어 사용 |
| `lang_zh_hans_long` | use Simplified Chinese for this menu | 這個選單使用簡體中文 | usar chino simplificado en este menú | utiliser le chinois simplifié pour ce menu | Vereinfachtes Chinesisch für dieses Menü verwenden | 这个菜单使用简体中文 | このメニューで簡体字中国語を使う | 이 메뉴에서 간체 중국어 사용 |
| `lang_ja_long` | use Japanese for this menu | 這個選單使用日文 | usar japonés en este menú | utiliser le japonais pour ce menu | Japanisch für dieses Menü verwenden | 这个菜单使用日文 | このメニューで日本語を使う | 이 메뉴에서 일본어 사용 |
| `lang_ko_long` | use Korean for this menu | 這個選單使用韓文 | usar coreano en este menú | utiliser le coréen pour ce menu | Koreanisch für dieses Menü verwenden | 这个菜单使用韩文 | このメニューで韓国語を使う | 이 메뉴에서 한국어 사용 |

#### Image board

| Key | en | zh-Hant | es | fr | de | zh-Hans | ja | ko |
|-----|---|---|---|---|---|---|---|---|
| `fam_ubuntu_long` | manage the Ubuntu image | 管理 Ubuntu 映像 | gestionar la imagen Ubuntu | gérer l'image Ubuntu | Ubuntu-Abbild verwalten | 管理 Ubuntu 映像 | Ubuntu イメージを管理する | Ubuntu 이미지 관리 |
| `fam_rocky_long` | manage the Rocky Linux image | 管理 Rocky Linux 映像 | gestionar la imagen Rocky Linux | gérer l'image Rocky Linux | Rocky-Linux-Abbild verwalten | 管理 Rocky Linux 映像 | Rocky Linux イメージを管理する | Rocky Linux 이미지 관리 |
| `fam_alpine_long` | manage the Alpine image | 管理 Alpine 映像 | gestionar la imagen Alpine | gérer l'image Alpine | Alpine-Abbild verwalten | 管理 Alpine 映像 | Alpine イメージを管理する | Alpine 이미지 관리 |
| `fam_busybox_long` | manage the busybox image | 管理 busybox 映像 | gestionar la imagen busybox | gérer l'image busybox | busybox-Abbild verwalten | 管理 busybox 映像 | busybox イメージを管理する | busybox 이미지 관리 |
| `act_create_long` | create this image | 建立這個映像 | crear esta imagen | créer cette image | dieses Abbild erstellen | 建立这个映像 | このイメージを作成する | 이 이미지 만들기 |
| `act_show_long` | show this image record | 顯示這個映像紀錄 | mostrar el registro de esta imagen | afficher la fiche de cette image | diesen Abbild-Datensatz zeigen | 显示这个映像记录 | このイメージの記録を表示する | 이 이미지 기록 보기 |
| `act_remove_long` | delete this image | 刪除這個映像 | eliminar esta imagen | supprimer cette image | dieses Abbild löschen | 删除这个映像 | このイメージを削除する | 이 이미지 삭제 |

#### Container board

| Key | en | zh-Hant | es | fr | de | zh-Hans | ja | ko |
|-----|---|---|---|---|---|---|---|---|
| `con_create_long` | new container from a managed image | 從已管理的映像建立新容器 | nuevo contenedor desde una imagen gestionada | nouveau conteneur depuis une image gérée | neuer Container aus einem verwalteten Abbild | 从已管理的映像建立新容器 | 管理済みイメージから新しいコンテナ | 관리 중인 이미지로 새 컨테이너 |
| `con_open_long` | numbered list of existing containers | 現有容器的編號清單 | lista numerada de contenedores existentes | liste numérotée des conteneurs existants | nummerierte Liste vorhandener Container | 现有容器的编号清单 | 既存コンテナの番号一覧 | 기존 컨테이너의 번호 목록 |
| `con_start_long` | boot this container | 啟動這個容器 | arrancar este contenedor | démarrer ce conteneur | diesen Container starten | 启动这个容器 | このコンテナを起動する | 이 컨테이너 부팅 |
| `con_stop_long` | stop this container | 停止這個容器 | detener este contenedor | arrêter ce conteneur | diesen Container stoppen | 停止这个容器 | このコンテナを停止する | 이 컨테이너 중지 |
| `con_execute_long` | run one command inside | 在裡面執行一個指令 | ejecutar un comando dentro | exécuter une commande à l'intérieur | einen Befehl darin ausführen | 在里面执行一个命令 | 中でコマンドを一つ実行する | 안에서 명령 하나 실행 |
| `con_shell_long` | enter a shell in this container | 進入這個容器的殼層 | entrar en un shell de este contenedor | entrer dans un shell de ce conteneur | eine Shell in diesem Container öffnen | 进入这个容器的壳层 | このコンテナのシェルに入る | 이 컨테이너의 셸에 들어가기 |
| `con_remove_long` | delete this container | 刪除這個容器 | eliminar este contenedor | supprimer ce conteneur | diesen Container löschen | 删除这个容器 | このコンテナを削除する | 이 컨테이너 삭제 |
| `none_yet` | No containers exist yet. | 還沒有容器。 | Aún no hay contenedores. | Aucun conteneur pour l'instant. | Noch keine Container. | 还没有容器。 | コンテナはまだありません。 | 컨테이너가 아직 없습니다. |

#### Self-management longs

| Key | en | zh-Hant | es | fr | de | zh-Hans | ja | ko |
|-----|---|---|---|---|---|---|---|---|
| `self_version_long` | show current version | 顯示目前版本 | mostrar la versión actual | afficher la version actuelle | aktuelle Version zeigen | 显示当前版本 | 現在のバージョンを表示する | 현재 버전 보기 |
| `self_about_long` | show detailed diagnostics | 顯示詳細診斷 | mostrar diagnóstico detallado | afficher le diagnostic détaillé | ausführliche Diagnose zeigen | 显示详细诊断 | 詳しい診断を表示する | 자세한 진단 보기 |
| `self_version_check_long` | compare local vs remote version | 比較本機與遠端版本 | comparar la versión local y la remota | comparer la version locale et la version distante | lokale und entfernte Version vergleichen | 比较本机与远端版本 | ローカルと遠隔のバージョンを比べる | 로컬과 원격 버전 비교 |
| `self_update_long` | update qemu-cli to a newer remote version | 將 qemu-cli 更新到較新的遠端版本 | actualizar qemu-cli a una versión remota más nueva | mettre qemu-cli à jour vers une version distante plus récente | qemu-cli auf eine neuere entfernte Version bringen | 将 qemu-cli 更新到较新的远端版本 | qemu-cli を新しい遠隔バージョンへ更新する | qemu-cli를 더 새로운 원격 버전으로 업데이트 |
| `self_uninstall_long` | remove qemu-cli | 移除 qemu-cli | eliminar qemu-cli | retirer qemu-cli | qemu-cli entfernen | 移除 qemu-cli | qemu-cli を削除する | qemu-cli 제거 |
| `self_install_long` | place this CLI only (copy when $0 is a script; download when piped) | 只放置這個 CLI（$0 是腳本時複製；管線時下載） | colocar solo este CLI (copiar si $0 es un script; descargar si viene por tubería) | placer seulement ce CLI (copier si $0 est un script ; télécharger si le flux est un tube) | nur dieses CLI ablegen (kopieren, wenn $0 ein Skript ist; herunterladen bei einer Pipe) | 只放置这个 CLI（$0 是脚本时复制；管道时下载） | この CLI だけを配置する（$0 がスクリプトならコピー、パイプなら取得） | 이 CLI만 배치 ($0 이 스크립트면 복사, 파이프면 받기) |

#### Help and about headings

| Key | en | zh-Hant | es | fr | de | zh-Hans | ja | ko |
|-----|---|---|---|---|---|---|---|---|
| `help_usage` | Usage: | 用法： | Uso: | Utilisation : | Verwendung: | 用法： | 使い方: | 사용법: |
| `about_title` | About / Diagnostics | 關於 / 診斷 | Acerca de / Diagnóstico | À propos / Diagnostic | Über / Diagnose | 关于 / 诊断 | 概要 / 診断 | 개요 / 진단 |
| `help_self_head` | Self-Management (Type 0 - any user): | 自我管理（任何使用者）： | Autogestión (cualquier usuario): | Autogestion (tout utilisateur) : | Selbstverwaltung (jeder Benutzer): | 自我管理（任何使用者）： | 自己管理（どの利用者でも）： | 자기관리 (아무 사용자): |
| `help_qemu_head` | QEMU: | QEMU： | QEMU: | QEMU : | QEMU: | QEMU： | QEMU： | QEMU: |
| `help_flags_head` | Global Options: | 全域選項： | Opciones globales: | Options globales : | Globale Optionen: | 全局选项： | 全体オプション： | 전역 옵션: |
| `help_env_head` | Environment: | 環境： | Entorno: | Environnement : | Umgebung: | 环境： | 環境： | 환경: |


### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | qemu-cli |
| **Ship unit** | `src/qemu-cli` (`VERSION="1.4.1"`) |
| **Handlers** | `app_lang_load`, `app_lang_save`, `app_menu_text`, `app_cmd_menu_language` |
| **Override env** | `QEMU_CLI_LANG` |
| **Leaf** | `${HOME}/.local/qemu-cli/language`, mode 0600 |
| **Default** | `en` |
| **Codes** | eight; a ninth is not accepted |
| **Bootstrap file** | `src/selfmanaged` remains the untouched Type 0 parent. It has no language board. It is not this product's ship unit |
| **Proof** | `tests/test_cli.sh` saves **62**, checks mode 0600, leaves an unrecognized first line unchanged, and checks that `QEMU_CLI_LANG=ja` does not write the file. English menu tests export `QEMU_CLI_LANG=en` |

### 2.6 Why this requirement exists (CIAO)

- **Caution:** An unrecognized file stays English and is not rewritten. A failed write does not pretend the language changed.
- **Intentional:** Eight codes, one leaf, one load per process.
- **Anti-fragile:** `QEMU_CLI_LANG` covers one run without touching the file.
- **Over-protect:** The catalog body stays free of the four-letter run so a command substitution of `app_menu_text` stays legal.

---

## Under command line for normal user only

When the product detects Termux, Git Bash, Windows cmd, or the same class:

**This requirement:** row **6** and children **61–68** still appear and still save the language file under this login's persistence directory. Language choice does not install packages and does not call `sudo`. Git Bash and Windows cmd do not invoke Termux `pkg`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Eight codes only. Anything else stays English.
- **Intentional:** Headings follow the saved code. Command rows, cache labels, and JSON stay English.
- **Anti-fragile:** One load at process start. A later pick updates `APP_LANG` without loading again.
- **Over-protect:** No ninth code, no catalog sentence that would make a command substitution illegal, no host SSH layout in this file.

---

## 4. Protection Rule (Sacred)

**Future assistants MUST NOT**:

1. Add a ninth language code in this version.
2. Call `app_lang_load` more than once in one process, or call it from `app_cmd_menu`.
3. Honor `SSHD_CLI_LANG`.
4. Put the language file in the cache folder.
5. Put a sentence that contains the letters r, e, a, d in a row inside `app_menu_text`.
6. Translate JSON about keys, the version one-liner, operational command output, or the English cache-folder labels.
7. Invent a sample line the ship unit does not print.
8. Print a hidden-row sentence for **81**.
9. Capture `prompt_ask` or `prompt_yes_no` with `$()`.

---

## 5. Definition of done

| Check | Where | Status |
|-------|-------|--------|
| Save **62** writes `zh-Hant`, mode 0600, and prints the Traditional Chinese saved line | `tests/test_cli.sh` | have |
| Unrecognized first line is not rewritten | `tests/test_cli.sh` | have |
| `QEMU_CLI_LANG=ja` does not write the file | `tests/test_cli.sh` | have |
| `app_menu_text` body has no four-letter run | `tests/test_cli.sh` | have |
| English menu tests set `QEMU_CLI_LANG=en` | `tests/helpers.sh` | have |

No new test-plan id is registered for these checks.

---

## 6. Related artifacts

| Artifact | Relationship |
|----------|----------------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-shell-cli-default-interaction.md` | Front **6**, children **61–68**, Back, Exit, choose-prompt |
| `docs/requirements/requirement-shell-cli-storage.md` | Persistence directory that holds the `language` leaf |
| `docs/requirements/requirement-shell-cli-interface.md` | `language` is not an argv verb; `menu` lists **6** |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` prints the catalog string |
| `src/qemu-cli` | Ship unit |

---

**Last Updated**: 2026-09-30
**Owner**: qemu-cli project maintainers
**Alignment:** requirement-shell-cli-default-interaction · requirement-shell-cli-storage · requirement-shell-cli-interface · requirement-shell-output-requirements · CIAO / CIAO-Lite

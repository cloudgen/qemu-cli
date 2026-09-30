**file**: docs/requirements/requirement-domain-qemu.md
**Status**: Active (Version 1.0.1)
**Area**: domain
**Key**: `requirement-domain-qemu`
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the single domain law for **qemu-cli**: install QEMU on the computer you are using, keep four guest image families, and start, stop, run a command in, or enter a shell in a QEMU guest this tool already owns.

A **container** in this product is a named QEMU virtual machine recorded under this login's persistence directory. It is not a Docker container, a Podman container, or an LXC container.

`setup` installs QEMU. `self-install` and its alias `install` only place this CLI. Those are different verbs.

**Honesty:** `src/qemu-cli` `1.4.1` implements these verbs. The suite covers the rows marked **have** in §5. A real guest boot, a second start and stop of that guest, a live image download, and a byte-for-byte check of the JSON samples stay **Gap**. Bootstrap `src/selfmanaged` remains and is not this ship unit.

### 1.1 Human-facing

**In one sentence:** You install QEMU for this computer, pick Ubuntu, Rocky Linux, Alpine, or busybox by number, then pick an existing container by number to start it, stop it, run one command, or open a shell.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | The person operating this CLI | `qemu-cli setup` |
| The other role | A QEMU guest this tool recorded for you | `qemu-cli container start web` |
| Not this file | Placing the CLI binary, checksum, or the self-management menu **8** | `qemu-cli self-install` |

| Includes | Excludes |
|----------|----------|
| Host QEMU packages, four image families, container start/stop/execute/shell | Docker, Podman, LXC, and extra image families |
| Numbered menus for images and existing containers | A dedicated system account or an approval queue |

| Surface | What you open | What for |
|---------|---------------|----------|
| `qemu-cli` on a terminal | Numbered front board | **1** setup, **2** images, **3** containers, **6** language, **8** self-management, **9** leave |
| `qemu-cli help` | Command | Domain verbs and self-management verbs in separate sections |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Install QEMU | The tool installs the distro packages for this computer, or reports that QEMU is already available. A normal Linux login that is not the administrator gets a clear error and no package change. | `qemu-cli setup` |
| Obtain an image | The four families are a numbered list. Creating one twice does not download it twice. | `qemu-cli image create ubuntu` |
| Use a container | Existing containers are a numbered list. Start, stop, execute, and shell are the next numbered list. | `qemu-cli container start web` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Words

| Word | Meaning |
|------|---------|
| **Container** | A QEMU virtual machine this tool created, with a record, a disk overlay, and a state of `stopped` or `running` |
| **Image family** | One of `ubuntu`, `rocky`, `alpine`, `busybox` |
| **Setup** | Install the host QEMU emulator and `qemu-img` for this operating system |
| **Administrator** | This process already has user id 0. This product does not call `sudo` |

### 2.2 Specialized CLI subcommands

Every row is also named on `requirement-shell-cli-interface.md`. Help lists these under **QEMU** and lists self-management verbs in a **separate** section. There is no test-purpose verb on this surface.

| Command | Privilege | Sample |
|---------|-----------|--------|
| `setup` | Administrator when Linux packages must be installed. This login when QEMU is already on `PATH`, or when macOS Homebrew installs as this login | `qemu-cli setup` |
| `image list` | This login | `qemu-cli image list` |
| `image create <family>` | This login (writes only under persistence). Busybox may also need the administrator rule in §2.4 | `qemu-cli image create ubuntu` |
| `image show <family>` | This login | `qemu-cli image show alpine` |
| `image remove <family>` | This login | `qemu-cli image remove busybox --force` |
| `container list` | This login | `qemu-cli container list` |
| `container create` | This login | `qemu-cli container create --name web --image ubuntu` |
| `container start <name>` | This login | `qemu-cli container start web` |
| `container stop <name>` | This login | `qemu-cli container stop web` |
| `container execute <name> -- <command…>` | This login | `qemu-cli container execute web -- uname -a` |
| `container shell <name>` | This login, and a terminal | `qemu-cli container shell web` |
| `container remove <name>` | This login | `qemu-cli container remove web --force` |

1. Unknown family or unknown container name **MUST** fail with a non-zero status and an operator-readable error.  
2. `container execute` and `container shell` on a **stopped** container **MUST** fail. They **MUST NOT** start the guest.  
3. Off a terminal, `container shell` **MUST** fail closed and **MUST NOT** hang.  
4. `--json` and a pipe **MUST NOT** prompt. Missing required fields are an error.  
5. Menu-invoked failures **MUST** use `out_error` and return to the front board. They **MUST NOT** `out_die`. The same failure from argv **MUST** exit non-zero.

### 2.3 Numbered menus

Numbering, drawing, bad picks, and return-to-front after a finished command stay on `requirement-shell-cli-default-interaction.md`. This file owns which domain rows exist:

| # | What the person picks |
|---|------------------------|
| **1** | Run `setup` |
| **2** | Image families **21** Ubuntu, **22** Rocky Linux, **23** Alpine, **24** busybox |
| **21–24** | **x1** create, **x2** show, **x3** remove (`211`–`213`, `221`–`223`, `231`–`233`, `241`–`243`) |
| **3** | Containers: **31** create, **32** open the existing-container list |
| **32** | Data picker **1..N** (one number per existing container) and **0** back. These numbers are local to that list |
| After a pick under **32** | **321** start, **322** stop, **323** execute, **324** shell, **325** remove |

**0** goes back one board. Front **9** leaves the program. Self-management stays **8** / **82–87**. Front **6** / **61–68** is the language board. That board is owned by `requirement-shell-cli-default-interaction.md` and `requirement-shell-cli-language.md`. This file does not own the language copy.

### 2.4 Setup (install QEMU on this computer)

Detect the host before any package command. Read `/etc/os-release` when it exists. On Darwin, treat the host as macOS.

| Host | Installer | Packages |
|------|-----------|----------|
| Debian or a derivative (`ID` or `ID_LIKE` contains `debian`) | `apt-get` | `qemu-system-x86` and `qemu-utils` on x86_64. On another architecture, the distro's `qemu-system-*` package for that architecture, plus `qemu-utils` |
| Red Hat, CentOS, Rocky Linux, Fedora (`ID` is `rhel`, `centos`, `rocky`, or `fedora`, or `ID_LIKE` contains `rhel` or `fedora`) | `dnf`, otherwise `yum` | `qemu-kvm` and `qemu-img` |
| Alpine (`ID=alpine`) | `apk` | `qemu-system-x86_64` and `qemu-img` on x86_64. On another architecture, `qemu-system-<arch>` and `qemu-img` |
| macOS | `brew` | formula `qemu` |
| Anything else, including Termux, Git Bash, and Windows cmd | none | Fail closed. Do not guess a package manager |

1. If `qemu-img` and a QEMU system emulator are already on `PATH`, `setup` **MUST** succeed and **MUST NOT** run the installer, unless `--force`.  
2. On Linux, if packages are required and the user id is not 0, **MUST** fail closed. **MUST NOT** call `sudo`. The error **MUST** tell the person to re-run `qemu-cli setup` as the administrator.  
3. On macOS, run `brew install qemu` as this login when `brew` is on `PATH`. If `brew` is missing, fail closed and name Homebrew as the required installer. **MUST NOT** download a disk image or a `.pkg` from any other site.  
4. On a terminal, ask one yes/no question before changing packages: yes installs, no or Enter leaves the system unchanged. `--force` skips the question and reinstalls. Off a terminal, do not ask: install when the rules above allow it, otherwise fail.  
5. A second `setup` with QEMU already present is success.

### 2.5 Images

Closed family set: `ubuntu`, `rocky`, `alpine`, `busybox`.

| Family | Default release | How it is obtained |
|--------|-----------------|--------------------|
| `ubuntu` | `26.04` | HTTPS from `cloud-images.ubuntu.com` only |
| `rocky` | `10` | HTTPS from `download.rockylinux.org` only |
| `alpine` | `3.24` | HTTPS from `dl-cdn.alpinelinux.org` only |
| `busybox` | none | Built on this computer from a static BusyBox. No download |

Overrides, when set, replace the default release: `QEMU_CLI_UBUNTU_RELEASE`, `QEMU_CLI_ROCKY_RELEASE`, `QEMU_CLI_ALPINE_RELEASE`. Each value **MUST** match `^[0-9]+(\.[0-9]+)*$`.

1. Cloud creates **MUST** download over HTTPS from that family's host only, **MUST** verify the vendor checksum file before keeping the bytes, and **MUST** store a qcow2 at the path in §2.7. A checksum miss or a non-200 **MUST** fail and leave no partial record.  
2. If zero or several Alpine generic qcow2 files match, fail closed and list the candidates.  
3. `busybox` **MUST** be a disk whose `/bin/sh` is BusyBox. If a static BusyBox binary or a kernel file QEMU can boot is missing, fail closed and name the missing piece. **MUST NOT** download a kernel from a host outside the table above. Obtaining the static BusyBox package uses the same administrator rule as `setup`.  
4. Create is idempotent when the record and disk already exist. `--force` replaces them only when no container record references that family.  
5. Remove **MUST** refuse while any container record uses that family. On a terminal, ask one yes/no first. Off a terminal, `--force` is required.

Worked Ubuntu source (recorded into the image file when this URL is the one fetched):

```text
https://cloud-images.ubuntu.com/releases/26.04/release/ubuntu-26.04-server-cloudimg-amd64.img
```

A different final URL after an allowed same-host redirect is acceptable. The record stores the URL that was fetched.

### 2.6 Containers

1. Create **MUST** refuse when the named image family has no record. It **MUST NOT** download during create.  
2. The container disk **MUST** be a qcow2 overlay on `images/<family>.qcow2`.  
3. Name **MUST** match `^[a-z][a-z0-9-]{0,30}$`.  
4. Start **MUST** launch QEMU as this login. Use KVM when `/dev/kvm` is usable by this login, HVF on macOS when QEMU accepts it, otherwise TCG, and record which one. User-mode networking only. Forwarded ports **MUST** bind `127.0.0.1` only.  
5. Ubuntu, Rocky Linux, and Alpine **MUST** boot with a NoCloud seed for user `qemu-cli` and a generated SSH key. Execute and shell **MUST** call `ssh` to `127.0.0.1` with that key, `BatchMode=yes`, and `IdentitiesOnly=yes`. **MUST NOT** use the login's default agent or `~/.ssh`.  
6. Busybox execute and shell **MUST** use the serial console. **MUST NOT** require sshd.  
7. Start when already running is success and **MUST NOT** launch a second QEMU. A stale pid file whose process is gone means stopped.  
8. Stop **MUST** request a guest power-down, wait up to 30 seconds, then terminate the QEMU process if it is still alive, then set `stopped`. Stop when already stopped is success.  
9. Execute **MUST** run one command, return that command's status, and **MUST NOT** leave the person inside the guest. A missing command is an error. On a terminal with no command, ask one field: "Command to run inside this container".  
10. Shell **MUST** attach an interactive shell inside the running guest until the person exits it or the guest process ends.  
11. Remove deletes the container record, overlay, pid, monitor socket, key, and seed. It **MUST NOT** delete the family image. On a terminal, one yes/no. Off a terminal, `--force` is required. Remove of a running container **MUST** stop it first.

### 2.7 Specialized features — files

Persistence root is `${HOME}/.local/qemu-cli` (`requirement-shell-cli-storage.md`). Mode **0700** on directories this tool creates. Private keys and the monitor socket are **0600**.

| Kind | Grammar | Sample basename |
|------|---------|-----------------|
| Image disk | `images/<family>.qcow2` | `images/ubuntu.qcow2` |
| Image record | `images/<family>.json` | `images/ubuntu.json` |
| Container record | `containers/<name>.json` | `containers/web.json` |
| Container disk | `containers/<name>.qcow2` | `containers/web.qcow2` |
| SSH key | `containers/<name>.key` | `containers/web.key` |
| Pid | `containers/<name>.pid` | `containers/web.pid` |
| Monitor | `containers/<name>.monitor` | `containers/web.monitor` |
| Cloud seed | `containers/<name>-cidata/` with `user-data` and `meta-data` | `containers/web-cidata/user-data` |

Image record (cloud family):

```json
{
  "schema_version": 1,
  "family": "ubuntu",
  "release": "26.04",
  "arch": "x86_64",
  "method": "vendor-cloud",
  "disk": "images/ubuntu.qcow2",
  "source_url": "https://cloud-images.ubuntu.com/releases/26.04/release/ubuntu-26.04-server-cloudimg-amd64.img",
  "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
}
```

Image record (busybox):

```json
{
  "schema_version": 1,
  "family": "busybox",
  "release": "",
  "arch": "x86_64",
  "method": "local-static",
  "disk": "images/busybox.qcow2",
  "source_url": "",
  "sha256": ""
}
```

The cloud sample's `sha256` is the shape of a vendor digest. The tool **MUST** write the digest it verified, and **MUST NOT** treat the sample hex as a real pin.

Container record (stopped):

```json
{
  "schema_version": 1,
  "name": "web",
  "image_family": "ubuntu",
  "disk": "containers/web.qcow2",
  "state": "stopped",
  "pid": null,
  "accel": "",
  "ssh_port": null,
  "memory_mib": 1024,
  "cpus": 1
}
```

Container record (running):

```json
{
  "schema_version": 1,
  "name": "web",
  "image_family": "ubuntu",
  "disk": "containers/web.qcow2",
  "state": "running",
  "pid": 4242,
  "accel": "kvm",
  "ssh_port": 2222,
  "memory_mib": 1024,
  "cpus": 1
}
```

JSON stdout **MUST NOT** include the private key, the seed body, or a password. It **MAY** include the key path.

### 2.8 Guided input

Choice **C**. On a terminal, ask one field at a time in the current shell (`PROMPT_ASK_VALUE`). **MUST NOT** capture `prompt_ask` or `prompt_yes_no` with `$()` or backticks. Off a terminal, flags only.

| Field | Secret | Prompt | Default | Skip if |
|-------|--------|--------|---------|---------|
| `name` | no | Name for this container | none | `--name` or the positional name |
| `image` | no | Image family: ubuntu, rocky, alpine, or busybox | none | `--image` |
| `memory_mib` | no | Memory in MiB | `1024` | `--memory`, or Enter on a terminal |
| `cpus` | no | Virtual CPUs | `1` | `--cpus`, or Enter on a terminal |
| execute command | no | Command to run inside this container | none | tokens after `--` |

Yes/no questions (setup when packages would change, image remove, container remove) use one `prompt_yes_no`. Yes proceeds. No or Enter cancels. `--force` skips that question. There is no skip, quit, or maybe choice.

### 2.9 Help items and about items

Help **QEMU** section **MUST** list every command in §2.2 with one line each, plus `--name`, `--image`, `--memory`, `--cpus`, and `--force`.

Help **self-management** section stays on `requirement-shell-cli-interface.md` and **MUST** stay visually separate.

`about` **MUST** add, without removing the existing diagnostics and without a `CHECKSUM` field:

| Field | Meaning |
|-------|---------|
| `qemu_present` | `yes` or `no` |
| `qemu_bin` | emulator path, or empty |
| `host_os_family` | `debian`, `redhat`, `alpine`, `macos`, or `unsupported` |
| `image_dir` | `images` under persistence |
| `container_dir` | `containers` under persistence |
| `kvm_usable` | `yes` or `no` |

### 2.10 Who acts

| Actor | Role | Subject | Submitter | Approver |
|-------|------|---------|-----------|----------|
| This login | Operator | The image or container named in the command | This login | **None** |

There is no approval queue and no dest fence. Class residual records the same **None**.

### 2.11 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `qemu-cli` |
| **Ship unit (law)** | `src/qemu-cli` |
| **Ship unit** | `src/qemu-cli` `1.4.1` |
| **Domain prefix** | `qemu_` (`qemu_setup`, `qemu_image_list`, `qemu_image_create`, `qemu_image_show`, `qemu_image_remove`, `qemu_container_list`, `qemu_container_create`, `qemu_container_start`, `qemu_container_stop`, `qemu_container_execute`, `qemu_container_shell`, `qemu_container_remove`) |
| **Persistence** | `${HOME}/.local/qemu-cli` |
| **Default releases** | Ubuntu `26.04`, Rocky Linux `10`, Alpine `3.24` (2026-09-30) |
| **Publish channel** | Ship-unit defaults `cloudgen` / `qemu-cli`. Git remote is `git@github.com:cloudgen/qemu-cli.git`. Image downloads **MUST NOT** use the CLI's `SCRIPT_URL` |
| **In-tool sudo** | **None** |
| **Status** | Handlers are on `src/qemu-cli`. Guest boot, live image download, and JSON-sample byte match stay **Gap** (§5) |

### 2.12 Why this requirement exists (CIAO)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): Unknown names, missing checksums, and a login that is not the administrator fail closed.  
- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Setup, images, and containers are separate from CLI self-install.  
- **CIAO Principle 9 – Three types of commands** (https://github.com/cloudgen/ciao): `setup` is administrator work when packages must change. Container operations stay this login.  
- **CIAO Principle 10 – Least-privilege user** (https://github.com/cloudgen/ciao): No `sudo` wrap and no dedicated system account.  
- **CIAO Principle 16 – Interactive vs non-interactive** (https://github.com/cloudgen/ciao): Terminals get one question at a time. Pipes do not wait.  
- **CIAO Principle 18 – Input pattern checking** (https://github.com/cloudgen/ciao): Container names and release overrides match a closed pattern.  
- **CIAO Principle 19 – Defensive storage** (https://github.com/cloudgen/ciao): Guest files stay under the persistence root with tight modes.

---

## Under command line for normal user only

When the product detects Termux, Git Bash, Windows cmd, or the same class:

**This requirement:** `setup` **MUST** fail closed before any package command. Image create **MUST NOT** call `apt`, `dnf`, `yum`, `apk`, `brew`, or `sudo`. Container start **MAY** run only when a QEMU emulator is already on `PATH` without those tools. Git Bash and Windows cmd **MUST NOT** invoke Termux `pkg`.

| MUST | MUST NOT |
|------|----------|
| Say this command line cannot install QEMU | Enable admin privilege or a dedicated system account |
| Keep container operations as this login | Recommend `sudo curl \| sh` or wrap `sudo` |

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Four image families, three download hosts, loopback forwards only.  
- **Intentional:** The word container means a QEMU guest this tool recorded.  
- **Anti-fragile:** A second setup, image create, start, or stop converges.  
- **Over-protect:** No `sudo`, no private-key display, no delete of an image that a container still uses.

---

## 4. Protection Rule (Sacred)

**Future assistants MUST NOT**:

1. Treat Docker, Podman, or LXC as this product's containers.  
2. Add an image family, or a download host, without changing this requirement.  
3. Call `sudo` or write a sudoers fragment from `setup`.  
4. Bind a guest forward on `0.0.0.0` or any non-loopback address.  
5. Print SSH private keys, seed files, or passwords.  
6. Start a guest from `execute` or `shell`.  
7. Use `$()` around `prompt_ask` or `prompt_yes_no`.  
8. Point image downloads at the CLI publish channel.  
9. Make `install` mean "install QEMU". That alias stays CLI place.

---

## 5. Design-time verification

| ID | Where | Status |
|----|-------|--------|
| **TP-QEMU-01** | `tests/test_cli.sh` | automated — skipped when `qemu-img` or a system emulator is absent |
| **TP-QEMU-02** | `tests/test_cli.sh` | have — Linux non-root `setup` fails and names the administrator |
| **TP-QEMU-03** | `tests/test_cli.sh` | have — `TERMUX_VERSION=1` refuses and does not call `apt-get` |
| **TP-QEMU-04** | `tests/test_cli.sh` | have — `image list` is the four families |
| **TP-QEMU-05** | `tests/test_cli.sh` | have — seeded image create reports already present and does not re-download |
| **TP-QEMU-06** | `tests/test_cli.sh` | have — `image remove --force` refuses while a container record uses the family |
| **TP-QEMU-07** | `tests/test_cli.sh` | have — container data picker is `1. web`, not `121` |
| **TP-QEMU-08** | `tests/test_cli.sh` | todo — second start and second stop of a real guest |
| **TP-QEMU-09** | `tests/test_cli.sh` | have — `execute` on a stopped container fails |
| **TP-QEMU-10** | `tests/test_cli.sh` | have — `shell` off a terminal fails and does not hang |
| **TP-QEMU-11** | `tests/test_cli.sh` | have — menu rows **1**, **21**, **31**, **321–325**, and **81** is absent |
| **TP-QEMU-12** | `tests/test_cli.sh` | todo — image and container JSON samples match §2.7 |
| **TP-QEMU-13** | `tests/test_cli.sh` | have — non-interactive create with no name does not prompt |
| **TP-QEMU-14** | `tests/test_cli.sh` | have — JSON output has no private key material |

---

## 6. Related artifacts

| Artifact | Relationship |
|----------|----------------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-shell-cli-interface.md` | Dual mention of every verb |
| `docs/requirements/requirement-shell-cli-default-interaction.md` | Numbers and boards |
| `docs/requirements/requirement-shell-cli-self-install.md` | CLI place is not `setup` |
| `docs/requirements/requirement-shell-cli-storage.md` | Persistence root |
| `docs/requirements/requirement-shell-idempotency.md` | Re-run matrix |
| `docs/requirements/requirement-shell-script-coding.md` | `qemu_` prefix, no `sudo` |
| `docs/requirements/requirement-class-software-dev.md` | Approver **None** |
| `docs/requirements/requirement-shell-cli-language.md` | Front **6** copy |
| `src/qemu-cli` | Ship unit |

---

**Last Updated**: 2026-09-30  
**Owner**: qemu-cli project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).

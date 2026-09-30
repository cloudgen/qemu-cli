# =============================================================================
# tests/test_cli.sh — Type 0 CLI surface (no network install required)
# =============================================================================
# Covers: syntax, version, help, about, unknown command, quiet/json modes,
# help must not list CHECKSUM, self-uninstall --json fail-closed (INC-20260713-002
# contract shape when a binary is present under isolated USER_BIN),
# TP-SI-01..08 self-install copy / dest 0700 / empty argv / pipe download /
# no chmod +x / isolated GLOBAL_BIN 0755 (PP-A-28).
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

# Remove one volatile cache leaf created by a test process.
# Only /dev/shm/cache and /tmp/cache leaves. Never a home path.
_sm_drop_cache_leaf() {
    _leaf="${1:-}"
    case "${_leaf}" in
        /dev/shm/cache/cache-qemu-cli-*|/tmp/cache/cache-qemu-cli-*)
            if [ -d "${_leaf}" ]; then
                rm -rf "${_leaf}"
            fi
            ;;
    esac
    unset _leaf
}

run_test_cli() {
    t_header "CLI surface"

    require_cmd sh
    require_cmd sha256sum
    require_cmd grep

    # --- syntax ---
    sh -n "${SCRIPT}"
    _syn=$?
    assert_eq "sh -n qemu-cli (syntax)" 0 "$_syn"

    # --- companion digest matches ship unit ---
    if [ -f "${REPO_ROOT}/src/qemu-cli.sha256" ]; then
        _expected=$(tr -d ' \n\r\t' < "${REPO_ROOT}/src/qemu-cli.sha256")
        _actual=$(sha256sum "${SCRIPT}" | awk '{print $1}')
        assert_eq "src/qemu-cli.sha256 matches src/qemu-cli" "$_expected" "$_actual"
    else
        t_fail "qemu-cli.sha256 missing beside src/qemu-cli"
    fi

    # --- version (human) ---
    _out=$(sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "version exit 0" 0 "$_ec"
    assert_contains "version human mentions version" "$_out" "${PRODUCT_VERSION}"
    assert_contains "version human mentions app" "$_out" "qemu-cli"

    # --- version (json) ---
    _out=$(sh "${SCRIPT}" --json version 2>/dev/null)
    _ec=$?
    assert_eq "version --json exit 0" 0 "$_ec"
    assert_contains "version --json type" "$_out" '"type":"version"'
    assert_contains "version --json app" "$_out" '"app":"qemu-cli"'
    assert_contains "version --json version field" "$_out" "\"version\":\"${PRODUCT_VERSION}\""
    # app_version is the live dispatcher target (M1); no dual inline path
    assert_contains "version human via app_version" "$(sh "${SCRIPT}" version 2>/dev/null)" "${PRODUCT_VERSION}"

    # --- help (human): commands present, CHECKSUM absent ---
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "help exit 0" 0 "$_ec"
    assert_contains "help lists self-install" "$_out" "self-install"
    assert_contains "help lists install" "$_out" "install"
    assert_contains "help lists version-check" "$_out" "version-check"
    assert_contains "help lists self-update" "$_out" "self-update"
    assert_contains "help lists self-uninstall" "$_out" "self-uninstall"
    assert_contains "help lists about" "$_out" "about"
    assert_contains "help lists --json" "$_out" "--json"
    assert_contains "help lists --force" "$_out" "--force"
    assert_contains "help lists REPO_USER" "$_out" "REPO_USER"
    assert_contains "help lists REPO_NAME" "$_out" "REPO_NAME"
    assert_contains "help lists SCRIPT_RELPATH" "$_out" "SCRIPT_RELPATH"
    assert_contains "help lists SCRIPT_URL" "$_out" "SCRIPT_URL"
    assert_not_contains "help must not list CHECKSUM" "$_out" "CHECKSUM"

    # --- help (json): short object, not full prose ---
    _out=$(sh "${SCRIPT}" --json help 2>/dev/null)
    _ec=$?
    assert_eq "help --json exit 0" 0 "$_ec"
    assert_contains "help --json type success" "$_out" '"type":"success"'
    assert_contains "help --json command help" "$_out" '"command":"help"'

    # --- about (json): no CHECKSUM field; cache folder fields ---
    _app="${APP_NAME:-qemu-cli}"
    _login=$(id -un 2>/dev/null || echo "unknown")
    _out=$(sh "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "about --json exit 0" 0 "$_ec"
    assert_contains "about --json type" "$_out" '"type":"about"'
    assert_contains "about --json app" "$_out" '"app":"qemu-cli"'
    assert_not_contains "about --json must not include CHECKSUM" "$_out" "CHECKSUM"
    assert_contains "about --json effective_storage" "$_out" '"effective_storage"'
    assert_contains "about --json storage_dir" "$_out" '"storage_dir"'
    assert_contains "about --json cache_used" "$_out" '"cache_used"'
    assert_contains "about --json cache_preferred" "$_out" '"cache_preferred"'
    assert_contains "about --json cache_fallback" "$_out" '"cache_fallback"'
    assert_contains "about --json cache_fallback_2" "$_out" '"cache_fallback_2"'
    assert_contains "about --json persistence_storage" "$_out" '"persistence_storage"'
    assert_contains "about --json storage includes app name" "$_out" "${_app}"
    assert_not_contains "about --json no Storage (effective) label" "$_out" "Storage (effective)"
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    _sm_drop_cache_leaf "${_eff}"

    # --- TP-STOR-04 cache folder: per login, per process, silent tier miss ---
    # Uses this login’s HOME. Does not point HOME at a scratch directory.
    _out=$(sh "${SCRIPT}" --json about 2>/dev/null)
    _pref=$(printf '%s' "$_out" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _pid="${_pref##*-}"
    case "${_pref}" in
        /dev/shm/cache/cache-"${_app}"-"${_login}"-[0-9]*)
            t_pass "TP-STOR-04 cache_preferred is shm login process leaf"
            ;;
        *) t_fail "TP-STOR-04 cache_preferred unexpected: '${_pref:-empty}'" ;;
    esac
    _fb=$(printf '%s' "$_out" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-STOR-04 cache_fallback 1st" "/tmp/cache/cache-${_app}-${_login}-${_pid}" "${_fb}"
    _fb2=$(printf '%s' "$_out" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-STOR-04 cache_fallback 2nd" "${HOME}/.cache/cache-${_app}-${_pid}" "${_fb2}"
    _used=$(printf '%s' "$_out" | sed -n 's/.*"cache_used":"\([^"]*\)".*/\1/p' | head -n1)
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-STOR-04 cache_used matches effective" "${_eff}" "${_used}"
    if [ -n "$_eff" ] && [ -d "$_eff" ]; then
        t_pass "TP-STOR-04 effective cache directory exists"
    else
        t_fail "TP-STOR-04 effective cache missing: '${_eff:-empty}'"
    fi
    case "${_eff}" in
        /dev/shm/"${_app}"|/dev/shm/"${_app}"-*)
            t_fail "TP-STOR-04 effective cache must not be a ram-drive project shape: '${_eff}'"
            ;;
        *) t_pass "TP-STOR-04 effective cache is not a ram-drive project shape" ;;
    esac
    case "${_eff}" in
        /dev/shm/cache/cache-"${_app}"-"${_login}"-*|/tmp/cache/cache-"${_app}"-"${_login}"-*)
            t_pass "TP-STOR-04 effective cache includes login segment"
            ;;
        *) t_fail "TP-STOR-04 effective cache missing login segment for '${_login}': ${_eff}" ;;
    esac
    _mode=$(stat -c %a "${_eff}" 2>/dev/null || echo "")
    assert_eq "TP-STOR-04 effective cache mode 0700" "700" "${_mode}"
    _persist=$(printf '%s' "$_out" | sed -n 's/.*"persistence_storage":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-STOR-04 persistence_storage path" "${HOME}/.local/${_app}" "${_persist}"
    if [ -n "${_persist}" ] && [ -d "${_persist}" ]; then
        t_pass "TP-STOR-04 persistence storage directory exists"
    else
        t_fail "TP-STOR-04 persistence storage missing: '${_persist:-empty}'"
    fi
    case "${_persist}" in
        */.local/bin|*/.local/bin/) t_fail "TP-STOR-04 persistence must not be the install bin: '${_persist}'" ;;
        *) t_pass "TP-STOR-04 persistence is not the install bin directory" ;;
    esac
    _hum=$(sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-STOR-04 human Cache folder used" "${_hum}" "Cache folder used:"
    assert_contains "TP-STOR-04 human Cache folder preferred" "${_hum}" "Cache folder (preferred):"
    assert_contains "TP-STOR-04 human Cache folder 1st fallback" "${_hum}" "Cache folder (1st fallback):"
    assert_contains "TP-STOR-04 human Cache folder 2nd fallback" "${_hum}" "Cache folder (2nd fallback):"
    assert_contains "TP-STOR-04 human Persistence storage" "${_hum}" "Persistence storage:"
    assert_contains "TP-STOR-04 human preferred path" "${_hum}" "/dev/shm/cache/cache-${_app}-${_login}-"
    assert_not_contains "TP-STOR-04 human no Storage (effective)" "${_hum}" "Storage (effective)"
    assert_not_contains "TP-STOR-04 human no Storage (fallback)" "${_hum}" "Storage (fallback)"
    _err=$(QEMU_CLI_CACHE_SKIP=preferred sh "${SCRIPT}" about 2>&1 >/dev/null)
    assert_not_contains "TP-STOR-04 silent cache fallback" "${_err}" "fallback"
    assert_not_contains "TP-STOR-04 silent cache fallback error" "${_err}" "Cannot create cache"
    assert_not_contains "TP-STOR-04 silent cache tier warn" "${_err}" "cache folder"
    _skip=$(QEMU_CLI_CACHE_SKIP=preferred sh "${SCRIPT}" --json about 2>/dev/null)
    _skip_eff=$(printf '%s' "$_skip" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    _skip_fb=$(printf '%s' "$_skip" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-STOR-04 skipped preferred uses 1st fallback" "${_skip_fb}" "${_skip_eff}"
    _gb=$(QEMU_CLI_CACHE_HOST=gitbash sh "${SCRIPT}" --json about 2>/dev/null)
    _gb_pref=$(printf '%s' "$_gb" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _gb_pid="${_gb_pref##*-}"
    assert_eq "TP-STOR-04 gitbash preferred" "/tmp/cache/cache-${_app}-${_login}-${_gb_pid}" "${_gb_pref}"
    _gb_fb=$(printf '%s' "$_gb" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-STOR-04 gitbash 1st fallback" "${HOME}/AppData/Local/Temp/cache-${_app}-${_gb_pid}" "${_gb_fb}"
    assert_contains "TP-STOR-04 gitbash json has cache_fallback_2" "${_gb}" '"cache_fallback_2":""'
    _gb_fb2=$(printf '%s' "$_gb" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-STOR-04 gitbash no 2nd fallback" "" "${_gb_fb2}"
    _hum_gb=$(QEMU_CLI_CACHE_HOST=gitbash sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-STOR-04 gitbash about 1st" "${_hum_gb}" "AppData/Local/Temp/cache-${_app}-"
    assert_not_contains "TP-STOR-04 gitbash about omits 2nd" "${_hum_gb}" "Cache folder (2nd fallback)"
    _mac=$(QEMU_CLI_CACHE_HOST=mac sh "${SCRIPT}" --json about 2>/dev/null)
    _mac_pref=$(printf '%s' "$_mac" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _mac_pid="${_mac_pref##*-}"
    assert_eq "TP-STOR-04 mac preferred" "/tmp/cache/cache-${_app}-${_login}-${_mac_pid}" "${_mac_pref}"
    _mac_fb=$(printf '%s' "$_mac" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-STOR-04 mac 1st fallback" "${HOME}/Library/Caches/cache-${_app}-${_mac_pid}" "${_mac_fb}"
    _mac_fb2=$(printf '%s' "$_mac" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-STOR-04 mac 2nd fallback" "${HOME}/cache/cache-${_app}-${_mac_pid}" "${_mac_fb2}"
    _hum_mac=$(QEMU_CLI_CACHE_HOST=mac sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-STOR-04 mac about 1st" "${_hum_mac}" "Library/Caches/cache-${_app}-"
    assert_contains "TP-STOR-04 mac about 2nd path" "${_hum_mac}" "Cache folder (2nd fallback): ${HOME}/cache/cache-${_app}-"
    _sm_drop_cache_leaf "${_eff}"
    _sm_drop_cache_leaf "${_skip_eff}"
    _sm_drop_cache_leaf "${_gb_pref}"
    _sm_drop_cache_leaf "${_mac_pref}"
    _hum_eff=$(printf '%s' "${_hum}" | sed -n 's/.*Cache folder used: //p' | head -n1)
    _sm_drop_cache_leaf "${_hum_eff}"
    _gb_hum_eff=$(printf '%s' "${_hum_gb}" | sed -n 's/.*Cache folder used: //p' | head -n1)
    _sm_drop_cache_leaf "${_gb_hum_eff}"
    _mac_hum_eff=$(printf '%s' "${_hum_mac}" | sed -n 's/.*Cache folder used: //p' | head -n1)
    _sm_drop_cache_leaf "${_mac_hum_eff}"

    # --- unknown command ---
    _err=$(sh "${SCRIPT}" no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "unknown command exit 1" 1 "$_ec"
    assert_contains "unknown command error text" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" --json no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "unknown command --json exit 1" 1 "$_ec"
    assert_contains "unknown command --json type error" "$_err" '"type":"out_error"'

    # --- quiet: version should not print info banners ---
    # Contract: --quiet suppresses non-error chatter; version uses out_info → suppressed.
    _out=$(sh "${SCRIPT}" --quiet version 2>/dev/null)
    _ec=$?
    assert_eq "version --quiet exit 0" 0 "$_ec"
    # out_info is suppressed under quiet → empty or near-empty stdout is correct
    if [ -z "$_out" ]; then
        t_pass "version --quiet suppresses human info"
    else
        _trim=$(printf '%s' "$_out" | tr -d ' \t\n\r')
        if [ -z "$_trim" ]; then
            t_pass "version --quiet suppresses human info"
        else
            t_fail "version --quiet expected empty stdout, got '$(_trunc "$_out")'"
        fi
    fi

    # --- HOME unset under set -u (INC-20260713-001) ---
    # Must not abort with "HOME: parameter not set"; defaults HOME then USER_BIN.
    _out=$(env -u HOME sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "env -u HOME version exit 0" 0 "$_ec"
    assert_contains "env -u HOME version still reports version" "$_out" "${PRODUCT_VERSION}"

    # --- zero-arg auto-install propagates failure (interpreter $0 / pipe; not exit 0 on download fail) ---
    # Script $0 copies offline; a dead SCRIPT_URL must be proven with interpreter $0.
    ci_isolated_env
    _errf="${CI_HOME}/zero-arg-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/qemu-cli-unreachable" \
        sh -s < "${SCRIPT}" 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ "$_ec" -ne 0 ]; then
        t_pass "zero-arg failed install exits non-zero"
    else
        t_fail "zero-arg failed install expected non-zero exit, got 0 (stdout='$(_trunc "$_out")' err='$(_trunc "$_err")')"
    fi
    assert_file_missing "zero-arg failed install left no binary" "${CI_USER_BIN}/qemu-cli"
    ci_cleanup_env

    # --- TP-SI-01 script $0 copies without download (dead SCRIPT_URL) ---
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" SCRIPT_URL="http://127.0.0.1:1/no-such-${APP_NAME:-qemu-cli}" sh "${SCRIPT}" self-install 2>&1)
    _ec=$?
    assert_eq "TP-SI-01 self-install copy exit 0" 0 "$_ec"
    assert_file_exists "TP-SI-01 binary at USER_BIN" "${CI_USER_BIN}/${APP_NAME:-qemu-cli}"
    assert_contains "TP-SI-01 copy from local script" "$_out" "Installing from local script"
    assert_not_contains "TP-SI-01 no companion download" "$_out" "Companion link:"

    # --- TP-SI-02 local dest mode 0700 ---
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME:-qemu-cli}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME:-qemu-cli}" 2>/dev/null || echo "")
    case "${_mode}" in
        700|0700) assert_eq "TP-SI-02 local dest mode 0700" "0700" "0700" ;;
        *) assert_eq "TP-SI-02 local dest mode 0700" "0700" "${_mode}" ;;
    esac

    # --- TP-SI-05 already-installed no-op ---
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" self-install 2>&1)
    _ec=$?
    assert_eq "TP-SI-05 second self-install exit 0" 0 "$_ec"
    assert_contains "TP-SI-05 already installed" "$_out" "already installed"
    ci_cleanup_env

    # --- TP-SI-03 NI empty argv is self-install (copy), not help ---
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" SCRIPT_URL="http://127.0.0.1:1/no-such-${APP_NAME:-qemu-cli}" sh "${SCRIPT}" 2>&1)
    _ec=$?
    assert_eq "TP-SI-03 empty argv copy exit 0" 0 "$_ec"
    assert_file_exists "TP-SI-03 empty argv placed binary" "${CI_USER_BIN}/${APP_NAME:-qemu-cli}"
    assert_contains "TP-SI-03 empty argv self-install banner" "$_out" "Starting self-install"
    assert_not_contains "TP-SI-03 empty argv is not help" "$_out" "Global Options"
    ci_cleanup_env

    # --- TP-SI-04 interpreter $0 (stdin pipe) uses channel download ---
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" SCRIPT_URL="file://${SCRIPT}" sh -s < "${SCRIPT}" 2>&1)
    _ec=$?
    assert_eq "TP-SI-04 pipe self-install exit 0" 0 "$_ec"
    assert_file_exists "TP-SI-04 pipe placed binary" "${CI_USER_BIN}/${APP_NAME:-qemu-cli}"
    assert_contains "TP-SI-04 pipe uses companion download" "$_out" "Companion link:"
    ci_cleanup_env

    # --- TP-SI-06 help lists self-install ---
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-SI-06 help lists self-install" "$_out" "self-install"

    # --- TP-SI-07 no chmod +x on place path (0711 trap; PP-A-28) ---
    # Live command only. Comments that say MUST NOT chmod +x are allowed.
    if grep -nE '^[[:space:]]*chmod[[:space:]]+\+x' "${SCRIPT}" >/dev/null 2>&1; then
        t_fail "TP-SI-07 ship unit must not chmod +x (mints 0711; other users cannot open shebang)"
    else
        t_pass "TP-SI-07 no chmod +x command"
    fi
    if grep -q 'inst_cli_dest_mode()' "${SCRIPT}"; then
        t_pass "TP-SI-07 inst_cli_dest_mode present"
    else
        t_fail "TP-SI-07 inst_cli_dest_mode missing"
    fi
    assert_contains "TP-SI-07 dest helper names 0755" "$(sed -n '/^inst_cli_dest_mode()/,/^}/p' "${SCRIPT}")" "0755"
    assert_contains "TP-SI-07 dest helper names 0700" "$(sed -n '/^inst_cli_dest_mode()/,/^}/p' "${SCRIPT}")" "0700"

    # --- TP-SI-08 isolated GLOBAL_BIN dest 0755 (heals leftover 0711) ---
    # Non-root CI cannot id -u 0; the copy helper is what root passes 0755 into.
    ci_isolated_env
    ci_source_ship_unit
    JSON=0
    : "${APP_NAME:=qemu-cli}"
    INSTALL_PATH="${CI_GLOBAL_BIN}/${APP_NAME}"
    mkdir -p "${CI_GLOBAL_BIN}"
    cp "${SCRIPT}" "${INSTALL_PATH}"
    chmod 0711 "${INSTALL_PATH}" 2>/dev/null || chmod 711 "${INSTALL_PATH}"
    inst_self_install_copy_from_script "${SCRIPT}" "0755"
    _ec=$?
    assert_eq "TP-SI-08 copy 0755 onto GLOBAL_BIN exit 0" 0 "$_ec"
    assert_file_exists "TP-SI-08 global dest exists" "${INSTALL_PATH}"
    _mode=$(stat -c '%a' "${INSTALL_PATH}" 2>/dev/null || stat -f '%OLp' "${INSTALL_PATH}" 2>/dev/null || echo "")
    case "${_mode}" in
        755|0755) assert_eq "TP-SI-08 global dest mode 0755 (not 0711)" "0755" "0755" ;;
        *) assert_eq "TP-SI-08 global dest mode 0755 (not 0711)" "0755" "${_mode}" ;;
    esac
    if [ -r "${INSTALL_PATH}" ] && [ -x "${INSTALL_PATH}" ]; then
        t_pass "TP-SI-08 global dest readable+executable (other-read shebang)"
    else
        t_fail "TP-SI-08 global dest must be readable+executable (0711 fails unprivileged /bin/sh open)"
    fi
    JSON=0
    ci_cleanup_env

    # --- self-uninstall --json without force when binary present (isolated) ---
    # Fail-closed confirm_required (INC-20260713-002 contract).
    ci_isolated_env
    mkdir -p "${CI_USER_BIN}"
    # Place a stub install so uninstall path runs without network
    cp "${SCRIPT}" "${CI_USER_BIN}/qemu-cli"
    chmod +x "${CI_USER_BIN}/qemu-cli"
    _errf="${CI_HOME}/un-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" \
        sh "${SCRIPT}" --json self-uninstall 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "self-uninstall --json without --force exit 1" 1 "$_ec"
    assert_contains "self-uninstall --json confirm_required code" "$_err" '"code":"confirm_required"'
    assert_contains "self-uninstall --json out_error type" "$_err" '"type":"out_error"'
    assert_not_contains "self-uninstall --json must not fake success cancel" "$_out$_err" "cancelled by user"
    assert_file_exists "binary remains without --force" "${CI_USER_BIN}/qemu-cli"
    ci_cleanup_env

    # --- TP-JSON-RAW-01 / TP-CLI-12: out_json @key inserts raw nested JSON ---
    ci_isolated_env
    ci_source_ship_unit
    JSON=1
    _out=$(out_json "success" "" "count" "2" "@items" '["a","b"]')
    _ec=$?
    assert_eq "TP-JSON-RAW-01 out_json @key exit 0" 0 "$_ec"
    assert_contains "TP-JSON-RAW-01 type success" "$_out" '"type":"success"'
    assert_contains "TP-JSON-RAW-01 string count stays quoted" "$_out" '"count":"2"'
    assert_contains "TP-JSON-RAW-01 raw nested array unquoted" "$_out" '"items":["a","b"]'
    assert_not_contains "TP-JSON-RAW-01 must not stringify the array" "$_out" '"items":"[\"a\",\"b\"]"'
    _out=$(out_json "success" "" "@meta" '{"n":1}')
    assert_contains "TP-JSON-RAW-01 raw nested object unquoted" "$_out" '"meta":{"n":1}'
    JSON=0
    _silent=$(out_json "success" "" "@items" '["x"]')
    if [ -z "$_silent" ]; then
        t_pass "TP-JSON-RAW-01 out_json no-ops when JSON=0"
    else
        t_fail "TP-JSON-RAW-01 expected empty when JSON=0, got '$(_trunc "$_silent")'"
    fi
    ci_cleanup_env

    # --- TP-CS-01: bootstrap ship unit has no in-tool sudo wrap ---
    if grep -q 'util_sudo()' "${SCRIPT}"; then
        t_fail "TP-CS-01 ship unit must not define util_sudo"
    else
        t_pass "TP-CS-01 no util_sudo function"
    fi
    if grep -E '^[[:space:]]*sudo[[:space:]]' "${SCRIPT}" >/dev/null 2>&1; then
        t_fail "TP-CS-01 ship unit must not invoke sudo as a command"
    else
        t_pass "TP-CS-01 no command-position sudo"
    fi

    # --- TP-CLI-17: default CLI main menu style on a TTY ---
    _out=$(printf '9\n' | TTY=1 sh "${SCRIPT}" 2>&1)
    _ec=$?
    assert_eq "TP-CLI-17 empty-argv menu exit 0" 0 "$_ec"
    assert_contains "TP-CLI-17 bold short name" "$_out" "$(printf '\033[1mself-management\033[0m')"
    assert_contains "TP-CLI-17 italic gray explain" "$_out" "$(printf '\033[3;37mthis CLI install, version, update, uninstall\033[0m')"
    assert_contains "TP-CLI-17 italic version" "$_out" "$(printf '\033[3m%s\033[0m' "${PRODUCT_VERSION}")"
    assert_contains "TP-CLI-17 exit row" "$_out" "9. Exit"
    _out=$(printf '9\n' | TTY=1 sh "${SCRIPT}" --json menu 2>&1)
    _ec=$?
    assert_eq "TP-CLI-17 menu --json on a TTY exit 0" 0 "$_ec"
    assert_contains "TP-CLI-17 menu --json on a TTY still draws the list" "$_out" "self-management"
    assert_not_contains "TP-CLI-17 menu --json on a TTY is not JSON help" "$_out" '"command":"help"'

    # --- TP-CLI-19: invalid choice reprints this layer ---
    _out=$(printf '4\n9\n' | TTY=1 sh "${SCRIPT}" 2>&1)
    _ec=$?
    assert_eq "TP-CLI-19 bad pick still exit 0" 0 "$_ec"
    assert_contains "TP-CLI-19 names the pick" "$_out" "Not a menu choice '4'"
    assert_not_contains "TP-CLI-19 is not unknown argv" "$_out" "Unknown command"
    _n=$(printf '%s\n' "$_out" | grep -c 'this CLI install, version, update, uninstall' || true)
    assert_eq "TP-CLI-19 reprints the front board" "2" "${_n}"

    # --- TP-CLI-21: finished leaf redisplays the front board ---
    _out=$(printf '8\n82\n9\n' | TTY=1 sh "${SCRIPT}" 2>&1)
    _ec=$?
    assert_eq "TP-CLI-21 version leaf exit 0" 0 "$_ec"
    assert_contains "TP-CLI-21 version ran" "$_out" "${PRODUCT_VERSION}"
    _n=$(printf '%s\n' "$_out" | grep -c 'this CLI install, version, update, uninstall' || true)
    assert_eq "TP-CLI-21 front board after the leaf" "2" "${_n}"

    # --- TP-CLI-22: self-management rows; off-TTY menu is help ---
    _out=$(printf '8\n0\n9\n' | TTY=1 sh "${SCRIPT}" 2>&1)
    _ec=$?
    assert_eq "TP-CLI-22 submenu exit 0" 0 "$_ec"
    assert_contains "TP-CLI-22 lists 87 self-install" "$_out" "87."
    assert_contains "TP-CLI-22 lists back" "$_out" "0. Back"
    assert_not_contains "TP-CLI-22 omits reserved 81" "$_out" "81."
    _out=$(sh "${SCRIPT}" menu </dev/null 2>&1)
    _ec=$?
    assert_eq "TP-CLI-22 off-tty menu exit 0" 0 "$_ec"
    assert_contains "TP-CLI-22 off-tty menu is help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-22 off-tty menu does not draw 82" "$_out" "82."

    # Catalog must stay free of the four-letter run that breaks command substitution.
    if awk '/^app_menu_text\(\)/,/^}$/' "${SCRIPT}" | grep -q -i 'read'; then
        t_fail "app_menu_text contains a banned letter run"
    else
        t_pass "app_menu_text has no banned letter run"
    fi

    ci_isolated_env
    _qenv="HOME=${CI_HOME} USER_BIN=${CI_USER_BIN} GLOBAL_BIN=${CI_GLOBAL_BIN} TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en"

    _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
        sh "${SCRIPT}" image list 2>&1)
    _ec=$?
    assert_eq "TP-QEMU-04 image list exit 0" 0 "${_ec}"
    assert_contains "TP-QEMU-04 ubuntu" "${_out}" "ubuntu"
    assert_contains "TP-QEMU-04 rocky" "${_out}" "rocky"
    assert_contains "TP-QEMU-04 alpine" "${_out}" "alpine"
    assert_contains "TP-QEMU-04 busybox" "${_out}" "busybox"

    _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
        sh "${SCRIPT}" image show alpine 2>&1)
    _ec=$?
    if [ "${_ec}" -ne 0 ]; then
        t_pass "image show of a missing family is non-zero"
    else
        t_fail "image show of a missing family exited 0"
    fi
    assert_contains "image show names the missing family" "${_out}" "No image record for family 'alpine'."

    _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
        sh "${SCRIPT}" container list 2>&1)
    _ec=$?
    assert_eq "container list exit 0" 0 "${_ec}"
    assert_contains "container list empty line" "${_out}" "No containers exist yet."

    _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
        sh "${SCRIPT}" container create --name demo --image ubuntu 2>&1)
    _ec=$?
    if [ "${_ec}" -ne 0 ]; then
        t_pass "container create without an image record is non-zero"
    else
        t_fail "container create without an image record exited 0"
    fi
    assert_contains "container create names the missing image" "${_out}" "No image record for family 'ubuntu'."

    _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
        sh "${SCRIPT}" container create --name BadName --image ubuntu 2>&1)
    _ec=$?
    if [ "${_ec}" -ne 0 ]; then
        t_pass "container create rejects a bad name"
    else
        t_fail "container create accepted a bad name"
    fi

    if command -v timeout >/dev/null 2>&1; then
        _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
            timeout 15 sh "${SCRIPT}" container create --image ubuntu 2>&1)
        _ec=$?
    else
        _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
            sh "${SCRIPT}" container create --image ubuntu 2>&1)
        _ec=$?
    fi
    if [ "${_ec}" -ne 0 ]; then
        t_pass "TP-QEMU-13 create without a name is non-zero"
    else
        t_fail "TP-QEMU-13 create without a name exited 0"
    fi
    assert_contains "TP-QEMU-13 names the missing field" "${_out}" "Container name is required."

    mkdir -p "${CI_HOME}/.local/qemu-cli/images" "${CI_HOME}/.local/qemu-cli/containers"
    printf '%s\n' '{' \
        '  "schema_version": 1,' \
        '  "family": "ubuntu",' \
        '  "release": "26.04",' \
        '  "arch": "x86_64",' \
        '  "method": "vendor-cloud",' \
        '  "disk": "images/ubuntu.qcow2",' \
        '  "source_url": "https://cloud-images.ubuntu.com/releases/26.04/release/ubuntu-26.04-server-cloudimg-amd64.img",' \
        '  "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"' \
        '}' > "${CI_HOME}/.local/qemu-cli/images/ubuntu.json"
    printf '%s\n' 'seed' > "${CI_HOME}/.local/qemu-cli/images/ubuntu.qcow2"
    if command -v timeout >/dev/null 2>&1; then
        _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
            timeout 20 sh "${SCRIPT}" image create ubuntu 2>&1)
        _ec=$?
    else
        _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
            sh "${SCRIPT}" image create ubuntu 2>&1)
        _ec=$?
    fi
    assert_eq "TP-QEMU-05 second image create exit 0" 0 "${_ec}"
    assert_contains "TP-QEMU-05 does not download again" "${_out}" "already present"

    printf '%s\n' '{' \
        '  "schema_version": 1,' \
        '  "name": "web",' \
        '  "image_family": "ubuntu",' \
        '  "disk": "containers/web.qcow2",' \
        '  "state": "stopped",' \
        '  "pid": null,' \
        '  "accel": "",' \
        '  "ssh_port": null,' \
        '  "memory_mib": 1024,' \
        '  "cpus": 1' \
        '}' > "${CI_HOME}/.local/qemu-cli/containers/web.json"
    printf '%s\n' 'BEGIN OPENSSH PRIVATE KEY' 'secret-marker-not-for-output' > "${CI_HOME}/.local/qemu-cli/containers/web.key"

    _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
        sh "${SCRIPT}" image remove ubuntu --force 2>&1)
    _ec=$?
    if [ "${_ec}" -ne 0 ]; then
        t_pass "TP-QEMU-06 image remove while in use is non-zero"
    else
        t_fail "TP-QEMU-06 image remove while in use exited 0"
    fi
    assert_contains "TP-QEMU-06 names the in-use family" "${_out}" "still used by a container"

    _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
        sh "${SCRIPT}" container execute web -- true 2>&1)
    _ec=$?
    if [ "${_ec}" -ne 0 ]; then
        t_pass "TP-QEMU-09 execute on a stopped container is non-zero"
    else
        t_fail "TP-QEMU-09 execute on a stopped container exited 0"
    fi
    assert_contains "TP-QEMU-09 says the container is stopped" "${_out}" "is stopped"

    _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
        sh "${SCRIPT}" container shell web 2>&1)
    _ec=$?
    if [ "${_ec}" -ne 0 ]; then
        t_pass "TP-QEMU-10 shell off a terminal is non-zero"
    else
        t_fail "TP-QEMU-10 shell off a terminal exited 0"
    fi
    assert_contains "TP-QEMU-10 names the terminal" "${_out}" "needs a terminal"

    _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=1 QUIET=1 FORCE=0 QEMU_CLI_LANG=en \
        sh "${SCRIPT}" --json container list 2>&1)
    assert_not_contains "TP-QEMU-14 list JSON has no private key" "${_out}" "BEGIN OPENSSH PRIVATE KEY"
    assert_not_contains "TP-QEMU-14 list JSON has no key marker" "${_out}" "secret-marker-not-for-output"
    _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=1 QUIET=1 FORCE=0 QEMU_CLI_LANG=en \
        sh "${SCRIPT}" --json about 2>&1)
    assert_contains "about JSON qemu_present" "${_out}" '"qemu_present":'
    assert_not_contains "about JSON has no CHECKSUM" "${_out}" "CHECKSUM"
    assert_not_contains "TP-QEMU-14 about JSON has no private key" "${_out}" "secret-marker-not-for-output"

    _qemu_ok=0
    if command -v qemu-img >/dev/null 2>&1; then
        if command -v qemu-system-x86_64 >/dev/null 2>&1 || command -v qemu-system-aarch64 >/dev/null 2>&1 || command -v qemu-system-arm >/dev/null 2>&1; then
            _qemu_ok=1
        fi
    fi
    if [ "${_qemu_ok}" -eq 1 ]; then
        _out=$(env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
            sh "${SCRIPT}" setup 2>&1)
        _ec=$?
        assert_eq "TP-QEMU-01 setup no-op exit 0" 0 "${_ec}"
        assert_contains "TP-QEMU-01 already available" "${_out}" "already available"
    else
        t_skip "TP-QEMU-01 qemu-img or a system emulator is not on PATH"
    fi

    _stub=$(mktemp -d "${TMPDIR:-/tmp}/qemu-cli-stub.XXXXXX")
    for _dir in /usr/bin /bin /usr/local/bin; do
        if [ ! -d "${_dir}" ]; then
            continue
        fi
        for _f in "${_dir}"/*; do
            if [ ! -x "${_f}" ]; then
                continue
            fi
            _base=${_f##*/}
            case "${_base}" in
                qemu-img|qemu-system*|apt-get|apt|dnf|yum|apk|brew|sudo) continue ;;
            esac
            if [ ! -e "${_stub}/${_base}" ]; then
                ln -s "${_f}" "${_stub}/${_base}" 2>/dev/null || true
            fi
        done
    done
    _out=$(env PATH="${_stub}" HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en TERMUX_VERSION=1 \
        sh "${SCRIPT}" setup 2>&1)
    _ec=$?
    if [ "${_ec}" -ne 0 ]; then
        t_pass "TP-QEMU-03 normal-user-only setup is non-zero"
    else
        t_fail "TP-QEMU-03 normal-user-only setup exited 0"
    fi
    assert_contains "TP-QEMU-03 cannot install" "${_out}" "This command line cannot install QEMU."
    assert_not_contains "TP-QEMU-03 did not run apt-get" "${_out}" "apt-get"
    if [ "$(id -u 2>/dev/null || echo 1)" -ne 0 ]; then
        _out=$(env PATH="${_stub}" HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=0 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
            sh "${SCRIPT}" setup 2>&1)
        _ec=$?
        if [ "${_ec}" -ne 0 ]; then
            t_pass "TP-QEMU-02 non-root setup is non-zero"
        else
            t_fail "TP-QEMU-02 non-root setup exited 0"
        fi
        assert_contains "TP-QEMU-02 tells the operator to re-run as administrator" "${_out}" "administrator"
    else
        t_skip "TP-QEMU-02 this process is the administrator"
    fi
    rm -rf "${_stub}"
    unset _stub _dir _f _base

    _out=$(printf '2\n0\n3\n32\n1\n0\n0\n0\n9\n' | env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=1 JSON=0 QUIET=0 FORCE=0 QEMU_CLI_LANG=en \
        sh "${SCRIPT}" 2>&1)
    _ec=$?
    assert_eq "TP-QEMU-11 menu exit 0" 0 "${_ec}"
    assert_contains "TP-QEMU-11 front setup" "${_out}" "$(printf '1. \033[1msetup\033[0m')"
    assert_contains "TP-QEMU-11 image child" "${_out}" "21."
    assert_contains "TP-QEMU-11 container child" "${_out}" "31."
    assert_contains "TP-QEMU-11 start" "${_out}" "321."
    assert_contains "TP-QEMU-11 stop" "${_out}" "322."
    assert_contains "TP-QEMU-11 execute" "${_out}" "323."
    assert_contains "TP-QEMU-11 shell" "${_out}" "324."
    assert_contains "TP-QEMU-11 remove" "${_out}" "325."
    assert_contains "TP-QEMU-07 picker number" "${_out}" "1. web"
    assert_not_contains "TP-QEMU-07 picker is not prefixed 121" "${_out}" "121."
    assert_not_contains "TP-QEMU-11 omits 81" "${_out}" "81."

    _out=$(printf '6\n0\n9\n' | env -u QEMU_CLI_LANG HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=1 JSON=0 QUIET=0 FORCE=0 \
        sh "${SCRIPT}" 2>&1)
    assert_contains "language board lists English" "${_out}" "61."
    assert_contains "language board lists Traditional Chinese" "${_out}" "62."
    assert_contains "language board lists Korean" "${_out}" "68."

    _out=$(printf '6\n62\n9\n' | env -u QEMU_CLI_LANG HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=1 JSON=0 QUIET=0 FORCE=0 \
        sh "${SCRIPT}" 2>&1)
    _ec=$?
    assert_eq "language save exit 0" 0 "${_ec}"
    assert_contains "language save speaks the new language" "${_out}" "選單語言是繁體中文"
    _langf="${CI_HOME}/.local/qemu-cli/language"
    assert_file_exists "language file exists" "${_langf}"
    _langv=$(awk 'NR==1{print; exit}' "${_langf}")
    assert_eq "language file is zh-Hant" "zh-Hant" "${_langv}"
    _mode=$(stat -c '%a' "${_langf}" 2>/dev/null || stat -f '%OLp' "${_langf}" 2>/dev/null || echo "")
    assert_eq "language file mode 0600" "600" "${_mode}"

    printf '%s\n' 'zz' > "${_langf}"
    env -u QEMU_CLI_LANG HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=1 JSON=0 QUIET=0 FORCE=0 \
        sh "${SCRIPT}" >/dev/null 2>&1 <<'EOF'
9
EOF
    _langv=$(awk 'NR==1{print; exit}' "${_langf}")
    assert_eq "unrecognized language file is not rewritten" "zz" "${_langv}"
    env QEMU_CLI_LANG=ja HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=1 JSON=0 QUIET=0 FORCE=0 \
        sh "${SCRIPT}" >/dev/null 2>&1 <<'EOF'
9
EOF
    _langv=$(awk 'NR==1{print; exit}' "${_langf}")
    assert_eq "QEMU_CLI_LANG does not write the language file" "zz" "${_langv}"

    ci_cleanup_env
    unset _out _ec _langf _langv _mode _qenv
}

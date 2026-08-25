#!/bin/sh

set -eu

mode="update"
case "${1:-}" in
    --status)
        mode="status"
        shift
        ;;
    --verify)
        mode="verify"
        shift
        ;;
esac

if { [ "$mode" = "status" ] && [ "$#" -ne 1 ]; } \
    || { [ "$mode" = "verify" ] && [ "$#" -ne 1 ]; } \
    || { [ "$mode" = "update" ] && [ "$#" -ne 1 ]; }; then
    echo "Usage: $0 --status <tuist-version> | $0 --verify <tuist-version> | $0 <tuist-binary>" >&2
    exit 1
fi

mode_argument="${1:-}"
script_directory=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
project_directory=$(CDPATH= cd "$script_directory/.." && pwd -P)
tuist_directory="$project_directory/Tuist"
registry_configuration="$tuist_directory/.swiftpm/configuration/registries.json"
lock_state="$tuist_directory/Package.lock-state"
lock_state_format=1
project_lock_key=$(printf '%s' "$project_directory" | shasum -a 256 | awk '{ print $1 }')
package_resolved_lock_root=${TMPDIR:-/tmp}
package_resolved_lock="${package_resolved_lock_root%/}/wrapkit-package-locks-$project_lock_key.lock"

acquire_package_resolved_lock() {
    exec 9>"$package_resolved_lock"
    /usr/bin/lockf -s -t 180 9
}

file_hash() {
    shasum -a 256 "$1" | awk '{ print $1 }'
}

manifest_hash() {
    file_hash "$tuist_directory/Package.swift"
}

resolved_origin_hash() {
    sed -n 's/^[[:space:]]*"originHash"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$1" \
        | head -n 1
}

state_value() {
    key="$1"
    sed -n "s/^$key=//p" "$lock_state" | head -n 1
}

locks_are_current() {
    expected_tuist_version="$1"
    [ -s "$tuist_directory/Package.resolved" ] \
        && [ -s "$tuist_directory/Package.registry.resolved" ] \
        && [ -s "$lock_state" ] \
        && plutil -convert json -o /dev/null -- "$tuist_directory/Package.resolved" >/dev/null 2>&1 \
        && plutil -convert json -o /dev/null -- "$tuist_directory/Package.registry.resolved" >/dev/null 2>&1 \
        && expected_hash=$(manifest_hash) \
        && [ "$(resolved_origin_hash "$tuist_directory/Package.resolved")" = "$expected_hash" ] \
        && [ "$(resolved_origin_hash "$tuist_directory/Package.registry.resolved")" = "$expected_hash" ] \
        && [ "$(state_value format)" = "$lock_state_format" ] \
        && [ "$(state_value tuist)" = "$expected_tuist_version" ] \
        && [ "$(state_value manifest_sha256)" = "$expected_hash" ] \
        && [ "$(state_value registry_config_sha256)" = "$(file_hash "$registry_configuration")" ] \
        && [ "$(state_value scm_lock_sha256)" = "$(file_hash "$tuist_directory/Package.resolved")" ] \
        && [ "$(state_value registry_lock_sha256)" = "$(file_hash "$tuist_directory/Package.registry.resolved")" ]
}

if [ ! -f "$registry_configuration" ]; then
    echo "[ERROR] Registry configuration is missing at $registry_configuration." >&2
    exit 1
fi

if [ "$mode" = "status" ] || [ "$mode" = "verify" ]; then
    if ! acquire_package_resolved_lock; then
        echo "[ERROR] Timed out waiting to inspect Tuist package locks. Retry later." >&2
        exit 1
    fi

    if locks_are_current "$mode_argument"; then
        echo "=== Tuist package locks are current ==="
        exit 0
    fi

    if [ "$mode" = "status" ]; then
        echo "=== Tuist package locks need to be updated ==="
        exit 3
    fi

    echo "[ERROR] Tuist package locks are stale, incomplete, or were edited manually." >&2
    echo "[ERROR] Run 'make project' locally and commit all generated package lock files." >&2
    exit 1
fi

tuist_binary="$mode_argument"

temporary_directory=$(mktemp -d "${TMPDIR:-/tmp}/wrapkit-package-locks.XXXXXX")
publish_started=0
scm_existed=0
registry_existed=0
state_existed=0
scm_output=""
registry_output=""
state_output=""
scm_backup="$temporary_directory/original.Package.resolved"
registry_backup="$temporary_directory/original.Package.registry.resolved"
state_backup="$temporary_directory/original.Package.lock-state"

cleanup() {
    status=$?
    trap - EXIT HUP INT TERM
    if [ "$status" -ne 0 ] && [ "$publish_started" -eq 1 ]; then
        if [ "$scm_existed" -eq 1 ]; then
            cp "$scm_backup" "$tuist_directory/Package.resolved" || \
                echo "[ERROR] Could not restore Tuist/Package.resolved." >&2
        else
            rm -f "$tuist_directory/Package.resolved" || true
        fi
        if [ "$registry_existed" -eq 1 ]; then
            cp "$registry_backup" "$tuist_directory/Package.registry.resolved" || \
                echo "[ERROR] Could not restore Tuist/Package.registry.resolved." >&2
        else
            rm -f "$tuist_directory/Package.registry.resolved" || true
        fi
        if [ "$state_existed" -eq 1 ]; then
            cp "$state_backup" "$lock_state" || \
                echo "[ERROR] Could not restore Tuist/Package.lock-state." >&2
        else
            rm -f "$lock_state" || true
        fi
    fi
    [ -z "$scm_output" ] || rm -f "$scm_output" || true
    [ -z "$registry_output" ] || rm -f "$registry_output" || true
    [ -z "$state_output" ] || rm -f "$state_output" || true
    rm -rf "$temporary_directory" || true
    exit "$status"
}

trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

if ! "$tuist_binary" version >/dev/null 2>&1; then
    echo "[ERROR] Tuist is not executable at $tuist_binary." >&2
    exit 1
fi

tuist_version=$("$tuist_binary" version 2>/dev/null | awk 'NR == 1 { print $1 }')
if [ -z "$tuist_version" ]; then
    echo "[ERROR] Could not determine the Tuist version at $tuist_binary." >&2
    exit 1
fi

source_manifest_hash=$(manifest_hash)
source_registry_config_hash=$(file_hash "$registry_configuration")
locks_were_current=0
if locks_are_current "$tuist_version"; then
    locks_were_current=1
fi

prepare_project() {
    destination="$1"
    mkdir -p "$destination/Tuist/.swiftpm/configuration"
    cp "$tuist_directory/Package.swift" "$destination/Tuist/Package.swift"
    cp "$registry_configuration" "$destination/Tuist/.swiftpm/configuration/registries.json"
}

scm_project="$temporary_directory/scm"
registry_project="$temporary_directory/registry"
prepare_project "$scm_project"
prepare_project "$registry_project"

echo "=== Resolving Git Package.resolved ==="
"$tuist_binary" install \
    --path "$scm_project" \
    --disable-scm-to-registry-transformation

echo "=== Resolving Registry-first Package.resolved ==="
"$tuist_binary" install \
    --path "$registry_project" \
    --replace-scm-with-registry

scm_candidate="$scm_project/Tuist/Package.resolved"
registry_candidate="$registry_project/Tuist/Package.resolved"

if [ ! -s "$scm_candidate" ] || [ ! -s "$registry_candidate" ]; then
    echo "[ERROR] Tuist did not generate both Package.resolved files." >&2
    exit 1
fi

registry_pin_count=$(grep -c '"kind"[[:space:]]*:[[:space:]]*"registry"' "$registry_candidate" 2>/dev/null || true)
resolved_pin_count=$(grep -c '"kind"[[:space:]]*:' "$registry_candidate" 2>/dev/null || true)
if [ "$resolved_pin_count" -gt 0 ] && [ "$registry_pin_count" -eq 0 ]; then
    echo "[ERROR] Registry-first resolution used only Git. Registry may be unavailable; old locks were preserved." >&2
    exit 1
fi

expected_hash=$(manifest_hash)
if [ "$(resolved_origin_hash "$scm_candidate")" != "$expected_hash" ] \
    || [ "$(resolved_origin_hash "$registry_candidate")" != "$expected_hash" ]; then
    echo "[ERROR] Generated Package.resolved files do not match Tuist/Package.swift." >&2
    exit 1
fi

# Network resolution happens in parallel, but only one process may validate and
# publish the shared lock files. The descriptor lock is released automatically
# on normal exit, signals, and crashes.
if ! acquire_package_resolved_lock; then
    echo "[ERROR] Timed out waiting to publish Tuist package locks. Retry later." >&2
    exit 1
fi

if [ "$(manifest_hash)" != "$source_manifest_hash" ] \
    || [ "$(file_hash "$registry_configuration")" != "$source_registry_config_hash" ]; then
    echo "[ERROR] Tuist package configuration changed while dependencies were resolving. Run 'make project' again." >&2
    exit 1
fi

if [ "$locks_were_current" -eq 0 ] && locks_are_current "$tuist_version"; then
    echo "=== Tuist package locks were updated by another process ==="
    exit 0
fi

if [ -f "$tuist_directory/Package.resolved" ]; then
    cp "$tuist_directory/Package.resolved" "$scm_backup"
    scm_existed=1
fi
if [ -f "$tuist_directory/Package.registry.resolved" ]; then
    cp "$tuist_directory/Package.registry.resolved" "$registry_backup"
    registry_existed=1
fi
if [ -f "$lock_state" ]; then
    cp "$lock_state" "$state_backup"
    state_existed=1
fi

scm_output=$(mktemp "$tuist_directory/.Package.resolved.XXXXXX")
registry_output=$(mktemp "$tuist_directory/.Package.registry.resolved.XXXXXX")
state_output=$(mktemp "$tuist_directory/.Package.lock-state.XXXXXX")

if ! cp "$scm_candidate" "$scm_output" || ! cp "$registry_candidate" "$registry_output"; then
    rm -f "$scm_output" "$registry_output" "$state_output"
    echo "[ERROR] Could not prepare resolved files for publishing." >&2
    exit 1
fi

printf '%s\n' \
    "format=$lock_state_format" \
    "tuist=$tuist_version" \
    "manifest_sha256=$(manifest_hash)" \
    "registry_config_sha256=$(file_hash "$registry_configuration")" \
    "scm_lock_sha256=$(file_hash "$scm_output")" \
    "registry_lock_sha256=$(file_hash "$registry_output")" \
    > "$state_output"

publish_started=1

if ! mv "$scm_output" "$tuist_directory/Package.resolved"; then
    rm -f "$scm_output" "$registry_output"
    echo "[ERROR] Could not update Tuist/Package.resolved." >&2
    exit 1
fi

if ! mv "$registry_output" "$tuist_directory/Package.registry.resolved"; then
    rm -f "$registry_output"
    echo "[ERROR] Could not update Tuist/Package.registry.resolved." >&2
    exit 1
fi

if ! mv "$state_output" "$lock_state"; then
    rm -f "$state_output"
    echo "[ERROR] Could not update Tuist/Package.lock-state." >&2
    exit 1
fi

publish_started=0

# Force the next install to rebuild transport-specific state for the new locks.
rm -f \
    "$tuist_directory/.build/.wrapkit-install-mode" \
    "$tuist_directory/.build/.wrapkit-tuist-version" \
    "$tuist_directory/.build/.wrapkit-lock-sha256"

echo "=== Updated Tuist/Package.resolved and Tuist/Package.registry.resolved ==="

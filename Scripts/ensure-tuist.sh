#!/bin/sh

set -eu

auto_confirm=0
if [ "${1:-}" = "--yes" ]; then
    auto_confirm=1
    shift
fi

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 [--yes] <version> <sha256> <install-directory>" >&2
    exit 2
fi

version="$1"
expected_sha256="$2"
install_directory="$3"
checksum_marker="$install_directory/.archive-sha256"

installed_version() {
    "$1" version 2>/dev/null | awk 'NR == 1 { print $1 }'
}

is_valid_distribution() {
    directory="$1"
    [ -x "$directory/tuist" ] \
        && [ -d "$directory/ProjectDescription.framework" ] \
        && [ "$(installed_version "$directory/tuist")" = "$version" ]
}

is_valid_cache() {
    [ -f "$checksum_marker" ] \
        && [ "$(cat "$checksum_marker")" = "$expected_sha256" ] \
        && is_valid_distribution "$install_directory"
}

if is_valid_cache; then
    echo "=== Using cached Tuist $version ==="
    exit 0
fi

if [ "$auto_confirm" -ne 1 ]; then
    if [ -n "${CI:-}" ]; then
        echo "[ERROR] Tuist is not installed in this CI environment." >&2
        exit 1
    fi

    if [ ! -t 0 ]; then
        echo "[ERROR] Tuist is not installed. Run 'make tuist-download' or install it with Homebrew/mise." >&2
        exit 1
    fi

    printf "Tuist is not installed. Download verified Tuist %s to %s? [y/N] " \
        "$version" \
        "$install_directory" >&2
    answer=""
    IFS= read -r answer || true

    case "$answer" in
        y|Y|yes|YES|Yes)
            ;;
        *)
            echo "Tuist installation cancelled."
            exit 1
            ;;
    esac
fi

for command_name in curl shasum unzip mktemp; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "[ERROR] Required command '$command_name' was not found." >&2
        exit 1
    fi
done

umask 077
parent_directory=$(dirname "$install_directory")
lock_directory="${install_directory}.lock"
lock_owner_file="$lock_directory/owner.pid"
temporary_directory=""
invalid_cache_directory=""

mkdir -p "$parent_directory"

acquire_lock() {
    if ! mkdir "$lock_directory" 2>/dev/null; then
        return 1
    fi
    if ! printf '%s\n' "$$" > "$lock_owner_file"; then
        rm -f "$lock_owner_file" || true
        rmdir "$lock_directory" 2>/dev/null || true
        return 1
    fi
    return 0
}

reclaim_stale_lock() {
    attempt_number="$1"
    owner_pid=$(cat "$lock_owner_file" 2>/dev/null || true)

    case "$owner_pid" in
        ''|*[!0-9]*)
            # Give a just-created lock time to publish its owner before reclaiming it.
            [ "$attempt_number" -ge 5 ] || return 1
            ;;
        *)
            kill -0 "$owner_pid" 2>/dev/null && return 1
            ;;
    esac

    stale_lock_directory="${lock_directory}.stale.$$"
    if mv "$lock_directory" "$stale_lock_directory" 2>/dev/null; then
        rm -rf "$stale_lock_directory" || true
        return 0
    fi
    return 1
}

lock_acquired=0
if acquire_lock; then
    lock_acquired=1
else
    echo "=== Waiting for another Tuist $version download ==="
    attempt=0
    while [ "$attempt" -lt 180 ]; do
        if is_valid_cache; then
            echo "=== Using cached Tuist $version ==="
            exit 0
        fi
        if acquire_lock; then
            lock_acquired=1
            break
        fi
        if reclaim_stale_lock "$attempt" && acquire_lock; then
            lock_acquired=1
            break
        fi
        sleep 1
        attempt=$((attempt + 1))
    done

    if [ "$lock_acquired" -ne 1 ]; then
        echo "[ERROR] Another Tuist $version download is still running. Retry later." >&2
        exit 1
    fi
fi

cleanup() {
    if [ -n "$temporary_directory" ] && [ -d "$temporary_directory" ]; then
        rm -rf "$temporary_directory" || true
    fi
    if [ -n "$invalid_cache_directory" ] && [ -e "$invalid_cache_directory" ]; then
        rm -rf "$invalid_cache_directory" || true
    fi
    if [ "$(cat "$lock_owner_file" 2>/dev/null || true)" = "$$" ]; then
        rm -f "$lock_owner_file" || true
        rmdir "$lock_directory" 2>/dev/null || true
    fi
}

trap cleanup 0
trap 'exit 1' 1 2 15

if is_valid_cache; then
    echo "=== Using cached Tuist $version ==="
    exit 0
fi

if [ -e "$install_directory" ]; then
    invalid_cache_directory="${install_directory}.invalid.$$"
    if ! mv "$install_directory" "$invalid_cache_directory"; then
        echo "[ERROR] Cached Tuist at $install_directory is incomplete and could not be replaced." >&2
        exit 1
    fi
    echo "=== Replacing incomplete Tuist cache at $install_directory ==="
fi

temporary_directory=$(mktemp -d "$parent_directory/.tuist-$version.XXXXXX")
archive="$temporary_directory/tuist.zip"
unpacked_directory="$temporary_directory/unpacked"

echo "=== Downloading Tuist $version to the project cache ==="
curl -fsSL --retry 2 \
    "https://github.com/tuist/tuist/releases/download/$version/tuist.zip" \
    -o "$archive"

printf "%s  %s\n" "$expected_sha256" "$archive" | shasum -a 256 -c -

mkdir -p "$unpacked_directory"
unzip -q "$archive" -d "$unpacked_directory"
chmod +x "$unpacked_directory/tuist"

if ! is_valid_distribution "$unpacked_directory"; then
    echo "[ERROR] Downloaded Tuist archive is incomplete or has the wrong version." >&2
    exit 1
fi

printf "%s\n" "$expected_sha256" > "$unpacked_directory/.archive-sha256"
mv "$unpacked_directory" "$install_directory"

if ! is_valid_cache; then
    echo "[ERROR] Cached Tuist validation failed." >&2
    exit 1
fi

echo "=== Installed Tuist $version in $install_directory ==="

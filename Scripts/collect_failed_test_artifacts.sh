#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

XCRESULT_PATH="${1:-}"
OUTPUT_BASE="${2:-$REPO_ROOT/TestArtifacts/failed-tests}"

if ! command -v python3 >/dev/null 2>&1; then
    echo "error: python3 is required" >&2
    exit 1
fi

if ! command -v xcrun >/dev/null 2>&1; then
    echo "error: xcrun is required" >&2
    exit 1
fi

find_latest_xcresult() {
    find "$HOME/Library/Developer/Xcode/DerivedData" -type d -name '*.xcresult' -print0 2>/dev/null |
        xargs -0 ls -td 2>/dev/null |
        head -n 1
}

if [ -z "$XCRESULT_PATH" ]; then
    XCRESULT_PATH="$(find_latest_xcresult)"
fi

if [ -z "$XCRESULT_PATH" ]; then
    echo "error: failed to find .xcresult in DerivedData" >&2
    exit 1
fi

if [ ! -d "$XCRESULT_PATH" ]; then
    echo "error: xcresult does not exist: $XCRESULT_PATH" >&2
    exit 1
fi

BRANCH_NAME="$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || echo detached)"
SHORT_SHA="$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
DIRTY_STATE="$(git -C "$REPO_ROOT" status --short 2>/dev/null || true)"
RUN_TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
SAFE_BRANCH_NAME="$(printf "%s" "$BRANCH_NAME" | tr '/: ' '___')"
RUN_DIR="$OUTPUT_BASE/${RUN_TIMESTAMP}_${SAFE_BRANCH_NAME}_${SHORT_SHA}"
LATEST_LINK="$OUTPUT_BASE/latest"
LATEST_IMAGES_LINK="$OUTPUT_BASE/latest-images"
TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT

mkdir -p "$RUN_DIR"

xcrun xcresulttool get test-results tests --path "$XCRESULT_PATH" --compact > "$TMP_JSON"

python3 - "$TMP_JSON" "$RUN_DIR" "$XCRESULT_PATH" "$BRANCH_NAME" "$SHORT_SHA" <<'PY'
import json
import os
import re
import shutil
import sys
from pathlib import Path
from urllib.parse import urlparse, unquote

json_path, run_dir, xcresult_path, branch_name, short_sha = sys.argv[1:6]
run_dir_path = Path(run_dir)
images_dir_path = run_dir_path / "images"
meta_dir_path = run_dir_path / "meta"
images_dir_path.mkdir(parents=True, exist_ok=True)
meta_dir_path.mkdir(parents=True, exist_ok=True)

with open(json_path, "r", encoding="utf-8") as file:
    root = json.load(file)

records = []


def sanitize(value: str) -> str:
    value = re.sub(r"[^A-Za-z0-9._-]+", "_", value.strip())
    return value.strip("_") or "unnamed"


def extract_failure_records(node, suite=None, test=None):
    if isinstance(node, dict):
        node_type = node.get("nodeType")
        name = node.get("name")
        result = node.get("result")

        if node_type == "Test Suite" and name:
            suite = name

        if node_type == "Test Case" and name:
            test = name

        if node_type == "Test Case" and result == "Failed":
            messages = []

            def collect_messages(candidate):
                if isinstance(candidate, dict):
                    if candidate.get("nodeType") == "Failure Message":
                        message = candidate.get("name")
                        if message:
                            messages.append(message)
                    for nested in candidate.values():
                        collect_messages(nested)
                elif isinstance(candidate, list):
                    for nested in candidate:
                        collect_messages(nested)

            collect_messages(node)

            if messages:
                for message in messages:
                    records.append({
                        "suite": suite or "UnknownSuite",
                        "test": test or "unknownTest",
                        "message": message,
                    })
            else:
                records.append({
                    "suite": suite or "UnknownSuite",
                    "test": test or "unknownTest",
                    "message": "No failure message found in xcresult.",
                })
            return

        for child in node.values():
            extract_failure_records(child, suite, test)
    elif isinstance(node, list):
        for child in node:
            extract_failure_records(child, suite, test)


extract_failure_records(root)

metadata_lines = [
    f"xcresult: {xcresult_path}",
    f"branch: {branch_name}",
    f"commit: {short_sha}",
    f"failed_records: {len(records)}",
]

(meta_dir_path / "run-info.txt").write_text("\n".join(metadata_lines) + "\n", encoding="utf-8")

index_lines = [
    "# Failed Tests",
    "",
    f"- xcresult: `{xcresult_path}`",
    f"- branch: `{branch_name}`",
    f"- commit: `{short_sha}`",
    f"- failed records: `{len(records)}`",
    "",
]

diff_url_pattern = re.compile(r"Diff snapshot URL:\s*(\S+)")

for position, record in enumerate(records, start=1):
    suite = record["suite"]
    test = record["test"]
    message = record["message"]

    diff_match = diff_url_pattern.search(message)
    artifact_variant = "no_artifacts"
    source_dir = None

    if diff_match:
        parsed_url = urlparse(diff_match.group(1))
        source_dir = Path(unquote(parsed_url.path))
        artifact_variant = source_dir.name or "snapshot_artifacts"

    item_name = f"{position:03d}_{sanitize(suite)}__{sanitize(test)}__{sanitize(artifact_variant)}"
    destination_dir = meta_dir_path / item_name
    destination_dir.mkdir(parents=True, exist_ok=True)

    failure_text = "\n".join([
        f"suite: {suite}",
        f"test: {test}",
        "",
        message,
        "",
        f"artifacts: {source_dir if source_dir else 'none'}",
    ])
    (destination_dir / "failure.txt").write_text(failure_text + "\n", encoding="utf-8")

    copied_files = []
    if source_dir and source_dir.is_dir():
        for order, file_name in (("01", "origin.png"), ("02", "new.png"), ("03", "diff.png")):
            source_file = source_dir / file_name
            if source_file.exists():
                flat_file_name = f"{item_name}__{order}_{file_name}"
                shutil.copy2(source_file, images_dir_path / flat_file_name)
                copied_files.append(file_name)

    index_lines.append(f"## {position:03d}. {suite} :: {test}")
    index_lines.append("")
    index_lines.append(f"- entry: `{item_name}`")
    index_lines.append(f"- artifacts: `{', '.join(copied_files) if copied_files else 'none'}`")
    if source_dir:
        index_lines.append(f"- source: `{source_dir}`")
    index_lines.append("")

(meta_dir_path / "README.md").write_text("\n".join(index_lines) + "\n", encoding="utf-8")
PY

rm -f "$LATEST_LINK"
ln -s "$RUN_DIR" "$LATEST_LINK"
rm -f "$LATEST_IMAGES_LINK"
ln -s "$RUN_DIR/images" "$LATEST_IMAGES_LINK"

{
    echo "dirty:"
    if [ -n "$DIRTY_STATE" ]; then
        printf "%s\n" "$DIRTY_STATE"
    else
        echo "clean"
    fi
} >> "$RUN_DIR/meta/run-info.txt"

echo "Collected failed test artifacts:"
echo "$RUN_DIR"
echo
echo "Latest run:"
echo "$LATEST_LINK"
echo
echo "Latest images:"
echo "$LATEST_IMAGES_LINK"

if [ "${OPEN_IN_FINDER:-0}" = "1" ]; then
    open "$RUN_DIR/images"
fi

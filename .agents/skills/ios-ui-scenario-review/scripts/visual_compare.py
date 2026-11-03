#!/usr/bin/env python3

from __future__ import annotations

import argparse
import hashlib
import html
import json
import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Compare UI screenshot trees and build a review gallery.")
    parser.add_argument("--before", type=Path, required=True)
    parser.add_argument("--after", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--pixel-threshold", type=int, default=8)
    parser.add_argument("--changed-only", action="store_true")
    return parser.parse_args()


def image_paths(root: Path) -> dict[str, Path]:
    extensions = {".png", ".jpg", ".jpeg", ".webp"}
    return {
        str(path.relative_to(root)): path
        for path in root.rglob("*")
        if path.is_file() and path.suffix.lower() in extensions
    }


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def difference_hash(image: Image.Image) -> int:
    gray = image.convert("L").resize((9, 8), Image.Resampling.LANCZOS)
    pixels = np.asarray(gray, dtype=np.int16)
    bits = pixels[:, 1:] > pixels[:, :-1]
    value = 0
    for bit in bits.flatten():
        value = (value << 1) | int(bit)
    return value


def compare_pair(before_path: Path, after_path: Path, threshold: int) -> tuple[dict, Image.Image | None]:
    before = Image.open(before_path).convert("RGBA")
    after = Image.open(after_path).convert("RGBA")
    result = {
        "before_sha256": sha256(before_path),
        "after_sha256": sha256(after_path),
        "before_size": list(before.size),
        "after_size": list(after.size),
    }
    result["exact_match"] = result["before_sha256"] == result["after_sha256"]
    result["dimension_match"] = before.size == after.size
    hash_delta = difference_hash(before) ^ difference_hash(after)
    result["dhash_distance"] = bin(hash_delta).count("1")

    if before.size != after.size:
        return result, None

    before_rgb = np.asarray(before.convert("RGB"), dtype=np.int16)
    after_rgb = np.asarray(after.convert("RGB"), dtype=np.int16)
    delta = np.abs(before_rgb - after_rgb)
    changed_mask = np.max(delta, axis=2) > threshold
    result["changed_pixel_ratio"] = float(np.mean(changed_mask))
    result["mean_absolute_difference"] = float(np.mean(delta) / 255.0)
    result["root_mean_square_difference"] = float(math.sqrt(np.mean(delta.astype(np.float64) ** 2)) / 255.0)

    if np.any(changed_mask):
        ys, xs = np.where(changed_mask)
        result["difference_bounds"] = [int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())]
    else:
        result["difference_bounds"] = None

    diff = ImageChops.difference(before.convert("RGB"), after.convert("RGB"))
    diff = diff.point(lambda value: min(255, value * 4))
    return result, diff


def comparison_image(before_path: Path, after_path: Path, diff: Image.Image | None) -> Image.Image:
    before = Image.open(before_path).convert("RGB")
    after = Image.open(after_path).convert("RGB")
    panels = [before, after]
    labels = ["BEFORE", "AFTER"]
    if diff is not None:
        panels.append(diff.convert("RGB"))
        labels.append("DIFF x4")

    width = max(panel.width for panel in panels)
    height = max(panel.height for panel in panels)
    canvas = Image.new("RGB", (width * len(panels), height + 44), "white")
    draw = ImageDraw.Draw(canvas)
    for index, (panel, label) in enumerate(zip(panels, labels)):
        x = index * width + (width - panel.width) // 2
        canvas.paste(panel, (x, 44))
        draw.text((index * width + 12, 12), label, fill="black")
    return canvas


def write_html(entries: list[dict], output: Path) -> None:
    rows = []
    for entry in entries:
        metrics = entry.get("metrics", {})
        status = entry["status"]
        image = entry.get("comparison")
        image_tag = f'<a href="{html.escape(image)}"><img src="{html.escape(image)}"></a>' if image else ""
        rows.append(
            "<section>"
            f"<h2>{html.escape(entry['path'])}</h2>"
            f"<p><strong>{html.escape(status)}</strong> "
            f"changed={metrics.get('changed_pixel_ratio', 'n/a')} "
            f"MAE={metrics.get('mean_absolute_difference', 'n/a')} "
            f"dHash={metrics.get('dhash_distance', 'n/a')}</p>"
            f"{image_tag}</section>"
        )
    document = f"""<!doctype html>
<html><head><meta charset="utf-8"><title>UI visual review</title>
<style>body{{font:14px -apple-system;margin:24px;background:#f5f5f5}}section{{background:white;padding:16px;margin:0 0 20px;border-radius:8px}}img{{max-width:100%;border:1px solid #ddd}}h2{{font-size:16px;word-break:break-all}}</style>
</head><body><h1>UI visual review</h1>{''.join(rows)}</body></html>"""
    (output / "index.html").write_text(document, encoding="utf-8")


def main() -> None:
    args = parse_args()
    before_paths = image_paths(args.before)
    after_paths = image_paths(args.after)
    relative_paths = sorted(set(before_paths) | set(after_paths))
    comparisons_dir = args.output / "comparisons"
    comparisons_dir.mkdir(parents=True, exist_ok=True)
    entries = []

    for index, relative_path in enumerate(relative_paths):
        before_path = before_paths.get(relative_path)
        after_path = after_paths.get(relative_path)
        if before_path is None or after_path is None:
            status = "missing_before" if before_path is None else "missing_after"
            entries.append({"path": relative_path, "status": status})
            continue

        metrics, diff = compare_pair(before_path, after_path, args.pixel_threshold)
        status = "unchanged" if metrics["exact_match"] else "changed"
        if args.changed_only and status == "unchanged":
            continue
        comparison_name = f"{index:04d}.jpg"
        comparison_image(before_path, after_path, diff).save(comparisons_dir / comparison_name, quality=88)
        entries.append({
            "path": relative_path,
            "status": status,
            "metrics": metrics,
            "comparison": f"comparisons/{comparison_name}",
        })

    summary = {
        "before": str(args.before.resolve()),
        "after": str(args.after.resolve()),
        "total": len(relative_paths),
        "changed": sum(entry["status"] == "changed" for entry in entries),
        "unchanged": sum(entry["status"] == "unchanged" for entry in entries),
        "missing": sum(entry["status"].startswith("missing_") for entry in entries),
        "entries": entries,
    }
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "report.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    write_html(entries, args.output)
    print(json.dumps({key: summary[key] for key in ("total", "changed", "unchanged", "missing")}, indent=2))


if __name__ == "__main__":
    main()

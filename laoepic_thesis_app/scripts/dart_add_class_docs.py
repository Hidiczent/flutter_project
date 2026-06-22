#!/usr/bin/env python3
"""Add English /// class docs where missing (public classes only)."""

from __future__ import annotations

import re
import sys
from pathlib import Path

CLASS = re.compile(r"^(\s*)class\s+(_?)(\w+)")


def describe(name: str, path: str) -> str:
    p = path.lower()
    n = name
    if n.endswith("Page"):
        base = re.sub(r"Page$", "", n)
        words = re.sub(r"([a-z])([A-Z])", r"\1 \2", base).lower()
        return f"Flutter screen for {words or 'this flow'} in the Lao Epic app."
    if n.endswith("Provider"):
        words = re.sub(r"Provider$", "", n)
        words = re.sub(r"([a-z])([A-Z])", r"\1 \2", words).lower()
        return f"App-wide state for {words} (Provider / ChangeNotifier)."
    if n.endswith("Api"):
        words = re.sub(r"Api$", "", n)
        words = re.sub(r"([a-z])([A-Z])", r"\1 \2", words).lower()
        return f"REST client for {words} endpoints on the Lao Epic API."
    if n.endswith("Section"):
        words = re.sub(r"Section$", "", n)
        words = re.sub(r"([a-z])([A-Z])", r"\1 \2", words).lower()
        return f"Home page section that displays {words}."
    if n.endswith("Card"):
        words = re.sub(r"Card$", "", n)
        words = re.sub(r"([a-z])([A-Z])", r"\1 \2", words).lower()
        return f"Reusable card widget for {words}."
    if "/models/" in p:
        words = re.sub(r"([a-z])([A-Z])", r"\1 \2", n).lower()
        return f"Data model for {words} parsed from API JSON."
    if n == "AppConfig":
        return "Runtime configuration: API origin, Google OAuth IDs, and media URLs."
    if n == "AppTheme":
        return "Material theme tokens aligned with Lao Epic brand colors and fonts."
    if n == "UiI18n":
        return "Loads and serves UI translation strings from bundled JSON assets."
    words = re.sub(r"([a-z])([A-Z])", r"\1 \2", n).lower()
    return f"{words.capitalize()} widget or type for the Lao Epic mobile app."


def has_doc_above(lines: list[str], idx: int) -> bool:
    j = idx - 1
    while j >= 0 and lines[j].strip() == "":
        j -= 1
    if j < 0:
        return False
    t = lines[j].strip()
    return t.startswith("///") or t.endswith("*/") or t.startswith("/**")


def process(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    lines = text.split("\n")
    inserts: list[tuple[int, str]] = []
    rel = str(path)

    for i, line in enumerate(lines):
        m = CLASS.match(line)
        if not m:
            continue
        indent, underscore, name = m.group(1), m.group(2), m.group(3)
        if underscore or name.startswith("_"):
            continue
        if has_doc_above(lines, i):
            continue
        doc = describe(name, rel)
        inserts.append((i, f"{indent}/// {doc}"))

    for idx, doc in reversed(inserts):
        lines.insert(idx, doc)

    updated = "\n".join(lines)
    if updated != text:
        path.write_text(updated, encoding="utf-8")
        return True
    return False


def main() -> None:
    root = Path(sys.argv[1])
    n = 0
    for p in root.rglob("*.dart"):
        if process(p):
            n += 1
            print(p.relative_to(root))
    print(f"Updated {n} files")


if __name__ == "__main__":
    main()

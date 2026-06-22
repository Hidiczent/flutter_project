#!/usr/bin/env python3
"""Add concise English JSDoc to exported functions/components missing docs."""

from __future__ import annotations

import re
import sys
from pathlib import Path

EXPORT_FN = re.compile(
    r"^export (?:async )?function (\w+)",
)
EXPORT_CONST = re.compile(
    r"^export const (\w+) = ",
)
EXPORT_DEFAULT = re.compile(
    r"^export default function (\w+)",
)


def camel_words(name: str) -> str:
    s = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", name)
    return s.replace("_", " ").lower()


def describe(name: str, path: str) -> str:
    p = path.lower()
    words = camel_words(name)
    if name.startswith("use") and len(name) > 3:
        return f"React hook that {camel_words(name[3:])} for booking and checkout flows."
    if "Page" in name or p.endswith("page.tsx"):
        return f"Admin or customer page for {words.replace(' page', '')}."
    if "Provider" in name:
        return f"React context provider for {words.replace(' provider', '')}."
    if "Layout" in name:
        return f"Layout wrapper for {words.replace(' layout', '')} screens."
    if name.startswith("fetch") or name.startswith("load"):
        return f"Loads {words.replace('fetch ', '').replace('load ', '')} from the Lao Epic API."
    if name.startswith("create"):
        return f"Creates {words.replace('create ', '')} via the REST API."
    if "/services/" in p:
        return f"API client: {words}."
    if "/lib/" in p or "/features/" in p and "/lib/" in p:
        return f"Helper: {words}."
    if "Component" in name or name[0].isupper():
        return f"UI component for {words} in the Lao Epic platform."
    return f"{words.capitalize()}."


def has_doc(lines: list[str], idx: int) -> bool:
    j = idx - 1
    while j >= 0 and lines[j].strip() == "":
        j -= 1
    if j < 0:
        return False
    t = lines[j].strip()
    return t.endswith("*/") or t.startswith("/**")


def process(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    lines = text.split("\n")
    inserts: list[tuple[int, str]] = []
    rel = str(path)

    for i, line in enumerate(lines):
        m = EXPORT_FN.match(line) or EXPORT_DEFAULT.match(line)
        if not m:
            m2 = EXPORT_CONST.match(line)
            if m2 and ("=>" in line or "async" in line):
                name = m2.group(1)
            else:
                continue
        else:
            name = m.group(1)
        if has_doc(lines, i):
            continue
        doc = describe(name, rel)
        inserts.append((i, f"/**\n * {doc}\n */"))

    for idx, doc in reversed(inserts):
        lines.insert(idx, doc)

    updated = "\n".join(lines)
    if updated != text:
        path.write_text(updated, encoding="utf-8")
        return True
    return False


def main() -> None:
    n = 0
    for root in map(Path, sys.argv[1:]):
        for p in root.rglob("*"):
            if p.suffix not in (".ts", ".tsx"):
                continue
            if ".test." in p.name:
                continue
            if process(p):
                n += 1
    print(f"Updated {n} files")


if __name__ == "__main__":
    main()

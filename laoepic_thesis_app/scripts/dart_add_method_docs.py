#!/usr/bin/env python3
"""Add /// docs to public instance/static methods missing documentation."""

from __future__ import annotations

import re
import sys
from pathlib import Path

METHOD = re.compile(
    r"^(\s{2})(static\s+)?(Future<[^>]+>|void|bool|String|int|double|List<[^>]+>|Widget\??)\s+(\w+)\s*\("
)


def camel_words(name: str) -> str:
    s = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", name)
    return s.replace("_", " ").lower()


def describe(name: str) -> str:
    if name == "fromJson":
        return "Creates an instance from a JSON map returned by the API."
    if name == "toJson":
        return "Serializes this object to a JSON map for API requests."
    if name.startswith("fetch"):
        return f"Fetches {camel_words(name[5:])} from the Lao Epic API."
    if name.startswith("load"):
        return f"Loads {camel_words(name[4:])} and notifies listeners."
    if name.startswith("create"):
        return f"Creates {camel_words(name[6:])} via POST on the API."
    if name.startswith("set"):
        return f"Updates {camel_words(name[3:])} and persists when needed."
    if name == "build":
        return "Builds the widget subtree for the current context."
    return f"{camel_words(name).capitalize()} for this module."


def has_doc(lines: list[str], idx: int) -> bool:
    j = idx - 1
    while j >= 0 and lines[j].strip() == "":
        j -= 1
    return j >= 0 and lines[j].strip().startswith("///")


def process(path: Path) -> bool:
    if "/features/" in str(path) and "widgets" not in str(path):
        return False  # skip page build methods
    text = path.read_text(encoding="utf-8")
    lines = text.split("\n")
    inserts: list[tuple[int, str]] = []
    for i, line in enumerate(lines):
        m = METHOD.match(line)
        if not m:
            continue
        name = m.group(4)
        if name.startswith("_") or name in ("build", "dispose", "initState"):
            continue
        if has_doc(lines, i):
            continue
        indent = m.group(1)
        inserts.append((i, f"{indent}/// {describe(name)}"))

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
    for sub in ("data/services", "data/models", "providers", "core", "config"):
        d = root / sub
        if not d.exists():
            continue
        for p in d.rglob("*.dart"):
            if process(p):
                n += 1
                print(p.relative_to(root))
    print(f"Updated {n} files")


if __name__ == "__main__":
    main()

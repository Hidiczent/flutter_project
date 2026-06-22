#!/usr/bin/env python3
"""Remove doc comments mistakenly inserted inside function bodies."""

from __future__ import annotations

import re
import sys
from pathlib import Path

FOLLOW_BAD = re.compile(
    r"^\s+(return\b|if\b|for\b|while\b|switch\b|await\b|throw\b|break\b|continue\b|"
    r"const\b|final\b|var\b|\}|\{|\)|else\b|case\b|default\b|try\b|catch\b)",
)

DOC_LINE = re.compile(r"^(\s{4,})///")


def clean(content: str) -> str:
    lines = content.split("\n")
    out: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        m = DOC_LINE.match(line)
        if m and i + 1 < len(lines) and FOLLOW_BAD.match(lines[i + 1]):
            i += 1
            continue
        out.append(line)
        i += 1
    return "\n".join(out)


def main() -> None:
    roots = [Path(a) for a in sys.argv[1:]]
    for root in roots:
        for path in root.rglob("*.dart"):
            text = path.read_text(encoding="utf-8")
            updated = clean(text)
            if updated != text:
                path.write_text(updated, encoding="utf-8")
                print(f"cleaned {path}")


if __name__ == "__main__":
    main()

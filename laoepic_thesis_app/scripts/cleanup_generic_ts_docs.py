#!/usr/bin/env python3
"""Remove low-quality auto-generated JSDoc from TypeScript/TSX sources."""

from __future__ import annotations

import re
import sys
from pathlib import Path

GENERIC_PATTERNS = (
    "implements application logic for this module",
    "derived from the current context or input",
    "Friendly error — implements",
)

BLOCK = re.compile(r"/\*\*[\s\S]*?\*/", re.MULTILINE)


def is_generic(block: str) -> bool:
    return any(p in block for p in GENERIC_PATTERNS)


def clean(text: str) -> str:
    def repl(m: re.Match[str]) -> str:
        return "" if is_generic(m.group(0)) else m.group(0)

    text = BLOCK.sub(repl, text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text


def main() -> None:
    n = 0
    for root in map(Path, sys.argv[1:]):
        for p in root.rglob("*"):
            if p.suffix not in (".ts", ".tsx"):
                continue
            if ".test." in p.name or "__tests__" in str(p):
                continue
            text = p.read_text(encoding="utf-8")
            updated = clean(text)
            if updated != text:
                p.write_text(updated, encoding="utf-8")
                n += 1
                print(p)
    print(f"Cleaned {n} files")


if __name__ == "__main__":
    main()

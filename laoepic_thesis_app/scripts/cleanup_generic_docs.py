#!/usr/bin/env python3
"""Strip low-quality or misplaced /// doc lines from Dart sources."""

from __future__ import annotations

import re
import sys
from pathlib import Path

# Heuristic docs from bulk script — remove everywhere.
GENERIC = re.compile(
    r"^\s*/// (?:(?:Utility:|Creates a new state|Builds the \w+|"
    r"HTTP handler:|Business logic:|React hook that|"
    r"Returns \w+ derived from the current context|"
    r"Loads \w+ from the API or local cache|"
    r"Callback invoked when|Defines the \w+ type used))\b.*\n",
    re.MULTILINE,
)

# Doc immediately above @override (keep @override clean).
BEFORE_OVERRIDE = re.compile(r"^\s+///[^\n]*\n(\s+@override)", re.MULTILINE)

# Doc inside method bodies (4+ spaces) before a statement.
INSIDE_METHOD = re.compile(
    r"^\s{4,}///[^\n]*\n(?=\s{4,}(?:\w+\(|if\b|for\b|while\b|return\b|await\b|super\.|final\b|const\b|var\b|throw\b))",
    re.MULTILINE,
)


def clean(content: str) -> str:
    content = GENERIC.sub("", content)
    content = BEFORE_OVERRIDE.sub(r"\1", content)
    content = INSIDE_METHOD.sub("", content)
    # Collapse triple+ blank lines
    content = re.sub(r"\n{3,}", "\n\n", content)
    return content


def main() -> None:
    for root in sys.argv[1:]:
        for path in Path(root).rglob("*.dart"):
            text = path.read_text(encoding="utf-8")
            updated = clean(text)
            if updated != text:
                path.write_text(updated, encoding="utf-8")
                print(path)


if __name__ == "__main__":
    main()

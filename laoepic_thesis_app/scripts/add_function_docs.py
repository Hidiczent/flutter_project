#!/usr/bin/env python3
"""
Add English doc comments to functions/classes that lack documentation.
Supports Dart (///) and TypeScript/JavaScript (/** */).
Skips test files and lines that already have docs.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

SKIP_PARTS = (
    ".test.",
    ".spec.",
    "__tests__",
    "node_modules",
    ".dart_tool",
    "widget_test.dart",
    "/test/",
    "/tests/",
)

# Thai file-header pattern to strip
THAI_FILE_HEADER = re.compile(
    r"^///\s*ไฟล์:.*\n(?:///.*\n)*",
    re.MULTILINE,
)

TS_FUNCTION = re.compile(
    r"^(\s*)(?:export\s+)?(?:async\s+)?(?:function\s+(\w+)|const\s+(\w+)\s*=\s*(?:async\s*)?\(|(\w+)\s*=\s*(?:async\s*)?\([^)]*\)\s*=>)",
    re.MULTILINE,
)

TS_METHOD = re.compile(
    r"^(\s*)(?:public\s+|private\s+|protected\s+|async\s+)*(\w+)\s*\([^)]*\)\s*(?::\s*[^{]+)?\s*\{",
    re.MULTILINE,
)

TS_CLASS = re.compile(r"^(\s*)(?:export\s+)?(?:abstract\s+)?class\s+(\w+)", re.MULTILINE)

DART_TOP = re.compile(
    r"^(\s*)(?:@\w+(?:\([^)]*\))?\s*\n\s*)?"
    r"(?!(?:return|if|for|while|switch|throw|await|const|final|var)\b)"
    r"(?:static\s+)?(?:Future<[^>]+>|void|String|bool|int|double|Widget|List<[^>]+>|[\w<>?,\s]+?)\s+(\w+)\s*\(",
    re.MULTILINE,
)

DART_CLASS = re.compile(r"^(\s*)(?:abstract\s+)?class\s+(\w+)", re.MULTILINE)


def camel_to_words(name: str) -> str:
    s = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", name)
    s = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1 \2", s)
    return s.replace("_", " ").lower()


def describe(name: str, kind: str = "function", path: str = "") -> str:
    lower = name.lower()
    words = camel_to_words(name)
    path_hint = path.replace("\\", "/").lower()

    if kind == "class":
        if "provider" in lower:
            return f"Change-notifier (or state holder) for {words} in the Lao Epic app."
        if "page" in lower or path_hint.endswith("_page.dart"):
            return f"Flutter screen widget for {words.replace(' page', '')}."
        if "service" in lower or "/services/" in path_hint:
            return f"Service layer for {words.replace(' api', '')} API operations."
        if "controller" in lower:
            return f"HTTP request handler for {words.replace(' controller', '')} routes."
        return f"Defines the {words} type used in the application."

    if lower.startswith("get") and len(name) > 3:
        return f"Returns {camel_to_words(name[3:])} derived from the current context or input."
    if lower.startswith("set") and len(name) > 3:
        return f"Updates {camel_to_words(name[3:])} on the receiver or in persistent storage."
    if lower.startswith("fetch") or lower.startswith("load"):
        return f"Loads {words.replace('fetch ', '').replace('load ', '')} from the API or local cache."
    if lower.startswith("create"):
        return f"Creates a new {words.replace('create ', '')} record or resource."
    if lower.startswith("update"):
        return f"Updates an existing {words.replace('update ', '')} with the supplied payload."
    if lower.startswith("delete") or lower.startswith("remove"):
        return f"Removes the {words.replace('delete ', '').replace('remove ', '')} from storage or state."
    if lower.startswith("list") or lower.startswith("fetchall"):
        return f"Lists {words.replace('list ', '')} items, optionally filtered or paginated."
    if lower.startswith("validate"):
        return f"Validates {words.replace('validate ', '')} and returns whether the input is acceptable."
    if lower.startswith("normalize"):
        return f"Normalizes {words.replace('normalize ', '')} into a canonical form for downstream use."
    if lower.startswith("format"):
        return f"Formats {words.replace('format ', '')} for display in the UI."
    if lower.startswith("resolve"):
        return f"Resolves {words.replace('resolve ', '')} from partial inputs or API payloads."
    if lower.startswith("ensure"):
        return f"Ensures {words.replace('ensure ', '')} is initialized before use."
    if lower.startswith("handle"):
        return f"Handles {words.replace('handle ', '')} events or HTTP requests."
    if lower.startswith("build"):
        return f"Builds the {words.replace('build ', '')} widget subtree or response object."
    if lower.startswith("is") or lower.startswith("can") or lower.startswith("has"):
        return f"Returns whether {words} based on the provided state."
    if lower.startswith("on"):
        return f"Callback invoked when {words.replace('on ', '')} occurs."
    if "middleware" in path_hint:
        return f"Express middleware that {words} on each matching request."
    if "/controller" in path_hint:
        return f"HTTP handler: {words} — validates input, calls the service layer, and sends JSON."
    if "/service" in path_hint or ".service." in path_hint:
        return f"Business logic: {words} — reads/writes the database and applies domain rules."
    if "/hooks/" in path_hint or path_hint.startswith("use"):
        return f"React hook that {words} for components in this feature."
    if "/lib/" in path_hint or "/utils/" in path_hint or "/shared/" in path_hint:
        return f"Utility: {words} — shared helper used across the app."

    return f"{words.capitalize()} — implements application logic for this module."


def has_doc_above(lines: list[str], idx: int) -> bool:
    j = idx - 1
    while j >= 0 and lines[j].strip() == "":
        j -= 1
    if j < 0:
        return False
    line = lines[j].strip()
    if line.endswith("*/") or line.startswith("///") or line.startswith("*"):
        return True
    # walk up block comment
    while j >= 0:
        t = lines[j].strip()
        if t.startswith("/**") or t.startswith("///"):
            return True
        if t.startswith("@") or t.startswith("["):
            j -= 1
            continue
        break
    return False


def indent_doc(indent: str, text: str, dart: bool) -> str:
    if dart:
        return "\n".join(f"{indent}/// {line}".rstrip() for line in text.split("\n"))
    wrapped = text
    return f"{indent}/**\n{indent} * {wrapped}\n{indent} */"


def process_ts(content: str, path: str) -> str:
    content = THAI_FILE_HEADER.sub("", content)
    lines = content.split("\n")
    inserts: list[tuple[int, str]] = []

    for i, line in enumerate(lines):
        if has_doc_above(lines, i):
            continue
        m = TS_CLASS.match(line)
        if m and not line.strip().startswith("//"):
            indent, name = m.group(1), m.group(2)
            if name.startswith("_"):
                continue
            doc = indent_doc(indent, describe(name, "class", path), False)
            inserts.append((i, doc))
            continue
        m = TS_FUNCTION.match(line)
        if m:
            name = m.group(2) or m.group(3) or m.group(4)
            if not name or name.startswith("_"):
                continue
            indent = m.group(1)
            doc = indent_doc(indent, describe(name, "function", path), False)
            inserts.append((i, doc))

    for idx, doc in reversed(inserts):
        lines.insert(idx, doc)

    return "\n".join(lines)


def process_dart(content: str, path: str) -> str:
    content = THAI_FILE_HEADER.sub("", content)
    lines = content.split("\n")
    inserts: list[tuple[int, str]] = []

    for i, line in enumerate(lines):
        if has_doc_above(lines, i):
            continue
        stripped = line.strip()
        if stripped.startswith("import ") or stripped.startswith("part ") or stripped.startswith("//"):
            continue
        m = DART_CLASS.match(line)
        if m:
            indent, name = m.group(1), m.group(2)
            if name.startswith("_"):
                continue
            doc = indent_doc(indent, describe(name, "class", path), True)
            inserts.append((i, doc))
            continue
        m = DART_TOP.match(line)
        if m and " class " not in line and "typedef " not in line:
            name = m.group(2)
            if name.startswith("_") or name in ("if", "for", "while", "switch"):
                continue
            indent = m.group(1)
            doc = indent_doc(indent, describe(name, "function", path), True)
            inserts.append((i, doc))

    for idx, doc in reversed(inserts):
        lines.insert(idx, doc)

    return "\n".join(lines)


def should_skip(path: Path) -> bool:
    s = str(path)
    return any(p in s for p in SKIP_PARTS)


def process_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if path.suffix == ".dart":
        updated = process_dart(text, str(path))
    elif path.suffix in (".ts", ".tsx", ".js", ".jsx"):
        updated = process_ts(text, str(path))
    else:
        return False
    if updated != text:
        path.write_text(updated, encoding="utf-8")
        return True
    return False


def process_tree(root: Path) -> int:
    count = 0
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if should_skip(path):
            continue
        if path.suffix not in (".dart", ".ts", ".tsx", ".js", ".jsx"):
            continue
        if process_file(path):
            count += 1
            print(f"  documented {path.relative_to(root)}")
    return count


def main() -> None:
    roots = [Path(a) for a in sys.argv[1:]] if len(sys.argv) > 1 else []
    if not roots:
        print("Usage: add_function_docs.py <root> [<root> ...]")
        sys.exit(1)
    total = 0
    for root in roots:
        print(f"Processing {root}...")
        total += process_tree(root)
    print(f"Done. Updated {total} files.")


if __name__ == "__main__":
    main()

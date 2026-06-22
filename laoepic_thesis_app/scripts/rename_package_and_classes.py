#!/usr/bin/env python3
"""Rename Dart package + align public widget class names with file names."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# Whole-word class renames (order matters for overlapping names).
CLASS_RENAMES: list[tuple[str, str]] = [
    ("DetailBookingPacketPage", "PackageDetailPage"),
    ("BookingFormPage", "BookingPage"),
    ("_BookingFormPageState", "_BookingPageState"),
    ("MainPage", "MainShellPage"),
    ("PackagePage", "MainPackagePage"),
    ("_PackagePageState", "_MainPackagePageState"),
    ("PacketTab", "PackageTab"),
    ("PaymentPage", "BookingPaymentPage"),
    ("SignUp", "SignUpPage"),
    ("_SignUpState", "_SignUpPageState"),
    ("EditEmail", "EditEmailPage"),
    ("_EditEmailState", "_EditEmailPageState"),
]

OLD_PACKAGE = "package:flutter_project/"
NEW_PACKAGE = "package:laoepic_thesis_app/"


def rename_classes(text: str) -> str:
    for old, new in CLASS_RENAMES:
        text = re.sub(rf"\b{re.escape(old)}\b", new, text)
    return text


def process_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    updated = original.replace(OLD_PACKAGE, NEW_PACKAGE)
    updated = rename_classes(updated)
    if updated != original:
        path.write_text(updated, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = 0
    for pattern in ("lib/**/*.dart", "test/**/*.dart"):
        for path in ROOT.glob(pattern):
            if process_file(path):
                changed += 1
                print(f"updated {path.relative_to(ROOT)}")
    print(f"Done. {changed} files changed.")


if __name__ == "__main__":
    main()

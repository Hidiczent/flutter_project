#!/usr/bin/env python3
"""One-time lib/ restructure: move files and rewrite package imports."""

from __future__ import annotations

import os
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"

# old relative to lib/ -> new relative to lib/
MOVES: dict[str, str] = {
    "config.dart": "config/app_config.dart",
    "api/api_locale_prefs.dart": "core/api/api_locale_prefs.dart",
    "AuthCheckPage.dart": "app/auth_check_page.dart",
    "MainPage.dart": "app/main_shell_page.dart",
    "models/BookingHistoryModel.dart": "data/models/booking_history_model.dart",
    "models/package_model.dart": "data/models/package_model.dart",
    "models/package_village.dart": "data/models/package_village.dart",
    "models/package_list_filters.dart": "data/models/package_list_filters.dart",
    "models/NotificationModel.dart": "data/models/notification_model.dart",
    "models/invoice_pdf_data.dart": "data/models/invoice_pdf_data.dart",
    "services/auth_api.dart": "data/services/auth_api.dart",
    "services/catalog_api.dart": "data/services/catalog_api.dart",
    "services/exchange_rates_api.dart": "data/services/exchange_rates_api.dart",
    "services/invoice_pdf_builder.dart": "data/services/invoice_pdf_builder.dart",
    "services/packages_api.dart": "data/services/packages_api.dart",
    "services/pending_payment.dart": "data/services/pending_payment.dart",
    "services/phajay_payment_navigator.dart": "data/services/phajay_payment_navigator.dart",
    "services/phajay_payment_service.dart": "data/services/phajay_payment_service.dart",
    "services/reviews_api.dart": "data/services/reviews_api.dart",
    "services/wishlist_api.dart": "data/services/wishlist_api.dart",
    "provider/api_locale_provider.dart": "providers/api_locale_provider.dart",
    "provider/package_provider.dart": "providers/package_provider.dart",
    "provider/Package_Detail_Provider.dart": "providers/package_detail_provider.dart",
    "provider/price_display_provider.dart": "providers/price_display_provider.dart",
    "provider/favorite_provider.dart": "providers/favorite_provider.dart",
    "provider/Bottom_nav_provider.dart": "providers/bottom_nav_provider.dart",
    "utils/app_date_format.dart": "shared/utils/app_date_format.dart",
    "utils/money_format.dart": "shared/utils/money_format.dart",
    "utils/invoice_status.dart": "shared/utils/invoice_status.dart",
    "utils/payment_launch.dart": "shared/utils/payment_launch.dart",
    "utils/responsive_layout.dart": "shared/utils/responsive_layout.dart",
    "utils/booking_review_eligibility.dart": "shared/utils/booking_review_eligibility.dart",
    "utils/open_filtered_packages.dart": "shared/utils/open_filtered_packages.dart",
    "utils/package_display.dart": "shared/utils/package_display.dart",
    "utils/phajay_qr_image.dart": "shared/utils/phajay_qr_image.dart",
    "Auth/pages/logIN.dart": "features/auth/pages/login_page.dart",
    "Auth/pages/reset_passwor.dart": "features/auth/pages/reset_password_page.dart",
    "Auth/pages/VerifyOtpPage.dart": "features/auth/pages/verify_otp_page.dart",
    "Auth/pages/SignUp.dart": "features/auth/pages/sign_up_page.dart",
    "Auth/pages/ForgotPasswordPage.dart": "features/auth/pages/forgot_password_page.dart",
    "Auth/pages/start.dart": "features/auth/pages/intro_page.dart",
    "Auth/pages/account_page.dart": "features/auth/pages/account_page.dart",
    "Auth/pages/edit_username_page.dart": "features/auth/pages/edit_username_page.dart",
    "Auth/pages/edit_profile_page.dart": "features/auth/pages/edit_profile_page.dart",
    "Auth/pages/edit_email.dart": "features/auth/pages/edit_email_page.dart",
    "Auth/pages/change_password_page.dart": "features/auth/pages/change_password_page.dart",
    "Screens/HomePage/HomePage.dart": "features/home/pages/home_page.dart",
    "widgets/home_hero_section.dart": "features/home/widgets/home_hero_section.dart",
    "widgets/home_about_highlights_section.dart": "features/home/widgets/home_about_highlights_section.dart",
    "widgets/home_best_top_section.dart": "features/home/widgets/home_best_top_section.dart",
    "widgets/home_top_experiences_section.dart": "features/home/widgets/home_top_experiences_section.dart",
    "widgets/home_package_types_section.dart": "features/home/widgets/home_package_types_section.dart",
    "widgets/home_our_services_section.dart": "features/home/widgets/home_our_services_section.dart",
    "widgets/home_reviews_section.dart": "features/home/widgets/home_reviews_section.dart",
    "Screens/PackagePages/Main_PackagePage.dart": "features/package/pages/main_package_page.dart",
    "Screens/PackagePages/PacketTab.dart": "features/package/pages/package_tab.dart",
    "Screens/PackagePages/About_tab.dart": "features/package/pages/about_tab.dart",
    "Screens/PackagePages/package_activity_tab.dart": "features/package/pages/package_activity_tab.dart",
    "Screens/PackagePages/filtered_packages_page.dart": "features/package/pages/filtered_packages_page.dart",
    "Screens/BookingPages/detail_booking_packet_page.dart": "features/package/pages/package_detail_page.dart",
    "widget/Package_Card.dart": "features/package/widgets/package_card.dart",
    "widgets/package_reviews_section.dart": "features/package/widgets/package_reviews_section.dart",
    "Screens/BookingPages/booking.dart": "features/booking/pages/booking_page.dart",
    "Screens/BookingPages/tourbooking.dart": "features/booking/pages/tour_booking_page.dart",
    "Screens/BookingPages/booking_travelers.dart": "features/booking/pages/booking_travelers_page.dart",
    "Screens/BookingPages/Booking_Confirm.dart": "features/booking/pages/booking_confirm_page.dart",
    "Screens/BookingPages/payment.dart": "features/booking/pages/booking_payment_page.dart",
    "Screens/BookingPages/invoice_page.dart": "features/booking/pages/invoice_page.dart",
    "Screens/BookingPages/booking_detail_page.dart": "features/booking/pages/booking_detail_page.dart",
    "Screens/BookingPages/historybook.dart": "features/booking/pages/booking_history_page.dart",
    "widgets/cancel_booking_dialog.dart": "features/booking/widgets/cancel_booking_dialog.dart",
    "widgets/booking_terms_accept_tile.dart": "features/booking/widgets/booking_terms_accept_tile.dart",
    "widgets/booking_review_section.dart": "features/booking/widgets/booking_review_section.dart",
    "widgets/invoice_export_view.dart": "features/booking/widgets/invoice_export_view.dart",
    "widgets/leave_review_sheet.dart": "features/booking/widgets/leave_review_sheet.dart",
    "Screens/FavoritePages/Favorite.dart": "features/favorite/pages/favorite_page.dart",
    "Screens/payment/payment_return_page.dart": "features/payment/pages/payment_return_page.dart",
    "Screens/payment/phajay_qr_payment_page.dart": "features/payment/pages/phajay_qr_payment_page.dart",
    "Screens/info/contact_page.dart": "features/info/pages/contact_page.dart",
    "Screens/info/help_center_page.dart": "features/info/pages/help_center_page.dart",
    "Screens/info/about_page.dart": "features/info/pages/about_page.dart",
    "Screens/info/info_text_page.dart": "features/info/pages/info_text_page.dart",
    "Screens/Nofitications/notification_page.dart": "features/notifications/pages/notification_page.dart",
    "widgets/review_item_card.dart": "shared/widgets/review_item_card.dart",
    "widgets/currency_display_button.dart": "shared/widgets/currency_display_button.dart",
    "widgets/app_feedback.dart": "shared/widgets/app_feedback.dart",
}

DELETE_PATHS = [
    "core/utils/main.dart",
    "core/errors/main.dart",
    "core/usecases/main.dart",
    "models/state_widget.dart",
    "widget/HomePageWidget.dart",
    "Screens/BookingPages/historyhome.dart",
]

PACKAGE_PREFIX = "package:flutter_project/"


def normalize_key(path: str) -> str:
    return path.replace("\\", "/")


def build_import_map() -> list[tuple[str, str]]:
    pairs: list[tuple[str, str]] = []
    for old, new in MOVES.items():
        pairs.append((old, new))
        # common alias paths (case / legacy)
        if old.startswith("Screens/payment/"):
            alt = old.replace("Screens/payment/", "Screens/Payment/")
            pairs.append((alt, new))
        if old.startswith("Screens/info/"):
            alt = old.replace("Screens/info/", "Screens/Info/")
            pairs.append((alt, new))
        if "provider/" in old:
            base = old.split("/")[-1]
            pairs.append((f"provider/{base.lower()}", new))
    # extra legacy import paths seen in codebase
    pairs.extend([
        ("provider/bottom_nav_provider.dart", "providers/bottom_nav_provider.dart"),
        ("provider/Package_Detail_Provider.dart", "providers/package_detail_provider.dart"),
        ("Auth/pages/logIN.dart", "features/auth/pages/login_page.dart"),
        ("Screens/Payment/payment_return_page.dart", "features/payment/pages/payment_return_page.dart"),
        ("Screens/Payment/phajay_qr_payment_page.dart", "features/payment/pages/phajay_qr_payment_page.dart"),
        ("Screens/Info/help_center_page.dart", "features/info/pages/help_center_page.dart"),
        ("Screens/Info/contact_page.dart", "features/info/pages/contact_page.dart"),
        ("Screens/Info/about_page.dart", "features/info/pages/about_page.dart"),
        ("widget/Package_Card.dart", "features/package/widgets/package_card.dart"),
    ])
    # dedupe, longest first
    seen: set[str] = set()
    unique: list[tuple[str, str]] = []
    for old, new in sorted(pairs, key=lambda x: len(x[0]), reverse=True):
        if old not in seen:
            seen.add(old)
            unique.append((old, new))
    return unique


IMPORT_MAP = build_import_map()
IMPORT_RE = re.compile(
    r"(import\s+['\"])"
    r"(?:package:flutter_project/|\.\./|\./)?"
    r"([^'\"]+)"
    r"(['\"])"
)


def move_files() -> None:
    for old, new in MOVES.items():
        src = LIB / old
        dst = LIB / new
        if not src.exists():
            # case-insensitive fallback on macOS
            found = None
            for p in LIB.rglob(Path(old).name):
                rel = p.relative_to(LIB).as_posix()
                if rel.lower() == old.lower():
                    found = p
                    break
            if found is None:
                print(f"SKIP missing: {old}")
                continue
            src = found
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.exists():
            print(f"SKIP exists: {new}")
            continue
        shutil.move(str(src), str(dst))
        print(f"MOVED {old} -> {new}")


def delete_dead_files() -> None:
    for rel in DELETE_PATHS:
        p = LIB / rel
        if p.exists():
            p.unlink()
            print(f"DELETED {rel}")


def rewrite_imports_in_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    original = text

    def sub_import(match: re.Match[str]) -> str:
        prefix, imp, suffix = match.group(1), match.group(2), match.group(3)
        imp_norm = normalize_key(imp)

        if imp_norm.startswith("package:flutter_project/"):
            imp_norm = imp_norm[len("package:flutter_project/") :]

        # relative imports -> convert using file location (best effort: use map only)
        for old, new in IMPORT_MAP:
            if imp_norm == old or imp_norm.lower() == old.lower():
                return f"{prefix}{PACKAGE_PREFIX}{new}{suffix}"
            if imp_norm.endswith("/" + old) or imp_norm.endswith(old):
                if imp_norm == old or imp_norm.lower() == old.lower():
                    return f"{prefix}{PACKAGE_PREFIX}{new}{suffix}"

        # already package import with old path
        if imp_norm.startswith("models/") or imp_norm.startswith("services/"):
            for old, new in IMPORT_MAP:
                if imp_norm == old:
                    return f"{prefix}{PACKAGE_PREFIX}{new}{suffix}"

        if imp.startswith("package:flutter_project/"):
            sub = imp[len("package:flutter_project/") :]
            for old, new in IMPORT_MAP:
                if sub == old or sub.lower() == old.lower():
                    return f"{prefix}{PACKAGE_PREFIX}{new}{suffix}"

        # bare relative config.dart etc.
        if imp_norm in ("config.dart", "../config.dart", "../../config.dart",
                        "../../../config.dart", "../../../../config.dart"):
            return f"{prefix}{PACKAGE_PREFIX}config/app_config.dart{suffix}"
        if "provider/bottom_nav_provider" in imp_norm.replace("\\", "/"):
            return f"{prefix}{PACKAGE_PREFIX}providers/bottom_nav_provider.dart{suffix}"

        return match.group(0)

    text = IMPORT_RE.sub(sub_import, text)

    # second pass: direct string replace for package imports (longest first)
    for old, new in IMPORT_MAP:
        text = text.replace(f"{PACKAGE_PREFIX}{old}", f"{PACKAGE_PREFIX}{new}")
        text = text.replace(f"{PACKAGE_PREFIX}{old.lower()}", f"{PACKAGE_PREFIX}{new}")

    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def rewrite_all_imports() -> None:
    changed = 0
    for dart in LIB.rglob("*.dart"):
        if rewrite_imports_in_file(dart):
            changed += 1
            print(f"IMPORTS {dart.relative_to(LIB)}")
    print(f"Updated imports in {changed} files")


def cleanup_empty_dirs() -> None:
    for _ in range(5):
        removed = False
        for dirpath, dirnames, filenames in os.walk(LIB, topdown=False):
            if not dirnames and not filenames:
                Path(dirpath).rmdir()
                print(f"RMDIR {Path(dirpath).relative_to(LIB)}")
                removed = True
        if not removed:
            break


def main() -> None:
    move_files()
    delete_dead_files()
    rewrite_all_imports()
    cleanup_empty_dirs()
    print("Done.")


if __name__ == "__main__":
    main()

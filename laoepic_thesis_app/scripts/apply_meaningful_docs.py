#!/usr/bin/env python3
"""Insert meaningful English /// docs for public classes and top-level functions."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib"

TARGET_DIRS = [
    "features",
    "data/services",
    "providers",
    "app",
    "config",
    "core",
    "shared/widgets",
]

GENERIC = [
    "Utility:",
    "Flutter screen widget for",
    "Service layer for",
    "Change-notifier",
    "Business logic:",
    "shared helper",
    "Defines the",
    "implements application logic",
]

DOCS: dict[str, str] = {
    # auth pages
    "features/auth/pages/account_page.dart:AccountPage":
        "User profile hub with links to edit credentials, language, currency, and logout.",
    "features/auth/pages/change_password_page.dart:ChangePasswordPage":
        "Form screen where signed-in users update their password after verifying the current one.",
    "features/auth/pages/edit_email_page.dart:EditEmailPage":
        "Lets the traveler change the email address tied to their Lao Epic account.",
    "features/auth/pages/edit_profile_page.dart:EditProfilePage":
        "Profile editor for display name, avatar, and links to username or email changes.",
    "features/auth/pages/edit_username_page.dart:EditUsernamePage":
        "Collects a new username and submits it to the backend profile API.",
    "features/auth/pages/forgot_password_page.dart:ForgotPasswordPage":
        "Requests a password-reset OTP sent to the user's registered email.",
    "features/auth/pages/intro_page.dart:IntroPage":
        "Welcome splash shown after registration before entering the main app shell.",
    "features/auth/pages/login_page.dart:LoginPage":
        "Sign-in screen supporting email/password and Google OAuth for Lao Epic travelers.",
    "features/auth/pages/reset_password_page.dart:ResetPasswordPage":
        "Sets a new password after the user verifies their reset OTP.",
    "features/auth/pages/sign_up_page.dart:SignUpPage":
        "Registration form that creates a new traveler account and sends an OTP for verification.",
    "features/auth/pages/verify_otp_page.dart:VerifyOtpPage":
        "OTP entry screen used during sign-up, email change, or password reset flows.",
    # booking
    "features/booking/pages/booking_detail_page.dart:BookingDetailPage":
        "Full booking summary with status, passengers, payment info, and actions like cancel or review.",
    "features/booking/pages/booking_history_page.dart:BookingHistoryPage":
        "Lists the traveler's past and upcoming tour bookings with filters and quick navigation.",
    "features/booking/pages/booking_page.dart:BookingPage":
        "Multi-step booking wizard for choosing dates, travelers, and confirming a package reservation.",
    "features/booking/pages/booking_payment_page.dart:BookingPaymentPage":
        "Placeholder step in the booking flow where payment method selection will appear.",
    "features/booking/pages/booking_travelers_page.dart:BookingTravelersSection":
        "Reusable form section for collecting passenger names and birth dates during checkout.",
    "features/booking/pages/invoice_page.dart:InvoicePage":
        "Displays a booking invoice with download and share actions for the traveler.",
    "features/booking/widgets/cancel_booking_dialog.dart:humanizeCancelError":
        "Maps raw cancellation API errors to localized, user-friendly messages.",
    "features/booking/widgets/cancel_booking_dialog.dart:submitBookingCancel":
        "Calls the backend to cancel a booking and returns the parsed response payload.",
    "features/booking/widgets/cancel_booking_dialog.dart:showCancelBookingDialog":
        "Presents the cancellation policy and confirmation dialog for an active booking.",
    "features/booking/widgets/leave_review_sheet.dart:showLeaveReviewSheet":
        "Opens a bottom sheet so the traveler can rate and review a completed tour.",
    "features/booking/widgets/leave_review_sheet.dart:LeaveReviewSheet":
        "Bottom-sheet form for star rating and written feedback on a finished booking.",
    # favorite & home
    "features/favorite/pages/favorite_page.dart:FavoritePage":
        "Shows wishlisted tour packages the traveler saved for later booking.",
    "features/home/pages/home_page.dart:HomePage":
        "Main landing screen aggregating hero, featured packages, reviews, and quick actions.",
    "features/home/pages/home_page.dart:ActionItem":
        "Tappable shortcut tile used in the home page quick-action grid.",
    "features/home/widgets/home_about_highlights_section.dart:HomeAboutHighlightsSection":
        "Highlights Lao Epic's mission and key selling points on the home screen.",
    "features/home/widgets/home_best_top_section.dart:HomeBestTopSection":
        "Ranked list of top-rated tour packages fetched from the catalog API.",
    "features/home/widgets/home_hero_section.dart:HomeHeroSection":
        "Full-width hero banner with search and promotional messaging on the home page.",
    "features/home/widgets/home_our_services_section.dart:HomeOurServicesSection":
        "Grid of service categories explaining what Lao Epic offers to travelers.",
    "features/home/widgets/home_package_types_section.dart:HomePackageTypesSection":
        "Horizontal scroller of package type chips that deep-link into filtered package lists.",
    "features/home/widgets/home_reviews_section.dart:HomeReviewsSection":
        "Carousel of featured traveler reviews pulled from the reviews API.",
    "features/home/widgets/home_top_experiences_section.dart:HomeTopExperiencesSection":
        "Curated experience rows highlighting popular destinations and activities.",
    # info & notifications
    "features/info/pages/about_page.dart:AboutPage":
        "Static about screen describing Lao Epic's story, pillars, and tourism focus.",
    "features/info/pages/contact_page.dart:ContactPage":
        "Contact screen with support channels, office details, and social links.",
    "features/info/pages/help_center_page.dart:HelpCenterPage":
        "FAQ and self-service help topics for common booking and account questions.",
    "features/notifications/pages/notification_page.dart:NotificationPage":
        "Inbox of booking and account notifications with tap-through to related screens.",
    # package
    "features/package/pages/about_tab.dart:AboutTab":
        "Package detail tab showing itinerary highlights, inclusions, and village information.",
    "features/package/pages/about_tab.dart:BulletText":
        "Simple bullet-list row widget used inside package about content.",
    "features/package/pages/main_package_page.dart:MainPackagePage":
        "Browse-all-packages tab with search and scrollable package cards.",
    "features/package/pages/package_detail_page.dart:PackageDetailPage":
        "Detail host that loads a single tour package and renders tabbed content.",
    "features/package/pages/package_tab.dart:PackageTab":
        "Overview tab on a package detail page with gallery, pricing, and review preview.",
    "features/package/pages/package_tab.dart:ServiceIcon":
        "Circular icon tile representing an included service on a package overview.",
    "features/package/pages/package_tab.dart:InclusionItem":
        "Row showing a single included or excluded item with a check or cross icon.",
    "features/package/widgets/package_card.dart:PackageCard":
        "Compact card listing a tour package's image, title, price, and favorite toggle.",
    "features/package/widgets/package_reviews_section.dart:PackageReviewsSection":
        "Expandable reviews block on a package page with average rating and recent comments.",
    # payment
    "features/payment/pages/payment_return_page.dart:PaymentReturnPage":
        "Handles the return URL after PhaJay payment and polls until the invoice is settled.",
    # services
    "data/services/auth_api.dart:AuthSession":
        "JWT token and decoded user payload returned after a successful sign-in.",
    "data/services/auth_api.dart:AuthApi":
        "HTTP client for authentication endpoints such as Google OAuth login.",
    "data/services/catalog_api.dart:CatalogApi":
        "Fetches catalog metadata like provinces, villages, package types, and tour seasons.",
    "data/services/exchange_rates_api.dart:ExchangeRate":
        "Single currency conversion rate record from the backend exchange-rates API.",
    "data/services/exchange_rates_api.dart:ExchangeRatesApi":
        "Loads latest LAK/USD/THB exchange rates used for approximate price display.",
    "data/services/packages_api.dart:PackagesApi":
        "Queries the tour package list with optional search and filter parameters.",
    "data/services/pending_payment.dart:PendingPayment":
        "Persists in-flight payment context locally so return URLs can resume the right booking.",
    "data/services/reviews_api.dart:PackageReview":
        "Data model for a traveler review including rating, comment, and package reference.",
    "data/services/reviews_api.dart:ReviewsApi":
        "Creates and fetches package reviews, including featured reviews for the home page.",
    "data/services/wishlist_api.dart:WishlistApi":
        "Syncs favorite package IDs with the backend wishlist for signed-in users.",
    # providers
    "providers/bottom_nav_provider.dart:BottomNavProvider":
        "Tracks the selected index of the main bottom navigation bar.",
    "providers/favorite_provider.dart:FavoriteProvider":
        "Manages wishlisted package IDs for both guest local storage and logged-in API sync.",
    "providers/package_detail_provider.dart:PackageDetailProvider":
        "Loads and caches images and detail data for the currently viewed tour package.",
    "providers/package_provider.dart:PackageProvider":
        "Holds the searchable package catalog list and active filter state for browsing.",
    # core
    "core/api/api_locale_prefs.dart:readApiLocaleCode":
        "Reads the persisted API content locale code (en, th, or lo) from SharedPreferences.",
    "core/api/api_locale_prefs.dart:writeApiLocaleCode":
        "Persists the chosen API content locale so requests send the matching Accept-Language header.",
    "core/api/api_locale_prefs.dart:localeHeadersFromCode":
        "Builds the Accept-Language header map for a given locale code.",
    # shared widgets
    "shared/widgets/app_feedback.dart:showAppFeedback":
        "Shows a styled dialog for success, error, warning, or info feedback to the traveler.",
}


def has_good_doc(lines: list[str], idx: int) -> bool:
    j = idx - 1
    while j >= 0 and lines[j].strip() == "":
        j -= 1
    while j >= 0 and lines[j].strip().startswith("@"):
        j -= 1
    if j < 0:
        return False
    docs: list[str] = []
    k = j
    while k >= 0 and lines[k].strip().startswith("///"):
        docs.insert(0, lines[k].strip()[3:].strip())
        k -= 1
    if not docs:
        return False
    text = " ".join(docs)
    if re.search(r"[\u0E00-\u0E7F]", text):
        return False
    if any(g in text for g in GENERIC):
        return False
    return len(text) >= 20


def rel_key(path: Path, name: str) -> str:
    rel = str(path.relative_to(ROOT)).replace("\\", "/")
    return f"{rel}:{name}"


def insert_doc(lines: list[str], idx: int, text: str) -> None:
    lines.insert(idx, f"/// {text}")


def process_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    lines = text.split("\n")
    inserts: list[tuple[int, str]] = []

    for i, line in enumerate(lines):
        m = re.match(r"^(\s*)(?:abstract\s+)?(?:sealed\s+)?class\s+(\w+)", line)
        if m and not m.group(2).startswith("_"):
            name = m.group(2)
            if has_good_doc(lines, i):
                continue
            key = rel_key(path, name)
            doc = DOCS.get(key)
            if doc:
                inserts.append((i, doc))
            continue

        if line and not line[0].isspace():
            stripped = line.lstrip()
            if stripped.startswith(
                ("import ", "part ", "//", "class ", "enum ", "typedef ", "const ", "final ", "var ")
            ):
                continue
            fm = re.match(
                r"^(?:@\w+(?:\([^)]*\))?\s*)*(?:static\s+)?"
                r"(?:Future<[^>]+>|void|String|bool|int|double|Widget|List<[^>]+>|Map<[^>]+>|[A-Z]\w*(?:<[^>]+>)?)\s+(\w+)\s*\(",
                stripped,
            )
            if fm and not fm.group(1).startswith("_") and fm.group(1) != "main":
                name = fm.group(1)
                if has_good_doc(lines, i):
                    continue
                key = rel_key(path, name)
                doc = DOCS.get(key)
                if doc:
                    inserts.append((i, doc))

    if not inserts:
        return False

    for idx, doc in reversed(inserts):
        insert_doc(lines, idx, doc)

    path.write_text("\n".join(lines), encoding="utf-8")
    return True


def main() -> None:
    count = 0
    for td in TARGET_DIRS:
        base = ROOT / td
        if not base.exists():
            continue
        for path in sorted(base.rglob("*.dart")):
            if process_file(path):
                count += 1
                print(f"  documented {path.relative_to(ROOT)}")
    print(f"Done. Updated {count} files.")


if __name__ == "__main__":
    main()

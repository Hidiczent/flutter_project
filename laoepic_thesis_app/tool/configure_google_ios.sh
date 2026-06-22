#!/usr/bin/env bash
# Writes iOS Google Sign-In keys into Info.plist from .env (run once after adding GOOGLE_IOS_CLIENT_ID).
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  echo "Missing .env — copy from .env.example and set GOOGLE_IOS_CLIENT_ID."
  exit 1
fi

# shellcheck disable=SC1091
source .env

if [[ -z "${GOOGLE_IOS_CLIENT_ID:-}" ]]; then
  echo "GOOGLE_IOS_CLIENT_ID is empty in .env"
  exit 1
fi

if [[ ! "$GOOGLE_IOS_CLIENT_ID" == *.apps.googleusercontent.com ]]; then
  echo "GOOGLE_IOS_CLIENT_ID must end with .apps.googleusercontent.com"
  exit 1
fi

PREFIX="${GOOGLE_IOS_CLIENT_ID%.apps.googleusercontent.com}"
URL_SCHEME="com.googleusercontent.apps.${PREFIX}"
PLIST="ios/Runner/Info.plist"

/usr/libexec/PlistBuddy -c "Delete :GIDClientID" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :GIDClientID string ${GOOGLE_IOS_CLIENT_ID}" "$PLIST"

/usr/libexec/PlistBuddy -c "Delete :CFBundleURLTypes" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleTypeRole string Editor" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string ${URL_SCHEME}" "$PLIST"

echo "Updated ${PLIST}"
echo "  GIDClientID = (ios client)"
echo "  URL scheme  = ${URL_SCHEME}"
echo "Then: flutter clean && flutter run"

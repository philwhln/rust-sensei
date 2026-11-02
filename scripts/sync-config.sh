#!/bin/sh
# Write Config/Local.xcconfig from .env so Xcode signs with the local team.
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$root"

if [ ! -f .env ]; then
  echo "Copy .env.example to .env and fill it in." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
. ./.env
set +a

: "${DEVELOPMENT_TEAM:?Set DEVELOPMENT_TEAM in .env}"
: "${PRODUCT_BUNDLE_IDENTIFIER:?Set PRODUCT_BUNDLE_IDENTIFIER in .env}"

case "$DEVELOPMENT_TEAM" in
  *[!A-Za-z0-9]*)
    echo "DEVELOPMENT_TEAM must be a team id." >&2
    exit 1
    ;;
esac
case "$PRODUCT_BUNDLE_IDENTIFIER" in
  *[!A-Za-z0-9.-]*)
    echo "PRODUCT_BUNDLE_IDENTIFIER must be a bundle id." >&2
    exit 1
    ;;
esac

mkdir -p Config
umask 077
cat > Config/Local.xcconfig <<EOF
// Generated from .env by scripts/sync-config.sh. Gitignored.
DEVELOPMENT_TEAM = ${DEVELOPMENT_TEAM}
PRODUCT_BUNDLE_IDENTIFIER = ${PRODUCT_BUNDLE_IDENTIFIER}
EOF

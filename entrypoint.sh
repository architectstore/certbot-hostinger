#!/bin/sh
set -eu

: "${LE_ENV:=prod}"              # prod | staging
: "${PROPAGATION_SECONDS:=180}"

CREDS_FILE="/etc/letsencrypt/hostinger/credentials.ini"

if [ ! -f "$CREDS_FILE" ]; then
  echo "Missing credentials file at $CREDS_FILE"
  exit 1
fi

chmod 600 "$CREDS_FILE" 2>/dev/null || true

STAGING_FLAG=""
if [ "$LE_ENV" = "staging" ]; then
  STAGING_FLAG="--test-cert"
fi

CMD="${1:-issue}"

case "$CMD" in
  issue)
    : "${LE_EMAIL:?Set LE_EMAIL}"
    : "${LE_DOMAIN:?Set LE_DOMAIN}"

    exec certbot certonly \
      $STAGING_FLAG \
      --non-interactive \
      --agree-tos \
      -m "$LE_EMAIL" \
      --authenticator dns-hostinger \
      --dns-hostinger-credentials "$CREDS_FILE" \
      --dns-hostinger-propagation-seconds "$PROPAGATION_SECONDS" \
      -d "$LE_DOMAIN"
    ;;
  renew)
    exec certbot renew $STAGING_FLAG --non-interactive
    ;;
  *)
    echo "Usage: entrypoint.sh [issue|renew]"
    exit 2
    ;;
esac

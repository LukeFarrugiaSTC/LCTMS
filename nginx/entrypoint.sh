#!/bin/bash
set -e

CONFIG_FILE="/frontend/lib/config/api_config.dart"
DEFAULT_API_HOST="192.168.1.218"

if [ -f "$CONFIG_FILE" ]; then
  echo "Found API config file at $CONFIG_FILE"
  API_URL=$(grep "const String apiBaseUrl" "$CONFIG_FILE" | sed "s/.*'\(https:\/\/[^']*\)'.*/\1/")
  if [ -n "$API_URL" ]; then
    echo "Extracted API URL: $API_URL"
    API_HOST=$(echo "$API_URL" | sed -E 's|https://([^:/]+).*|\1|')
else
    echo "Unable to extract API URL. Falling back to default host."
    API_HOST="$DEFAULT_API_HOST"
  fi
else
  echo "API config file not found. Falling back to default host: $DEFAULT_API_HOST"
  API_HOST="$DEFAULT_API_HOST"
fi

echo "Using API host: $API_HOST"

CERT_DIR="/etc/nginx/ssl"
CRT_FILE="$CERT_DIR/selfsigned.crt"
KEY_FILE="$CERT_DIR/selfsigned.key"

# Force regeneration by removing existing certificate files (development only)
rm -f "$CRT_FILE" "$KEY_FILE"

echo "Generating self-signed certificate for $API_HOST..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CRT_FILE" \
  -subj "/CN=$API_HOST" \
  -addext "subjectAltName = IP:$API_HOST,DNS:localhost"
echo "Certificate generated."

FRONTEND_CERT_DIR="/frontend/assets/certs"
mkdir -p "$FRONTEND_CERT_DIR"
cp "$CRT_FILE" "$FRONTEND_CERT_DIR/selfsigned.crt"
echo "Certificate copied to Flutter assets."

exec "$@"
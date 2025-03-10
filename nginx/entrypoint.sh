#!/bin/bash
set -e

CERT_DIR="/etc/nginx/ssl"
CRT_FILE="$CERT_DIR/selfsigned.crt"
KEY_FILE="$CERT_DIR/selfsigned.key"

if [ ! -f "$CRT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
  echo "Generating self-signed certificate..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CRT_FILE" \
    -subj "/CN=localhost"
  echo "Certificate generated."
fi

# Execute the CMD
exec "$@"
#!/bin/bash
# update_api_config.sh

# Retrieve your current local IP address.
# For macOS (Wi-Fi interface is en0):
IP=$(ipconfig getifaddr en0)

# If IP is empty, exit with an error.
if [ -z "$IP" ]; then
  echo "Unable to retrieve IP address. Check your network connection."
  exit 1
fi

# Define the API base URL using your IP and the port that Nginx is serving HTTPS (443)
API_URL="https://$IP:443"

# Generate/update a Dart configuration file.
cat <<EOF > frontend/lib/config/api_config.dart
// GENERATED FILE - DO NOT MODIFY DIRECTLY
const String apiBaseUrl = '$API_URL';
EOF

echo "API configuration updated to: $API_URL"
#!/bin/bash
set -e

# Determine the OS and retrieve the local IP address.
if [[ "$OSTYPE" == "darwin"* ]]; then
  IP=$(ipconfig getifaddr en0)
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  IP=$(hostname -I | awk '{print $1}')
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  IP=$(ipconfig | grep 'IPv4 Address' | awk -F: '{print $2}' | tr -d ' ' | head -n1)
else
  echo "Unsupported OS type: $OSTYPE"
  exit 1
fi

# Exit if IP was not found.
if [ -z "$IP" ]; then
  echo "Unable to retrieve IP address. Check your network connection."
  exit 1
fi

# Define the API base URL using the retrieved IP and the HTTPS port.
API_URL="https://$IP:443"

# Ensure the config directory exists.
mkdir -p frontend/lib/config

# Generate/update the Dart configuration file.
cat <<EOF > frontend/lib/config/api_config.dart
// GENERATED FILE - DO NOT MODIFY DIRECTLY
const String apiBaseUrl = '$API_URL';
EOF

echo "API configuration updated to: $API_URL"
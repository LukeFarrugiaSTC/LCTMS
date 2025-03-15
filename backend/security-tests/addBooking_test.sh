#!/bin/bash
# Test the login and booking endpoints with optional proxy support.
# Usage examples:
#   ./addBooking_test.sh
#   ./addBooking_test.sh --use-proxy

set -euo pipefail

USE_PROXY=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --use-proxy)
            USE_PROXY=true
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
    shift
done

# Set proxy options if --use-proxy is provided.
if [ "$USE_PROXY" = true ]; then
    PROXY="-x http://localhost:8080 --proxy-insecure"
    echo "Using proxy: http://localhost:8080"
else
    PROXY=""
fi

# Define the login endpoint and payload.
LOGIN_URL="https://localhost:443/endpoints/user/login.php"
LOGIN_PAYLOAD='{"email": "test@example.com", "password": "Password12!"}'

echo "Logging in..."
LOGIN_RESPONSE=$(curl -ks $PROXY -X POST -H "Content-Type: application/json" -d "$LOGIN_PAYLOAD" "$LOGIN_URL")
echo "Login response: $LOGIN_RESPONSE"

# Extract the token using jq (ensure jq is installed)
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token')
echo "Extracted token: $TOKEN"

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo "No valid token found. Exiting..."
    exit 1
fi

# Source the .env file from two directories up for environment consistency.
if [ -f ./../../.env ]; then
    source ./../../.env
else
    echo ".env file not found at ./../../.env"
    exit 1
fi

if [ -z "${API_KEY:-}" ]; then
    echo "API_KEY is not set in the .env file."
    exit 1
fi

# Define the booking endpoint and payload.
BOOKING_URL="https://localhost:443/endpoints/bookings/addBooking.php"
BOOKING_PAYLOAD=$(cat <<EOF
{
    "api_key": "$API_KEY",
    "destinationName": "Mater Dei Hospital",
    "bookingDateTime": "2025-03-12 14:30:00"
}
EOF
)
# Remove newlines for curl compatibility.
BOOKING_PAYLOAD=$(echo "$BOOKING_PAYLOAD" | tr -d "\n")

echo "Calling addBooking endpoint with token..."
RESULT=$(curl -ks $PROXY -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$BOOKING_PAYLOAD" \
    "$BOOKING_URL")

echo "addBooking response: $RESULT"
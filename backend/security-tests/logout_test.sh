#!/bin/bash
# Updated test script for login and authenticated endpoint testing.
#
# This script logs in to obtain a token, then calls a protected endpoint (logout in this example)
# with the token in the Authorization header. A test type parameter lets you modify the token
# to simulate different scenarios. Use --rate-limit to send multiple concurrent requests.
#
# Usage examples:
#   ./logout_test.sh --test-type valid
#   ./logout_test.sh --test-type malformed
#   ./logout_test.sh --test-type missing-token
#   ./logout_test.sh --test-type injection
#   ./logout_test.sh --rate-limit --test-type valid
#   ./logout_test.sh --use-proxy --test-type valid

set -euo pipefail

RATE_LIMIT_TEST=false
TEST_TYPE="valid"
USE_PROXY=false

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --rate-limit)
            RATE_LIMIT_TEST=true
            ;;
        --test-type)
            shift
            TEST_TYPE="$1"
            ;;
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

# LOGIN
LOGIN_URL="https://localhost:443/endpoints/user/login.php"
LOGIN_PAYLOAD='{"email": "test@example.com", "password": "Password12!"}'

echo "Logging in..."
LOGIN_RESPONSE=$(curl -ks $PROXY -X POST -H "Content-Type: application/json" -d "$LOGIN_PAYLOAD" "$LOGIN_URL")
echo "Login response: $LOGIN_RESPONSE"

# Extract the token from JSON (requires jq to be installed)
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token')
echo "Extracted token: $TOKEN"

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo "No valid token found. Exiting..."
    exit 1
fi

# Adjust token based on the test type
case "$TEST_TYPE" in
    valid)
        # Use the token as is
        FINAL_TOKEN="$TOKEN"
        ;;
    malformed)
        # Remove the last character to simulate a malformed token
        FINAL_TOKEN="${TOKEN:0:-1}"
        ;;
    missing-token)
        # For missing-token, we'll clear the token so no header is sent
        FINAL_TOKEN=""
        ;;
    injection)
        # Use an injection payload in place of the token
        FINAL_TOKEN="' OR '1'='1"
        ;;
    *)
        echo "Unknown test type: $TEST_TYPE"
        exit 1
        ;;
esac

# Set the protected endpoint URL (logout endpoint in this example)
LOGOUT_URL="https://localhost:443/endpoints/user/logout.php"

# Function to send a single authenticated request
send_request() {
    if [ -z "$FINAL_TOKEN" ]; then
        # If FINAL_TOKEN is empty, do not send the Authorization header.
        RESPONSE=$(curl -ks $PROXY -X POST "$LOGOUT_URL")
    else
        RESPONSE=$(curl -ks $PROXY -X POST -H "Authorization: Bearer $FINAL_TOKEN" "$LOGOUT_URL")
    fi
    echo "Response: $RESPONSE"
}

if [ "$RATE_LIMIT_TEST" = true ]; then
    echo "Running rate limit test for authenticated endpoint with test type '$TEST_TYPE'..."
    for i in $(seq 1 70); do
        echo "Sending request $i"
        send_request &
    done
    wait
    echo "Rate limit test completed."
else
    echo "Sending a single test request to the authenticated endpoint with test type '$TEST_TYPE'..."
    send_request
fi
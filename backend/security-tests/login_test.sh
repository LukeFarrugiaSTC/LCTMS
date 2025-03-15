#!/bin/bash
# Updated test script for the login endpoint with additional test cases.
#
# Supported test types:
#   valid         - Sends the correct payload.
#   malformed     - Sends an intentionally broken JSON payload.
#   missing-email - Omits the email field.
#   injection     - Inserts an injection string into the email field.
#
# Usage examples:
#   ./login_test.sh --test-type valid
#   ./login_test.sh --test-type malformed
#   ./login_test.sh --test-type missing-email
#   ./login_test.sh --test-type injection
#   ./login_test.sh --rate-limit --test-type valid
#   ./login_test.sh --use-proxy --test-type valid

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

# Optionally source the .env file from two directories up (if available)
if [ -f ./../../.env ]; then
    source ./../../.env
else
    echo ".env file not found at ./../../.env"
fi

# Define the endpoint URL for login
URL="https://localhost:443/endpoints/user/login.php"

# Construct the base JSON payload for login (email and password)
PAYLOAD='{"email": "test@example.com", "password": "Password12!"}'

# Adjust the payload based on the test type
case "$TEST_TYPE" in
    valid)
        # Use the payload as is
        ;;
    malformed)
        # Remove the last character to break the JSON format
        PAYLOAD="${PAYLOAD:0:-1}"
        ;;
    missing-email)
        # Remove the "email" field from the payload
        PAYLOAD=$(echo "$PAYLOAD" | sed 's/"email": *"[^"]*",//')
        ;;
    injection)
        # Replace the email with an injection payload
        PAYLOAD=$(echo "$PAYLOAD" | sed 's/"email": *"[^"]*"/"email": "\047 OR \0471\047=\0471"/')
        ;;
    *)
        echo "Unknown test type: $TEST_TYPE"
        exit 1
        ;;
esac

# Set proxy options if --use-proxy is provided.
if [ "$USE_PROXY" = true ]; then
    PROXY="-x http://localhost:8080 --proxy-insecure"
    echo "Using proxy: http://localhost:8080"
else
    PROXY=""
fi

if [ "$RATE_LIMIT_TEST" = true ]; then
    echo "Running rate limit test for login endpoint with test type '$TEST_TYPE'..."
    for i in $(seq 1 70); do
        echo "Sending request $i"
        curl -ks $PROXY -X POST -d "$PAYLOAD" "$URL" &
    done
    wait
    echo "Rate limit test completed."
else
    echo "Sending a single test request to the login endpoint with test type '$TEST_TYPE'..."
    curl -ks $PROXY -X POST -d "$PAYLOAD" "$URL"
    echo
fi
#!/bin/bash
# Updated test script for the registration endpoint with additional test cases.
# Supports --rate-limit, --test-type, and --use-proxy flags.

set -euo pipefail

TEST_TYPE="valid"
RATE_LIMIT_TEST=false
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

# Source the .env file from two directories up for environment consistency
if [ -f ./../../.env ]; then
    source ./../../.env
else
    echo ".env file not found at ./../../.env"
    exit 1
fi

URL="https://localhost:443/endpoints/user/registration.php"

# Base payload for a valid registration request
PAYLOAD=$(cat <<EOF
{
    "email": "test@example.com",
    "fname": "John",
    "lname": "Doe",
    "houseNumber": "123",
    "streetName": "Triq Censu Vella",
    "townName": "L-Imsida",
    "mobile": "12345678",
    "dob": "1990-01-01",
    "password": "Password12!",
    "confirm": "Password12!"
}
EOF
)
# Remove newlines for curl compatibility
PAYLOAD=$(echo "$PAYLOAD" | tr -d "\n")

# Adjust payload based on the test type
case "$TEST_TYPE" in
    valid)
        # Use the payload as is
        ;;
    malformed)
        # Create malformed JSON by removing the last character
        PAYLOAD="${PAYLOAD:0:-1}"
        ;;
    missing-field)
        # Remove a required field (for example, email)
        PAYLOAD=$(echo "$PAYLOAD" | sed 's/"email": *"[^"]*",//')
        ;;
    injection)
        # Inject an SQL injection payload into the email field
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
    echo "Running rate limit test for registration endpoint with test type '$TEST_TYPE'..."
    for i in $(seq 1 70); do
        echo "Sending request $i"
        curl -ks $PROXY -X POST -d "$PAYLOAD" "$URL" &
    done
    wait
    echo "Rate limit test completed."
else
    echo "Running test type '$TEST_TYPE' for registration endpoint..."
    curl -ks $PROXY -X POST -d "$PAYLOAD" "$URL"
    echo
fi
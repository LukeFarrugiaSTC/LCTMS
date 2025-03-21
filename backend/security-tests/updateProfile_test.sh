#!/bin/bash
# Updated test script for the profileUpdate endpoint with additional test cases
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

# Source the .env file from two directories up
if [ -f ./../../.env ]; then
    source ./../../.env
else
    echo ".env file not found at ./../../.env"
    exit 1
fi

# Check that API_KEY is set in the .env file if we need a valid test or injection test
if [ "$TEST_TYPE" == "valid" ] || [ "$TEST_TYPE" == "injection" ]; then
    if [ -z "${API_KEY:-}" ]; then
        echo "API_KEY is not set in the .env file."
        exit 1
    fi
fi

# Define the endpoint URL for profileUpdate (adjust as necessary)
URL="https://localhost:443/endpoints/user/profileUpdate.php"

# Base payload for a valid request
PAYLOAD=$(cat <<EOF
{
    "api_key": "$API_KEY",
    "email": "test@example.com",
    "name": "Jane",
    "surname": "Doe",
    "houseNumber": "123 Main St",
    "street": "00410019",
    "town": "0044",
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
        # Remove the last character to create malformed JSON
        PAYLOAD="${PAYLOAD:0:-1}"
        ;;
    missing-api)
        # Replace payload with an empty JSON object
        PAYLOAD='{}'
        ;;
    injection)
        # Inject an SQL injection payload into the api_key field
        # or any other field you want to test
        PAYLOAD=$(cat <<EOF
{
    "api_key": "' OR '1'='1",
    "email": "test@example.com",
    "name": "Jane",
    "surname": "Doe",
    "houseNumber": "123 Main St",
    "street": "00410019",
    "town": "0044",
    "mobile": "12345678",
    "dob": "1990-01-01",
    "password": "Password12!",
    "confirm": "Password12!"
}
EOF
)
        PAYLOAD=$(echo "$PAYLOAD" | tr -d "\n")
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
    echo "Running rate limit test for profileUpdate endpoint with test type '$TEST_TYPE'..."
    # Adjust the number of workers and requests as needed.
    # If your Python script also supports --use-proxy, pass it along:
    PROXY_FLAG=""
    if [ "$USE_PROXY" = true ]; then
        PROXY_FLAG="--use-proxy"
    fi

    python3 test_profile_update.py --url "$URL" --data "$PAYLOAD" --workers 10 --requests 70 $PROXY_FLAG
    echo "Rate limit test completed."
else
    echo "Running test type '$TEST_TYPE' for profileUpdate endpoint..."
    curl -ks $PROXY -X POST -d "$PAYLOAD" "$URL"
    echo
fi
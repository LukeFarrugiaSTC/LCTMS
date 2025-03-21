#!/bin/bash
# Updated test script for the readRoles endpoint with additional test cases.
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

# For test types that require a valid API_KEY, check if it's set
if [ "$TEST_TYPE" == "valid" ] || [ "$TEST_TYPE" == "injection" ]; then
    if [ -z "${API_KEY:-}" ]; then
        echo "API_KEY is not set in the .env file."
        exit 1
    fi
fi

URL="https://localhost:443/endpoints/user/readRoles.php"

# Prepare payload based on the test type
case "$TEST_TYPE" in
    valid)
        PAYLOAD='{"api_key": "'"$API_KEY"'"}'
        ;;
    malformed)
        # Create malformed JSON by omitting the closing brace
        PAYLOAD='{"api_key": "'"$API_KEY"'"'
        ;;
    missing-api)
        PAYLOAD='{}'
        ;;
    injection)
        PAYLOAD='{"api_key": "'\'' OR '\''1'\''='\''1"}'
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
    echo "Running rate limit test for the readRoles endpoint with test type '$TEST_TYPE'..."
    for i in $(seq 1 70); do
        echo "Sending request $i"
        curl -ks $PROXY -X POST -d "$PAYLOAD" "$URL" &
    done
    wait
    echo "Rate limit test completed."
else
    echo "Running test type '$TEST_TYPE' for the readRoles endpoint..."
    curl -ks $PROXY -X POST -d "$PAYLOAD" "$URL"
    echo
fi
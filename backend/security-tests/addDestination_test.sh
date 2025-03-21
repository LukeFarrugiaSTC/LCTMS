#!/bin/bash
# Updated test script for the login (or addDestination) endpoint with optional rate limit test.
# Supports --rate-limit and --use-proxy flags.
#
# Usage examples:
#   ./addDestination_test
#   ./addDestination_test --rate-limit
#   ./addDestination_test --use-proxy
#   ./addDestination_test --rate-limit --use-proxy

set -euo pipefail

RATE_LIMIT_TEST=false
USE_PROXY=false

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --rate-limit)
            RATE_LIMIT_TEST=true
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

# Ensure API_KEY is set in the .env file
if [ -z "${API_KEY:-}" ]; then
    echo "API_KEY is not set in the .env file."
    exit 1
fi

# Define the endpoint URL.
# Adjust the URL if you intend to test a different endpoint.
URL="https://localhost:443/endpoints/locations/addDestination.php"

# Construct the JSON payload.
PAYLOAD=$(cat <<EOF
{
    "destinationName": "test",
    "streetName": "Triq il- Gostra",
    "townName": "Is-Swatar, L-Imsida",
    "api_key": "$API_KEY"
}
EOF
)
# Remove newlines for curl compatibility.
PAYLOAD=$(echo "$PAYLOAD" | tr -d "\n")

# Set proxy options if --use-proxy flag is provided.
if [ "$USE_PROXY" = true ]; then
    PROXY="-x http://localhost:8080 --proxy-insecure"
    echo "Using proxy: http://localhost:8080"
else
    PROXY=""
fi

if [ "$RATE_LIMIT_TEST" = true ]; then
    echo "Running rate limit test for the endpoint..."
    for i in $(seq 1 70); do
        echo "Sending request $i"
        curl -ks $PROXY -X POST -d "$PAYLOAD" "$URL" &
    done
    wait
    echo "Rate limit test completed."
else
    echo "Sending a single test request to the endpoint..."
    curl -ks $PROXY -X POST -d "$PAYLOAD" "$URL"
    echo
fi
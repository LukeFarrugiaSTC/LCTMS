#!/bin/bash
# Test the townsList endpoint with optional rate limit test

# Parse command-line arguments
RATE_LIMIT_TEST=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --rate-limit) RATE_LIMIT_TEST=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
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

# API_KEY is required for townsList
if [ -z "$API_KEY" ]; then
    echo "API_KEY is not set in the .env file."
    exit 1
fi

URL="https://localhost:443/endpoints/locations/townsList.php"
PAYLOAD='{"api_key": "'"$API_KEY"'"}'

if [ "$RATE_LIMIT_TEST" = true ]; then
    echo "Running rate limit test for townsList endpoint..."
    for i in $(seq 1 70); do
        echo "Sending request $i"
        curl -ks -X POST -d "$PAYLOAD" "$URL" &
    done
    wait
    echo "Rate limit test completed."
else
    curl -ks -X POST -d "$PAYLOAD" "$URL"
    echo
fi
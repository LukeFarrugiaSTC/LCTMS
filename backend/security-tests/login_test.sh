#!/bin/bash
# Test the login endpoint with optional rate limit test

# Parse command-line arguments
RATE_LIMIT_TEST=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --rate-limit) RATE_LIMIT_TEST=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Source the .env file from two directories up (if available)
if [ -f ./../../.env ]; then
    source ./../../.env
else
    echo ".env file not found at ./../../.env"
fi

# The login endpoint doesn't require an API key so we only need email and password
URL="https://localhost:443/endpoints/login.php"
PAYLOAD='{"email": "test@example.com", "password": "Password12!"}'

if [ "$RATE_LIMIT_TEST" = true ]; then
    echo "Running rate limit test for login endpoint..."
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
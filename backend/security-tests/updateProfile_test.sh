#!/bin/bash
# Test the profileUpdate endpoint using the provided Python testing tool.
# This script sources the API key from a .env file located two directories up.
# It sends a payload with the required fields for the profile update.
#
# Usage:
#   ./test_profile_update.sh [--rate-limit]
#
# If --rate-limit is provided, the Python script will be used to send concurrent requests.

# Default to not running rate limit test
RATE_LIMIT_TEST=false

# Parse command-line arguments
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

# Check that API_KEY is set in the .env file
if [ -z "$API_KEY" ]; then
    echo "API_KEY is not set in the .env file."
    exit 1
fi

# Define the endpoint URL for profileUpdate (adjust as necessary)
URL="https://localhost:443/endpoints/user/profileUpdate.php"

# Construct the JSON payload.
# Adjust the values as required. All required fields are provided:
# api_key, email, name, surname, address, street, town, dob, mobile
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

# If rate limit test flag is true, call the Python script to send concurrent requests.
if [ "$RATE_LIMIT_TEST" = true ]; then
    echo "Running rate limit test for profileUpdate endpoint..."
    # Adjust the number of workers and requests as needed.
    python3 test_profile_update.py --url "$URL" --data "$PAYLOAD" --workers 10 --requests 70
    echo "Rate limit test completed."
else
    # Otherwise, send a single test request using curl.
    echo "Sending a single test request to the profileUpdate endpoint..."
    curl -ks -X POST -d "$PAYLOAD" "$URL"
    echo
fi
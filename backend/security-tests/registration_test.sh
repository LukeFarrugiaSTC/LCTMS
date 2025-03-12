#!/bin/bash
# Test the registration endpoint with optional rate limit test

# Parse command-line arguments
RATE_LIMIT_TEST=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --rate-limit) RATE_LIMIT_TEST=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Optionally source the .env file if needed for environment consistency
if [ -f ./../../.env ]; then
    source ./../../.env
else
    echo ".env file not found at ./../../.env"
    exit 1
fi

URL="https://localhost:443/endpoints/user/registration.php"
PAYLOAD=$(cat <<EOF
{
    "email": "test@example.com",
    "fname": "John",
    "lname": "Doe",
    "houseNumber": "123 Main St",
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

if [ "$RATE_LIMIT_TEST" = true ]; then
    echo "Running rate limit test for registration endpoint..."
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
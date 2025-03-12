LOGIN_URL="https://localhost:443/endpoints/user/login.php"
LOGIN_PAYLOAD='{"email": "test@example.com", "password": "Password12!"}'

echo "Logging in..."
LOGIN_RESPONSE=$(curl -ks -X POST -d "$LOGIN_PAYLOAD" "$LOGIN_URL")
echo "Login response: $LOGIN_RESPONSE"

# Extract the token from JSON (requires jq to be installed)
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token')
echo "Extracted token: $TOKEN"

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo "No valid token found. Exiting..."
    exit 1
fi

# Source the .env file from two directories up (if available)
if [ -f ./../../.env ]; then
    source ./../../.env
else
    echo ".env file not found at ./../../.env"
fi

if [ -z "$API_KEY" ]; then
    echo "API_KEY is not set in the .env file."
    exit 1
fi

# 2) Call your booking endpoint with the token
BOOKING_URL="https://localhost:443/endpoints/bookings/addBooking.php"
BOOKING_PAYLOAD='{"api_key": "'"$API_KEY"'", "destinationName": "Mater Dei Hospital", "bookingDateTime": "2025-03-12 14:30:00" }'

echo "Calling addBooking endpoint with token..."
RESULT=$(curl -ks -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$BOOKING_PAYLOAD" \
    "$BOOKING_URL")

echo "addBooking response: $RESULT"
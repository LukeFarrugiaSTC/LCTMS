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


# 2) Call your booking endpoint with the token
LOGOUT_URL="https://localhost:443/endpoints/user/logout.php"

echo "Calling addBooking endpoint with token..."
RESULT=$(curl -ks -X POST \
    -H "Authorization: Bearer $TOKEN" \
    "$LOGOUT_URL"
    )

echo "addBooking response: $RESULT"
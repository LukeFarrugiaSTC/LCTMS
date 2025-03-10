<?php
function generateApiToken($userId) {
    // Generate a unique token for the user
    $token = bin2hex(random_bytes(32));
    
    storeTokenForUser($userId, $token);
    
    return $token;
}

function validateApiToken($token, $userId) {
    $storedToken = getStoredTokenForUser($userId);
    
    return hash_equals($storedToken, $token);
}
?>

//To be implemented in flutter

import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://your-api-url.com';
  String apiToken;

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      // Assuming the login endpoint returns the API token
      apiToken = json.decode(response.body)['token'];
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<dynamic> makeApiCall(String endpoint, {Map<String, dynamic> body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'X-API-Token': apiToken,
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('API call failed');
    }
  }
}

// API Implementation

<?php
require_once '../includes/api_protection.php';

// Get the API token from the request header
$apiToken = $_SERVER['HTTP_X_API_TOKEN'] ?? '';

// Get the user ID (you'll need to implement user authentication)
$userId = getCurrentUserId();

// Validate the API token
if (!validateApiToken($apiToken, $userId)) {
    http_response_code(403);
    echo json_encode(['error' => 'Invalid API token']);
    exit;
}

// Process the API request
// ...
?>

<?php
require_once __DIR__ . '/../../includes/config.php';
require_once __DIR__ . '/../../classes/utility.class.php';
require_once __DIR__ . '/../../classes/user.class.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../helpers/apiSecurityHelper.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
require_once __DIR__ . '/../../vendor/autoload.php';
require_once __DIR__ . '/../../helpers/JwtHelper.php';

use Helpers\JwtHelper;

try {
    $apiSecurity = new ApiSecurity();
    
    // Perform all security checks
    $apiSecurity->checkHttps();
    $apiSecurity->checkRequestMethod('POST');
    $apiSecurity->rateLimiter();
    $data = $apiSecurity->getJsonInput();

    UserValidator::validateLogin($data);

    // Initialize User class and set credentials
    $user = new User();
    $user->setUserEmail($data['email']);
    $user->setUserPassword($data['password']);

    // Call the login method and get the response
    $response = $user->login();
    // Decode the JSON-encoded login response
    $responseData = json_decode($response, true);

    // Validate if the user is active
    UserValidator::isUserActive($responseData);

    // If login is successful, generate a JWT and store it in Redis
    if ($responseData['status'] === 'success') {

        // Retrieve the secret key from environment variables
        $secretKey = getenv('JWT_KEY');
        if (!$secretKey) {
            throw new Exception("Secret key is not set.");
        }
        
        // Instantiate the helper with your secret key and algorithm
        $jwtHelper = new JwtHelper($secretKey, 'HS256');

        // Build token payload (the helper will add 'iat' and 'exp' automatically)
        $payload = [
            'userId' => $responseData['userId'],
            'roleId' => $responseData['roleId']
        ];
        
        // Generate the JWT token (with a 3600-second expiration)
        $jwt = $jwtHelper->encodeToken($payload, 3600);

        // Optionally store the token in Redis for session management / revocation
        $redis = new Redis();
        $redis->connect('redis', 6379);

        // Make sure we have a valid connection
        if (!$redis->ping()) {
            throw new Exception("Could not connect to Redis");
        }

        // Set the token in Redis with a TTL of 3600 seconds
        $redisKey = "auth_token:" . $responseData['userId'];
        $ttl      = 3600; // 1 hour
        $result = $redis->setex($redisKey, $ttl, $jwt);
        if (!$result) {
            error_log("Failed to add token to Redis");
        }
        
        // Include the token in the response data
        $responseData['token'] = $jwt;
    }
    
} catch (ValidationException $e) {
    sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
} catch (ApiSecurityException $e) {
    sendResponse(["status" => "error", "message" => $e->getMessage()], $e->getCode());
    exit;
} catch (Exception $e) {
    sendResponse(["status" => "error", "message" => $e->getMessage()], 500);
    exit;
}

// Send the final response with the token (if generated)
sendResponse($responseData);
?>
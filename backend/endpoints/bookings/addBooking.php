<?php
require_once __DIR__ . '/../../includes/config.php';
require_once __DIR__ . '/../../classes/utility.class.php';
require_once __DIR__ . '/../../classes/user.class.php';
require_once __DIR__ . '/../../classes/userBookings.class.php';
require_once __DIR__ . '/../../classes/destination.class.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../helpers/apiSecurityHelper.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
require_once __DIR__ . '/../../vendor/autoload.php';
require_once __DIR__ . '/../../helpers/JwtHelper.php';

use Helpers\JwtHelper;

try {
    $apiSecurity = new ApiSecurity();

    // Perform standard security checks
    $apiSecurity->checkHttps();               // Enforce HTTPS
    $apiSecurity->checkRequestMethod('POST');   // Expect POST requests
    $apiSecurity->rateLimiter();                // Rate-limiting if configured

    // Retrieve the Authorization header (expecting "Authorization: Bearer <JWT>")
    $headers = apache_request_headers();
    if (!isset($headers['Authorization'])) {
        throw new Exception("Missing Authorization header.");
    }

    $authHeader = $headers['Authorization'];
    if (stripos($authHeader, 'Bearer ') !== 0) {
        throw new Exception("Invalid Authorization header format. Expected 'Bearer <token>'.");
    }

    // Extract the token portion from the header
    $jwtToken = substr($authHeader, 7); // everything after "Bearer "

    // Retrieve your secret key from the environment (.env)
    $secretKey = getenv('JWT_KEY');
    if (!$secretKey) {
        throw new Exception("JWT_KEY is not set in environment variables.");
    }

    // Instantiate the helper with your secret key
    $jwtHelper = new JwtHelper($secretKey);

    // Use the helper to decode and verify the token
    $decoded = $jwtHelper->decodeToken($jwtToken);
    $userId = $decoded->userId;

    // (Optional) Validate the token against Redis to ensure it's not revoked
    $redis = new Redis();
    $redis->connect('redis', 6379); // Adjust host/port as needed
    if (!$redis->ping()) {
        throw new Exception("Could not connect to Redis.");
    }
    // The key used in the login script might be "auth_token:userId"
    $redisKey = "auth_token:" . $decoded->userId; 
    $storedToken = $redis->get($redisKey);

    if (!$storedToken || $storedToken !== $jwtToken) {
        // If there's no match, the token might be revoked or missing
        throw new Exception("Token not found or mismatch in Redis (possibly revoked).");
    }

    // Now that the token is valid, get the POST data
    $data = $apiSecurity->getJsonInput();
    
    $destination = new Destination();
    $userBookings = new UserBookings();

    $destionationId = $destination->getDestinationIdFromDestinationName($data['destinationName']);
    $userBookings = $userBookings->addUserBooking($userId, $destionationId, $data['bookingDateTime']?? date('Y-m-d'));

    // Return a success response (you can add additional data as needed)
    $response = [
        "status"  => "success",
        "message" => "Booking added successfully",
        "userId"    => $userId
    ];

    sendResponse($response);

} catch (ValidationException $e) {
    // Handle validation errors specifically
    sendResponse([
        "status"  => "error", 
        "message" => implode(', ', $e->getErrors())
    ], 400);
} catch (ApiSecurityException $e) {
    // Handle custom API security exceptions
    sendResponse([
        "status"  => "error", 
        "message" => $e->getMessage()
    ], $e->getCode());
    exit;
} catch (Exception $e) {
    // Handle all other exceptions
    sendResponse([
        "status"  => "error", 
        "message" => $e->getMessage()
    ], 500);
    exit;
}
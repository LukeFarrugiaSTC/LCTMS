<?php
require_once __DIR__ . '/../../includes/config.php';
require_once __DIR__ . '/../../classes/utility.class.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../helpers/apiSecurityHelper.php';
require_once __DIR__ . '/../../vendor/autoload.php';
require_once __DIR__ . '/../../helpers/JwtHelper.php';

use Helpers\JwtHelper;


try {
    $apiSecurity = new ApiSecurity();
    
    // Security checks
    $apiSecurity->checkHttps();
    $apiSecurity->checkRequestMethod('POST');
    $apiSecurity->rateLimiter();

    // Get the Authorization header
    $headers = apache_request_headers();
    if (!isset($headers['Authorization'])) {
        throw new Exception("Missing Authorization header.");
    }

    $authHeader = $headers['Authorization'];
    if (stripos($authHeader, 'Bearer ') !== 0) {
        throw new Exception("Invalid Authorization header format. Expected 'Bearer <token>'.");
    }

    // Extract the token
    $jwtToken = substr($authHeader, 7);

    // Load your secret key
    $secretKey = getenv('JWT_KEY');
    if (!$secretKey) {
        throw new Exception("JWT_KEY is not set in environment variables.");
    }

    // Instantiate the helper with your secret key
    $jwtHelper = new JwtHelper($secretKey);

    // Use the helper to decode and verify the token
    $decoded = $jwtHelper->decodeToken($jwtToken);

    // Connect to Redis and remove the token (or mark it revoked)
    $redis = new Redis();
    $redis->connect('redis', 6379);
    if (!$redis->ping()) {
        throw new Exception("Could not connect to Redis.");
    }

    // Based on how you stored it in the login endpoint
    $redisKey = "auth_token:" . $decoded->userId;
    $storedToken = $redis->get($redisKey);

    if (!$storedToken) {
        // Possibly already logged out or expired
        // Return success anyway or handle differently
        sendResponse(["status" => "success", "message" => "You are already logged out."], 200);
        exit;
    }

    // If the stored token matches the one being sent, remove it
    if ($storedToken === $jwtToken) {
        $redis->del($redisKey);
    }
    
    // Return a success response
    sendResponse(["status" => "success", "message" => "Logged out successfully."]);

} catch (Exception $e) {
    sendResponse(["status" => "error", "message" => $e->getMessage()], 500);
    exit;
}
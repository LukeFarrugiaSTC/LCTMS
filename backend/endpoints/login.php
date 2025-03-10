<?php
// backend/endpoints/login.php

require_once '../classes/user.class.php';
require_once '../helpers/responseHelper.php';
require_once '../helpers/apiSecurityHelper.php';

// Determine if the connection is secure
$isSecure = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ||
            (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https');

if (!$isSecure) {
    sendResponse(["status" => "error", "message" => "HTTPS is required"], 403);
}

// Ensure the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse([
        "status"  => "error",
        "message" => "Invalid request method"
    ], 405);
}

$apiSecurity = new ApiSecurity();

if (!$apiSecurity->rateLimiter()) {
    exit;
}

// Get the raw POST data
$data = json_decode(file_get_contents('php://input'), true);

// Validate that email and password are provided
if (empty($data['email']) || empty($data['password'])) {
    sendResponse([
        "status"  => "error",
        "message" => "Missing email or password"
    ]);
}

// Initialize User class
$user = new User();
$user->setUserEmail($data['email']);
$user->setUserPassword($data['password']);

// Call the login method and get the response
$response = $user->login();

// Decode the JSON-encoded login response
$responseData = json_decode($response, true);

// Check if the user's account is not active
if (isset($responseData['isActive']) && $responseData['isActive'] == 0) {
    sendResponse([
        "status"  => "error",
        "message" => "account not active"
    ]);
}

// Send the response using the helper function
sendResponse($responseData);
?>
<?php
require_once '../includes/config.php';
require_once '../classes/utility.class.php';
require_once '../classes/town.class.php';
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
    sendResponse(["status" => "error", "message" => "Invalid request method"], 405);
}

$apiSecurity = new ApiSecurity();

if (!$apiSecurity->rateLimiter()) {
    exit;
}

// Get and decode the raw POST data
$rawInput = file_get_contents('php://input');
$data = json_decode($rawInput, true);

// Check for JSON decoding errors
if (json_last_error() !== JSON_ERROR_NONE) {
    sendResponse(["status" => "error", "message" => "Malformed JSON input"], 400);
}

// Initialize Utility to get the API key
$utility = new Utility();
$expectedAPIKey = $utility->getMyAPI_key();

// Validate that an API key was provided
if (empty($data['api_key'])) {
    sendResponse(["status" => "error", "message" => "API Key is required"], 400);
}

// Validate the provided API key
if ($data['api_key'] !== $expectedAPIKey) {
    sendResponse(["status" => "error", "message" => "Invalid API Key"], 403);
}

// If API key is valid, fetch towns
$town = new Town();
$townResponse = json_decode($town->townRead(), true);
sendResponse($townResponse);
?>
<?php
require_once '../classes/user.class.php';
require_once '../helpers/responseHelper.php';
require_once '../classes/utility.class.php';
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

// List of required fields
$requiredFields = [
    'email', 'fname', 'lname', 'address', 
    'streetCode', 'townCode', 'mobile', 
    'dob', 'password', 'confirm'
];

// Validate that all required fields exist and are not empty
foreach ($requiredFields as $field) {
    if (empty($data[$field])) {
        sendResponse([
            "status"  => "error",
            "message" => "Missing or empty field: $field"
        ], 400);
    }
}

// Validate password strength (Minimum 8 characters, at least one letter and one number)
if (!Utility::validatePassword($data['password'])) {
    sendResponse([
        "status"  => "error",
        "message" => "Password does not meet strength requirements"
    ], 400);
}

// Check if passwords match
if ($data['password'] !== $data['confirm']) {
    sendResponse([
        "status"  => "error",
        "message" => "Passwords do not match"
    ], 400);
}

// Initialize the User class and set the provided data
$user = new User();
$user->setUserEmail($data['email']);
$user->setUserFirstname($data['fname']);
$user->setUserLastname($data['lname']);
$user->setUserAddress($data['address']);
$user->setStreetCode($data['streetCode']);
$user->setTownCode($data['townCode']);
$user->setMobile($data['mobile']);
$user->setUserDob($data['dob']);
$user->setUserPassword($data['password']);
$user->setUserConfirm($data['confirm']);

// Call the registration method and decode its JSON response
$response = json_decode($user->registration(), true);
sendResponse($response);
?>
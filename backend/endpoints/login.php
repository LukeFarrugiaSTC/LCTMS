<?php
// backend/endpoints/login.php

require_once '../classes/user.class.php';
require_once '../helpers/responseHelper.php';

// Ensure the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse([
        "status"  => "error",
        "message" => "Invalid request method"
    ], 405);
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

// Since login() returns JSON-encoded string, decode it to an array
$responseData = json_decode($response, true);

// Send the response using the helper function
sendResponse($responseData);
?>
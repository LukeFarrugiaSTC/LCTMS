<?php
// Include the User class from the classes directory
require_once '../classes/user.class.php';

// Set the response content type to JSON
header('Content-Type: application/json');

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    // Get the raw POST data
    $data = json_decode(file_get_contents('php://input'), true);

    // Validate if email and password are provided
    if (!empty($data['email']) && !empty($data['password'])) {
        
        // Initialize User class
        $user = new User();

        // Set user data
        $user->setUserEmail($data['email']);
        $user->setUserPassword($data['password']);
	 

        // Call the login method and get the response
        $response = $user->login();
        
        // Output the response as JSON
        echo json_encode($response);
	  	exit;
    } else {
        // Invalid request, missing parameters
        echo json_encode([
            "status"  => "error",
            "message" => "Missing email or password"
        ]);
	  	exit;
    }
} else {
    // If the request method is not POST
    echo json_encode([
        "status"  => "error",
        "message" => "Invalid request method"
    ]);
  	exit;
}
?>
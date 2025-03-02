<?php
// Include the User class from the classes directory
require_once '../classes/user.class.php';

// Set the response content type to JSON
header('Content-Type: application/json');

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    // Get the raw POST data
    $data = json_decode(file_get_contents('php://input'), true);
  	error_log("Received Data: ".json_encode($data));

  	// Check if all the attributes exist in the POST request
  	if (!isset($data['email']) || !isset($data['fname']) || !isset($data['lname']) || !isset($data['address']) || !isset($data['streetCode']) || !isset($data['townCode']) || 
		!isset($data['mobile']) || !isset($data['dob']) || !isset($data['password']) || !isset($data['confirm']))
	{
		echo json_encode([
		  "status" 	=> 	"error",
		  "message" =>	"One or more inputs are missing"
		  ]);
	  	exit;
	}
  
    // Validate if required fields contain data
    if (!empty($data['email']) && !empty($data['fname']) && !empty($data['lname']) && !empty($data['address']) && !empty($data['streetCode']) && 
		!empty($data['townCode']) && !empty($data['mobile']) && !empty($data['dob']) && !empty($data['password']) && !empty($data['confirm'])) {
	  
	  	// Check if passwords match
	  	if ($data['password'] !== $data['confirm']) {
			echo json_encode([
				"status" 	=>	"error",
		  		"message" 	=>	"Passwords do not match"
			]);
		  	exit;
		}
        
        // Initialize User class
        $user = new User();

        // Set user data
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

        // Call the login method and get the response
        $response = $user->registration();
        
        // Output the response as JSON
        echo $response;
	  	exit;
    } else {
        // Invalid request, missing parameters
        echo json_encode([
            "status"  => "error",
            "message" => "Missing user information"
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
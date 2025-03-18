<?php
/*
	 * **************************************************
	 * Name: 	    generatePIN.php
	 * Description: Handles user password reset
	 * Author: 		Andrew Mallia
	 * Date: 		2025-03-12
	 * **************************************************
	 */

    require_once '../includes/config.php';
    require_once '../classes/utility.class.php';
    require_once '../classes/user.class.php';
    
    // Set the response content type to JSON
    header('Content-Type: application/json');

    // Get database connection
    $conn = Dbh::getInstance()->getConnection();

    // Check if the request method is POST 
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        
        // Get the raw POST data
        $data = json_decode(file_get_contents('php://input'), true);
      
        // Create a Utility object and get the API key
        $utility = new Utility();
        $API_Key = $utility->getMyAPI_key();
      
        // Debugging output to check both keys
        if (isset($data['api_key'])){
            //Step1: Check if the API key is valid
            if ($data['api_key'] !== $API_Key){
                echo json_encode(["status" => "error", "message" => "Invalid API Key"]);
                exit;
            }
            //Step2: Check if the API key is empty 
            else if (empty($data['api_key'])){
                echo json_encode(["status" => "error", "message" => "API Key is required"]);
            }
            //Step3: Check if the email is valid
            if (!isset($data['email']) || empty($data['email']) || !$utility->validateEmail($data['email'])) {
                echo json_encode(["status" => "error", "message" => "Email is required"]);
                exit;
            }
 
            // Check if the user exists
            $user = new User();
            $user->setUserEmail($data['email']);
            $result = $user->resetPassword();
            $result = json_decode($result, true);
          
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid request method"]);
    }
          
?>
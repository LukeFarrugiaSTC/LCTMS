<?php
/*
	 * **************************************************
	 * Class Name: 	profileRead
	 * Description: Handles user profile read
	 * Author: 		Andrew Mallia
	 * Date: 		2025-03-08
	 * **************************************************
	 */

    require_once '../includes/config.php';
    require_once '../classes/utility.class.php';
    require_once '../classes/user.class.php';
    require_once '../helpers/apiSecurityHelper.php';

    // Determine if the connection is secure
    $isSecure = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ||
    (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https');

    if (!$isSecure) {
    sendResponse(["status" => "error", "message" => "HTTPS is required"], 403);
    }

    $apiSecurity = new ApiSecurity();

    if (!$apiSecurity->rateLimiter()) {
        exit;
    }

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
            if ($data['api_key'] !== $API_Key){
                echo json_encode(["status" => "error", "message" => "Invalid API Key"]);
                exit;
            } else if (empty($data['api_key'])){
                echo json_encode(["status" => "error", "message" => "API Key is required"]);
            }
          
            if (!isset($data['email']) || empty($data['email']) || !$utility->validateEmail($data['email'])) {
                echo json_encode(["status" => "error", "message" => "Email is required"]);
                exit;
            }

            // If API key is valid, fetch user profile
            $user = new User();
            $user->setUserEmail($data['email']);
            echo $user->profileRead();
          
        } else {
            echo json_encode(["status" => "error", "message" => "API Key is required"]);
        }
    } else { // if request is not POST
        echo json_encode(["status" => "error", "message" => "Invalid request method"]);
    }
  
 ?>
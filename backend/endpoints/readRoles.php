<?php
    // Include required files
    require_once '../includes/config.php';   // Ensure database connection is available
    require_once '../classes/utility.class.php';
    require_once '../classes/role.class.php';
    require_once '../helpers/apiSecurityHelper.php';
    require_once '../helpers/responseHelper.php';

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

    // Get database connection
    $conn = Dbh::getInstance()->getConnection();

    // Get the raw POST data
    $data = json_decode(file_get_contents('php://input'), true);
    $utility = new Utility();
    

    // Get the API key from the utility class
    $API_Key = $utility->getMyAPI_key();
    
    // Debugging output to check both keys
    if (isset($data['api_key'])){
        if ($data['api_key'] !== $API_Key){
            echo sendResponse(["status" => "error", "message" => "Invalid API Key"]);
            exit;
        } else if (empty($data['api_key'])){
            echo sendResponse(["status" => "error", "message" => "API Key is required"]);
            exit;
        }
        
        // If API key is valid, fetch roles
        $role = new Role();
        echo $role->roleRead();
        
    } else {
        echo sendResponse(["status" => "error", "message" => "API Key is required"]);
    }
?>




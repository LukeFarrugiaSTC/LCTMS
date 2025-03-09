<?php
    /*
        * **************************************************
        * Class Name:   profileUpdate
        * Description:  Handles user profile update
        * Author:       Andrew Mallia
        * Date:         2025-03-09
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
          
            if (!isset($data['name']) || empty($data['name']) || !$utility->validateName($data['name'])) {
                echo json_encode(["status" => "error", "message" => "Name is required"]);
                exit;
            }
          
            if (!isset($data['surname']) || empty($data['surname']) || !$utility->validateSurname($data['surname'])) {
                echo json_encode(["status" => "error", "message" => "Surname is required"]);
                exit;
            }

            if (!isset($data['address']) || empty($data['address']) || !$utility->validateAddress($data['address'])) {
                echo json_encode(["status" => "error", "message" => "Address is required"]);
                exit;
            }            

            if (!isset($data['street']) || empty($data['street']) || !$utility->validateStreetCode($data['street'])) {  
                echo json_encode(["status" => "error", "message" => "Street is required"]);
                exit;
            }
          
            if (!isset($data['town']) || empty($data['town']) || !$utility->validateTownCode($data['town'])) {
                echo json_encode(["status" => "error", "message" => "Town is required"]);
                exit;
            }
          
            if (!isset($data['dob']) || empty($data['dob']) || !$utility->validateDate($data['dob'])) {
                echo json_encode(["status" => "error", "message" => "Date of Birth is required"]);
                exit;
            }

            if (!isset($data['mobile']) || empty($data['mobile']) || !$utility->validateMobile($data['mobile'])) {
                echo json_encode(["status" => "error", "message" => "Mobile is required"]);
                exit;
            }

            // Proceed with the update
            $user = new User();
            $user->setUserEmail($data['email']);
            $user->setUserFirstname($data['name']);
            $user->setUserLastname($data['surname']);
            $user->setUserAddress($data['address']);
            $user->setStreetCode($data['street']);
            $user->setTownCode($data['town']);
            $user->setUserDob($data['dob']);
            $user->setMobile($data['mobile']);
            echo $user->profileUpdate();

        } else {
            echo json_encode(["status" => "error", "message" => "API Key is required"]);
        }
    } else { // if request is not POST
        echo json_encode(["status" => "error", "message" => "Invalid request method"]);
    }
?>
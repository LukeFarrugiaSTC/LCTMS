<?php
// Include required files
require_once '../includes/config.php';   // Ensure database connection is available
require_once '../classes/utility.class.php';
require_once '../classes/street.class.php';


// Set the response content type to JSON
header('Content-Type: application/json');

// Get database connection
$conn = Dbh::getInstance()->getConnection();

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    // Get the raw POST data
    $data = json_decode(file_get_contents('php://input'), true);
  	$utility = new Utility();
  

    // Get the API key from the request
  	$API_Key = $utility->getMyAPI_key();
  
  	// Debugging output to check both keys
  	if (isset($data['api_key'])){
		if ($data['api_key'] !== $API_Key){
			echo json_encode(["status" => "error", "message" => "Invalid API Key"]);
		  	exit;
		} else if (empty($data['api_key'])){
			echo json_encode(["status" => "error", "message" => "API Key is required"]);
		}
	  
	  	if (isset($data['townCode']) && !empty($data['townCode'])){
			// If API key is valid, fetch towns
			$street = new Street();
		  	$street->setTownCode($data['townCode']);
			echo $street->readStreetsByTown();	
		} else {
			echo json_encode(["status" => "error", "message" => "Town Code is Required"]);
		}
	  
	  
	} else {
		echo json_encode(["status" => "error", "message" => "API Key is required"]);
	}

  } else { // if request is not POST
	  echo json_encode(["status" => "error", "message" => "Invalid request method"]);
  }
?>
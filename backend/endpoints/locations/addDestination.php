<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/destination.class.php';
require_once __DIR__ . '/../../classes/town.class.php';
require_once __DIR__ . '/../../classes/street.class.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';

class AddDestinationController extends BaseApiController {
    public function handle() {
        try {
            $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');
            
            $destination = new Destination();
            $town = new Town();
            $street = new Street();
            
            $destination->setDestinationName($this->data['destinationName']);
            
            $townCode = $town->getTownCodeFromTownName($this->data['townName']);
            $destination->setTownCode($townCode);
            
            $streetCode = $street->getStreetCodeFromStreetName($this->data['streetName']);
            if ($street->getTownCodeFromStreetCode($streetCode) != $townCode) {
                sendResponse(["status" => "error", "message" => "Invalid street name for town selected"], 400);
                exit;
            }
            $destination->setStreetCode($streetCode);
            
            // Assuming addDestination returns a JSON encoded response
            $response = json_decode($destination->addDestination(), true);
            sendResponse(['status' => "success", "data" => 'Destination added successfully.'], 201);
        } catch (ValidationException $e) {
            sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
        } catch (ApiSecurityException $e) {
            sendResponse(["status" => "error", "message" => $e->getMessage()], $e->getCode());
            exit;
        }
    }
}

$controller = new AddDestinationController();
$controller->handle();
?>
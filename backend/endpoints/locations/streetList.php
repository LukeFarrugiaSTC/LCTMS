<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/street.class.php';
require_once __DIR__ . '/../../classes/town.class.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';

class StreetsController extends BaseApiController {
    public function handle() {
        try {
            $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');
            // Validate that the required field exists
            UserValidator::checkForRequiredFields($this->data, ['townName']);
            
            $town = new Town();
            $street = new Street();
            $townCode = $town->getTownCodeFromTownName($this->data['townName']);
            $streetResponse = $street->getStreetsFromTownCode($townCode);
            if ($streetResponse === null) {
                sendResponse(["status" => "error", "message" => "No street data found"], 404);
                exit;
            }
            sendResponse($streetResponse);
        } catch (ValidationException $e) {
            sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
        } catch (ApiSecurityException $e) {
            sendResponse(["status" => "error", "message" => $e->getMessage()], $e->getCode());
            exit;
        }
    }
}

$controller = new StreetsController();
$controller->handle();
?>
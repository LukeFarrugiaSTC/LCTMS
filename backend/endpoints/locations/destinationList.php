<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/destination.class.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';

class DestinationController extends BaseApiController {
    public function handle() {
        try {
            $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');
            $destination = new Destination();
            $destinationResponse = $destination->getAllDestinations();
            sendResponse($destinationResponse);
        } catch (ValidationException $e) {
            sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
        } catch (ApiSecurityException $e) {
            sendResponse(["status" => "error", "message" => $e->getMessage()], $e->getCode());
            exit;
        }
    }
}

$controller = new DestinationController();
$controller->handle();
?>
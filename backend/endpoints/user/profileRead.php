<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/user.class.php';
require_once __DIR__ . '/../../classes/street.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../vendor/autoload.php';

class ProfileReadController extends BaseApiController {
    public function handle() {
        try {
            // Validate API key if provided
            $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');
            // Validate required fields
            UserValidator::checkForRequiredFields($this->data, ['email']);

            $user = new User();
            $user->setUserEmail($this->data['email']);
            $responseJson = $user->profileRead(); // This is a JSON string
            $response = json_decode($responseJson, true); // decode to array
            
            if (!is_array($response)) {
                sendResponse([
                    "status" => "error",
                    "message" => "profileRead returned invalid JSON"
                ], 400);
                return;
            }
            
            if ($response['status'] === 'success') {
                $street = new Street();
                $streetName = $street->getStreetNameFromStreetCode($response['streetCode']);
                $response['streetName'] = $streetName;
            
                sendResponse(['status' => 'successful', 'message' => $response]);
            } else {
                // Handle the error or else case, e.g.:
                sendResponse([
                    'status' => 'error',
                    'message' => $response['message'] ?? 'Unknown error'
                ], 400);
            }
        } catch (ValidationException $e) {
            sendResponse(
                ["status" => "error", "message" => implode(', ', $e->getErrors())],
                400
            );
        } catch (ApiSecurityException $e) {
            sendResponse(
                ["status" => "error", "message" => $e->getMessage()],
                $e->getCode()
            );
            exit;
        }
    }
}

$controller = new ProfileReadController();
$controller->handle();
?>
<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/user.class.php';
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
            $response = $user->profileRead();
            sendResponse(['status' => 'successful', 'message' => $response]);
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
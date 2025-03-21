<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/user.class.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
require_once __DIR__ . '/../../vendor/autoload.php';

class GeneratePinController extends BaseApiController {
    public function handle() {
        try {
            $user = new User();
            $user->setUserEmail($this->data['email']);
            $response = $user->resetPassword();
            $responseData = json_decode($response, true);

            sendResponse($responseData);
        } catch (ValidationException $e) {
            sendResponse(
                ["status" => "error", "message" => implode(', ', $e->getErrors())],
                400
            );
        }
    }
}

$controller = new GeneratePinController();
$controller->handle();
?>

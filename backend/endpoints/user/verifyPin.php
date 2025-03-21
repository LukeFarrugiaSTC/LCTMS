<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
require_once __DIR__ . '/../../helpers/redisHelper.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../vendor/autoload.php';

class VerifyPinController extends BaseApiController {
    public function handle() {
        try {
            // Retrieve the JSON input (this should include 'email' and 'pin')
            $data = $this->data;
            
            // Ensure both email and pin are provided
            if (!isset($data['email']) || !isset($data['pin'])) {
                sendResponse(["status" => "error", "message" => "Email and PIN are required."], 400);
                return;
            }
            $email = $data['email'];
            $inputPin = $data['pin'];
            
            // Use RedisHelper to retrieve the stored reset PIN for this email.
            $redisHelper = new RedisHelper();
            $storedPin = $redisHelper->getResetPin($email);
            
            if (!$storedPin) {
                // If there is no stored PIN, it might have expired or was never set.
                sendResponse(["status" => "error", "message" => "PIN has expired or is invalid."], 400);
                return;
            }
            
            // Compare the provided PIN with the stored PIN (trim spaces if needed)
            if (trim($storedPin) !== trim($inputPin)) {
                sendResponse(["status" => "error", "message" => "Invalid PIN provided."], 400);
                return;
            }
            
            // If the PIN matches, send a success response.
            sendResponse(["status" => "success", "message" => "PIN verified."], 200);
        } catch (ValidationException $e) {
            sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
        } catch (Exception $e) {
            sendResponse(["status" => "error", "message" => $e->getMessage()], 500);
        }
    }
}

$controller = new VerifyPinController();
$controller->handle();
?>
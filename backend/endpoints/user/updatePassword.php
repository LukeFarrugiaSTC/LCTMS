<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/user.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../vendor/autoload.php';
require_once __DIR__ . '/../../helpers/redisHelper.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';

class UpdatePasswordController extends BaseApiController {
    public function handle() {
        try {
            // Ensure email, pin, and newPassword are provided
            if (!isset($this->data['email'], $this->data['pin'], $this->data['newPassword'])) {
                sendResponse([
                    "status"  => "error",
                    "message" => "Email, PIN, and new password are required."
                ], 400);
            }
            
            $email      = $this->data['email'];
            $inputPin   = $this->data['pin'];
            $newPassword= $this->data['newPassword'];
            
            // Instantiate a User object and set the email
            $user = new User();
            $user->setUserEmail($email);
            
            // Verify that the email exists
            if (!$user->doesTheEmailExist()) {
                throw new Exception("Email does not exist.");
            }
            
            // Use Redis to fetch the stored reset PIN
            $redisHelper = new RedisHelper();
            $storedPin = $redisHelper->getResetPin($email);
            
            if (!$storedPin || (int)$storedPin !== (int)$inputPin) {
                throw new Exception("Invalid or expired PIN provided.");
            }
            
            // Hash the new password
            $hashedPassword = password_hash($newPassword, PASSWORD_BCRYPT);
            
            // Update the password using the updatePassword method
            $updateResult = $user->updatePassword($hashedPassword);
            if ($updateResult) {
                // Optionally, delete the PIN from Redis after successful update
                $redisHelper->deleteResetPin($email);
                
                sendResponse([
                    "status"  => "success",
                    "message" => "Password has been reset successfully."
                ]);
            } else {
                sendResponse([
                    "status"  => "error",
                    "message" => "Failed to update the password."
                ], 500);
            }
        } catch (ValidationException $e) {
            sendResponse([
                "status"  => "error",
                "message" => implode(', ', $e->getErrors())
            ], 400);
        } catch (Exception $e) {
            sendResponse([
                "status"  => "error",
                "message" => $e->getMessage()
            ], 400);
        }
    }
}

$controller = new UpdatePasswordController();
$controller->handle();
?>
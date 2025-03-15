<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/user.class.php';
require_once __DIR__ . '/../../classes/town.class.php';
require_once __DIR__ . '/../../classes/street.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';

class RegistrationController extends BaseApiController {
    public function handle() {
        try {
            // Validate the registration data
            UserValidator::validateRegistration($this->data);
            
            $user   = new User();
            $town   = new Town();
            $street = new Street();
            
            $user->setUserEmail($this->data['email']);
            $user->setUserFirstname($this->data['fname']);
            $user->setUserLastname($this->data['lname']);
            $user->setUserAddress($this->data['houseNumber']);
            
            $townCode = $town->getTownCodeFromTownName($this->data['townName']);
            $user->setTownCode($townCode);
            
            $streetCode = $street->getStreetCodeFromStreetName($this->data['streetName']);
            if ($street->getTownCodeFromStreetCode($streetCode) != $townCode) {
                sendResponse(["status" => "error", "message" => "Invalid street name for town selected"], 400);
                exit;
            }
            $user->setStreetCode($streetCode);
            
            $user->setMobile($this->data['mobile']);
            $user->setUserDob($this->data['dob']);
            $user->setUserPassword($this->data['password']);
            $user->setUserConfirm($this->data['confirm']);
            
            $response = $user->registration();
            sendResponse($response);
        } catch (ValidationException $e) {
            sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
        } catch (ApiSecurityException $e) {
            sendResponse(["status" => "error", "message" => $e->getMessage()], $e->getCode());
            exit;
        } catch (Exception $e) {
            sendResponse(["status" => "error", "message" => "An unexpected error occurred. Please try again later."], 500);
        }
    }
}

$controller = new RegistrationController();
$controller->handle();
?>
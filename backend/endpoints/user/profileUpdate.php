<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/user.class.php';
require_once __DIR__ . '/../../classes/street.class.php';
require_once __DIR__ . '/../../classes/town.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';

class ProfileUpdateController extends BaseApiController {
    public function handle() {
        try {
            // Validate API key if provided
            $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');
            // Validate the profile update data
            UserValidator::validateProfileUpdate($this->data);
            
            // Proceed with updating the user profile
            $user = new User();

            $street = new Street();
            $streetCode = $street->getStreetCodeFromStreetName($this->data['street']);

            $town = new Town();
            $townCode = $town->getTownCodeFromTownName($this->data['town']);

            $user->setUserEmail($this->data['email']);
            $user->setUserFirstname($this->data['name']);
            $user->setUserLastname($this->data['surname']);
            $user->setUserAddress($this->data['houseNumber']);
            $user->setStreetCode($streetCode);
            $user->setTownCode($townCode);
            $user->setUserDob($this->data['dob']);
            $user->setMobile($this->data['mobile']);
            
            echo $user->profileUpdate();
        } catch (ValidationException $e) {
            sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
        } catch (ApiSecurityException $e) {
            sendResponse(["status" => "error", "message" => $e->getMessage()], $e->getCode());
            exit;
        }
    }
}

$controller = new ProfileUpdateController();
$controller->handle();
?>
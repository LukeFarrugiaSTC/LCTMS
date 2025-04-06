<?php
    require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
    require_once __DIR__ . '/../../classes/user.class.php';
    require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
    require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
    require_once __DIR__ . '/../../vendor/autoload.php';

    class GetClientDetailsController extends BaseApiController {
        public function handle() {
            try {
                // Validate API key if provided
                $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');
                // Validate required field(s)
                UserValidator::checkForRequiredFields($this->data,['email']);

                $user = new User();
                $user->setUserEmail($this->data['email']);

                $response = json_decode($user->getClientDetails(), true);
                sendResponse($response);
            } catch (ValidationException $e){
                sendResponse(
                    ["status" => "error", "message" => implode(',', $e->getErrors())]
                );
            } catch (ApiSecurityException $e){
                sendResponse(
                    ["status" => "error", "message" => $e->getMessage()],
                    $e->getCode()
                );
                exit;
            }
        }
    }

    $controller = new GetClientDetailsController();
    $controller->handle();

?>
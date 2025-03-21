<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/role.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';

class ReadRolesController extends BaseApiController {
    public function handle() {
        try {
            // Validate API key if provided
            $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');
            
            $role = new Role();
            echo $role->roleRead();
        } catch (ValidationException $e) {
            sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
        } catch (ApiSecurityException $e) {
            sendResponse(["status" => "error", "message" => $e->getMessage()], $e->getCode());
            exit;
        }
    }
}

$controller = new ReadRolesController();
$controller->handle();
?>
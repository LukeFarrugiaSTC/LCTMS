<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../classes/user.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
require_once __DIR__ . '/../../helpers/jwtHelper.php';
require_once __DIR__ . '/../../helpers/redisHelper.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../vendor/autoload.php';


use Helpers\JwtHelper;

class LoginController extends BaseApiController {
    public function handle() {
        try {
            // Validate input
            UserValidator::validateLogin($this->data);

            // Initialize the User and set credentials
            $user = new User();
            $user->setUserEmail($this->data['email']);
            $user->setUserPassword($this->data['password']);

            // Attempt login
            $response = $user->login();
            $responseData = json_decode($response, true);

            // Validate active user status
            UserValidator::isUserActive($responseData);

            if ($responseData['status'] === 'success') {
                $secretKey = getenv('JWT_KEY');
                if (!$secretKey) {
                    throw new Exception("Secret key is not set.");
                }
                // Generate JWT
                $jwtHelper = new JwtHelper($secretKey, 'HS256');
                $payload = [
                    'userId' => $responseData['userId'],
                    'roleId' => $responseData['roleId']
                ];
                $jwt = $jwtHelper->encodeToken($payload, 3600);

                // Store token in Redis
                $redisHelper = new RedisHelper();
                $redisHelper->storeAuthToken($responseData['userId'], $jwt, 3600);
                $responseData['token'] = $jwt;
            }

            sendResponse($responseData);
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
        } catch (Exception $e) {
            sendResponse(
                ["status" => "error", "message" => $e->getMessage()],
                500
            );
            exit;
        }
    }
}

$controller = new LoginController();
$controller->handle();
?>
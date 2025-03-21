<?php
require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
require_once __DIR__ . '/../../helpers/jwtHelper.php';
require_once __DIR__ . '/../../vendor/autoload.php';

use Helpers\JwtHelper;

class LogoutController extends BaseApiController {
    public function handle() {
        try {
            // Extract token from Authorization header
            $headers = apache_request_headers();
            if (!isset($headers['Authorization'])) {
                throw new Exception("Missing Authorization header.");
            }
            $authHeader = $headers['Authorization'];
            if (stripos($authHeader, 'Bearer ') !== 0) {
                throw new Exception("Invalid Authorization header format. Expected 'Bearer <token>'.");
            }
            $jwtToken = substr($authHeader, 7);

            $secretKey = getenv('JWT_KEY');
            if (!$secretKey) {
                throw new Exception("JWT_KEY is not set in environment variables.");
            }
            $jwtHelper = new JwtHelper($secretKey);
            $decoded = $jwtHelper->decodeToken($jwtToken);

            // Connect to Redis and remove token
            $redis = new Redis();
            $redis->connect('redis', 6379);
            if (!$redis->ping()) {
                throw new Exception("Could not connect to Redis.");
            }
            $redisKey = "auth_token:" . $decoded->userId;
            $storedToken = $redis->get($redisKey);

            if (!$storedToken) {
                sendResponse(
                    ["status" => "success", "message" => "You are already logged out."],
                    200
                );
                exit;
            }

            if ($storedToken === $jwtToken) {
                $redis->del($redisKey);
            }

            sendResponse(["status" => "success", "message" => "Logged out successfully."]);
        } catch (Exception $e) {
            sendResponse(
                ["status" => "error", "message" => $e->getMessage()],
                500
            );
            exit;
        }
    }
}

$controller = new LogoutController();
$controller->handle();
?>
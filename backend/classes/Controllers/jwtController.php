<?php
require_once __DIR__ . '/BaseApiController.php';
require_once __DIR__ . '/../../helpers/jwtHelper.php';
require_once __DIR__ . '/../../helpers/RedisHelper.php';

use Helpers\JwtHelper;

abstract class JwtController extends BaseApiController {
    protected $userId;
    protected $jwtToken;

    public function __construct() {
        parent::__construct();
        $this->authenticateJWT();
    }

    /**
     * Extracts the JWT from the request headers,
     * validates it using the secret key and Redis,
     * and sets the $userId property.
     *
     * @throws Exception if the JWT is missing, malformed, or invalid.
     */
    protected function authenticateJWT() {
        $headers = getallheaders();
        if (!isset($headers['Authorization'])) {
            throw new Exception("Missing Authorization header.");
        }
        $authHeader = $headers['Authorization'];
        if (stripos($authHeader, 'Bearer ') !== 0) {
            throw new Exception("Invalid Authorization header format. Expected 'Bearer <token>'.");
        }
        $this->jwtToken = substr($authHeader, 7);
        
        $secretKey = getenv('JWT_KEY');
        if (!$secretKey) {
            throw new Exception("JWT_KEY is not set in environment variables.");
        }
        
        $jwtHelper = new JwtHelper($secretKey, 'HS256');
        $decoded = $jwtHelper->decodeToken($this->jwtToken);
        $this->userId = $decoded->userId;
        
        $redisHelper = new RedisHelper();
        $storedToken = $redisHelper->getAuthToken($this->userId);
        if (!$storedToken || $storedToken !== $this->jwtToken) {
            throw new Exception("Token not found or mismatch in Redis (possibly revoked).");
        }
    }
}
?>
<?php
require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/rateLimitHelper.php';

class ApiSecurity {
    private $rateLimiter;

    public function __construct() {
        $this->rateLimiter = new RateLimiter(10, 60); 
    }

    function getClientIp() {
        if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            $ip = $_SERVER['HTTP_CLIENT_IP'];
        } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
        } else {
            $ip = $_SERVER['REMOTE_ADDR'];
        }
        return $ip;
    }

    public function rateLimiter() {
        $ip = $this->getClientIp();
        $rateLimitKey = "rate_limit:login:$ip";
        if (!$this->rateLimiter->limitRequest($rateLimitKey)) {
            http_response_code(429);
            echo json_encode(['error' => 'Too Many Requests']);
            return false;
        }
        return true;
    }

}
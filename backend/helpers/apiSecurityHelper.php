<?php

require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/rateLimitHelper.php';

class ApiSecurityException extends Exception {}

class ApiSecurity {
    private $rateLimiter;

    public function __construct() {
        $this->rateLimiter = new RateLimiter(10, 60); 
    }

    public function getClientIp() {
        if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            return $_SERVER['HTTP_CLIENT_IP'];
        } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            return $_SERVER['HTTP_X_FORWARDED_FOR'];
        } else {
            return $_SERVER['REMOTE_ADDR'];
        }
    }

    public function checkHttps() {
        $isSecure = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ||
                    (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https');
        if (!$isSecure) {
            throw new ApiSecurityException("HTTPS is required", 403);
        }
    }
    
    public function checkRequestMethod($expectedMethod = 'POST') {
        if ($_SERVER['REQUEST_METHOD'] !== $expectedMethod) {
            throw new ApiSecurityException("Invalid request method", 405);
        }
    }
    
    public function rateLimiter() {
        $ip = $this->getClientIp();
        $rateLimitKey = "rate_limit:login:$ip";
        if (!$this->rateLimiter->limitRequest($rateLimitKey)) {
            throw new ApiSecurityException("Too Many Requests", 429);
        }
    }
    
    public function getJsonInput() {
        $rawInput = file_get_contents('php://input');
        $data = json_decode($rawInput, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new ApiSecurityException("Malformed JSON input", 400);
        }
        return $data;
    }

    public function checkIfAPIKeyExistsAndIsValid(string $apiKey) {
        if (empty($apiKey)) {
            throw new ApiSecurityException("API Key is required", 403);
        }
        if(Utility::getMyApi_key() != $apiKey) {
            throw new ApiSecurityException("Invalid API Key", 403);
        } 
    }
}
<?php
namespace Helpers;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Firebase\JWT\ExpiredException;

class JwtHelper {
    protected $secretKey;
    protected $algorithm;

    public function __construct($secretKey, $algorithm = 'HS256'){
        $this->secretKey = $secretKey;
        $this->algorithm = $algorithm;
    }

    /**
     * Decodes and verifies a JWT token.
     *
     * @param string $jwtToken
     * @return object The decoded token payload.
     * @throws Exception if token is expired or invalid.
     */
    public function decodeToken($jwtToken) {
        try {
            $decoded = JWT::decode($jwtToken, new Key($this->secretKey, $this->algorithm));
            return $decoded;
        } catch(ExpiredException $e) {
            throw new \Exception("Token has expired.", 401);
        } catch(\Exception $e) {
            throw new \Exception("Invalid token.", 401);
        }
    }

    /**
     * Encodes a payload into a JWT token.
     *
     * @param array $payload
     * @param int $expirationTimeInSeconds Token expiration time from now.
     * @return string The encoded JWT token.
     */
    public function encodeToken($payload, $expirationTimeInSeconds = 3600) {
        $issuedAt = time();
        $expire = $issuedAt + $expirationTimeInSeconds;
        $payload['iat'] = $issuedAt;
        $payload['exp'] = $expire;
        return JWT::encode($payload, $this->secretKey, $this->algorithm);
    }
}
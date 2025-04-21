<?php
class RedisHelper {
    private $redis;

    public function __construct() {
        $this->redis = new Redis();
        $this->redis->connect('redis', 6379);
    
        // Authenticate with Redis using environment variable
        $redisPassword = getenv('REDIS_PASSWORD');
        if ($redisPassword && !$this->redis->auth($redisPassword)) {
            throw new Exception("Redis authentication failed");
        }
    
        // Verify the connection
        if (!$this->redis->ping()) {
            throw new Exception("Could not connect to Redis");
        }
    }

    /**
     * Stores the authentication token in Redis.
     *
     * @param int|string $userId
     * @param string $token
     * @param int $ttl Time to live in seconds.
     * @return bool True on success, false on failure.
     */
    public function storeAuthToken($userId, $token, $ttl = 3600) {
        $redisKey = "auth_token:" . $userId;
        $result = $this->redis->setex($redisKey, $ttl, $token);
        if (!$result) {
            error_log("Failed to add token to Redis");
        }
        return $result;
    }

    public function getAuthToken($userId) {
        $redisKey = "auth_token:" . $userId;
        $result = $this->redis->getex($redisKey);
        if (!$result) {
            error_log("Failed to retrieve token from Redis");
        }
        return $result;
    }
    
    /**
     * Stores a password reset PIN in Redis with a given TTL.
     *
     * @param string $email
     * @param mixed $pin
     * @param int $ttl Time to live in seconds.
     * @return bool
     */
    public function storeResetPin($email, $pin, $ttl = 600) {
        $redisKey = "reset_pin:" . $email;
        $result = $this->redis->setex($redisKey, $ttl, $pin);
        if (!$result) {
            error_log("Failed to store reset PIN in Redis");
        }
        return $result;
    }
    
    /**
     * Retrieves the password reset PIN for a given email.
     *
     * @param string $email
     * @return mixed
     */
    public function getResetPin($email) {
        $redisKey = "reset_pin:" . $email;
        return $this->redis->get($redisKey);
    }
    
    /**
     * Deletes the stored reset PIN for a given email.
     *
     * @param string $email
     * @return int Number of keys deleted.
     */
    public function deleteResetPin($email) {
        $redisKey = "reset_pin:" . $email;
        return $this->redis->del($redisKey);
    }
}
?>
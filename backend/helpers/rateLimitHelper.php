<?php
class RateLimiter {
    private $redis;
    private $maxRequests;
    private $perSeconds;

    public function __construct($maxRequests = 60, $perSeconds = 60) {
        $this->redis = new Redis();
        
        // Use the service name from docker-compose, not 127.0.0.1
        $redisHost = 'redis';  
        $redisPort = 6379;
        
        // Add connection timeout and retry
        $connectSuccess = false;
        $attempts = 0;
        $maxAttempts = 3;
        
        while (!$connectSuccess && $attempts < $maxAttempts) {
            try {
                $connectSuccess = $this->redis->connect($redisHost, $redisPort, 2.0); // 2 second timeout
                if ($connectSuccess) {
                    $redisPassword = getenv('REDIS_PASSWORD');
                    if ($redisPassword) {
                        $this->redis->auth($redisPassword);
                    }
                }
            } catch (Exception $e) {
                $attempts++;
                if ($attempts >= $maxAttempts) {
                    // Log error or handle gracefully
                    throw $e;
                }
                // Wait before retrying
                usleep(500000); // 500ms
            }
        }
        
        $this->maxRequests = $maxRequests;
        $this->perSeconds = $perSeconds;
    }
    
    public function limitRequest($key) {
        $current = $this->redis->get($key);
        if (!$current) {
            $this->redis->setex($key, $this->perSeconds, 1);
            return true;
        }

        if ($current >= $this->maxRequests) {
            return false;
        }

        $this->redis->incr($key);
        return true;
    }
}
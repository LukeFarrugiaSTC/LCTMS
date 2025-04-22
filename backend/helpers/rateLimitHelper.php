<?php
class RateLimiter {
    private $redis;
    private $maxRequests;
    private $perSeconds;

    public function __construct($maxRequests = 60, $perSeconds = 60) {
        $this->redis = new Redis();
        $this->redis->connect('redis', 6379);
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
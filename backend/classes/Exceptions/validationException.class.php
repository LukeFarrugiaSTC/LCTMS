<?php

class ValidationException extends Exception {
    protected $errors;
    
    public function __construct(array $errors, $code = 0) {
        parent::__construct("Validation failed", $code);
        $this->errors = $errors;
    }
    
    public function getErrors() {
        return $this->errors;
    }
}
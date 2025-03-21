<?php

require_once __DIR__ . '/../../helpers/apiSecurityHelper.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';

class BaseApiController {
    protected $apiSecurity;
    protected $data;

    public function __construct() {
        $this->apiSecurity = new ApiSecurity();
        $this->apiSecurity->checkHttps();
        $this->apiSecurity->checkRequestMethod('POST');
        $this->apiSecurity->rateLimiter();
        $this->data = $this->apiSecurity->getJsonInput();
    }

    protected function sendErrorResponse($message, $code = 400) {
        sendResponse(["status" => "error", "message" => $message], $code);
        exit;
    }
}
<?php 

ob_start();
    function sendResponse(array $data, int $statusCode = 200) {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        header('Cache-Control: no-store, no-cache, must-revalidate');
        echo json_encode($data, $statusCode);
        exit;
    }
ob_end_flush();

?>
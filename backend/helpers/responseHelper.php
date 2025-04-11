<?php
function sendResponse(array $data, int $statusCode = 200) {
    // Clear any output buffers to prevent data leakage
    while (ob_get_level()) {
        ob_end_clean();
    }
    
    // Start fresh output buffer
    ob_start();
    
    // Set HTTP status code
    http_response_code($statusCode);

    if (headers_sent($file, $line)) {
        error_log("Headers already sent in $file on line $line");
        // Still attempt to send the JSON data
        echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }
    
    // Set security headers
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('Pragma: no-cache');
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('X-XSS-Protection: 1; mode=block');
    header('Referrer-Policy: strict-origin-when-cross-origin');
    
    // Send JSON response with proper encoding
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    
    // Flush and end output buffer
    ob_end_flush();
    exit;
}
?>
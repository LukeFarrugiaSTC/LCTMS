<?php
/*
	 * **************************************************
	 * Class Name: 	profileRead
	 * Description: Handles user profile read
	 * Author: 		Andrew Mallia
	 * Date: 		2025-03-08
	 * **************************************************
	 */

     require_once __DIR__ . '/../../includes/config.php';
     require_once __DIR__ . '/../../classes/utility.class.php';
     require_once __DIR__ . '/../../classes/user.class.php';
     require_once __DIR__ . '/../../helpers/responseHelper.php';
     require_once __DIR__ . '/../../helpers/apiSecurityHelper.php';
     require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
     require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
     
    try {
        $apiSecurity = new ApiSecurity();
    
        // Perform all security checks
        $apiSecurity->checkHttps();
        $apiSecurity->checkRequestMethod('POST');
        $apiSecurity->rateLimiter();
        $data = $apiSecurity->getJsonInput();
        $apiSecurity->checkIfAPIKeyExistsAndIsValid($data['api_key']?? '');

        UserValidator::checkForRequiredFields($data, ['email']);

        $user = new User();
        $user->setUserEmail($data['email']);
        $response = $user->profileRead();
        sendResponse(['status' => 'successful', 'message' => $response]);

    } catch (ValidationException $e) {
        sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
    } catch (ApiSecurityException $e) {
        sendResponse(["status" => "error", "message" => $e->getMessage()], $e->getCode());
        exit;
    }

 ?>
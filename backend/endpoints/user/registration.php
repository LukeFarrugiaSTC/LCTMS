<?php
require_once __DIR__ . '/../../includes/config.php';
require_once __DIR__ . '/../../classes/utility.class.php';
require_once __DIR__ . '/../../classes/user.class.php';
require_once __DIR__ . '/../../classes/town.class.php';
require_once __DIR__ . '/../../classes/street.class.php';
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

    // Validate input
    UserValidator::validateRegistration($data);
    
    $user = new User();
    $town = new Town();
    $street = new Street();

    $user->setUserEmail($data['email']);
    $user->setUserFirstname($data['fname']);
    $user->setUserLastname($data['lname']);
    $user->setUserAddress($data['houseNumber']);

    $townCode = $town->getTownCodeFromTownName($data['townName']);
    $user->setTownCode($townCode);

    $streetCode = $street->getStreetCodeFromStreetName($data['streetName']);

    if($street->getTownCodeFromStreetCode($streetCode) != $townCode) {
        sendResponse(["status" => "error", "message" => "Invalid street name for town selected"], 400);
        exit;
    }

    $user->setStreetCode($streetCode);

    $user->setMobile($data['mobile']);
    $user->setUserDob($data['dob']);
    $user->setUserPassword($data['password']);
    $user->setUserConfirm($data['confirm']);

    // Call the registration method and decode its JSON response
    $response = json_decode($user->registration(), true);
    sendResponse($response);

    } catch (ValidationException $e) {
        sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
    } catch (ApiSecurityException $e) {
        sendResponse(["status" => "error", "message" => $e->getMessage()], $e->getCode());
        exit;
    } catch (Exception $e) {
        sendResponse(["status" => "error", "message" => "An unexpected error occurred. Please try again later."], 500);
    }

?>
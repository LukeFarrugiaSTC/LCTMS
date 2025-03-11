<?php
require_once __DIR__ . '/../../includes/config.php';
require_once __DIR__ . '/../../classes/utility.class.php';
require_once __DIR__ . '/../../classes/destination.class.php';
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
    $apiSecurity->checkIfAPIKeyExistsAndIsValid($data['api_key']?? '');


    // If API key is valid, fetch streets
    $destination = new Destination();
    $town = new Town();
    $street = new Street();

    $destination->setDestinationName($data['destinationName']);

    $townCode = $town->getTownCodeFromTownName($data['townName']);
    $destination->setTownCode($townCode);

    $streetCode = $street->getStreetCodeFromStreetName($data['streetName']);

    if($street->getTownCodeFromStreetCode($streetCode) != $townCode) {
        sendResponse(["status" => "error", "message" => "Invalid street name for town selected"], 400);
        exit;
    }

    $destination->setStreetCode($streetCode);

    $response = json_decode($destination->addDestination(), true);
    sendResponse(['status' => "success", "data" => 'Destination added successfully.'], 201);

    } catch (ValidationException $e) {
        sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
    } catch (ApiSecurityException $e) {
        sendResponse(["status" => "error", "message" => $e->getMessage()], $e->getCode());
        exit;
    }
?>
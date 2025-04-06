<?php
    require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
    require_once __DIR__ . '/../../classes/user.class.php';
    require_once __DIR__ . '/../../classes/street.class.php';
    require_once __DIR__ . '/../../classes/town.class.php';
    require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
    require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
    require_once __DIR__ . '/../../vendor/autoload.php';

    class CreateClientController extends BaseApiController {
        public function handle() {
            try {
                // Validate API Key
                $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');
                
                // Validate required field(s)
                UserValidator::checkForRequiredFields($this->data,[
                    'email',
                    'firstname',
                    'lastname',
                    'address',
                    'streetName',
                    'townName'
                ]);

                // Get street and town code from names
                $street = new Street();

                $streetCode = $street->getStreetCodeFromStreetName($this->data['streetName']);
                if(!$streetCode){
                    sendResponse(["status" => "error", "message" => "Invalid street name provided."]);
                    exit;
                }

                // Get townCode from streetCode
                $townCode = $street->getTownCodeFromStreetCode($streetCode);
                if (!$townCode) {
                    sendResponse(["status" => "error", "message" => "Unable to retrieve town code for the street"], 400);
                    exit;
                }
                
                // Validate the townName passed from the app matches the street's townCode (optional, extra safety)
                //$townNameFromRequest = strtolower(trim($this->data['townName']));
                //$actualTownName = strtolower(trim($street->getTownNameFromStreetCode($streetCode)));

                // if ($townNameFromRequest !== $actualTownName) {
                //     sendResponse(["status" => "error", "message" => "Invalid street name for the selected town"], 400);
                //     exit;
                // }

                // Initialize User object
                $user = new User();
                $user->setUserEmail($this->data['email']);
                $user->setUserFirstname($this->data['firstname']);
                $user->setUserLastname($this->data['lastname']);
                $user->setUserAddress($this->data['address']);
                $user->setStreetCode($streetCode);
                $user->setTownCode($townCode);
                $user->setMobile($this->data['mobile']);            

                // Handle optional fields
                if (!empty($this->data['mobile'])) {
                    $user->setMobile($this->data['mobile']);
                } else {
                    $user->setMobile(null);
                }

                if (!empty($this->data['dob'])) {
                    $user->setUserDob($this->data['dob']);
                }

                // Create the new client
                $response = json_decode($user->createNewClient(), true);

                if ($response['status'] === 'success') {
                    sendResponse([
                        'status' => 'success',
                        'message' => 'Client created successfully.',
                        'clientId' => $response['clientId']
                    ]);
                } else {
                    sendResponse([
                        'status' => 'error',
                        'message' => $response['message']
                    ]);
                }

            } catch (ValidationException $e) {
                sendResponse([
                    'status' => 'error',
                    'message' => implode(', ', $e->getErrors())
                ]);
            } catch (ApiSecurityException $e) {
                sendResponse([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ], $e->getCode());
                exit;
            } catch (Exception $e) {
                sendResponse([
                    'status' => 'error',
                    'message' => 'Unexpected Error: ' . $e->getMessage()
                ]);
            }
        }
    }

        // Instantiate and handle request
        $controller = new CreateClientController();
        $controller->handle();
?>

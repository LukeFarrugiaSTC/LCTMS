<?php
    header('Content-Type: application/json');
    
    require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
    require_once __DIR__ . '/../../classes/userBookings.class.php';
    require_once __DIR__ . '/../../classes/validators/bookingValidator.class.php';
    require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
    require_once __DIR__ . '/../../classes/destination.class.php';
    require_once __DIR__ . '/../../vendor/autoload.php';

    // =================================================================================
    // API Request Format (for Flutter Developer)
    //
    // @ POST    api_key            => "api_key_here"
    // @ POST    clientEmail        => "andrew.mallia2@micas.art"
    // @ POST    destinationName    => "Mater Dei Hospital"
    // @ POST    bookingDateTime    => "2025-04-12 10:00:00"
    // @ POST    userId             => "5"
    //
    // Notes:
    // - bookingDateTime must be in 'YYYY-MM-DD HH:MM:SS' format.
    //
    // Example:
    // POST https://localhost:443/endpoints/bookings/addBookingR2.php
    // ================================================================================== 

    class AddBookingController extends BaseApiController {
        public function handle() {
            try {
                // Step 1: Validate the API Key
                $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');

                // Step 2: Validate required fields
                BookingValidator::checkForRequiredFields($this->data, [
                    'clientEmail',
                    'destinationName',
                    'bookingDateTime',
                    'userId'
                ]);

                // Step 3: Initialize classes
                $destination = new Destination();
                $userBooking = new UserBookings();

                // ============================================================================
                // Step 4: Resolve userId from clientEmail
                // ============================================================================
                $clientId = $userBooking->getUserIdFromUserEmail($this->data['clientEmail']);
                if (!$clientId) {
                    sendResponse(['status' => "error", "message" => "Invalid client email provided."], 400);
                    exit;
                }
                $userEmail = $userBooking->getUserEmailFromUserID($this->data['userId']); 
                if (!$userEmail){
                    sendResponse(['status' => "error", "message" => "Invalid user ID provided."], 400);
                    exit;
                }

                // ============================================================================
                // Step 5: Resolve destinationId from destinationName
                // ============================================================================                
                $destinationName = $this->data['destinationName'];
                $destinationId = $destination->getDestinationIdFromDestinationName($destinationName);

                if (!$destinationId){
                    sendResponse(['status' => "error", "message" => "Invalid destination name provided."], 400);
                    exit;
                }

                // Step 5:  Check if booking time is full (maximum 8 bookings for the same datetime)
                $bookingDateTime = $this->data['bookingDateTime'];

                if ($userBooking->checkIfBookingSlotIsFull($bookingDateTime)){
                    sendResponse([
                        "status" => "error",
                        "message" => "Selected time is fully booked."
                    ], 400);
                }

                // Step 6: Add the booking
                $result = $userBooking->addUserBooking(
                    $clientId,
                    $destinationId,
                    $bookingDateTime,
                    $this->data['userId'],
                    $userEmail
                );

                if ($result === true){
                    sendResponse([
                        "status" => "success", 
                        "message" => "booking created successfully",
                        "bookingDateTime" => $bookingDateTime,
                        "destinationName" => $destinationName
                    ]); 
                } else {
                    sendResponse([
                        "status" => "error",
                        "message" => "Booking could not be created."
                    ]);
                }
            } catch (ValidationException $e){
                sendResponse([
                    "status" => "error",
                    "message" => implode(', ',$e->getErrors())
                ]);
            } catch (ApiSecurityException $e) {
                sendResponse([
                    "status" => "error",
                    "message" => $e->getMessage()
                ], $e->getCode());
            } catch (Exception $e){
                sendResponse([
                    "status" => "error",
                    "message" => "Unexpected Error: ".$e->getMessage()
                ]);
            }
        }
    }

    // Instatiate and handle request
    $controller = new AddBookingController();
    $controller->handle();
?>
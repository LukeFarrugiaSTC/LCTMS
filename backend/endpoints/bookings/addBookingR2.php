<?php
    require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
    require_once __DIR__ . '/../../classes/userBookings.class.php';
    require_once __DIR__ . '/../../classes/validators/bookingValidator.class.php';
    require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
    require_once __DIR__ . '/../../classes/destination.class.php';
    require_once __DIR__ . '/../../vendor/autoload.php';

    class AddBookingController extends BaseApiController {
        public function handle() {
            try {
                // Step 1: Validate the API Key
                $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');

                // Step 2: Validate required fields
                BookingValidator::checkForRequiredFields($this->data, [
                    'clientId',
                    'destinationName',
                    'bookingDateTime',
                    'userId'
                ]);

                // Step 3: Initialize classes
                $destination = new Destination();
                $userBooking = new UserBookings();

                // Step 4: Resolve destinationId from destinationName
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
                    $this->data['clientId'],
                    $destinationId,
                    $bookingDateTime,
                    $this->data['userId']
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
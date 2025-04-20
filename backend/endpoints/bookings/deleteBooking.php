<?php
    /*
    * **************************************
    * Filename:    deleteBooking.php
    * Author:      Andrew Mallia
    * Date:        2025-03-31
    * Description: Delete a booking
    * **************************************
    */ 
    require_once __DIR__ . '/../../classes/Controllers/JwtController.php';  
    require_once __DIR__ . '/../../classes/userBookings.class.php';
    require_once __DIR__ . '/../../helpers/responseHelper.php';
    require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
    require_once __DIR__ . '/../../classes/validators/bookingValidator.class.php';
    require_once __DIR__ . '/../../vendor/autoload.php';

    // =================================================================
    // API Request Format (for Flutter Developer)
    //
    // @ POST    api_key            => "api_key_here"
    // @ POST    userId             => "6"
    // @ POST    clientEmail        => "andrew.mallia@micas.art"
    // @ POST    bookingId          => "24"
    // @ POST    bookingStatus      => "confirmed"
    //
    // Notes:
    // - userId is the clientId of the person who made the request.
    //
    // Example:
    // POST https://localhost:443/endpoints/bookings/deleteBooking.php
    // =================================================================

    class DeleteBookingController extends JwtController {
        public function handle() {
            try {
                // Check the API Key is valid and exists
                $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');

                $data = $this->data; // Being handled by BaseApiController

                // Validate the request data
                BookingValidator::validateBookingDeleteR2($data);

                // Get userId of the clientEmail provided
                $booking    = new UserBookings();    
                $clientId   = $booking->getUserIdFromUserEmail($data['clientEmail']);

                if (!$clientId) {
                    sendResponse(['status' => "error", "message" => "Invalid client email provided."], 400);
                    return;
                }
                
                $wasDeleted = $booking->deleteUserBooking($clientId, $data['bookingId']);

                if ($wasDeleted) {
                    $response = [
                        "status"  => "success",
                        "message" => "Booking deleted successfully"
                    ];
                } else {
                    $response = [
                        "status"  => "error",
                        "message" => "No booking found for the given client and booking ID."
                    ];
                }
                
                sendResponse($response);

            } catch (ValidationException $e) {
                sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
            } catch (Exception $e) {
                sendResponse(["status" => "error", "message" => $e->getMessage()], 500);
            }
        }
    }

    $controller = new DeleteBookingController();
    $controller->handle();

?>



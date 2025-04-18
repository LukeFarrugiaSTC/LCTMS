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

    // =================================================================================
    // API Request Format (for Flutter Developer)
    //
    // @ POST    api_key            => "api_key_here"
    // @ POST    userId             => "6"
    // @ POST    clientId           => "6"
    // @ POST    bookingId          => "24"
    //
    // Notes:
    // - userId is the clientId of the person who made the request.
    //
    // Example:
    // POST https://localhost:443/endpoints/bookings/deleteBooking.php
    // ================================================================================== 

    class DeleteBookingController extends JwtController {
        public function handle() {
            try {
                $data = $this->data; // Being handled by BaseApiController
                
                BookingValidator::validateBookingDeleteR2($data);

                // Proceed with deleting the booking
                $booking = new UserBookings();
                $booking->deleteUserBooking($data['bookingId'], $data['clientId']);

                $response = [
                    "status"  => "success",
                    "message" => "Booking deleted successfully"
                ];
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



<?php
    /* **************************************
     * Filename:    updateBookingStatus.php
     * Author:      Andrew Mallia 
     * Date:        2025-03-30
     * Description: Update booking details
     * ************************************** 
     */
    require_once __DIR__ . '/../../classes/Controllers/JwtController.php';
    require_once __DIR__ . '/../../classes/userBookings.class.php';
    require_once __DIR__ . '/../../helpers/responseHelper.php';
    require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
    require_once __DIR__ . '/../../classes/validators/bookingValidator.class.php';
    require_once __DIR__ . '/../../vendor/autoload.php';

    class UpdateBookingController extends JwtController {
        public function handle() {
            try {

                $data = $this->data;
                
                BookingValidator::validateBookingUpdateStatus($data);
                
                // Proceed with updating the booking status
                $booking = new UserBookings();
                $booking->updateBookingStatusR2(
                    $data['bookingId'], 
                    $data['bookingStatus'], 
                    $data['userId']);

                $response = [
                    "status"  => "success",
                    "message" => "Booking updated successfully"
                ];
                sendResponse($response);

            } catch (ValidationException $e) {
                sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
            } catch (Exception $e) {
                sendResponse(["status" => "error", "message" => $e->getMessage()], 500);
            }
        }
    }

    $controller = new UpdateBookingController();
    $controller->handle();

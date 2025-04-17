<?php
require_once __DIR__ . '/../../classes/Controllers/JwtController.php';
require_once __DIR__ . '/../../classes/userBookings.class.php';
require_once __DIR__ . '/../../classes/destination.class.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../classes/validators/bookingValidator.class.php';
require_once __DIR__ . '/../../vendor/autoload.php';

class AddUserBookingController extends JwtController {
    public function handle() {
        try {
            $data = $this->data;

            // 1. Validate the required fields
            BookingValidator::validateBookingAddR2($data);
            
            // 2. Resolve the destination ID from the destination name
            $destination = new Destination();
            $destinationId = $destination->getDestinationIdFromDestinationName($data['destinationName']);
            if (!$destinationId) {
                throw new Exception("Invalid destination name.");
            }
            
            // 3. Add the booking
            $userBookings = new UserBookings();
            $userBookings->addUserBooking($data['clientId'], $destinationId, $data['bookingDateTime'],$data['userId']);
            
            $response = [
                "status"  => "success",
                "message" => "Booking added successfully",
                "userId"  => $this->userId
            ];
            sendResponse($response);
        } catch (ValidationException $e) {
            sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
        } catch (Exception $e) {
            sendResponse(["status" => "error", "message" => $e->getMessage()], 500);
            exit;
        }
    }
}

$controller = new AddUserBookingController();
$controller->handle();
?>
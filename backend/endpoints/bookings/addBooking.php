<?php
require_once __DIR__ . '/../../classes/Controllers/JwtController.php';
require_once __DIR__ . '/../../classes/userBookings.class.php';
require_once __DIR__ . '/../../classes/destination.class.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';
require_once __DIR__ . '/../../vendor/autoload.php';

class AddUserBookingController extends JwtController {
    public function handle() {
        try {
            $data = $this->data;
            
            if (!isset($data['destinationName']) || !isset($data['bookingDateTime'])) {
                throw new Exception("Missing required booking data.");
            }
            
            $destination = new Destination();
            $destinationId = $destination->getDestinationIdFromDestinationName($data['destinationName']);
            if (!$destinationId) {
                throw new Exception("Invalid destination name.");
            }
            
            $userBookings = new UserBookings();
            $userBookings->addUserBooking($this->userId, $destinationId, $data['bookingDateTime'] ?? date('Y-m-d'));
            
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
<?php
require_once __DIR__ . '/../../classes/Controllers/JwtController.php';
require_once __DIR__ . '/../../classes/userBookings.class.php';
require_once __DIR__ . '/../../helpers/responseHelper.php';
require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
require_once __DIR__ . '/../../classes/validators/userValidator.class.php';

class GetUserBookingsController extends JwtController {
    public function handle() {
        try {
            // Retrieve the user's bookings using the authenticated $userId
            $userBookings = new UserBookings();
            $bookings = $userBookings->getUserBookingsByUserId($this->userId);

            $response = [
                "status"  => "success",
                "message" => "User bookings retrieved successfully",
                "userId"  => $this->userId,
                "bookings"=> $bookings
            ];
            sendResponse($response);
        } catch (ValidationException $e) {
            sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
        } catch (Exception $e) {
            sendResponse(["status" => "error", "message" => $e->getMessage()], 500);
        }
    }
}

$controller = new GetUserBookingsController();
$controller->handle();
?>
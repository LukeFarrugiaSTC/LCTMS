<?php
    require_once __DIR__ . '/../../classes/Controllers/JwtController.php';
    require_once __DIR__ . '/../../classes/userBookings.class.php';
    require_once __DIR__ . '/../../helpers/responseHelper.php';
    require_once __DIR__ . '/../../classes/Exceptions/validationException.class.php';
    require_once __DIR__ . '/../../classes/validators/userValidator.class.php'; 
    require_once __DIR__ . '/../../vendor/autoload.php';

    // =================================================================================
    // API Request Format (for Flutter Developer)
    //
    // @ POST    api_key        => "api_key_here" 
    // @ POST    userId         => "5"
    // @ POST    clientId       => "5"
    //
    // Notes:
    // - startDate must be in 'YYYY-MM-DD' format.
    //
    // Example: 
    // POST https://localhost:443/endpoints/bookings/getUsersBookings.php
    // ================================================================================== 

    class GetUserBookingsController extends JwtController {
        public function handle() {
            try {
                // Retrieve the user's bookings using the authenticated $userId
                $userBookings = new UserBookings();
                $bookings = $userBookings->getUserBookingsByUserId($this->userId);
                
                $formattedBookings = [];
                foreach ($bookings as $booking) {
                    $formattedBookings[] = [
                        'booking_id'        => $booking['booking_id'],
                        'destinationName'   => $booking['destination_name'],
                        'bookingDate'       => $booking['bookingDate'],
                        'bookingStatus'     => $booking['bookingStatus']
                    ];
                }
                $response = [
                    "status"  => "success",
                    "message" => "User bookings retrieved successfully",
                    "userId"  => $this->userId,
                    "bookings"=> $formattedBookings
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
<?php
    require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
    require_once __DIR__ . '/../../classes/userBookings.class.php';
    require_once __DIR__ . '/../../vendor/autoload.php';

    // =================================================================================
    // API Request Format (for Flutter Developer)
    //
    // @ POST    api_key            => "api_key_here"
    // @ POST    date               => "2025-04-20"
    //
    // Notes:
    // - date MUST be greater than or equal to today's date.
    //
    // Example:
    // POST https://localhost:443/endpoints/bookings/getAvailableTimes.php
    // ================================================================================== 

    class GetAvailableTimesController extends BaseApiController {
        public function handle() {
            try {
                // Step 1: Validate API Key
                $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');

                // Step 2: Validate required 'date' field
                if (empty($this->data['date'])){
                    sendResponse([
                        "status" => "error",
                        "message" => "Date is required."
                    ], 400);
                    exit;
                }
                $selectedDate = $this->data['date'];

                // Step 3: Validate that selected date is today or in the future
                $today= date('Y-m-d');
                if ($selectedDate < $today) {
                    sendResponse([
                        "status" => "error",
                        "message" => "Booking date cannot be in the past."
                    ], 400);
                    exit;
                }

                // Step 4: Use userBookings class to get counts
                $userBooking = new UserBookings();
                $bookingCounts = $userBooking->getBookingCountsForDate($selectedDate);

                sendResponse($bookingCounts);

            } catch(ApiSecurityException $e) {
                sendResponse([
                    "status" => "error",
                    "message" => $e->getMessage()
                ], $e->getCode());
            } catch(Exception $e){
                sendResponse([
                    "status" => "error",
                    "message" => "Unexpected Error: ".$e->getMessage()
                ]);
            }
        }
    }

    // Instantiate and handle the request
    $controller = new GetAvailableTimesController();
    $controller->handle(); 

?>
<?php
    require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
    require_once __DIR__ . '/../../classes/userBookings.class.php';
    require_once __DIR__ . '/../../classes/destination.class.php';
    require_once __DIR__ . '/../../vendor/autoload.php';

    // =================================================================================
    // API Request Format (for Flutter Developer)
    //
    // @ POST    api_key       => "api_key_here"
    // @ POST    startDate     => "2025-04-12"
    // @ GET     ?export       => csv [optional]
    //
    // Notes:
    // - startDate must be in 'YYYY-MM-DD' format.
    // - startDate cannot be in the past.
    // - export=csv is optional, returns CSV file if set. 
    //
    // Example:
    // POST https://localhost:443/endpoints/bookings/getConfirmedBookings.php
    // POST https://localhost:443/endpoints/bookings/getConfirmedBookings.php?export=csv
    // ================================================================================== 

    class GetConfirmedBookings extends BaseApiController
    {
        public function handle(){
            try {
                // Step 1: Validate the API Key
                $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');

                // Step 2: Analyze $_POST data
                $startDateRaw = $this->data['startDate'] ?? null;
                $export = $_GET['export'] ?? null; // Check if export is set in the query string

                $startDate = $startDateRaw ? date ('Y-m-d', strtotime($startDateRaw)) : null;

                // Step 3: Validate date and status
                $today = date('Y-m-d');
                if ($startDate < $today) {
                    sendResponse([
                        "status" => "error",
                        "message" => "Start date cannot be in the past."
                    ], 400);
                    exit;
                }

                // Step 5: Query data
                $userBookings = new UserBookings();
                $pdo = $userBookings->conn;

                // Step 6: Prepare and execute the query
                $sql = "
                    SELECT 
                        b.booking_id,
                        b.clientId,
                        a.userEmail,
                        a.userFirstname,
                        a.userLastname,
                        a.userAddress,
                        d.streetName,
                        e.townName,
                        b.bookingDate,
                        b.destinationId,
                        c.destination_name
                    FROM 
                        bookings b
                    LEFT JOIN 
                        destinations AS c ON c.destinationId = b.destinationId
                    LEFT JOIN
                        users AS a ON a.id = b.clientId
                    LEFT JOIN
                        streets AS d ON d.streetCode = a.streetCode
                    LEFT JOIN
                        towns AS e ON e.townCode = d.townCode
                    WHERE 
                        DATE(b.bookingDate) = ?
                        AND b.bookingStatus = 'confirmed'
                    ORDER BY 
                        b.bookingDate ASC
                ";
           
                $stmt = $pdo->prepare($sql);
                $stmt->execute([$startDate]);

                // Step 7: Fetch and return the results
                $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

                // Step 8: Export to CSV if requested
                if ($export === 'csv'){
                    header('content-Type: text/csv');
                    header('content-Disposition: attachment; filename=bookings.csv');
                    $fp = fopen('php://output', 'w');

                    // Out the column headings
                    fputcsv($fp, [
                        'Booking ID',
                        'Client ID',
                        'User Email',
                        'User First Name',
                        'User Last Name',
                        'User Address',
                        'Street Name',
                        'Town Name',
                        'Booking Date',
                        'Destination ID',
                        'Destination Name'
                    ]);
                
                    foreach ($bookings as $row) {
                        fputcsv($fp, $row);
                    }
                    exit;
                }

                // Step 9: Send the response
                sendResponse([
                    "status" => "success",
                    "data" => $bookings
                ]);
            } catch (ApiSecurityException $e) {
                sendResponse([
                    "status" => "error",
                    "message" => "API Security error: " . $e->getMessage()
                ], 403);
            } catch (PDOException $e) {
            sendResponse([
                "status" => "error",
                "message" => "Database error: " . $e->getMessage()
            ], 500);
            } catch (ValidationException $e) {
            sendResponse([
                "status" => "error",
                "message" => "Validation error: " . implode(", ", $e->getErrors())
            ], 400);
            } catch (Exception $e) {
                sendResponse([
                    "status" => "error",
                    "message" => "An unexpected error occurred: " . $e->getMessage()
                ], 500);
                exit;
            }
        }
    }

    $controller = new GetConfirmedBookings();
    $controller->handle();
?>
   
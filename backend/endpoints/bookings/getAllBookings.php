<?php
    require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
    require_once __DIR__ . '/../../classes/userBookings.class.php';
    require_once __DIR__ . '/../../classes/destination.class.php';
    require_once __DIR__ . '/../../vendor/autoload.php';

    // =================================================================================
    // API Request Format (for Flutter Developer)
    //
    // @ POST    api_key       => "api_key_here"
    // @ GET     ?export       => csv [optional]
    //
    // Notes:
    // - export=csv is optional, returns CSV file if set. 
    //
    // Example:
    // POST https://localhost:443/endpoints/bookings/getAllBookings.php
    // POST https://localhost:443/endpoints/bookings/getAllBookings.php?export=csv
    // ================================================================================== 

    class GetAllBookings extends BaseApiController
    {
        public function handle(){
            try {
                // Step 1: Validate the API Key
                $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');

                // Step 2: Check if export parameter is set
                $export = isset($_GET['export']) ? $_GET['export'] : null;

                // Step 2: Query data
                $userBookings = new UserBookings();
                $pdo = $userBookings->conn;

                // Step 3: Prepare and execute the query
                $sql = "
                    SELECT 
                        b.booking_id,
                        b.bookingStatus,
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
                    ORDER BY 
                        b.bookingDate ASC
                ";
           
                $stmt = $pdo->prepare($sql);
                $stmt->execute([]);

                // Step 4: Fetch and return the results
                $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

                // Step 5: Export to CSV if requested
                if ($export === 'csv'){
                    header('content-Type: text/csv');
                    header('content-Disposition: attachment; filename=bookings.csv');
                    $fp = fopen('php://output', 'w');

                    // Out the column headings
                    fputcsv($fp, [
                        'Booking ID',
                        'Status',
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

                // Step 6: Send the response
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

    $controller = new GetAllBookings();
    $controller->handle();
?>
   
<?php
    require_once __DIR__ . '/../../classes/Controllers/BaseApiController.php';
    require_once __DIR__ . '/../../classes/userBookings.class.php';
    require_once __DIR__ . '/../../classes/destination.class.php';
    require_once __DIR__ . '/../../vendor/autoload.php'; 

    class GetCompletedRidesReportController extends BaseApiController {
        public function handle() {
            try {
                // Step 1: Validate the API Key
                $this->apiSecurity->checkIfAPIKeyExistsAndIsValid($this->data['api_key'] ?? '');

                // Step 2: Prepare optional filters
                $startDateRaw = $this->data['startDate'] ?? null;
                $endDateRaw = $this->data['endDate'] ?? null;
                $export = $_GET['export'] ?? null; // Check if export is set in the query string

                $startDate = $startDateRaw ? date('Y-m-d', strtotime($startDateRaw)) : null;
                $endDate = $endDateRaw ? date('Y-m-d', strtotime($endDateRaw)) : null;

                // Step 3: Validate dates (if provided)
                $today = date('Y-m-d');
                if ($startDate && $startDate > $today) {
                    sendResponse([
                        "status" => "error",
                        "message" => "Start date cannot be in the future."
                    ], 400);
                    exit;
                }
                if ($endDate && $endDate < $today) {
                    sendResponse([
                        "status" => "error",
                        "message" => "End date cannot be in the future."
                    ], 400);
                    exit;
                }

                // Step 4: Query data
                $userBooking = new UserBookings();
                $pdo = $userBooking->conn;

                // Build SQL 
                $conditions = ["b.bookingStatus = 'completed'"];
                $params = [];
                
                if (!empty($startDate)) {
                    $conditions[] = "DATE(b.bookingDate) >= ?";
                    $params[] = $startDate;
                }
                
                if (!empty($endDate)) {
                    $conditions[] = "DATE(b.bookingDate) <= ?";
                    $params[] = $endDate;
                }
                
                $sql = "
                    SELECT 
                        DATE(b.bookingDate) AS rideDate,
                        d.destination_name AS destination,
                        COUNT(*) AS completedRides,
                        COUNT(b.clientId) AS totalPassengers
                    FROM bookings AS b
                    LEFT JOIN destinations AS d ON b.destinationId = d.destinationId
                    WHERE " . implode(' AND ', $conditions) . "
                    GROUP BY rideDate, d.destination_name
                    ORDER BY rideDate DESC
                ";               

                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                $reportData = $stmt->fetchAll(PDO::FETCH_ASSOC);

                // Step 5: Export to CSV if requested
                if ($export === 'csv'){
                    header('Content-Type: text/csv');
                    header('Content-Disposition: attachment; filename="completed_rides_report.csv"');
                    $output = fopen('php://output', 'w');

                    // Output the column headings
                    fputcsv($output, ['Ride Date', 'Destination', 'Completed Rides', 'Total Passengers']);

                    // Output the data
                    foreach ($reportData as $row) {
                        fputcsv($output, [
                            $row['rideDate'],
                            $row['destination'],
                            $row['completedRides'],
                            $row['totalPassengers']
                        ]);
                    }
                    fclose($output);
                    exit;
                } 

                // Step 6: Return normal JSON response
                sendResponse([
                    "status" => "success",
                    "data" => $reportData
                ]);

            } catch (ApiSecurityException $e) {
                sendResponse([
                    "status" => "error",
                    "message" => $e->getMessage()
                ], 403);
            } catch (Exception $e) {
                sendResponse([
                    "status" => "error",
                    "message" => $e->getMessage()
                ], 500);
                exit;
            }
        }
    }

    $controller = new GetCompletedRidesReportController();
    $controller->handle();
?>
<?php

require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/utility.class.php';
 
class UserBookings {
    private $_clientId;
    private $_userId;
    private $_destinationId;
    private $_bookingId;
    private $_bookingDetails;
    private $_bookingStatus;
    private $_bookingDate;
    public $conn;
 
    public function __construct() {
        $this->conn = Dbh::getInstance()->getConnection();
    }
 
    // Getters and Setters
    public function setBookingId($var)       { $this->_bookingId = $var; }
    public function setClientId($var)       { $this->_clientId = $var; }
    public function setUserId($var)         { $this->_userId = $var; }
    public function setDestinationId($var)  { $this->_destinationId = $var; }
    public function setBookingDetails($var) { $this->_bookingDetails = $var; }
    public function setBookingStatus($var)  { $this->_bookingStatus = $var; }
    public function setBookingDate($var)    { $this->_bookingDate = $var; }
 
    public function getBookingId()           { return $this->_bookingId; }
    public function getClientId()           { return $this->_clientId; }
    public function getUserId()             { return $this->_userId; }
    public function getDestinationId()      { return $this->_destinationId; }
    public function getBookingDetails()     { return $this->_bookingDetails; }
    public function getBookingStatus()      { return $this->_bookingStatus; }
    public function getBookingDate()        { return $this->_bookingDate; }
 
    /**
     * Retrieve all bookings for a specific user.
     */
    public function getUserBookingsByUserId($userId) {
        try {
            $stmt = $this->conn->prepare("
                SELECT 
                  b.booking_id, 
                  b.userId, 
                  b.destinationId, 
                  b.bookingStatus, 
                  b.bookingDate,
                  u.userFirstname AS name,
                  u.userLastname AS surname,
                  u.userAddress AS pickupHouse,
                  ps.streetName AS pickupStreet,
                  pt.townName AS pickupTown,
                  d.destination_name,
                  ds.streetName AS dropoffStreet,
                  dt.townName AS dropoffTown
                FROM bookings b
                JOIN users u ON b.userId = u.id
                JOIN destinations d ON b.destinationId = d.destinationId
                LEFT JOIN streets ps ON u.streetCode = ps.streetCode
                LEFT JOIN towns pt ON u.townCode = pt.townCode
                LEFT JOIN streets ds ON d.streetCode = ds.streetCode
                LEFT JOIN towns dt ON d.townCode = dt.townCode
                WHERE b.userId = ?
                ORDER BY b.bookingDate ASC
            ");
            $stmt->execute([$userId]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            echo "Error: " . $e->getMessage();
        }
    }
 
    public function getUserUpcomingBookings($userId) {
        try {
            $currentDateTime = date('Y-m-d H:i:s');
            $stmt = $this->conn->prepare("
                SELECT 
                  b.booking_id, 
                  b.userId, 
                  b.destinationId, 
                  b.bookingStatus, 
                  b.bookingDate,
                  u.userFirstname AS name,
                  u.userLastname AS surname,
                  u.userAddress AS pickupHouse,
                  ps.streetName AS pickupStreet,
                  pt.townName AS pickupTown,
                  d.destination_name,
                  ds.streetName AS dropoffStreet,
                  dt.townName AS dropoffTown
                FROM bookings b
                JOIN users u ON b.userId = u.id
                JOIN destinations d ON b.destinationId = d.destinationId
                LEFT JOIN streets ps ON u.streetCode = ps.streetCode
                LEFT JOIN towns pt ON u.townCode = pt.townCode
                LEFT JOIN streets ds ON d.streetCode = ds.streetCode
                LEFT JOIN towns dt ON d.townCode = dt.townCode
                WHERE b.userId = ? 
                  AND b.bookingDate > ? 
                  AND b.bookingStatus != 'completed'
                ORDER BY b.bookingDate ASC
            ");
            $stmt->execute([$userId, $currentDateTime]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            echo "Error: " . $e->getMessage();
        }
    }
    
    public function getUserPastBookings($userId) {
        try {
            $currentDateTime = date('Y-m-d H:i:s');
            $stmt = $this->conn->prepare("
                SELECT 
                  b.booking_id, 
                  b.userId, 
                  b.destinationId, 
                  b.bookingStatus, 
                  b.bookingDate,
                  u.userFirstname AS name,
                  u.userLastname AS surname,
                  u.userAddress AS pickupHouse,
                  ps.streetName AS pickupStreet,
                  pt.townName AS pickupTown,
                  d.destination_name,
                  ds.streetName AS dropoffStreet,
                  dt.townName AS dropoffTown
                FROM bookings b
                JOIN users u ON b.userId = u.id
                JOIN destinations d ON b.destinationId = d.destinationId
                LEFT JOIN streets ps ON u.streetCode = ps.streetCode
                LEFT JOIN towns pt ON u.townCode = pt.townCode
                LEFT JOIN streets ds ON d.streetCode = ds.streetCode
                LEFT JOIN towns dt ON d.townCode = dt.townCode
                WHERE b.userId = ? 
                  AND (b.bookingDate < ? OR b.bookingStatus = 'completed')
                ORDER BY b.bookingDate DESC
            ");
            $stmt->execute([$userId, $currentDateTime]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            echo "Error: " . $e->getMessage();
        }
    }

    /* **********************************************************************************
     * Update the status of a booking.
     * 
     * @param int $bookingId        - The ID of the booking to update.
     * @param string $bookingStatus - The new status of the booking.
     * @param int $userId           - The ID of the user making the update.
     * @return bool                 - True if the update was successful, false otherwise.
     * **********************************************************************************/    
    public function updateBookingStatusR2($bookingId, $bookingStatus, $userId) {
        try {
            $stmt = $this->conn->prepare("
                UPDATE bookings 
                SET 
                bookingStatus = ?,
                modifiedBy = ?,
                modifiedDate = NOW()
                WHERE booking_id = ?
            ");
            $stmt->execute([$bookingStatus, $userId, $bookingId]);
 
            return $stmt->rowCount() > 0;
        } catch (PDOException $e) {
            return json_encode([
                "status" => "error",
                "message" => $e->getMessage()
            ]);
        }
    }
 
    public function updateBookingStatus($userId, $destinationId, $bookingStatus) {
        try {
            $stmt = $this->conn->prepare("
                UPDATE bookings 
                SET bookingStatus = ? 
                WHERE userId = ? AND destinationId = ?
            ");
            $stmt->execute([$bookingStatus, $userId, $destinationId]);
 
            return $stmt->rowCount() > 0;
        } catch (PDOException $e) {
            return json_encode([
                "status" => "error",
                "message" => $e->getMessage()
            ]);
        }
    }

    /* **********************************************************************************
     * Find available booking slots free for a day
     * 
     * @param date $selectedDate   - Filter bookings for a particular day 
     * 
     * Notes:
     * - The function checks for bookings that are not cancelled.
     * **********************************************************************************/    
 
    public function getBookingCountsForDate($selectedDate){
        try {
            // Define the times (one-hour interval)
            $timeSlots = [
                '08:00:00',
                '09:00:00',
                '10:00:00',
                '11:00:00',
                '12:00:00',
                '13:00:00',
                '14:00:00',
            ];

            $resultList = [];

            foreach($timeSlots as $time){
                $bookingDateTime = $selectedDate.' '.$time;

                $stmt = $this->conn->prepare("
                    SELECT COUNT(*) AS bookingCount
                    FROM bookings
                    WHERE bookingDate = ?
                    AND bookingStatus != 'cancelled'
                ");

                $stmt->execute([$bookingDateTime]);
                $result = $stmt->fetch(PDO::FETCH_ASSOC);

                $resultList[] = [
                    'time' => substr($time,0,5), 
                    'bookings' => (int)($result['bookingCount'] ?? 0)
                ];
            } 

            return [
                'status' => 'success',
                'date' => $selectedDate,
                'times' => $resultList
            ];
        } catch (PDOException $e) {
            error_log("Error in getBookingCountsForDate: " .$e->getMessage());

            return [
                'status' => 'error',
                'message' => 'Database error: '.$e->getMessage()
            ];

        }
    }

    /* *****************************************************************************************
     * Check if a time slot is available for booking
     * 
     * @param datetime $bookingDateTime - The date and time of the booking.
     * @return int - return the number of bookings available for the given time slot.
     * 
     * Notes:
     * - This function requires $bookingDateTime, to count the number of bookings for the given 
     *   time slot.
     * - This function will not accept bookings if the number of bookings equals or exceeds 8.
     * *****************************************************************************************/ 
    public function checkIfBookingSlotIsFull($bookingDateTime) {
        try {
            $stmt = $this->conn->prepare("
                SELECT COUNT(*) as count 
                FROM bookings 
                WHERE bookingDate = ?
            ");
            $stmt->execute([$bookingDateTime]);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            $maxBookingsAllowed = 8; // adjust based on your system
    
            return $result['count'] >= $maxBookingsAllowed;
        } catch (PDOException $e) {
            error_log("Error checking booking slot: " . $e->getMessage());
            return false; // fallback
        }
    }    
     
        
    /* *****************************************************************************************
     * Delete a booking for a specific client and booking ID.
     * 
     * @param int $clientId             - The ID of the client associated with the booking.
     * @param int $destinationId        - The ID of the destination associated with the booking.
     * @param datetime $bookingDateTime - The date and time of the booking.
     * @param int $userId               - The ID of the user making the booking.
     * 
     * @return bool - True if the booking was deleted successfully, false otherwise.
     * 
     * Notes:
     * - This function requires clientId, to represent the client requesting the booking. 
     * - This function requires destinationId, to represent the destination of the booking.
     * - This function requires bookingDateTime, to represent the date and time of the booking.
     * - This function requires userId, to represent the user making the booking
     * *****************************************************************************************/  
    public function addUserBooking($clientId, $destinationId, $bookingDateTime, $userId, $userEmail){
        try {
            $sql = "INSERT INTO bookings 
                    (
                        userId,
                        clientId, 
                        destinationId, 
                        bookingStatus, 
                        bookingDate, 
                        createdBy, 
                        createdDate
                    ) 
                    VALUES 
                    (
                        ?,
                        ?, 
                        ?, 
                        ?, 
                        ?, 
                        ?, 
                        NOW()
                    )";

            $stmt = $this->conn->prepare($sql);
            $stmt->execute([$userId,$clientId, $destinationId, 'pending',$bookingDateTime, $userEmail]);

            if($stmt->rowCount()>0){
                error_log('Booking added successfully');
                return true;
            }else{
                error_log('Booking not added');
                return false;
            }
 
            return $this->conn->lastInsertId();
        } catch (PDOException $e) {
            return json_encode([
                "status" => "error",
                "message" => $e->getMessage()
            ]);
        }
    }
 
    /* **********************************************************************************
     * Delete a booking for a specific client and booking ID.
     * 
     * @param int $clientId - The ID of the client associated with the booking.
     * @param int $bookingId - The ID of the booking to delete.
     * @return bool - True if the booking was deleted successfully, false otherwise.
     * Filter bookings for a particular day 
     * **********************************************************************************/       
    public function deleteUserBooking($clientId, $bookingId) {
        try {
            error_log("Attempting to delete booking: $bookingId for client: $clientId");
    
            $stmt = $this->conn->prepare("
                DELETE FROM bookings
                WHERE clientId = ? AND booking_id = ? 
            ");
            $stmt->execute([$clientId, $bookingId]);
    
            $rows = $stmt->rowCount();
            error_log("Rows deleted: $rows");
    
            return $rows > 0;
        } catch (PDOException $e) {
            error_log("Delete error: " . $e->getMessage());
            return false;
        }
    }
 
    /* **********************************************************************************
     * Delete a booking for a specific client and booking ID.
     * 
     * @param int $clientId - The ID of the client associated with the booking.
     * 
     * Notes:
     * - Filter bookings for a particular clientId 
     * **********************************************************************************/     
    public function getUsersCompletedBookings($clientId) {
        try {
            $stmt = $this->conn->prepare("
                SELECT destinationId, bookingStatus, bookingDate
                FROM bookings
                WHERE clientId = ? AND bookingStatus = 'completed'
            ");
            $stmt->execute([$userId]);
 
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            return json_encode([
                "status" => "error",
                "message" => $e->getMessage()
            ]);
        }
    }
 
    public function getUsersPendingBookings($userId) {
        try {
            $stmt = $this->conn->prepare("
                SELECT destinationId, bookingStatus, bookingDate
                FROM bookings
                WHERE userId = ? AND bookingStatus = 'pending'
            ");
            $stmt->execute([$userId]);
 
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            return json_encode([
                "status" => "error",
                "message" => $e->getMessage()
            ]);
        }
    }
 
    public function getBookingsByDate($date) {
        try {
            $stmt = $this->conn->prepare("
                SELECT destinationId, bookingStatus, bookingDate
                FROM bookings
                WHERE bookingDate = ?
            ");
            $stmt->execute([$date]);
 
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            return json_encode([
                "status" => "error",
                "message" => $e->getMessage()
            ]);
        }
    }

    /* **********************************************************************************
     * Return userEmail from userId
     * 
     * @param int $userId   - The ID of the user associated with this booking.
     * @return string       - return the userEmail of the userId provided.
     * 
     * Filter users by userId 
     * **********************************************************************************/           
     public function getUserEmailFromUserID($userId) {
        try {
            $sql = "SELECT userEmail FROM users WHERE id = ?";
            $stmt = $this->conn->prepare($sql);
            $stmt->execute([$userId]);
    
            if ($stmt->rowCount() > 0) {
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                return $row['userEmail'];
            } else {
                return null; // No user found
            }
        } catch (PDOException $e) {
            error_log("Database Error: " . $e->getMessage());
            return null; // Or throw new Exception("Database error") if preferred
        } catch (Exception $e) {
            error_log("Error: " . $e->getMessage());
            return null;
        }
    }   

     // Retrieve the userId of the clientEmail provided.
     public function getUserIdFromUserEmail($clientEmail) {
        try {
            $sql = "SELECT id FROM users WHERE userEmail = ?";
            $stmt = $this->conn->prepare($sql);
            $stmt->execute([$clientEmail]);
    
            if ($stmt->rowCount() > 0) {
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                return $row['id'];
            } else {
                return null; // No user found
            }
        } catch (PDOException $e) {
            error_log("Database Error: " . $e->getMessage());
            return null; // Or throw new Exception("Database error") if preferred
        } catch (Exception $e) {
            error_log("Error: " . $e->getMessage());
            return null;
        }
    }   
}
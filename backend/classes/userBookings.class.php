<?php
require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/utility.class.php';
 
class UserBookings {
    private $_userId;
    private $_destinationId;
    private $_bookingStatus;
    private $_bookingDate;
    public $conn;
 
    public function __construct() {
        $this->conn = Dbh::getInstance()->getConnection();
    }
 
    // Getters and Setters
    public function setUserId($var) { $this->_userId = $var; }
    public function setDestinationId($var) { $this->_destinationId = $var; }
    public function setBookingStatus($var) { $this->_bookingStatus = $var; }
    public function setBookingDate($var) { $this->_bookingDate = $var; }
 
    public function getUserId() { return $this->_userId; }
    public function getDestinationId() { return $this->_destinationId; }
    public function getBookingStatus() { return $this->_bookingStatus; }
    public function getBookingDate() { return $this->_bookingDate; }
 
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
 
    public function updateBookingStatus($userId, $destinationId, $newStatus) {
        try {
            $stmt = $this->conn->prepare("
                UPDATE bookings 
                SET bookingStatus = ? 
                WHERE userId = ? AND destinationId = ?
            ");
            $stmt->execute([$newStatus, $userId, $destinationId]);
 
            return $stmt->rowCount() > 0;
        } catch (PDOException $e) {
            echo "Error: ". $e->getMessage();
        }
    }
 
    public function addUserBooking($userId, $destinationId, $bookingDateTime) {
        try {
            $stmt = $this->conn->prepare("
                INSERT INTO bookings (userId, destinationId, bookingStatus, bookingDate)
                VALUES (?, ?, 'pending', ?)
            ");
            $stmt->execute([$userId, $destinationId, $bookingDateTime]);
 
            return $this->conn->lastInsertId();
        } catch (PDOException $e) {
            echo "Error: ". $e->getMessage();
        }
    }
 
    public function deleteUserBooking($userId, $destinationId) {
        try {
            $stmt = $this->conn->prepare("
                DELETE FROM bookings
                WHERE userId = ? AND destinationId = ?
            ");
            $stmt->execute([$userId, $destinationId]);
 
            return $stmt->rowCount() > 0;
        } catch (PDOException $e) {
            echo "Error: ". $e->getMessage();
        }
    }
 
    public function getUsersCompletedBookings($userId) {
        try {
            $stmt = $this->conn->prepare("
                SELECT destinationId, bookingStatus, bookingDate
                FROM bookings
                WHERE userId = ? AND bookingStatus = 'completed'
            ");
            $stmt->execute([$userId]);
 
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            echo "Error: ". $e->getMessage();
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
            echo "Error: ". $e->getMessage();
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
            echo "Error: ". $e->getMessage();
        }
    }
}
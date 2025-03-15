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

        public function getUserBookingsByUserId($userId) {
            try {
                $stmt = $this->conn->prepare("SELECT destinationId, bookingStatus, bookingDate FROM user_bookings WHERE userId =?;");
                $stmt->execute([$userId]);

                // Fetch all results as an associative array
                $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

                return $bookings;
            } catch (PDOException $e) {
                echo "Error: ". $e->getMessage();
            }
        }

        public function getUserUpcomingBookings($userId) {
            try {
                $currentDateTime = date('Y-m-d H:i:s');
                $stmt = $this->conn->prepare("
                    SELECT destinationId, bookingStatus, bookingDate 
                    FROM user_bookings 
                    WHERE userId = ? AND bookingDate > ? AND bookingStatus != 'completed'
                    ORDER BY bookingDate ASC
                ");
                $stmt->execute([$userId, $currentDateTime]);
    
                // Fetch all results as an associative array
                $upcomingBookings = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
                return $upcomingBookings;
            } catch (PDOException $e) {
                echo "Error: " . $e->getMessage();
            }
        }
    
        public function getUserPastBookings($userId) {
            try {
                $currentDateTime = date('Y-m-d H:i:s');
                $stmt = $this->conn->prepare("
                    SELECT destinationId, bookingStatus, bookingDate 
                    FROM user_bookings 
                    WHERE userId = ? AND (bookingDate < ? OR bookingStatus = 'completed')
                    ORDER BY bookingDate DESC
                ");
                $stmt->execute([$userId, $currentDateTime]);
    
                // Fetch all results as an associative array
                $pastBookings = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
                return $pastBookings;
            } catch (PDOException $e) {
                echo "Error: " . $e->getMessage();
            }
        }

        public function updateBookingStatus($userId, $destinationId, $newStatus) {
            try {
                $stmt = $this->conn->prepare("UPDATE bookings SET bookingStatus =? WHERE userId =? AND destinationId =?;");
                $stmt->execute([$newStatus, $userId, $destinationId]);

                return $stmt->rowCount() > 0;
            } catch (PDOException $e) {
                echo "Error: ". $e->getMessage();
            }
        
        }

        public function addUserBooking($userId, $destinationId, $bookingDateTime) {
            try {
                $stmt = $this->conn->prepare("INSERT INTO bookings (userId, destinationId, bookingStatus, bookingDate) VALUES (?,?, 'pending', ?);");
                $stmt->execute([$userId, $destinationId, $bookingDateTime]);

                return $this->conn->lastInsertId();
            } catch (PDOException $e) {
                echo "Error: ". $e->getMessage();
            }
        }

        public function deleteUserBooking($userId, $destinationId) {
            try {
                $stmt = $this->conn->prepare("DELETE FROM bookings WHERE userId =? AND destinationId =?;");
                $stmt->execute([$userId, $destinationId]);

                return $stmt->rowCount() > 0;
            } catch (PDOException $e) {
                echo "Error: ". $e->getMessage();
            }
        }

        public function getUsersCompletedBookings($userId) {
            try {
                $stmt = $this->conn->prepare("SELECT destinationId, bookingStatus, bookingDate FROM user_bookings WHERE userId =? AND bookingStatus = 'completed';");
                $stmt->execute([$userId]);

                // Fetch all results as an associative array
                $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

                return $bookings;
            } catch (PDOException $e) {
                echo "Error: ". $e->getMessage();
            }
        }

        public function getUsersPendingBookings($userId) {
            try {
                $stmt = $this->conn->prepare("SELECT destinationId, bookingStatus, bookingDate FROM user_bookings WHERE userId =? AND bookingStatus = 'pending';");
                $stmt->execute([$userId]);

                // Fetch all results as an associative array
                $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

                return $bookings;
            } catch (PDOException $e) {
                echo "Error: ". $e->getMessage();
            }
        }

        public function getBookingsByDate($date) {
            try {
                $stmt = $this->conn->prepare("SELECT destinationId, bookingStatus, bookingDate FROM user_bookings WHERE bookingDate =?;");
                $stmt->execute([$date]);

                // Fetch all results as an associative array
                $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

                return $bookings;
            } catch (PDOException $e) {
                echo "Error: ". $e->getMessage();
            }
        }

}
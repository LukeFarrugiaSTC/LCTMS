<?php
    require_once __DIR__ . '/../includes/config.php';
    require_once __DIR__ . '/utility.class.php';
    
    class Street {
        private $_streetCode;
        private $_townCode;
        private $_streetName;
        private $_streetLongitude;
        private $_streetLatitude;
        public $conn;

        public function __construct() {
            $this->conn = Dbh::getInstance()->getConnection();
        }

        // Getters and Setters
        public function setStreetCode($var) { $this->_streetCode = $var; }
        public function setTownCode($var) { $this->_townCode = $var; }
        public function setStreetName($var) { $this->_streetName = $var; }
        public function setStreetLongitude($var) { $this->_streetLongitude = $var; }
        public function setStreetLatitude($var) { $this->_streetLatitude = $var; }

        public function getStreetCode() { return $this->_streetCode; }
        public function getTownCode() { return $this->_townCode; }
        public function getStreetName() { return $this->_streetName; }
        public function getStreetLongitude() { return $this->_streetLongitude; }
        public function getStreetLatitude() { return $this->_streetLatitude; }

        public function streetRead() {
            try {
                $stmt = $this->conn->prepare("SELECT streetCode, townCode, streetName, streetLongitude, streetLatitude FROM streets;");
                $stmt->execute();

                // Fetch all results as an associative array
                $streets = $stmt->fetchAll(PDO::FETCH_ASSOC);

                // Return the JSON-encoded data
                return json_encode(["status" => "success", "data" => $streets]);
            } catch (PDOException $e) {
                error_log($e->getMessage());
                return json_encode([
                    "status"  => "error",
                    "message" => "An unexpected error occurred. Please try again later."
                ]);
            }
        }

        public function getStreetCodeFromStreetName($streetName) {
            try {
                $stmt = $this->conn->prepare("SELECT streetCode, townCode, streetName, streetLongitude, streetLatitude FROM streets WHERE streetName = ?");
                $stmt->execute([$streetName]);
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                if ($result === false) {
                    return null;
                }
                // Return just the streetCode
                return $result['streetCode'];
            } catch (PDOException $e) {
                error_log($e->getMessage());
                return null;
            }
        }

        public function getTownCodeFromStreetCode($streetCode) {
            try {
                $stmt = $this->conn->prepare("SELECT townCode FROM streets WHERE streetCode =?");
                $stmt->execute([$streetCode]);
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                return $result['townCode'];
            } catch (PDOException $e) {
                error_log($e->getMessage());
                return null;
            }
        }

        public function getStreetsFromTownCode($townCode) {
            try {
                $stmt = $this->conn->prepare("SELECT streetName FROM streets WHERE townCode =?;");
                $stmt->execute([$townCode]);

                // Fetch all results as an associative array
                $streets = $stmt->fetchAll(PDO::FETCH_ASSOC);

                return $streets;
            } catch (PDOException $e) {
                error_log($e->getMessage());
                return [];
            }
        }
    }
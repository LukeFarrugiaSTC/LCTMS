<?php
	require_once __DIR__ . '/../includes/config.php';
	require_once __DIR__ . '/utility.class.php';

    class Destination {
        private $_destination_name;
        private $_streetCode;
        private $_townCode;
        public $conn;

        public function __construct() {
            $this->conn = Dbh::getInstance()->getConnection();
        }

        // Getters and Setters
        public function setDestinationName($var) { $this->_destination_name = $var; }
        public function setStreetCode($var) { $this->_streetCode = $var; }
        public function setTownCode($var) { $this->_townCode = $var; }

        public function getDestinationName() { return $this->_destination_name; }
        public function getStreetCode() { return $this->_streetCode; }
        public function getTownCode() { return $this->_townCode; }

        public function getAllDestinations() {
            try {
                $stmt = $this->conn->prepare("SELECT destination_name, streetCode, townCode FROM destinations;");
                $stmt->execute();

                // Fetch all results as an associative array
                $destinations = $stmt->fetchAll(PDO::FETCH_ASSOC);

                return $destinations;
            } catch (PDOException $e) {
                echo "Error: ". $e->getMessage();
            }
        }

        public function addDestination() {
            try {
                $stmt = $this->conn->prepare("INSERT INTO destinations (destination_name, streetCode, townCode) VALUES (?,?,?)");
                $stmt->execute([$this->getDestinationName(), $this->getStreetCode(), $this->getTownCode()]);

                return $this->conn->lastInsertId();
            } catch (PDOException $e) {
                echo "Error: ". $e->getMessage();
            }
        }

        public function getDestinationIdFromDestinationName($destinationName) {
            try {
                $stmt = $this->conn->prepare("SELECT destinationId FROM destinations WHERE destination_name =?");
                $stmt->execute([$destinationName]);
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                return $result['destinationId'];
            } catch (PDOException $e) {
                echo "Error: ". $e->getMessage();
            }
        }

    }
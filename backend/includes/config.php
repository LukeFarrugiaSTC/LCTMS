<?php
	class Dbh {
    	private static $instance = null;
    	private $conn;

    	private function __construct() {
		  // Fetch environment variables
		  $db_host = 'sql10.bravehost.com';
		  $db_name = 'lctms_1744612';
		  $db_user = 'malla112';
		  $db_pass = 'lctms!2025';

		  if (!$db_host || !$db_name || !$db_user || !$db_pass) {
			  die(json_encode(["status" => "error", "message" => "Missing database configuration"]));
		  }

		  try {
			  $this->conn = new PDO(
				  "mysql:host=$db_host;dbname=$db_name;charset=utf8",
				  $db_user,
				  $db_pass
			  );
			  $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		  } catch (PDOException $e) {
			  die(json_encode(["status" => "error", "message" => "Database connection failed: " . $e->getMessage()]));
		  }
    	}

    	public static function getInstance() {
        	if (self::$instance == null) {
            	self::$instance = new Dbh();
        	}
        	return self::$instance;
    	}

    	public function getConnection() {
       		return $this->conn;
    	}
	
	}

?>
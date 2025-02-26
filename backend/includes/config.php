<?php

	class Dbh {
    	private static $instance = null;
    	private $conn;
    	private $host = "sql10.bravehost.com";
    	private $dbname = "lctms_1744612";
    	private $username = "malla112";
    	private $password = "lctms!2025";

    	private function __construct() {
        	try {
            	$this->conn = new PDO(
                	"mysql:host=" . $this->host . ";dbname=" . $this->dbname . ";charset=utf8",
                	$this->username,
                	$this->password
            	);
            	$this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        	} catch (PDOException $e) {
            	die(json_encode(["status" => "error", "message" => "Database connection failed"]));
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
<?php

	require_once '../includes/config.php';
	require_once 'utility.class.php';

	class Street {
		private $_streetCode;
	  	private $_streetName;
	  	private $_townCode;
	  
	  	public function __construct(){
			$this->conn = Dbh::getInstance()->getConnection();
		}
	  
	  	// Getters and Setters 
	  	public function setStreetCode($var) 	{	$this->_streetCode 	= 	$var;	}
	  	public function setStreetName($var)		{	$this->_streetName 	= 	$var;	}
	  	public function setTownCode($var) 		{	$this->_townCode 	=	$var;	}
	  
	  	public function getStreetCode()			{	return $this->_streetCode;		}
	  	public function getStreetName() 		{	return $this->_streetName;		}
	  	public function getTownCode()			{	return $this->_townCode;		}
	  
	  	public function readStreetsByTown(){
			try {
			  $stmt = $this->conn->prepare("SELECT streetCode, streetName, streetLongitude, streetLatitude, townCode FROM streets WHERE townCode = ?;");
			  $stmt->execute([
			  	$this->getTownCode()
			  ]);
			  
			  // Fetch all results as an associate array
			  $streets = $stmt->fetchAll(PDO::FETCH_ASSOC);
			  
			  // Return the JSON-encoded data
			  return json_encode(["status" => "success", "data" => $streets]);
			} catch (PDOException $e) {
			  die(json_encode(["status" => "error", "message" => "Database error: ".$e->getMessage()]));
			}
		}
	}

?>
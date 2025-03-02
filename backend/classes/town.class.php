<?php
	require_once '../includes/config.php';
	require_once 'utility.class.php';

	class Town {
		private $_townCode;
	  	private $_townName;
	  	private $_districtCode;
	  
	    public function __construct() {
        	$this->conn = Dbh::getInstance()->getConnection();
    	}
	  
	  	// Getters and Setters 
	  	public function setTownCode($var) 		{	$this->_townCode		=	$var;	}
	  	public function setTownName($var)		{	$this->_townName 		=	$var;	}
	  	public function setDistrictCode($var)	{	$this->_districtCode	=	$var;	}
	  
	  	public function getTownCode()			{	return $this->_townCode;			}
	  	public function getTownName()			{	return $this->_townName;			}
	  	public function getDistrictCode()		{	return $this->_districtCode;		}
	  
	  	public function townRead(){
			try {
			  	$stmt = $this->conn->prepare("SELECT townCode, townName, districtCode FROM towns;");	
			  	$stmt->execute();

				// Fetch all results as an associative array
				$towns = $stmt->fetchAll(PDO::FETCH_ASSOC);

				// Return the JSON-encoded data
				return json_encode(["status" => "success", "data" => $towns]);			  
			} catch (PDOException $e) {
    			die(json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]));
			}
	  
		}
	}
?>
	  
	  
	    
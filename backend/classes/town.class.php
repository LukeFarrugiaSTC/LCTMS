<?php
    require_once __DIR__ . '/../includes/config.php';
    require_once __DIR__ . '/utility.class.php';

	class Town {
		private $_townCode;
	  	private $_townName;
	  	private $_districtCode;
		public $conn;
	  
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
				error_log($e->getMessage());
				return json_encode([
					"status"  => "error",
					"message" => "An unexpected error occurred. Please try again later."
				]);
			}
		}

		public function getAllTownNames() {
			try {
                $stmt = $this->conn->prepare("SELECT townName FROM towns");
                $stmt->execute();
                $result = $stmt->fetchAll(PDO::FETCH_COLUMN);
                return $result;
            } catch (PDOException $e) {
                error_log($e->getMessage());
                return [];
            }
		}
		
		public function getTownCodeFromTownName($townName) {
			try {
                $stmt = $this->conn->prepare("SELECT townCode FROM towns WHERE townName =?");
                $stmt->execute([$townName]);
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                return $result['townCode'];
            } catch (PDOException $e) {
                error_log($e->getMessage());
                return null;
            }
		}

		public function checkIfTownExists($townCode) {
			try {
                $stmt = $this->conn->prepare("SELECT COUNT(*) as total FROM towns WHERE townCode =?");
                $stmt->execute([$townCode]);
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                return $result['total'] > 0;
            } catch (PDOException $e) {
                error_log($e->getMessage());
                return false;
            }
        }
<<<<<<< HEAD

		// ****************************************************
		// This method is used to get all streets in a town
		// It takes the townCode using the getTownCode() method
		// ****************************************************

		public function townStreets(){
			try {
				$stmt = $this->conn->prepare("SELECT streetCode, streetName, townCode FROM streets WHERE townCode = ?;");

				// Make sure to set the townCode before calling this function
				$stmt->execute([$this->_townCode]);

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
	}
?>
				error_log($e->getMessage());
				return json_encode([
					"status"  => "error",
					"message" => "An unexpected error occurred. Please try again later."
				]);
			}
		}

		public function getAllTownNames() {
			try {
                $stmt = $this->conn->prepare("SELECT townName FROM towns");
                $stmt->execute();
                $result = $stmt->fetchAll(PDO::FETCH_COLUMN);
                return $result;
            } catch (PDOException $e) {
                error_log($e->getMessage());
                return [];
            }
		}
		
		public function getTownCodeFromTownName($townName) {
			try {
                $stmt = $this->conn->prepare("SELECT townCode FROM towns WHERE townName =?");
                $stmt->execute([$townName]);
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                return $result['townCode'];
            } catch (PDOException $e) {
                error_log($e->getMessage());
                return null;
            }
		}

		public function checkIfTownExists($townCode) {
			try {
                $stmt = $this->conn->prepare("SELECT COUNT(*) as total FROM towns WHERE townCode =?");
                $stmt->execute([$townCode]);
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                return $result['total'] > 0;
            } catch (PDOException $e) {
                error_log($e->getMessage());
                return false;
            }
        }
=======
>>>>>>> 7dc2828 (Add booking endpoints and classes Revision 2)

		// ****************************************************
		// This method is used to get all streets in a town
		// It takes the townCode using the getTownCode() method
		// ****************************************************

		public function townStreets(){
			try {
				$stmt = $this->conn->prepare("SELECT streetCode, streetName, townCode FROM streets WHERE townCode = ?;");

				// Make sure to set the townCode before calling this function
				$stmt->execute([$this->_townCode]);

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
	}
?>
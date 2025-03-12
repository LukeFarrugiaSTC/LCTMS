<?php
	/*
	 * **************************************************
	 * Class Name: 	User
	 * Description: Handles user registration and login
	 * Author: 		Andrew Mallia
	 * Date: 		2025-03-08
	 * **************************************************
	 */
	
	require_once __DIR__ . '/../includes/config.php';
	require_once __DIR__ . '/utility.class.php';
	require_once __DIR__ . '/Exceptions/validationException.class.php';
	require_once __DIR__ . '/validators/userValidator.class.php';
	require_once __DIR__ . '/../helpers/responseHelper.php';

	class User {
		private $_userId;
		private $_userEmail;
	  	private $_userFirstname;
	  	private $_userLastname;
	  	private $_userAddress;
	  	private $_streetCode;
	  	private $_townCode;
	  	private $_userDob;
	  	private $_mobile;
	  	private $_userPassword;
	  	private $_userConfirm;
	  	private $_userRole;
	  	private $_isActive;
		public $data;
		public $conn;
	  
	    public function __construct() {
        	$this->conn = Dbh::getInstance()->getConnection();
    	}
	  
	  	// Getters and Setters 
		public function setUserId($var)			{	$this->_userId		=		$var;	}
	  	public function setUserEmail($var) 		{	$this->_userEmail		=	$var;	}
	  	public function setUserFirstname($var)	{	$this->_userFirstname 	=	$var;	}
	  	public function setUserLastname($var)	{	$this->_userLastname 	=	$var;	}
	  	public function setUserAddress($var)	{	$this->_userAddress 	=	$var;	}
	  	public function setStreetCode($var)		{	$this->_streetCode 		=	$var;	}
	  	public function setTownCode($var) 		{	$this->_townCode 		=	$var;	}
	  	public function setUserDob($var)		{	$this->_userDob			=	$var;	}
	  	public function setMobile($var) 		{	$this->_mobile 			=	$var;	}
	  	public function setUserPassword($var)	{	$this->_userPassword	=	$var;	}
	  	public function setUserConfirm($var)	{	$this->_userConfirm 	=	$var;	}
	  	public function setUserRoleId($var)		{	$this->_userRole 		=	$var;	}
	  	public function setIsActive($var)		{	$this->_isActive 		=	$var;	}
	  
		public function getUserId()				{	return $this->_userId;				}
	  	public function getUserEmail()			{	return $this->_userEmail;			}
	  	public function getUserFirstname()		{	return $this->_userFirstname;		}
	  	public function getUserLastname()		{	return $this->_userLastname;		}
	  	public function getUserAddress()		{	return $this->_userAddress;			}
	  	public function getStreetCode()			{	return $this->_streetCode;			}
	  	public function getTownCode()			{	return $this->_townCode;			}
	  	public function getUserDob()			{	return $this->_userDob;				}
	  	public function getMobile()				{	return $this->_mobile;				}
	  	public function getUserPassword()		{	return $this->_userPassword;		}
	  	public function getUserConfirm()		{	return $this->_userConfirm;			}
	  	public function getUserRoleId()			{	return $this->_userRole;			}
	  	public function getIsActive()			{	return $this->_isActive;			}

		public function getAllUserDetails() {

			$this->data['email'] = $this->getUserEmail();
			$this->data['fname'] = $this->getUserFirstname();
			$this->data['lname'] = $this->getUserLastname();
			$this->data['houseNumber'] = $this->getUserAddress();
			$this->data['streetCode'] = $this->getStreetCode();
			$this->data['townCode'] = $this->getTownCode();
			$this->data['mobile'] = $this->getMobile();
			$this->data['dob'] = $this->getUserDob();
			$this->data['password'] = $this->getUserPassword();
			$this->data['confirm'] = $this->getUserConfirm();
			$this->data['isActive'] = $this->getIsActive();
			$this->data['roleId'] = $this->getUserRoleId();
		}

	  
	  	public function registration() {
			try {
				$stmt = $this->conn->prepare("SELECT userEmail FROM users WHERE userEmail = ?");
				$stmt->execute([$this->getUserEmail()]);
				if ($stmt->rowCount() > 0) {
					return sendResponse(["status" => "error", "message" => "Email already exists"]);
				}

				$this->getAllUserDetails();
			  
			  	// Hash the password after the validation is found to be TRUE
			  	$hashedPassword = password_hash($this->getUserPassword(), PASSWORD_DEFAULT);
			  
			  	$sql	=	"INSERT INTO users (";
			  	$sql 	.=	"	userEmail, ";
			  	$sql 	.=	"	userFirstname, ";
			  	$sql 	.=	"	userLastname, ";
			  	$sql 	.=	"	userAddress, ";
			  	$sql 	.=	" 	streetCode, ";
			  	$sql 	.=	"	townCode, ";
			  	$sql	.=	"	userDob, ";
			  	$sql 	.=	"	userMobile, ";
			  	$sql	.=	"	userPassword, ";
			  	$sql 	.=	"	roleId, ";
			  	$sql 	.=	"	isActive, ";
			  	$sql 	.=	"	createdDate";
			  	$sql 	.=	") ";
			  	$sql 	.=	"VALUES (?,?,?,?,?,?,?,?,?,3,1,NOW())";
				$stmt = $this->conn->prepare($sql);
			  	$stmt->execute([
					$this->data['email'],
				  	$this->data['fname'],
				  	$this->data['lname'],
				  	$this->data['houseNumber'],
				  	$this->data['streetCode'],
				  	$this->data['townCode'],
				  	$this->data['dob'],
				  	$this->data['mobile'],
				  	$hashedPassword
				]);
			  	return sendResponse([
					"status"	=> 	"success",
				  	"message"	=> 	"Insertion completed"
				]);
			  	exit;
			} catch (PDOException $e) {
				return sendResponse([
					"status"	=>	"error",
				  	"message"	=>	$e
				]);
			} catch (ValidationException $e) {
				sendResponse(["status" => "error", "message" => implode(', ', $e->getErrors())], 400);
			}
		}

		public function profileUpdate() {
			try {

				$this->getAllUserDetails();

				$stmt = $this->conn->prepare("SELECT userEmail FROM users WHERE userEmail = ?");
				$stmt->execute([$this->data['email']]);
				if ($stmt->rowCount() === 0) {
					return sendResponse(["status" => "error", "message" => "Email does not exist"]);
				}

				$sql = "UPDATE users SET userFirstname = ?, userLastname = ?, userAddress = ?, streetCode = ?, townCode = ?, userDob = ?, userMobile = ? WHERE userEmail = ?";
				$stmt = $this->conn->prepare($sql);
				$stmt->execute([
					$this->data['fname'],
					$this->data['lname'],
					$this->data['houseNumber'],
					$this->data['streetCode'],
					$this->data['townCode'],
					$this->data['dob'],
					$this->data['mobile'],
					$this->data['email']
				]);
				return sendResponse([
					"status"	=>	"success",
				  	"message"	=>	"Profile updated"
				]);
				exit;
			} catch (PDOException $e) {
				return sendResponse([
					"status"	=>	"error",
				  	"message"	=>	"Database Error:".$e->getMessage()
				]);
			}
		}

		public function profileRead() {
			try {
				$sql = "SELECT userEmail, userFirstname, userLastname, userAddress, streetCode, townCode, userDob, userMobile, isActive, roleId FROM users WHERE userEmail = ?";
				$stmt = $this->conn->prepare($sql);		
				$stmt->execute([
					$this->getUserEmail()
				]);

				if ($stmt->rowCount()>0) {
					$row = $stmt->fetch(PDO::FETCH_ASSOC);
					return json_encode([
						"status"		=>	"success",
					  	"message"		=>	"Profile found",
					  	"userEmail"		=>	$row['userEmail'],
					  	"userFirstname"	=>	$row['userFirstname'],
					  	"userLastname"	=>	$row['userLastname'],
					  	"userAddress"	=>	$row['userAddress'],
					  	"streetCode"	=>	$row['streetCode'],
					  	"townCode"		=>	$row['townCode'],
					  	"userDob"		=>	$row['userDob'],
					  	"userMobile"	=>	$row['userMobile'],
						"isActive"		=>	$row['isActive'],
						"roleId"		=>	$row['roleId']
				  	]);
				  	exit;
				} else {
					return json_encode([
						"status"	=>	"error",
					  	"message"	=>	"Profile not found"
					]);
				  	exit;
				}
			} catch (PDOException $e) {
				return json_encode([
					"status"	=>	"error",
				  	"message"	=>	"Database Error:".$e->getMessage()
				]);
			}
		}
	  
		public function login() {
			// Validate form fields 
			if (!utility::validateEmail($this->getUserEmail())) {
				return json_encode(["status" => "error", "message" => "Invalid email address"]);
			}
		
			try {
				$stmt = $this->conn->prepare("
					SELECT id, userEmail, userPassword, roleId, isActive 
					FROM users 
					WHERE userEmail = ?
				");
				$stmt->execute([$this->getUserEmail()]);
		
				if ($stmt->rowCount() > 0) {
					$row = $stmt->fetch(PDO::FETCH_ASSOC);
					if ($row && password_verify($this->getUserPassword(), $row['userPassword'])) {
						$this->setUserId($row['id']);
						return json_encode([
							"status"   => "success",
							"message"  => "Login successful",
							"roleId"   => $row['roleId'],
							"isActive" => $row['isActive'],
							"userId"   => $this->getUserId()
						]);
					} else {
						return json_encode([
							"status"  => "error",
							"message" => "Invalid credentials"
						]);
					}
				} else {
					return json_encode([
						"status"  => "error",
						"message" => "Invalid credentials"
					]);
				}
			} catch (PDOException $e) {
				error_log($e->getMessage());
				return json_encode([
					"status"  => "error",
					"message" => $e->getMessage()
				]);
			}
		}
	}
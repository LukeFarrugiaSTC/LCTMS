<?php
/*
 * **************************************************
 * Class Name:   User
 * Description:  Handles user registration, login, profile updates,
 *               password resets, and related database operations.
 * Author:       Andrew Mallia
 * Date:         2025-03-08
 * **************************************************
 */

require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/utility.class.php';
require_once __DIR__ . '/Exceptions/validationException.class.php';
require_once __DIR__ . '/validators/userValidator.class.php';
require_once __DIR__ . '/../helpers/responseHelper.php';
require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../helpers/jwtHelper.php';
require_once __DIR__ . '/../helpers/redisHelper.php';

use Symfony\Component\Mailer\Transport;
use Symfony\Component\Mailer\Mailer;
use Symfony\Component\Mime\Email;
use Helpers\JwtHelper;

class User {
    // Private properties for user data.
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
    private $_userPin;
    public $data;
    public $conn;

    public function __construct() {
        // Assume Dbh::getInstance()->getConnection() returns a PDO connection.
        $this->conn = Dbh::getInstance()->getConnection();
    }

    // Getters and Setters
    public function setUserId($var)          { $this->_userId = $var; }
    public function setUserEmail($var)       { $this->_userEmail = $var; }
    public function setUserFirstname($var)   { $this->_userFirstname = $var; }
    public function setUserLastname($var)    { $this->_userLastname = $var; }
    public function setUserAddress($var)     { $this->_userAddress = $var; }
    public function setStreetCode($var)      { $this->_streetCode = $var; }
    public function setTownCode($var)        { $this->_townCode = $var; }
    public function setUserDob($var)         { $this->_userDob = $var; }
    public function setMobile($var)          { $this->_mobile = $var; }
    public function setUserPassword($var)    { $this->_userPassword = $var; }
    public function setUserConfirm($var)     { $this->_userConfirm = $var; }
    public function setUserRoleId($var)      { $this->_userRole = $var; }
    public function setUserPin($var)         { $this->_userPin = $var; }
    public function setIsActive($var)        { $this->_isActive = $var; }

    public function getUserId()              { return $this->_userId; }
    public function getUserEmail()           { return $this->_userEmail; }
    public function getUserFirstname()       { return $this->_userFirstname; }
    public function getUserLastname()        { return $this->_userLastname; }
    public function getUserAddress()         { return $this->_userAddress; }
    public function getStreetCode()          { return $this->_streetCode; }
    public function getTownCode()            { return $this->_townCode; }
    public function getUserDob()             { return $this->_userDob; }
    public function getMobile()              { return $this->_mobile; }
    public function getUserPassword()        { return $this->_userPassword; }
    public function getUserConfirm()         { return $this->_userConfirm; }
    public function getUserRoleId()          { return $this->_userRole; }
    public function getIsActive()            { return $this->_isActive; }

    // Helper method to aggregate user details into the data array.
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

    // Check if an email already exists in the database.
    public function doesTheEmailExist() {
        $stmt = $this->conn->prepare("SELECT userEmail FROM users WHERE userEmail = ?");
        $stmt->execute([$this->getUserEmail()]);
        return ($stmt->rowCount() > 0);
    }

    // Generate a reset PIN for password resets.
    private function generateResetPin() {
        // Generate a 5-digit PIN.
        return (int) random_int(10000, 99999);
    }

    // Register a new user.
    public function registration() {
        try {
            if($this->doesTheEmailExist()) {
                throw new Exception('Email already exists.');
            }

            $this->getAllUserDetails();

            // Hash the password after validation is true.
            $hashedPassword = password_hash($this->getUserPassword(), PASSWORD_DEFAULT);

            $sql  = "INSERT INTO users (
                        userEmail, userFirstname, userLastname, userAddress, 
                        streetCode, townCode, userDob, userMobile, userPassword, 
                        roleId, isActive, createdDate
                    ) VALUES (?,?,?,?,?,?,?,?,?,3,1,NOW())";
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
            return [
                "status"  => "success",
                "message" => "Insertion completed"
            ];
        } catch (PDOException $e) {
            return [
                "status"  => "error",
                "message" => $e->getMessage()
            ];
        } catch (Exception $e) {
            return [
                "status"  => "error",
                "message" => $e->getMessage()
            ];
        }
    }

    // Update the user's password.
    public function updatePassword($hashedPassword) {
        try {
            // Check if the user exists using the email.
            $stmt = $this->conn->prepare("SELECT userEmail FROM users WHERE userEmail = ?");
            $stmt->execute([$this->getUserEmail()]);
            if ($stmt->rowCount() === 0) {
                throw new Exception("Email does not exist.");
            }

            $sql = "UPDATE users SET userPassword = ? WHERE userEmail = ?";
            $stmt = $this->conn->prepare($sql);
            $result = $stmt->execute([
                $hashedPassword,
                $this->getUserEmail()
            ]);

            return $result;
        } catch (PDOException $e) {
            throw new Exception("Database error: " . $e->getMessage());
        }
    }

    // Update the user's profile details.
    public function profileUpdate() {
        try {
            $this->getAllUserDetails();

            $stmt = $this->conn->prepare("SELECT userEmail FROM users WHERE userEmail = ?");
            $stmt->execute([$this->data['email']]);
            if ($stmt->rowCount() === 0) {
                return json_encode(["status" => "error", "message" => "Email does not exist"]);
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
            return json_encode([
                "status"  => "success",
                "message" => "Profile updated"
            ]);
        } catch (PDOException $e) {
            return json_encode([
                "status"  => "error",
                "message" => "Database Error: " . $e->getMessage()
            ]);
        }
    }
    
    // Retrieve the user's account details
    public function getClientDetails() {
        try {
            $sql =  "SELECT ";
            $sql .= "id, userEmail, userFirstname, userLastname, userAddress, client.streetCode, street.streetName, ";
            $sql .= "client.townCode, town.townName, userDob, userMobile, isActive, roleId ";
            $sql .= "FROM `lctms`.`users` AS client ";
            $sql .= "LEFT JOIN `lctms`.`streets` AS street ON street.streetCode = client.streetCode ";
            $sql .= "LEFT JOIN `lctms`.`towns` AS town ON town.townCode = client.townCode ";
            $sql .= "WHERE client.userEmail=? LIMIT 1";
            
            $stmt = $this->conn->prepare($sql);
            $stmt->execute([
                $this->getUserEmail()
            ]);

            if ($stmt->rowCount() >0){
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                return json_encode([
                    "status"        =>  "success",
                    "message"       =>  "Client found",
                    "clientId"      =>  $row['id'],
                    "userEmail"     =>  $row['userEmail'],
                    "userFirstname" =>  $row['userFirstname'],
                    "userLastname"  =>  $row['userLastname'],
                    "userAddress"   =>  $row['userAddress'],
                    "streetName"    =>  $row['streetName'],
                    "townName"      =>  $row['townName'],
                    "userMobile"    =>  $row['userMobile']
                ]);
            } else {
                return json_encode([
                    "status"    =>  "error",
                    "message"   =>  "Client not found. Please create a new client."
                ]);
            }
        } catch (PDOException $e) {
            return json_encode([
                "status"    => "error",
                "message"   => "Database Error: ".$e->getMessage()
            ]);
        }
    }

    public function createNewClient() {
        try {
            $sql = "INSERT INTO users 
                    (userEmail, userFirstname, userLastname, userAddress, streetCode, townCode, userDob, userMobile, userPassword, roleId, isActive, createdDate) 
                    VALUES 
                    (?, ?, ?, ?, ?, ?, ?, ?, ?, 3, 1, NOW())";
            
            $stmt = $this->conn->prepare($sql);
    
            // Handle optional fields
            $dob = $this->getUserDob() ?: null;
            $mobile = $this->getMobile() ?: null;
    
            $stmt->execute([
                $this->getUserEmail(),
                $this->getUserFirstname(),
                $this->getUserLastname(),
                $this->getUserAddress(),
                $this->getStreetCode(),
                $this->getTownCode(),
                $dob,
                $mobile,
                password_hash('defaultPassword', PASSWORD_DEFAULT)
            ]);
    
            return json_encode([
                "status" => "success",
                "message" => "Client created successfully",
                "clientId" => $this->conn->lastInsertId()
            ]);
        } catch (PDOException $e) {
            error_log($e->getMessage()); 
            return json_encode([
                "status" => "error",
                "message" => "Database Error: " . $e->getMessage()
            ]);
        }
    }    

    // Retrieve the user's profile details.
    public function profileRead() {
        try {
            $sql = "SELECT userEmail, userFirstname, userLastname, userAddress, streetCode, townCode, userDob, userMobile, isActive, roleId 
                    FROM users WHERE userEmail = ?";
            $stmt = $this->conn->prepare($sql);
            $stmt->execute([$this->getUserEmail()]);

            if ($stmt->rowCount() > 0) {
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                return [
                    "status"        => "success",
                    "message"       => "Profile found",
                    "userEmail"     => $row['userEmail'],
                    "userFirstname" => $row['userFirstname'],
                    "userLastname"  => $row['userLastname'],
                    "userAddress"   => $row['userAddress'],
                    "streetCode"    => $row['streetCode'],
                    "townCode"      => $row['townCode'],
                    "userDob"       => $row['userDob'],
                    "userMobile"    => $row['userMobile'],
                    "isActive"      => $row['isActive'],
                    "roleId"        => $row['roleId']
                ];
            } else {
                return json_encode([
                    "status"  => "error",
                    "message" => "Profile not found"
                ]);
            }
        } catch (PDOException $e) {
            return json_encode([
                "status"  => "error",
                "message" => "Database Error: " . $e->getMessage()
            ]);
        }
    }

    // Reset the user's password by generating a PIN and emailing it.
	public function resetPassword() {
		try {
			if (!$this->doesTheEmailExist()) {
				throw new Exception('Email does not exist.');
			}
			
			// Generate a reset PIN.
			$pin = $this->generateResetPin();
	
			// Update the user's record with the new reset PIN (optional if you use Redis only).
			$updateStmt = $this->conn->prepare("UPDATE users SET userPin = ? WHERE userEmail = ?");
			$updateStmt->execute([$pin, $this->getUserEmail()]);
	
			// Store the reset PIN in Redis with a TTL of 600 seconds (10 minutes)
			$redisHelper = new RedisHelper();
			$redisHelper->storeResetPin($this->getUserEmail(), $pin, 600);
	
			// Send the PIN via email.
			$this->sendResetEmail($this->getUserEmail(), $pin);
			
			return json_encode([
				"status"  => "success",
				"message" => "A password reset PIN has been sent to your email."
			]);
		} catch (PDOException $e) {
			return json_encode([
				"status"  => "error",
				"message" => "Database Error: " . $e->getMessage()
			]);
		}
	}

    // Send the password reset email containing the PIN.
    private function sendResetEmail($userEmail, $pin) {
        // Retrieve DSN from environment or configuration.
        $mailerDsn = $_ENV['MAILER_DSN'] ?? 'smtp://mailhog:1025';
        
        // Configure the mail transport using Symfony Mailer.
        $transport = Transport::fromDsn($mailerDsn);
        $mailer = new Mailer($transport);
        
        // Build the HTML content.
        $htmlContent = '
            <html>
                <body style="font-family: Arial, sans-serif;">
                    <p>Enter the following PIN in your app to reset your password:</p>
                    <h2 style="color: #007BFF;">' . $pin . '</h2>
                    <p>If you did not request a password reset, please ignore this email.</p>
                </body>
            </html>
        ';
        
        // Create the email message.
        $email = (new Email())
            ->from('info@andrewmallia.com')
            ->to($userEmail)
            ->subject('Password Reset Request')
            ->text("Use the following PIN to reset your password: " . $pin . "\n\nIf you did not request a password reset, please ignore this email.")
            ->html($htmlContent);
        
        // Send the email.
        $mailer->send($email);
    }

    // Log the user in.
    public function login() {
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
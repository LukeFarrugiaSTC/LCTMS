<?php
	require_once __DIR__ . '/../includes/config.php';

	class Utility
	{

		private static $myAPI_key;

		public static function getMyAPI_key() {
			self::$myAPI_key = getenv('API_KEY');
			return self::$myAPI_key;
		}		

		// Validate email format
	  	public static function validateEmail($email) {
		  	if (!empty($email)){
				return filter_var($email, FILTER_VALIDATE_EMAIL);			
			} 
		  	return false;
		}
	  
		// Validate if a name contains only letters 
	  	public static function validateName($name) {
			return preg_match("/^[a-zA-Z]+$/",$name);
		}
	  
	  	// Validate if surname contains only letters
	  	public static function validateSurname($surname){
			return preg_match("/^[a-zA-Z]+$/",$surname);
		}
	  
	  	// Validate that address contains at least 1 character
	  	public static function validateAddress($address) {
			return strlen(trim($address))>0;
		}
	  
	  	// Validate that streetCode contains exactly 8 digits
	  	public static function validateStreetCode($streetCode){
			return preg_match("/^\d{8}$/", $streetCode);
		}
	  
	  	// Validate that townCode contains exactly 4 digits
	  	public static function validateTownCode($townCode){
			return preg_match("/^\d{4}$/", $townCode);
		}

		// Validate that userPin contains exactly 11 digits
		public static function validatePin($pin){
			return preg_match("/^\d{11}$/", $pin);
		}
	  
	  	// Validate date format (YYYY-MM-DD)
	  	public static function validateDate($date){
			return preg_match("/^\d{4}-\d{2}-\d{2}$/",$date);
		}
	  
	  	// Validate that mobile contains exactly 8 digits
	  	public static function validateMobile($mobile){
			return preg_match("/^\d{8}$/", $mobile);
		}
	  	
  public static function validatePassword($password) {
      // Minimum length of 8 characters
      // At least one uppercase letter
      // At least one lowercase letter
      // At least one number
      // At least one special character
      // Maximum length of 128 characters to prevent potential DoS attacks
      $regex = "/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,128}$/";

      if (!preg_match($regex, $password)) {
          return false;
      }

      // Check against a list of common passwords
      $commonPasswords = ['password', '123456', 'qwerty', 'admin', 'letmein']; 
      if (in_array(strtolower($password), $commonPasswords)) {
          return false;
      }

      return true;
  }
	  
	  	// Check if two passwords match
	  	public static function passwordsMatch($password, $confirmPassword) {
			return $password === $confirmPassword;
		}
	}

?>
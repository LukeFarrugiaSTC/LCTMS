<?php
	require_once '../includes/config.php';

	class Utility
	{
	 	private static $myAPI_key = '93a7b1d4e8f42f6c5a3e9d8b7c6f1a0e2d4c8f7e5b9a2c3d1f6e4a5b7d9c8e0';
		  
		// getters and setters
		public static function getMyAPI_key() 		{	return self::$myAPI_key;		}
	  	

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
	  
	  	// Validate date format (YYYY-MM-DD)
	  	public static function validateDate($date){
			return preg_match("/^\d{4}-\d{2}-\d{2}$/",$date);
		}
	  
	  	// Validate that mobile contains exactly 8 digits
	  	public static function validateMobile($mobile){
			return preg_match("/^\d{8}$/", $mobile);
		}
	  	
	  	// Validate password (Minimum 8 characters with at least one letter and one number) {
		public static function validatePassword($password){
			return preg_match("/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/", $password);
		}
	  
	  	// Check if two passwords match
	  	public static function passwordsMatch($password, $confirmPassword) {
			return $password === $confirmPassword;
		}
	}

?>
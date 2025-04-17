<?php
require_once __DIR__ . '/../utility.class.php';
require_once __DIR__ . '/../Exceptions/validationException.class.php';

class UserValidator {
    public static function checkForRequiredFields(array $data, array $fields) {
        $errors = [];
        foreach ($fields as $field) {
            if (!isset($data[$field]) || trim($data[$field]) === '') {
                $errors[] = "The field '$field' is required.";
            }
        }
        if (!empty($errors)) {
            throw new ValidationException($errors);
        }
    }

    public static function validateRegistration(array $data) {
        $errors = [];

        // 1. Check for required fields.
        $requiredFields = ['email', 'fname', 'lname', 'houseNumber', 'streetName', 'townName', 'mobile', 'dob', 'password', 'confirm'];

        self::checkForRequiredFields($data, $requiredFields);

        // 2. Validate email format.
        if (!Utility::validateEmail($data['email'])) {
            $errors[] = "Invalid email format.";
        }

        // 3. Validate first name and last name.
        if (!Utility::validateName($data['fname'])) {
            $errors[] = "Invalid first name.";
        }
        if (!Utility::validateSurname($data['lname'])) {
            $errors[] = "Invalid last name.";
        }

        // 4. Validate address (you might check for a minimum length or pattern).
        if (!Utility::validateAddress($data['houseNumber'])) {
            $errors[] = "Invalid address.";
        }

        // 5. Validate street and town codes (format or numeric checks).
        if (!Utility::validateStreetName($data['streetName'])) {
            $errors[] = "Invalid street name.";
        }
        if (!Utility::validateTownName($data['townName'])) {
            $errors[] = "Invalid town name.";
        }

        // 6. Validate date of birth.
        if (!Utility::validateDate($data['dob'])) {
            $errors[] = "Invalid date of birth format.";
        } else {
            try {
                $dob = new DateTime($data['dob']);
                $today = new DateTime();
                $age = $today->diff($dob)->y;
                if ($age < 18) {
                    $errors[] = "You must be at least 18 years old to register.";
                }
            } catch (Exception $e) {
                $errors[] = "Date of birth processing error.";
            }
        }

        // 7. Validate mobile number.
        if (!Utility::validateMobile($data['mobile'])) {
            $errors[] = "Invalid mobile number.";
        }

        if (!Utility::validatePassword($data['password'])) {
            $errors[] = "Password does not meet strength requirements (min 8 characters, include letters and numbers).";
        }

        // 9. Validate that password and confirmation match.
        if (!Utility::passwordsMatch($data['password'], $data['confirm'])) {
            $errors[] = "Passwords do not match.";
        }

        if (!empty($errors)) {
            throw new ValidationException($errors);
        }
    
        return true;
    }

    public static function validateProfileUpdate(array $data) {
        $errors = [];
        
        // Define the required fields for a profile update
        $requiredFields = ['email', 'name', 'surname', 'houseNumber', 'street', 'town', 'dob', 'mobile'];
        // Check that these fields are present and not empty
        self::checkForRequiredFields($data, $requiredFields);

        // Validate email
        if (!Utility::validateEmail($data['email'])) {
            $errors[] = "Invalid email format.";
        }

        // Validate name
        if (!Utility::validateName($data['name'])) {
            $errors[] = "Invalid name.";
        }

        // Validate surname
        if (!Utility::validateSurname($data['surname'])) {
            $errors[] = "Invalid surname.";
        }

        // Validate address
        if (!Utility::validateAddress($data['houseNumber'])) {
            $errors[] = "Invalid address.";
        }

        // Validate street using your street code function
        // if (!Utility::validateStreetCode($data['street'])) {
        //     $errors[] = "Invalid street.";
        // }

        // // Validate town using your town code function
        // if (!Utility::validateTownCode($data['town'])) {
        //     $errors[] = "Invalid town.";
        // }

        // Validate date of birth
        if (!Utility::validateDate($data['dob'])) {
            $errors[] = "Invalid date of birth.";
        }

        // Validate mobile number
        if (!Utility::validateMobile($data['mobile'])) {
            $errors[] = "Invalid mobile number.";
        }

        if (!empty($errors)) {
            throw new ValidationException($errors);
        }

        return true;
    }

    public static function validateLogin(array $data) {
        $errors = [];

        $requiredFields = ['email', 'password'];

        self::checkForRequiredFields($data, $requiredFields);

        if (!Utility::validateEmail($data['email'])) {
            $errors[] = "Invalid email format.";
        }

        // Validate name
        if (!Utility::validatePassword($data['password'])) {
            $errors[] = "Invalid password.";
        }
        
        if (!empty($errors)) {
            throw new ValidationException($errors);
        }
    
        return true;
    }

    public static function isUserActive(array $data) {

        if (isset($data['isActive']) && $data['isActive'] == 0) {
            throw new ValidationException(['Account not active.']);
        }
    }
}

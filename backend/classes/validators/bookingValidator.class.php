<?php
// Check if required files exist before including them
$utilityFilePath = __DIR__ . '/../../classes/utility.class.php';
$validationExceptionFilePath = __DIR__ . '/../Exceptions/validationException.class.php';

//echo file_exists($utilityFilePath) or die("File not found: $utilityFilePath");
//echo file_exists($validationExceptionFilePath) or die("File not found: $validationExceptionFilePath");

// Include the required files
require_once $utilityFilePath;
require_once $validationExceptionFilePath;

class BookingValidator extends Utility {
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

    public static function validateBooking(array $data) {

    }

    public static function validateBookingAddR2(array $data) {
        $errors = [];
        // 1. Check for required fields.
        // $requiredFields = ['destinationId', 'bookingDateTime', 'userId', 'clientId'];
        // self::checkForRequiredFields($data, $requiredFields);

        //echo $data['clientId'].'|'.$data['destinationName'].'|'.$data['bookingDateTime'].'|'.$data['userId'];


        // 2. Validate destination name.
        if (!isset($data['destinationName']) || empty(trim($data['destinationName']))) {
            $errors[] = "Invalid destination name.";
        }
        // 3. Validate booking date and time.
        if (!isset($data['bookingDateTime']) || !preg_match('/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/', $data['bookingDateTime'])) {
            $errors[] = "Invalid booking date and time format. Expected format: YYYY-MM-DD HH:MM:SS";
        }
        // 4. Validate user ID.
        if (!isset($data['userId']) || !is_numeric($data['userId'])) {
            $errors[] = "Invalid user ID.";
        }
        // 5. Validate client ID.
        if (!isset($data['clientId']) || !is_numeric($data['clientId'])) {
            $errors[] = "Invalid client ID.";
        }

        //echo $errors[];

        if (!empty($errors)) {
            throw new ValidationException($errors);
        }

    }

    public static function validateBookingDeleteR2(array $data) {
        $errors = [];

        // 1. Check for required fields.
        $requiredFields = ['bookingId', 'userId', 'clientEmail', 'bookingStatus'];
        self::checkForRequiredFields($data, $requiredFields);

        // 2. Validate booking ID.
        if (!isset($data['bookingId']) || !is_numeric($data['bookingId'])) {
            $errors[] = "Invalid booking ID.";
        }

        // 3. Validate user ID.
        if (!isset($data['userId']) || !is_numeric($data['userId'])) {
            $errors[] = "Invalid user ID.";
        }

        // 4. Validate client email address.
        if (!Utility::validateEmail($data['clientEmail'])) {
            $errors[] = "Invalid email format.";
        }        

        // 5. Validate booking status.
        $validStatuses = [
            'pending',
            'confirmed',
            'driver en route',
            'driver arrived',
            'client picked up',
            'cancelled',
            'client no show',
            'rejected',
            'failed'
        ];
        if (!isset($data['bookingStatus']) || !in_array(strtolower($data['bookingStatus']), $validStatuses)) {
            $errors[] = "Invalid booking status.";
        }

        if (!empty($errors)) {
            throw new ValidationException($errors);
        }
    }

    public static function validateBookingUpdateStatus(array $data) {
        $errors = [];

        // 1. Check for required fields.
        $requiredFields = ['bookingId', 'bookingStatus', 'userId'];
        self::checkForRequiredFields($data, $requiredFields);

        // 2. Validate booking ID.
        if (!is_numeric($data['bookingId'])) {
            $errors[] = "Invalid booking ID.";
        }

        // *************************************
        // 3. Validate booking status
        // *************************************
        $validStatuses = ['pending', 'confirmed', 'driver en route', 'driver arrived', 'client picked up', 'completed', 'cancelled', 'client no show', 'rejected', 'failed'];
        if (!in_array($data['bookingStatus'], $validStatuses)) {
            $errors[] = "Invalid booking status.";
        }


        if (!empty($errors)) {
            throw new ValidationException($errors);
        }
    }
}

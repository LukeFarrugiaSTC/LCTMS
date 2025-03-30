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

    public static function validateBookingUpdateStatus(array $data) {
        $errors = [];

        // 1. Check for required fields.
        $requiredFields = ['bookingId', 'bookingStatus', 'userId'];
        self::checkForRequiredFields($data, $requiredFields);

        // 2. Validate booking ID.
        if (!is_numeric($data['bookingId'])) {
            $errors[] = "Invalid booking ID.";
        }

        // 3. Validate booking status
        $validStatuses = ['pending', 'confirmed', 'driver en route', 'driver arrived', 'client picked up', 'completed', 'cancelled', 'client no show', 'rejected', 'failed'];
        if (!in_array($data['bookingStatus'], $validStatuses)) {
            $errors[] = "Invalid booking status.";
        }


        if (!empty($errors)) {
            throw new ValidationException($errors);
        }
    }
}

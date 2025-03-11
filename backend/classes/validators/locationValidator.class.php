<?php
require_once __DIR__ . '/../utility.class.php';
require_once __DIR__ . '/../Exceptions/validationException.class.php';

class locationValidator {
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


}

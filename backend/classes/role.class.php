<?php

/*
    * **************************************************
    * Class Name: 	Role
    * Description:  Handles user roles
    * Author: 		Andrew Mallia
    * Date: 		2025-03-08
    * **************************************************
    */

    require_once '../includes/config.php';
    require_once 'utility.class.php';

    class Role {
        private $_roleId;
        private $_roleName;

        public function __construct() {
            $this->conn = Dbh::getInstance()->getConnection();
        }

        // Getters and Setters
        public function setRoleId($var) { $this->_roleId = $var; }
        public function setRoleName($var) { $this->_roleName = $var; }

        public function getRoleId() { return $this->_roleId; }
        public function getRoleName() { return $this->_roleName; }

        public function roleRead() {
            try {
                $query = "SELECT * FROM roles";
                $stmt = $this->conn->prepare($query);
                $stmt->execute();
                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                return json_encode($result);
            } catch (PDOException $e) {
                return json_encode(["status" => "error", "message" => $e->getMessage()]);
            }
        }
    }
?>
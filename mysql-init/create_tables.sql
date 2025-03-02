CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    userEmail VARCHAR(255) NOT NULL UNIQUE,
    userFirstname VARCHAR(100) NOT NULL,
    userLastname VARCHAR(100) NOT NULL,
    userAddress VARCHAR(255),
    streetCode VARCHAR(50),
    townCode VARCHAR(50),
    userDob DATE,
    userMobile VARCHAR(20),
    userPassword VARCHAR(255) NOT NULL,
    roleId INT DEFAULT 3,
    isActive TINYINT DEFAULT 1,
    createdDate DATETIME DEFAULT CURRENT_TIMESTAMP
);
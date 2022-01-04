-- IT393 AY22-1 WPR2 V1
-- NAME: Jack Summers

-- DO NOT CHANGE THESE LINES!
-- The WPR begins on line 10
DROP DATABASE IF EXISTS wpr2v1;
CREATE DATABASE wpr2v1;
USE wpr2v1;

-- YOUR CODE GOES HERE.

-- Create the tables:

CREATE TABLE Attendee (
	emailAddress VARCHAR(255) NOT NULL,
    lastName VARCHAR(35),
    firstName VARCHAR(35),
    creditCard VARCHAR(16),
    PRIMARY KEY (emailAddress)
    );
    
CREATE TABLE Conference (
	conferenceID INT AUTO_INCREMENT,
    name VARCHAR(70) NOT NULL,
    registrationPrice DECIMAL(6,2) NOT NULL,
    registrationEndDate DATE NOT NULL,
    website VARCHAR(255),
    description TEXT,
    PRIMARY KEY (conferenceID)
    );
    
CREATE TABLE Registration (
	emailAddress VARCHAR(255) NOT NULL,
    conferenceID INT NOT NULL,
    registrationDate DATETIME,
    PRIMARY KEY (emailAddress, conferenceID),
    FOREIGN KEY (emailAddress) REFERENCES Attendee (emailAddress)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (conferenceID) REFERENCES Conference (conferenceID)
    );

-- Create stored procedures for each use case:
DELIMITER //
-- Use Case 1: EnterNewConference

CREATE PROCEDURE EnterNewConference (
	
    pName VARCHAR(70),
    pPrice DECIMAL(6,2),
    pRegistrationEnd DATE,
    pWebsiteLink VARCHAR(255),
    pDescription TEXT
	)
BEGIN 
    INSERT INTO Conference (name, registrationPrice, registrationEndDate, website, description) 
    VALUES (pName, pPrice, pRegistrationEnd, pWebsiteLink, pDescription);
end //

-- Use Case 2: ViewConferenceRegistrations

CREATE PROCEDURE ViewConferenceRegistrations (
	pConferenceID INT
    )
BEGIN 
	SELECT emailAddress, registrationDate FROM Registration 
    WHERE pConferenceID = conferenceID
    ORDER BY emailAddress ASC;
end //

-- Use Case 3: ViewAvailableConferences

CREATE PROCEDURE ViewAvailableConferences()
BEGIN
	SELECT name, registrationPrice, website, description FROM Conference
    WHERE registrationEndDate < CURDATE()
    ORDER BY name;
end //

-- Use Case 4: Register

CREATE PROCEDURE Register (
	pEmail VARCHAR(255),
    pConID INT
    )
BEGIN 

	INSERT INTO Registration (emailAddress, conferenceID, registrationDate)
    VALUES (pEmail, pConID, NOW());
end //
DELIMITER ;
-- Create the users:
DROP USER IF EXISTS conAdmin;
DROP USER IF EXISTS Attendee;

CREATE USER conAdmin;
CREATE USER Attendee;

-- Give the users permission to execute their use cases:
GRANT EXECUTE ON PROCEDURE EnterNewConference TO conAdmin;
GRANT EXECUTE ON PROCEDURE ViewConferenceRegistrations TO conAdmin;
GRANT EXECUTE ON PROCEDURE ViewAvailableConferences TO Attendee;
GRANT EXECUTE ON PROCEDURE Register TO Attendee;

-- Uncomment the test data to check your answers.
-- DO NOT CHANGE ANY LINES BELOW!

-- Delete this line to uncomment the test data

INSERT INTO attendee (emailAddress, lastName, firstName, creditCard) VALUES
('data1@test.data', 'Data 1', 'Test', '000-NOT-REAL-000'),
('data2@test.data', 'Data 2', 'Test', '111-NOT-REAL-111'),
('data3@test.data', 'Data 3', 'Test', '222-NOT-REAL-222');

CALL EnterNewConference("EnergyCon", 599.99, '2021-12-03', NULL, "All things energy!");
CALL EnterNewConference("DrinksCon", 600, '2021-12-31', "https://drinks.con", NULL);
CALL Register ('data1@test.data', (SELECT conferenceID FROM conference WHERE name = "EnergyCon"));
CALL Register ('data2@test.data', (SELECT conferenceID FROM conference WHERE name = "DrinksCon"));

SELECT 'Should be "1"' AS `PASS`, (
	SELECT conferenceID FROM conference WHERE registrationPrice = 600
) = (
	SELECT COUNT(*) FROM registration
) AS `CHECK`;

-- DELETE this line to uncomment the test data
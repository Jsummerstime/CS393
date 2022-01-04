DROP DATABASE IF EXISTS it393_hw3;
CREATE DATABASE it393_hw3;
USE it393_hw3;

CREATE TABLE school (
	schoolName CHAR(20) NOT NULL,
    institutionType CHAR(20) NOT NULL,
    PRIMARY KEY (schoolName)
    );
    
CREATE TABLE user (
	userID INT AUTO_INCREMENT,
    userName CHAR(20),
    email CHAR(30),
	password CHAR(20),
    isAdmin BIT(1),
    PRIMARY KEY (userID),
    UNIQUE (userName),
    UNIQUE (password),
    UNIQUE (email)
    
    -- UNIQUE (userName, email, password, isAdmin)
    
    );
    
CREATE TABLE member (
	userID INT AUTO_INCREMENT,
    userName CHAR(20),
    email CHAR(30),
	password CHAR(20),
    isAdmin BIT(1),
    schoolName CHAR(20),
    PRIMARY KEY (userID),
    FOREIGN KEY (userID) REFERENCES user (userID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (userName) REFERENCES user (userName) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (email) REFERENCES user (email) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (password) REFERENCES user (password) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (schoolName) REFERENCES school (schoolName) ON DELETE RESTRICT ON UPDATE CASCADE
    -- FOREIGN KEY (isAdmin) REFERENCES user (isAdmin) ON DELETE CASCADE ON UPDATE CASCADE
    );
    
    CREATE TABLE administrator (
	userID INT AUTO_INCREMENT,
    userName CHAR(30),
    email CHAR(20),
	password CHAR(20),
    isAdmin BIT(1),
    permisionLvl CHAR(10),
    position CHAR(20),
    PRIMARY KEY (userID),
    FOREIGN KEY (userID) REFERENCES user (userID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (userName) REFERENCES user (userName) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (email) REFERENCES user (email) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (password) REFERENCES user (password) ON DELETE CASCADE ON UPDATE CASCADE
    -- FOREIGN KEY (isAdmin) REFERENCES user (isAdmin) ON DELETE CASCADE ON UPDATE CASCADE
    );
    
CREATE TABLE academicClassFolder (
	className CHAR(20),
	userID INT,
	PRIMARY KEY (className),
	FOREIGN KEY (userID) REFERENCES user (userID) ON DELETE CASCADE ON UPDATE CASCADE
	);
        
CREATE TABLE studySet (
	setID INT AUTO_INCREMENT,
	studySetname CHAR(20),
	className CHAR(20),
	numberOfCards INT,
	PRIMARY KEY (setID),
	FOREIGN KEY (className) REFERENCES academicClassFolder (className) ON DELETE CASCADE ON UPDATE CASCADE
	);
    
CREATE TABLE card (
	cardTerm CHAR(20),
    note TEXT,
    setID INT,
    PRIMARY KEY (cardTerm),
    FOREIGN KEY (setID) REFERENCES studySet (setID) ON DELETE CASCADE ON UPDATE CASCADE
	);
    
-- insert Data:
INSERT INTO user (userName, email, password) VALUES
	('ArmyTeam', 'hooah@westpoint.edu', '1234'),
    ('jsummerstime', 'jack.summers@westpoint.edu', '4242'),
    ('GoBucks', 'ohio@gmail.com', 'password');
INSERT INTO school (schoolName, institutionType) VALUES
	('West Point', 'college'),
    ('Ohio State', 'college');
INSERT INTO member (username, email, password, schoolName) VALUES
	('ArmyTeam', 'hooah@westpoint.edu', '1234', 'West Point'),
    ('jsummerstime', 'jack.summers@westpoint.edu', '4242', 'West Point'),
    ('GoBucks', 'ohio@gmail.com', 'password', 'Ohio State');
INSERT INTO academicClassFolder (className, userID) VALUES 
	('MA104', 1),
	('CS393', 2),
    ('EN101', 3);
INSERT INTO studySet (studySetname, className) VALUES
	('Quiz3', 'MA104'),
	('WPR1', 'CS393'),
    ('Test1', 'EN101');
INSERT INTO card (cardTerm, note, setID) VALUES
	('1 + 2', '3', 1),
	('SQL', 'Structured Query Language', 2),
    ('Carrot', 'an orange vegtable', 3);


-- Procedures:

-- use case 1
DELIMITER //
CREATE PROCEDURE viewStudySet ( -- view cards within a specified study set
	studySetGiven CHAR(20)
    )
BEGIN
	SELECT cardTerm, note FROM card WHERE setID IN
	(SELECT setID FROM studySet WHERE studySetGiven = studySetName);
END //

-- use case 2
DELIMITER //
CREATE PROCEDURE enterPersonalInfo ( -- enter personal info
	nameGiven CHAR(20),
    emailGiven CHAR(30),
    passGiven CHAR(20)
    )
BEGIN
	INSERT INTO user (userName, email, password) VALUES
    (nameGiven, emailGiven, passGiven);
END //

-- use case 3
DELIMITER //
CREATE PROCEDURE searchForStudySet (          -- *CITATION* I USED: https://www.mysqltutorial.org/mysql-if-statement/ in order to understand the syntax of and IF ELSE conditional in sql      
	searchType CHAR(20),
    searchName CHAR(30)
    )
BEGIN
	IF searchType = 'username' THEN -- user search for a study set made by a specific user
		SELECT studySetName FROM studySet NATURAL JOIN academicClassFolder
        WHERE className IN (SELECT className FROM academicClassFolder WHERE userID IN 
        (SELECT userID FROM user WHERE userName = searchName));
        
	ELSEIF searchType = 'classname' THEN -- user search for a study set within a specific acadmic class
		SELECT studySetName FROM studySet WHERE searchName = className;
        
	ELSEIF searchType = 'school' THEN -- user lists all study sets from particular school 
		SELECT studySetName FROM studySet NATURAL JOIN academicClassFolder
        WHERE className IN (SELECT className FROM academicClassFolder WHERE userID IN 
        (SELECT userID FROM member WHERE schoolName = searchName));
	END IF;
    
END //

-- use case 4

DELIMITER //
CREATE PROCEDURE createClassFolder ( -- add a new class folder to a specific user account
	userGiven CHAR(20),
    classNameGiven CHAR(20)
    )
BEGIN
	INSERT INTO academicClassFolder (className, userID) VALUES
    (classNameGiven, (SELECT userID FROM user WHERE userName = userGiven));
END //

-- use case 5

DELIMITER //
CREATE PROCEDURE createStudySet ( -- add a new study set to a specific class folder
	nameGiven CHAR(20),
    classGiven CHAR(20)
    )
BEGIN
	INSERT INTO studySet (studySetName, className) VALUES
    (nameGiven, classGiven);
END //

-- testing procedures
-- CALL viewStudySet('Quiz3');
-- CALL enterPersonalInfo('jsummerstime', 'jack.summers@westpoint.edu', '4242');
-- SELECT * FROM user;
-- CALL searchForStudySet('username','jsummerstime');
-- CALL searchForStudySet('classname', 'EN101');
-- CALL searchForStudySet('school', 'West Point');
-- CALL createClassFolder('jsummerstime', 'CY450');
-- SELECT * FROM academicClassFolder;
-- CALL createStudySet('Lab1', 'CY450');
-- SELECT studySetName FROM studySet WHERE className = 'CY450';







    
    
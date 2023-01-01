-- Student Data Cleaning Project *Cleaning up MySQL student data in a MySQL database using SQL commands*
-- Skills used: regular expressions, table creation, and data insertion.


-- Analyze an existing people database table for Normalization
SELECT *
FROM people;

-- Using SQL REGEX to check and clean the address in the MySQL table
SELECT address
FROM people
WHERE address NOT REGEXP '^[0-9a-zA_Z\. ]+;[a-zA-Z ]+;[A-Z ]+;[0-9 ]+$';

-- Creating a Query to display the atomic values within the address field
-- SELECT substring_index(substring_index(address, ';',1), ';',-1) FROM people;
-- SELECT substring_index(substring_index(address, ';',2), ';',-1) FROM people;
-- SELECT substring_index(substring_index(address, ';',3), ';',-1) FROM people;
-- SELECT substring_index(substring_index(address, ';',4), ';',-1) FROM people;

SELECT substring_index(substring_index(address, ';',1), ';',-1) as street, 
substring_index(substring_index(address, ';',2), ';',-1) as city, 
substring_index(substring_index(address, ';',3), ';',-1) as state,
substring_index(substring_index(address, ';',4), ';',-1) as zip
FROM people;

-- Using the existing address field to create an address table
-- DROP TABLE IF EXISTS address;
CREATE TABLE address (
  id int NOT NULL AUTO_INCREMENT,
  street varchar(255) NOT NULL,
  city varchar(255) NOT NULL,
  state varchar(2) NOT NULL,
  zip varchar(10) NOT NULL,
  pfk int DEFAULT NULL,
  PRIMARY KEY (id)
  );
  
  -- Using SQL to Insert the Data into the address table using existing data
INSERT INTO address(street, city, state, zip, pfk)
SELECT trim(substring_index(substring_index(address, ';',1), ';',-1)) as street, 
trim(substring_index(substring_index(address, ';',2), ';',-1)) as city, 
trim(substring_index(substring_index(address, ';',3), ';',-1)) as state,
trim(substring_index(substring_index(address, ';',4), ';',-1)) as zip,
id
FROM people;

SELECT *
FROM company.people, company.address
WHERE people.id = address.pfk;

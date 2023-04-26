CREATE SCHEMA IF NOT EXISTS `VivaKHR`;
USE `VivaKHR` ;


# creating region table and populating data from matching table from temperory database
CREATE TABLE IF NOT EXISTS `region`(
	`region_id` INT (11) AUTO_INCREMENT PRIMARY KEY,
	`region_name` VARCHAR (25) DEFAULT NULL
);

INSERT INTO VivaKHR.region(`region_id` ,`region_name`)
SELECT region_id,region_name from temp.regions;

select *from VivaKHR.region;

# creating Department table and populating data from matching table from temperory database
CREATE TABLE IF NOT EXISTS `Department` (
  `department_id` INT NOT NULL,
  `department_name` VARCHAR(45) NULL,
  PRIMARY KEY (`department_id`));
  
INSERT INTO VivaKHR.Department(`department_id` ,`department_name`)
SELECT department_id,department_name from `temp`.`departments2csv`;

SELECT * FROM VivaKHR.Department ;
 
 # creating countries table and populating data from matching table from temperory database
    CREATE TABLE IF NOT EXISTS `countries` (
	`country_code` INT AUTO_INCREMENT PRIMARY KEY,
    `country_id` CHAR (2) UNIQUE,
	`country_name` VARCHAR (40) DEFAULT NULL,
	`region_id` INT (11) NOT NULL,
     CONSTRAINT cntry_fk
	 FOREIGN KEY (`region_id`)
     REFERENCES region(`region_id`)
     ON UPDATE CASCADE
     ON DELETE CASCADE);
 
INSERT INTO VivaKHR.countries(`country_code` ,`country_id`,`country_name`,`region_id`)
SELECT `country_code` ,`country_id`,`country_name`,`region_id` from `temp`.`countries`;

SELECT * FROM VivaKHR.countries ;

# creating location table and populating data from matching table from temperory database
CREATE TABLE IF NOT EXISTS `Location` (
  `location_id` INT ,
  `location_code` INT UNIQUE,
  `street_address` VARCHAR(45) ,
  `postal_code` VARCHAR(45) ,
  `city` VARCHAR(45) ,
  `state_province` VARCHAR(45) ,
  `country_code` INT ,
   `country_id` CHAR(2) ,
  PRIMARY KEY (`location_id`),
  CONSTRAINT lctn_fk
	 FOREIGN KEY (`country_code`)
     REFERENCES `countries`(`country_code`)
     ON UPDATE CASCADE
     ON DELETE CASCADE);
  
INSERT INTO VivaKHR.Location(`location_id`,`location_code`,`street_address`,`postal_code`,`city`,`state_province`,`country_code`,`country_id`)
SELECT `location_id`,`location_code`,`street_address`,`postal_code`,`city`,`state_province`,`country_code`,`country_id` from `temp`.`location2csv`;

SELECT * FROM VivaKHR.Location;

# creating Organizational_structure table and populating data from matching table from temperory database  
  CREATE TABLE IF NOT EXISTS `Organizational_Structure` (
  `job_id` INT NOT NULL,
  `job_title` VARCHAR(45),
  `min_salary`  DOUBLE(10,2),
  `max_salary`  DOUBLE(10,2),
  `department_name` VARCHAR(45),
   `department_id` INT NOT NULL,
  `Reports_to` INT,
  PRIMARY KEY (`job_id`),
   CONSTRAINT Os_fk
	 FOREIGN KEY (`department_id`)
     REFERENCES `department`(`department_id`)
     ON UPDATE CASCADE
     ON DELETE CASCADE);
 
INSERT INTO VivaKHR.Organizational_Structure ( `job_id`,`job_title`,`min_salary`,`max_salary`,`department_name`,`department_id`,`Reports_to` )
SELECT `job_id`,`job_title`,`min_salary`,`max_salary`,`department_name`,`department_id`,`Reports_to` from `temp`.`orgstructure_v2csv`;

SELECT * FROM VivaKHR.Organizational_Structure;
 
 # creating Organizational_structure table and populating data from matching table from temperory database   
  CREATE TABLE IF NOT EXISTS `Employee` (
  `employee_id` INT NOT NULL UNIQUE,
  `first_name` TEXT NULL,
  `last_name` TEXT NULL,
  `email` TEXT NULL,
  `phone_number` TEXT NULL,
  `job_id` INT NULL,
  `salary` DOUBLE(10,2),
  `report_to` INT NULL,
  `Location_id` INT ,
  `hire_date` DATE NULL,
  PRIMARY KEY (`employee_id`),
   CONSTRAINT emp_fk1
	 FOREIGN KEY (`job_id`)
     REFERENCES `Organizational_Structure`(`job_id`)
     ON UPDATE CASCADE
     ON DELETE CASCADE,
      CONSTRAINT emp_fk2
	 FOREIGN KEY (`Location_id`)
     REFERENCES `Location`(`Location_id`)
     ON UPDATE CASCADE
     ON DELETE CASCADE);
     
INSERT INTO VivaKHR.Employee (  `employee_id`,`first_name`,`last_name`,`email` ,`phone_number` ,`job_id`,`salary`,`report_to` ,`Location_id`,`hire_date` )
SELECT  `employee_id`,`first_name`,`last_name`,`email` ,`phone_number` ,`job_id`,`salary`,`report_to` ,`Location_id`,`hire_date` from `temp`.`employee_dupl`;

SELECT * FROM VivaKHR.Employee;

# creating Location_emp_details table table and populating data from matching table from temperory database  
 CREATE TABLE IF NOT EXISTS `Location_Emp_Details` (
  `job_id` INT,
  `job_title` VARCHAR(45) NULL,
  `Full Name` VARCHAR(45) ,
  `location_code` INT ,
   PRIMARY KEY (`job_id`,`location_code`),
	 FOREIGN KEY (`location_code`)
     REFERENCES `Location`(`location_code`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
	);
    
    INSERT INTO VivaKHR.`Location_Emp_Details` (  `job_id`,`job_title`,`Full Name`,`location_code` )
	SELECT `job_id`,`job_title`,`Full Name`,`location_code`  from `temp`.`Location_Emp_Details`; 
    
    select * from `VivaKHR`.`Location_Emp_Details`;
    
    
    ## creating Dependent table and populating data from matching table from temporary database
    CREATE TABLE IF NOT EXISTS `VivaKHR`.dependent
    ( `dependent_id` int,
      `first_name` text,
      `last_name` text,
      `relationship` text,
      `employee_id` int,
       PRIMARY KEY (`dependent_id`,`employee_id`),
      CONSTRAINT dpt_fk1
	 FOREIGN KEY (`employee_id`)
     REFERENCES `VivaKHR`.`employee`(`employee_id`)
     ON UPDATE CASCADE
     ON DELETE CASCADE);
	
    INSERT  INTO `VivaKHR`.dependent (  `dependent_id`,`first_name`,`last_name`,`relationship`,`employee_id` )
	SELECT `dependent_id`,`first_name`,`last_name`,`relationship`,`employee_id`  from `temp`.`dependent`; 
    

     select * from `VivaKHR`.dependent;
     
     
     #Adding a calculated column experience_at_VivaK at employee table
     ALTER TABLE VivaKHR.Employee
     ADD experience_at_VivaK INT;
	# Generating values for experience_at_VivaK column
     
     
	#Include last_performance_rating at employee table
      ALTER TABLE VivaKHR.Employee
     ADD last_performance_rating DOUBLE(2,2);
     # Generating values for last_performance_rating column
     
     
     #Include salary_after_increment at employee table
	 ALTER TABLE VivaKHR.Employee
     ADD salary_after_increment DOUBLE(10,2);
     # Generating values for salary_after_increment column
     
     
     #Include annual_dependent_benefit at employee table
	 ALTER TABLE VivaKHR.Employee
     ADD annual_dependent_benefit DOUBLE(10,2);
     # Generating values for annual_dependent_benefit column
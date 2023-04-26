use temp;
#Step 1
#Adding location code to every location tables
select * from location1400;

ALTER TABLE location1400
ADD location_code INT;

UPDATE location1400
SET location_code = 1400;

ALTER TABLE location1500
ADD location_code INT;

UPDATE location1500
SET location_code = 1500;

ALTER TABLE location1700
ADD location_code INT;

UPDATE location1700
SET location_code = 1700;

ALTER TABLE location2400
ADD location_code INT;

UPDATE location2400
SET location_code = 2400;

ALTER TABLE location2500
ADD location_code INT;

UPDATE location2500
SET location_code = 2500;

ALTER TABLE location2700
ADD location_code INT;

UPDATE location2700
SET location_code = 2700;

ALTER TABLE location1800
ADD location_code INT;

UPDATE location1800
SET location_code = 1800;

select * from location1500;
select * from location1700;
select * from location1800;
select * from location2400;
select * from location2500;
select * from location2700;

#step 2
#Creating new table to make new employee location table by combining 7 location tables.

use temp;
CREATE TABLE IF NOT EXISTS temp.`Location_Emp_Details` (
  `job_id` INT NOT NULL,
  `job_title` VARCHAR(45) NULL,
  `Full Name` VARCHAR(45) ,
  `Location_code` INT ,
  PRIMARY KEY (`job_id`,`Location_code` ))
ENGINE = InnoDB;

#Merging all 7 location tables to form one single table using union.
commit;

INSERT INTO temp.Location_Emp_details (`job_id`, `job_title`, `Full Name`, `Location_code`)
select * from location1400
UNION ALL
select * from location1500
UNION ALL
select * from location1700
UNION ALL
select * from location1800
UNION ALL
select * from location2400
UNION ALL
select * from location2500
UNION ALL
select * from location2700;

select * from temp.Location_Emp_details;

#step 3
#changing column name of employees table department_id to location_id
ALTER TABLE temp.employees
CHANGE department_id location_id char(30);

# step 4
#Adding useful tables from Old HR schema
CREATE TABLE IF NOT EXISTS temp.regions (
	region_id INT (11) AUTO_INCREMENT PRIMARY KEY,
	region_name VARCHAR (25) DEFAULT NULL
);

# creating countries table and adding country_code as primarykey using auto increment
CREATE TABLE IF NOT EXISTS temp.countries (
	country_code INT AUTO_INCREMENT PRIMARY KEY,
    country_id CHAR (2) UNIQUE,
	country_name VARCHAR (40) DEFAULT NULL,
	region_id INT (11) NOT NULL
);

#Inserting values into the regions and countries table
INSERT INTO temp.regions(region_id,region_name) VALUES (1,'Europe'),(2,'Americas')
,(3,'Asia'),(4,'Middle East and Africa');

/*Data for the table countries */
INSERT INTO temp.countries(country_id,country_name,region_id) VALUES ('AR','Argentina',2),
 ('AU','Australia',3),
 ('BE','Belgium',1),
 ('BR','Brazil',2),
 ('CA','Canada',2),
('CH','Switzerland',1),
('CN','China',3),
('DE','Germany',1),
('DK','Denmark',1),
('EG','Egypt',4), 
('FR','France',1),
('HK','HongKong',3),
('IL','Israel',4),
 ('IN','India',3),
 ('IT','Italy',1),
 ('JP','Japan',3),
 ('KW','Kuwait',4),
 ('MX','Mexico',2),
 ('NG','Nigeria',4),
('NL','Netherlands',1),
 ('SG','Singapore',3),
 ('UK','United Kingdom',1),
 ('US','United States of America',2),
 ('ZM','Zambia',4), ('ZW','Zimbabwe',4);

select * from temp.employees;

#step 5
# Adding country_code column in location table and assigning values comparing country_id
ALTER TABLE temp.location2csv 
ADD `country_code` INT;

# Fetching countrycode from countries table to location table inorder to create a foreign key  
select c.country_code
from location2csv as l
join countries as c
using(country_id);

                    
UPDATE temp.location2csv
			join countries
			on location2csv.country_id =countries.country_id
            SET location2csv.country_code =countries.country_code
			where location2csv.country_code is null;

#step 6		
#creating Reporting employee column
#Created a new table reports to find out who is reporting to who(higher position) interms of jobId
CREATE  TABLE temp.reports
(employee_id INT ,
`full name` text,
empJobID int, 
empLocID int,
LocLocCod int,
OrgJobID int,
Reports_to text);

#inserting values
INSERT INTO temp.reports(employee_id ,`full name` ,empJobID , empLocID,LocLocCod ,OrgJobID ,Reports_to)
SELECT e.employee_id,concat(e.first_name,' ',e.last_name) as `full name`, e.job_id as empJobID, e.location_id as empLocID, l.location_code LocLocCod, os.job_id as OrgJobID, os.Reports_to
FROM employees AS e
JOIN location2csv AS l
USING(location_id)
JOIN orgstructure_v2csv AS os
USING(job_id);

select * from temp.reports;

#step 7
#Finding reporting managerid that maches to each employee at each location
#Used self join method to find relation btw employee and his/her 
SELECT * from reports as r1
left join reports as r2
on r1.Reports_to=r2.empjobID
and r1.locloccod=r2.locloccod;
#using the findings, created a duplicated table of employee with reporting manager details
create table temp.employee_dupl as (
with c as (
SELECT r1.employee_id as emp_id, r2.employee_id as report_managerID 
from temp.reports as r1
left join temp.reports as r2
on r1.Reports_to=r2.empjobID
and r1.locloccod=r2.locloccod)
select * from employees e
left join c on c.emp_id = e.employee_id); 


select * from temp.employee_dupl;
#dropping manager id column from employee duplicate table  
ALTER TABLE  temp.employee_dupl
drop manager_id;        

#Step 7 - Modifying required temperory schema tables to match with requirements of 
#tables of vivaKHR database, which is created based on customer requirement.

#step 7.1
#Add department_id to orgstructure table from departments table
#Also changing datatype of reports_to column to match with vivakhr 
 SELECT os.*, d.`department_id`
 FROM temp.orgstructure_v2csv AS os
 LEFT JOIN  temp.`departments2csv` AS d
 USING (`department_name`);
 
 ALTER TABLE temp.orgstructure_v2csv
 ADD department_id INT;
 
 UPDATE temp.orgstructure_v2csv
			LEFT JOIN temp.`departments2csv` 
			on orgstructure_v2csv.department_name =departments2csv.department_name
            SET orgstructure_v2csv.department_id =departments2csv.department_id
			where orgstructure_v2csv.department_id is null;
 


#Assumption - Assumes that presedent's report_to column is 0 because president reports to no one
#converting reports with null to 0
UPDATE temp.orgstructure_v2csv
SET Reports_to = CASE
    WHEN Reports_to = '' THEN '0'
    ELSE Reports_to
END;

# changing datatype of reports_to column
ALTER TABLE temp.orgstructure_v2csv
modify COLUMN Reports_to INT ;

SELECT * FROM temp.orgstructure_v2csv;



#step 
#Dropping unnecessary tables


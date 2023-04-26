#Step 1 Handling Duplicates
# checking if there is any duplicate values in each table

#organizational_structure Table
 select * 
 from `vivakhr`.`organizational_structure`
 GROUP BY `job_id` 
 HAVING COUNT(*) > 1;
 
 # there is no dulicates found 
 
 #`region` table
 
 select * 
 from `vivakhr`.`region`
 GROUP BY `region_id`
 HAVING COUNT(*) > 1;
 
 # There is no duplicates in region table
 
 #`location_emp_details` table
 
 select * 
 from `vivakhr`.`location_emp_details`
 GROUP BY `job_id`,`location_code`
 HAVING COUNT(*) > 1; 
 
 #There is no duplicates in this table
 
 #`location` table
 
  select * 
 from `vivakhr`.`location`
 GROUP BY `location_id`
 HAVING COUNT(*) > 1; 
 
  #There is no duplicates in this table
  
 # `employee` table
 select * 
 from `vivakhr`.`employee`
 GROUP BY `employee_id`
 HAVING COUNT(*) > 1; 
 
 #There is no duplicates in this table
 
 #`department`
 
 select * 
 from `vivakhr`. `department`
 GROUP BY `department_id`
 HAVING COUNT(*) > 1;
 
 #There is no dulicates in this table
  
  #`countries`
  
 select * 
 from `vivakhr`. `countries`
 GROUP BY `country_code`
 HAVING COUNT(*) > 1;
 
 
# There is no  duplicates




# Dependent table have duplicates


#step 2 modifying  phone number column in employee table


select*
from vivakhr.employee
Left Join
vivakhr.location as l
join vivakhr.countries
using (country_code)
using(Location_id);


#step 2.1 Adding a new column in employee table  country phone code
#compared location and employee table with location_id then using country id in location table,
#added values to new country_phone_code in  employee table.

ALTER TABLE `vivakhr`.`employee`
ADD country_phone_code TEXT ;

UPDATE `vivakhr`.`employee`
			join vivakhr.location
			on employee.location_id =location.location_id
            SET employee.country_phone_code = CASE WHEN location.country_id = 'US' THEN '+1'
							  WHEN location.country_id = 'CA' THEN '+1'
                              WHEN location.country_id = 'UK' THEN '+44'
                              WHEN location.country_id = 'DE' THEN '+45'
                              ELSE NULL END
			where employee.country_phone_code is null;
            
SELECT * FROM `vivakhr`.`employee`;

#step 2.3 changing current messed phone number format into proper format
UPDATE `vivakhr`.`employee`
SET `phone_number`= REPLACE (`phone_number`,'.','-');

#step 2.4 Finally updating  phone number column into the required format by adding country code into it
#Also treated missing values in phone number column           
UPDATE `vivakhr`.`employee`
SET `phone_number`= CASE WHEN `phone_number` = '' then 'Not Provided'
						ELSE concat(country_phone_code,'-',phone_number) END;
                        
#step 2.5 Dropping temporarly created country_phone_code column from employee table	
ALTER TABLE `vivakhr`.`employee`
DROP country_phone_code;				
 
SELECT * FROM `vivakhr`.`employee`; 

#Step 3 Treating missing values

#step 3.1 checking missing values in other columns in employee table other than phone number(which is already treated)
SELECT * FROM `vivakhr`.`employee`
WHERE `salary`= ''  OR `report_to`=NULL;
#there are missing values in salary, report to , and phone number, 
#where phone number is already treated while altering phone number column

#Step 3.1.1Treating missing salary
UPDATE `vivakhr`.`employee`
			join `vivakhr`.`organizational_structure`
			on employee.job_id = organizational_structure.job_id
            SET employee.salary = (`organizational_structure`.`max_salary`+`organizational_structure`.`min_salary`)/2
			where employee.salary=''; 
#Assumption 2- The missing values in salary colum in employee is filled by assuming the salary,
# of an employee is the average of min salary and max salary considering the job position

#Step 3.1.1Treating missing values in report_to column
#Missing values were found in the Vice presidents of all locations other than the head office. 
#all the vice presidents directly reports to the President of the orginization and his employee id is 100
#missing columns can be replaced with 100 as the report_to column

SELECT * FROM `vivakhr`.`employee`
WHERE`job_id` IN(1,2,3);
#Replacing values
UPDATE `vivakhr`.`employee`
SET employee.report_to = 100 #Employee id of the president
WHERE `job_id` IN(2,3); 

UPDATE `vivakhr`.`employee`
SET employee.report_to = 0 #Reports to nobody as per Assumption 1
WHERE `job_id` =1; 

SELECT * FROM `vivakhr`.`employee`;


#Step 4 - Task 4
SELECT * FROM `vivakhr`.`employee`;
#Q1
#calculating the time difference (in months) between the hire date and the current date for each employee and updating the column.
UPDATE `vivakhr`.`employee`
SET `employee`.`experience_at_VivaK`= PERIOD_DIFF(DATE_FORMAT(current_date(), '%Y%m'), DATE_FORMAT(hire_date, '%Y%m'));

#Q2
# Updating rating of each employee using  random numbers with two decimal places between 0 to 10  
UPDATE `vivakhr`.`employee`
SET last_performance_rating = ROUND(RAND()*10,2);

#Q3
#Salary_after_increment is calcualted using the given formula
#for that a new column rating_increment is added
ALTER TABLE `vivakhr`.`employee`
ADD rating_increment double(3,2);

#rating_increment column is populated using the given table of conditions 
UPDATE `vivakhr`.`employee`
SET rating_increment = case when last_performance_rating >=0.9 then 0.15
							 when last_performance_rating >=0.8 then 0.12
                             when last_performance_rating >=0.7 then 0.10
                             when last_performance_rating >=0.6 then 0.08
                             when last_performance_rating >=0.5 then 0.05
                             ELSE 0.02 END
WHERE rating_increment IS NULL;

#salary_after_increment is calculated 

UPDATE `vivakhr`.`employee`
SET `salary_after_increment`= salary * (1 + (0.01 * experience_at_VivaK) + rating_increment);

#temp column rating_increment is deleted from the table
ALTER TABLE `vivakhr`.`employee`
DROP rating_increment;

#the salary_after_increment is checked against the maximum salary to make sure it is
#not going above the maximun salary of that particular job titile if that happens the salary_after_increment
#column is replaced with the maximum salary for that role by using orgnizational_structure table

UPDATE `vivakhr`.`employee`
			join `vivakhr`.`organizational_structure`
			on employee.job_id = organizational_structure.job_id
            SET salary_after_increment = CASE WHEN salary_after_increment< max_salary THEN salary_after_increment
											  ELSE 	max_salary END
			where salary_after_increment is not null; 
                             




#Q5
#Updating the email id of each employee by replacing the part after @ with '@vivaK.com'
#substring index function is used to keep the part before @ and and concat is used to join '@vivaK.com' after
UPDATE `vivakhr`.`employee`
SET email = CONCAT(SUBSTRING_INDEX(email, '@', 1), '@vivaK.com');

SELECT * FROM `vivakhr`.`employee`;

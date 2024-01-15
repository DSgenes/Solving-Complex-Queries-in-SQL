/*  Using different techniques for solving complex sql queries.  */  -- Query 1:  --Write a SQL query to fetch all the duplicate records from a table.  --Note: Record is considered duplicate if a user name is present more than once.  --Approach: Partition the data based on user name and then give a row number to each of the partitioned user name. --If a user name is exists more than once then it would have multiple row numbers. Using the row number which is  --other than 1, we can identify the duplicate records.  drop table users; create table users ( user_id int primary key, user_name varchar(30) not null, email varchar(50));  insert into users values (1, 'Robert', 'robert@gmail.com'), (2, 'Jasmine', 'jasmine@gmail.com'), (3, 'Rose', 'rose@gmail.com'), (4, 'Stewart', 'stewart@gmail.com'), (5, 'Stewart', 'stewart@gmail.com');  select * from users;  select user_id, user_name, email from(    select *,    row_number() over (partition by user_name order by user_id) as rn    from users    ) x  where x.rn > 1; ----------------------------------------------------------------------------------------------------------------- --Query 2

--Write a SQL query to fetch the second last record from employee table.

--Table Name: EMPLOYEE

--Approach: Using window function sort the data in descending order based on employee id. Provide a row number
--to each of the record and fetch the record having row number as 2.

drop table employee;

create table employee
( emp_ID int primary key
, emp_NAME varchar(50) not null
, DEPT_NAME varchar(50)
, SALARY int);

insert into employee 
values(101, 'Mohan', 'Admin', 4000),
      (102, 'Rajkumar', 'HR', 3000),
      (103, 'Akbar', 'IT', 4000),
      (104, 'Dorvin', 'Finance', 6500),
      (105, 'Rohit', 'HR', 3000),
      (106, 'Rajesh',  'Finance', 5000),
      (107, 'Preet', 'HR', 7000),
      (108, 'Maryam', 'Admin', 4000),
      (109, 'Sanjay', 'IT', 6500),
      (110, 'Vasudha', 'IT', 7000),
      (111, 'Melinda', 'IT', 8000),
      (112, 'Komal', 'IT', 10000),
      (113, 'Gautham', 'Admin', 2000),
      (114, 'Manisha', 'HR', 3000),
      (115, 'Chandni', 'IT', 4500),
      (116, 'Satya', 'Finance', 6500),
      (117, 'Adarsh', 'HR', 3500),
      (118, 'Tejaswi', 'Finance', 5500),
      (119, 'Cory', 'HR', 8000),
      (120, 'Monica', 'Admin', 5000),
      (121, 'Rosalin', 'IT', 6000),
      (122, 'Ibrahim', 'IT', 8000),
      (123, 'Vikram', 'IT', 8000),
      (124, 'Dheeraj', 'IT', 11000);

select *
from employee

select *,
row_number() over (order by emp_id desc) as rn
from employee 
-----------------------------------------------
select emp_id, emp_name, dept_name, salary
from (
select *,
row_number() over (order by emp_id desc) as rn
from employee e) x
where x.rn = 2;
-------------------------------------------------------------------------------------------------------- --Query 3

--Write a SQL query to display only the details of employees who either earn the highest salary or the lowest salary 
--in each department from the employee table.

--Approach: Write a sub query which will partition the data based on each department and then identify the record with
--maximum and minimum salary for each of the partitioned department. Finally, from the main query fetch only the data
--which matches the maximum and minimum salary returned from the sub query.

select *,
max(salary) over (partition by dept_name) as max_salary,
min(salary) over (partition by dept_name) as min_salary
from employee
-----------------------------------------------------------
select x.*
from employee e
join (select *,
max(salary) over (partition by dept_name) as max_salary,
min(salary) over (partition by dept_name) as min_salary
from employee) x
on e.emp_id = x.emp_id
and (e.salary = x.max_salary or e.salary = x.min_salary)
order by x.dept_name, x.salary; ---------------------------------------------------------------------------------------------------------------- --Query 4  --From the doctors table, fetch the details of doctors who work in the same hospital but in different speciality.  --Additional Query : Write SQL query to fetch the doctors who work in same hospital irrespective of their speciality.  create table doctors ( id int primary key, name varchar(50) not null, speciality varchar(100), hospital varchar(50), city varchar(50), consultation_fee int );  insert into doctors values (1, 'Dr. Shashank', 'Ayurveda', 'Apollo Hospital', 'Bangalore', 2500), (2, 'Dr. Abdul', 'Homeopathy', 'Fortis Hospital', 'Bangalore', 2000), (3, 'Dr. Shwetha', 'Homeopathy', 'KMC Hospital', 'Manipal', 1000), (4, 'Dr. Murphy', 'Dermatology', 'KMC Hospital', 'Manipal', 1500), (5, 'Dr. Farhana', 'Physician', 'Gleneagles Hospital', 'Bangalore', 1700), (6, 'Dr. Maryam', 'Physician', 'Gleneagles Hospital', 'Bangalore', 1500);  select * from doctors  --we need to compare each record in this table with every other of this table.  select d1.*  from doctors d1 join doctors d2 on d1.id <> d2.id and d1.hospital = d2.hospital and d1.speciality <> d2.speciality; 
--Now find the doctors who work in same hospital irrespective of their speciality.

--Solution:

select d1.name, d1.speciality,d1.hospital
from doctors d1
join doctors d2
on d1.hospital = d2.hospital
and d1.id <> d2.id;

------------------------------------------------------------------------------------------------------- --Query 5  --From the login details_table, fetch the users who logged in consecutively 3 or more times.  --Approach : We need to fetch users who have appeared 3 or more times consecutively in login details table.  --There is a window function which can be used to fetch data from the following record. Use that window function  --to compare the user name in current row with user name in the next row and in the row following the next row.  --If it matches then fetch those records.  create table login_details( login_id int primary key, user_name varchar(50) not null, login_date date);  insert into login_details values (101, 'Michael', '2021-08-21'), (102, 'James', '2021-08-21'), (103, 'Stewart', '2021-08-22'), (104, 'Stewart', '2021-08-22'), (105, 'Stewart', '2021-08-22'), (106, 'Michael', '2021-08-23'), (107, 'Michael', '2021-08-23'), (108, 'Stewart', '2021-08-24'), (109, 'Stewart', '2021-08-24'), (110, 'James', '2021-08-25'), (111, 'James', '2021-08-25'), (112, 'James', '2021-08-26'), (113, 'James', '2021-08-27');  select * from login_details  select *, case when user_name = lead(user_name) over(order by login_id)      and user_name = lead(user_name, 2) over(order by login_id) 	 then user_name 	 else null end as repeated_users from login_details;  --we only want the repeated users not the values as null  select user_name from( select *, case when user_name = lead(user_name) over(order by login_id)      and user_name = lead(user_name, 2) over(order by login_id) 	 then user_name 	 else null end as repeated_users from login_details) x where x.repeated_users is not null;  --we dont want james value to be repeated so  select distinct user_name from( select *, case when user_name = lead(user_name) over(order by login_id)      and user_name = lead(user_name, 2) over(order by login_id) 	 then user_name 	 else null end as repeated_users from login_details) x where x.repeated_users is not null; ----------------------------------------------------------------------------------------------------------- --Query 6  --From the weather table, fetch all the records when London had extremely cold temperature for 3 consecutive days or more.  --Note: Weather is considered to be extremely cold then its temperature is less than zero.  --Approach: First using a sub query identify all the records where the temperature was very cold and then use a main query --to fetch only the records returned as very cold from the sub query. You will not only need to compare the records following --the current row but also need to compare the records preceding the current row. And may also need to compare rows preceding  --and following the current row. Identify a window function which can do this comparison pretty easily.  create table weather ( id int, city varchar(50), temperature int, day date );  insert into weather values (1, 'London', -1, '2021-01-01'), (2, 'London', -2, '2021-01-02'), (3, 'London', 4, '2021-01-03'), (4, 'London', 1, '2021-01-04'), (5, 'London', -2, '2021-01-05'), (6, 'London', -5, '2021-01-06'), (7, 'London', -7, '2021-01-07'), (8, 'London', 5, '2021-01-08');  select * from weather  select id, city, temperature, day from (     select *,         case when temperature < 0               and lead(temperature) over(order by day) < 0               and lead(temperature,2) over(order by day) < 0         then 'Yes'         when temperature < 0               and lead(temperature) over(order by day) < 0               and lag(temperature) over(order by day) < 0         then 'Yes'         when temperature < 0               and lag(temperature) over(order by day) < 0               and lag(temperature,2) over(order by day) < 0         then 'Yes'         end as flag     from weather) x where x.flag = 'Yes'; ---------------------------------------------------------------------------------------------------------------- --Query 7

-- From the students table, write a SQL query to interchange the adjacent student names.

--Approach: Assuming id will be a sequential number always. If id is an odd number then fetch the student name 
--from the following record. If id is an even number then fetch the student name from the preceding record.Try
--to figure out the window function which can be used to fetch the preceding the following record data. 

--If the last record is an odd number then it wont have any adjacent even number hence figure out a way to not 
--interchange the last record data

drop table students;
create table students
(
id int primary key,
student_name varchar(50) not null
);

insert into students values
(1, 'James'),
(2, 'Michael'),
(3, 'George'),
(4, 'Stewart'),
(5, 'Robin');

select * from students;

select id,student_name,
case when id%2 <> 0 then lead(student_name,1,student_name) over(order by id)
when id%2 = 0 then lag(student_name) over(order by id) end as new_student_name
from students;
------------------------------------------------------------------------------------------------- --Query 8  --From the following 3 tables (event_category, physician_speciality, patient_treatment), write a SQL query to get the --histogram of specialties of the unique physicians who have done the procedures but never did prescribe anything.  --Approach: Using the patient treatment and event category table, identify all the physicians who have done “Prescription”.  --Have this recorded in a sub query.Then in the main query join the patient treatment, event category and physician speciality  --table to identify all the physician who have done “Procedure”. From these physicians, remove those physicians you got from --sub query to return the physicians who have done Procedure but never did Prescription.  create table event_category (   event_name varchar(50),   category varchar(100) );  create table physician_speciality (   physician_id int,   speciality varchar(50) );  create table patient_treatment (   patient_id int,   event_name varchar(50),   physician_id int );  insert into event_category  values ('Chemotherapy','Procedure'),        ('Radiation','Procedure'),        ('Immunosuppressants','Prescription'),        ('BTKI','Prescription'),        ('Biopsy','Test');  drop table physician_speciality insert into physician_speciality  values (1000,'Radiologist'),        (2000,'Oncologist'),        (3000,'Hermatologist'),        (4000,'Oncologist'),        (5000,'Pathologist'), 	   (6000,'Oncologist');  insert into patient_treatment  values (1,'Radiation', 1000),        (2,'Chemotherapy', 2000),        (1,'Biopsy', 1000),        (3,'Immunosuppressants', 2000),        (4,'BTKI', 3000),        (5,'Radiation', 4000),        (4,'Chemotherapy', 2000),        (1,'Biopsy', 5000),        (6,'Chemotherapy', 6000);  select * from patient_treatment; select * from event_category; select * from physician_speciality;  select ps.speciality, count(1) as speciality_count from patient_treatment pt join event_category ec on ec.event_name = pt.event_name join physician_speciality ps on ps.physician_id = pt.physician_id where ec.category = 'Procedure' and pt.physician_id not in (select pt2.physician_id 							from patient_treatment pt2 							join event_category ec on ec.event_name = pt2.event_name 							where ec.category in ('Prescription')) group by ps.speciality; ---------------------------------------------------------------------------------------------------------- --Query 9  --Find the top 2 accounts with the maximum number of unique patients on a monthly basis.  --Note: Prefer the account if with the least value in case of same number of unique patients  --Approach: First convert the date to month format since we need the output specific to each --month. Then group together all data based on each month and account id so you get the  --total no of patients belonging to each account per month basis.  --Then rank this data as per no of patients in descending order and account id in ascending  --order so in case there are same no of patients present under multiple account if then the  --ranking will prefer the account if with lower value. Finally, choose upto 2 records only per  --month to arrive at the final output.  drop table patient_logs create table patient_logs (   account_id int,   date date,   patient_id int );  insert into patient_logs  values     (1, '2020-01-02', 100),            (1, '2020-01-27', 200),            (2, '2020-01-01', 300),            (2, '2020-01-21', 400),            (2, '2020-01-21', 300),            (2, '2020-01-01', 500),            (3, '2020-01-20', 400),            (1, '2020-03-04', 500),            (3, '2020-01-20', 450);   select DateName(MONTH, date) as month, account_id, patient_id
from patient_logs;
----------------------------------------------------------------------------
--all this data is grouped and it'll count how many patients are present

select month, account_id, count(1) as no_of_patients
from(
     select distinct DateName(MONTH, date) as month, account_id, patient_id
from patient_logs) pl 
group by month, account_id;
----------------------------------------------------------------------------
select month, account_id, no_of_patients
from( 
     select *,
     rank() over (partition by month order by no_of_patients desc, account_id) as rnk
     from(
         select month, account_id, count(1) as no_of_patients
         from(
            select distinct DateName(MONTH, date) as month, account_id, patient_id
            from patient_logs) pl 
            group by month, account_id) x 
		   ) temp
where temp.rnk in (1,2);
----------------------------------------------------------------------------------------------

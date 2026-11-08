-- lab 4a: built-in functions
use employees;
-- question 1 : What is the avg of each employee
select s.emp_no, avg(s.salary) as average_salary
from salaries as s
group by s.emp_no;
--  question 2: How much was each employee paid in total?
select s.emp_no, sum(s.salary) as total_salary
from salaries as s
group by s.emp_no;
-- question 3: Minimum, maximum and total salaries of each department
select d.dept_name,
       min(s.salary) as min_salary,
       max(s.salary) as max_salary,
       sum(s.salary) as total_salary
from departments as d
join dept_emp as de on d.dept_no = de.dept_no
join salaries as s on de.emp_no = s.emp_no
group by d.dept_no, d.dept_name;
-- question 4:which departments have paid more than 20 billion dollars for their employees?
select d.dept_name, sum(s.salary) as total_salary
from departments as d
join dept_emp as de on d.dept_no = de.dept_no
join salaries as s on de.emp_no = s.emp_no
group by d.dept_no, d.dept_name
having sum(s.salary) > 20000000000;
-- question 5: total salaries of male employees in each department?
select d.dept_name, sum(s.salary) as total_salary
from departments as d
join dept_emp as de on d.dept_no = de.dept_no
join employees as e on de.emp_no = e.emp_no
join salaries as s on e.emp_no = s.emp_no
where e.gender = 'M'
group by d.dept_no, d.dept_name;
-- question 6: total salaries of department managers for each department, from highest to lowest?
select d.dept_name, sum(s.salary) as total_salary
from departments as d
join dept_manager as dm on d.dept_no = dm.dept_no
join salaries as s on dm.emp_no = s.emp_no
group by d.dept_no, d.dept_name
order by total_salary desc;

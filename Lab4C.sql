
-- lab 4c: views
use employees;


-- question 1: who have the same name as the managers of the "Finance" department?
create view lab4c_finance_manager_names as
select distinct m.first_name, m.last_name
from employees as m
join dept_manager as dm on m.emp_no = dm.emp_no
join departments as d on dm.dept_no = d.dept_no
where d.dept_name = 'Finance';

select e.emp_no, e.first_name, e.last_name
from employees as e
join lab4c_finance_manager_names as fm
    on e.first_name = fm.first_name
    and e.last_name = fm.last_name;


-- question 2: who in the "Production" department were hired after the promotion of the last manager in that department?
create view lab4c_production_last_manager as
select d.dept_no, max(dm.from_date) as last_promotion_date
from departments as d
join dept_manager as dm on d.dept_no = dm.dept_no
where d.dept_name = 'Production'
group by d.dept_no;

select e.emp_no, e.first_name, e.last_name, e.hire_date
from employees as e
join dept_emp as de on e.emp_no = de.emp_no
join lab4c_production_last_manager as pm on de.dept_no = pm.dept_no
where e.hire_date > pm.last_promotion_date
order by e.hire_date asc;


-- question 3: find the average salary of each department, from highest to lowest
create view lab4c_employee_avg_salary as
select s.emp_no, avg(s.salary) as avg_salary
from salaries as s
group by s.emp_no;

select d.dept_name, avg(a.avg_salary) as average_salary
from departments as d
join dept_emp as de on d.dept_no = de.dept_no
join lab4c_employee_avg_salary as a on de.emp_no = a.emp_no
group by d.dept_no, d.dept_name
order by average_salary desc;


-- question 4: find the average salary for each type of Engineer, from highest to lowest
create view lab4c_engineer_avg_salary as
select t.title, t.emp_no, avg(s.salary) as avg_salary
from titles as t
join salaries as s on t.emp_no = s.emp_no
where t.title like '%Engineer%'
group by t.title, t.emp_no;

select a.title, avg(a.avg_salary) as average_salary
from lab4c_engineer_avg_salary as a
group by a.title
order by average_salary desc;


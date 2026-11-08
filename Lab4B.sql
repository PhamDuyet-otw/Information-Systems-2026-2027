
-- lab 4b: subqueries
use employees;


-- question 1: who have the same name as the managers of the "Finance" department?
select e.emp_no, e.first_name, e.last_name
from employees as e
where exists (
    select 1
    from employees as m
    join dept_manager as dm on m.emp_no = dm.emp_no
    join departments as d on dm.dept_no = d.dept_no
    where d.dept_name = 'Finance'
      and e.first_name = m.first_name
      and e.last_name = m.last_name
);


-- question 2: who in the "Production" department were hired after the promotion of the last manager in that department?
select e.emp_no, e.first_name, e.last_name, e.hire_date
from employees as e
join dept_emp as de on e.emp_no = de.emp_no
join departments as d on de.dept_no = d.dept_no
where d.dept_name = 'Production'
  and e.hire_date > (
      select max(dm.from_date)
      from dept_manager as dm
      where dm.dept_no = d.dept_no
  )
order by e.hire_date asc;


-- question 3: find the average salary of each department, from highest to lowest
select d.dept_name, avg(s.avg_salary) as average_salary
from departments as d
join dept_emp as de on d.dept_no = de.dept_no
join (
    select emp_no, avg(salary) as avg_salary
    from salaries
    group by emp_no
) as s on de.emp_no = s.emp_no
group by d.dept_no, d.dept_name
order by average_salary desc;


-- question 4: find the average salary for each type of Engineer, from highest to lowest
select t.title, avg(t.avg_salary) as average_salary
from (
    select ti.title, ti.emp_no, avg(s.salary) as avg_salary
    from titles as ti
    join salaries as s on ti.emp_no = s.emp_no
    where ti.title like '%Engineer%'
    group by ti.title, ti.emp_no
) as t
group by t.title
order by average_salary desc;

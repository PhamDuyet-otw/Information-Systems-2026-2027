SELECT * FROM employees LIMIT 5;
SELECT * FROM departments;
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM employees
LIMIT 5;
SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name
FROM employees AS e
JOIN dept_emp AS de
    ON e.emp_no = de.emp_no
JOIN departments AS d
    ON de.dept_no = d.dept_no
WHERE d.dept_name = 'Sales'
  AND de.to_date = '9999-01-01';
SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name
FROM employees AS e
JOIN dept_emp AS de
    ON e.emp_no = de.emp_no
JOIN departments AS d
    ON de.dept_no = d.dept_no
WHERE d.dept_name = 'Finance'
    AND e.gender = 'M'
    AND de.to_date = '9999-01-01';
SELECT s.salary
FROM employees AS e
JOIN dept_emp AS de
    ON e.emp_no = de.emp_no
JOIN departments AS d
    ON de.dept_no = d.dept_no
JOIN salaries AS s
    ON e.emp_no = s.emp_no
WHERE e.gender = 'F'
    AND d.dept_name = 'Marketing'
    AND de.to_date = '9999-01-01'
    AND s.to_date = '9999-01-01';
SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name
FROM employees AS e
JOIN dept_emp AS de
    ON e.emp_no = de.emp_no
JOIN dept_manager AS dm
    ON de.dept_no = dm.dept_no
JOIN employees AS m
    ON dm.emp_no = m.emp_no
WHERE e.last_name = m.last_name
    AND de.to_date = '9999-01-01'
    AND dm.to_date = '9999-01-01'
    AND e.emp_no <> m.emp_no;
SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name
FROM employees AS e
JOIN dept_manager AS dm
    ON e.emp_no = dm.emp_no
GROUP BY e.emp_no, e.first_name, e.last_name
HAVING COUNT(*) >= 2;
SELECT emp_no, COUNT(*) AS management_count
FROM dept_manager
GROUP BY emp_no
ORDER BY management_count DESC;
SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name
FROM employees AS e
JOIN salaries AS s
    ON e.emp_no = s.emp_no
WHERE s.salary > 100000
GROUP BY e.emp_no, e.first_name, e.last_name;
SELECT DISTINCT d.dept_name
FROM departments AS d
JOIN dept_emp AS de
    ON d.dept_no = de.dept_no
JOIN salaries AS s
    ON de.emp_no = s.emp_no
WHERE s.salary > 100000;
SELECT TABLE_NAME,
       COLUMN_NAME,
       REFERENCED_TABLE_NAME,
       REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'employees'
  AND REFERENCED_TABLE_NAME = 'departments';
  CREATE DATABASE employees_lab3;
SHOW DATABASES LIKE 'employees_lab3';
CREATE TABLE employees_lab3.departments
LIKE employees.departments;
INSERT INTO employees_lab3.departments
SELECT * FROM employees.departments;
SELECT *
FROM employees_lab3.departments;
CREATE TABLE employees_lab3.dept_emp
LIKE employees.dept_emp;
INSERT INTO employees_lab3.dept_emp
SELECT * FROM employees.dept_emp;
SELECT 'Original' AS source, COUNT(*) AS total_rows
FROM employees.dept_emp
UNION ALL
SELECT 'Lab3' AS source, COUNT(*) AS total_rows
FROM employees_lab3.dept_emp;
CREATE TABLE employees_lab3.dept_manager
LIKE employees.dept_manager;
INSERT INTO employees_lab3.dept_manager
SELECT * FROM employees.dept_manager;
SELECT 'Original' AS source, COUNT(*) AS total_rows
FROM employees.dept_manager
UNION ALL
SELECT 'Lab3', COUNT(*)
FROM employees_lab3.dept_manager;
SELECT 'dept_emp' AS table_name,
       COUNT(*) AS collision_groups
FROM (
    SELECT emp_no,
           CASE
               WHEN dept_no IN ('d005', 'd008') THEN 'd010'
               WHEN dept_no IN ('d001', 'd007') THEN 'd011'
               ELSE dept_no
           END AS new_dept_no
    FROM employees_lab3.dept_emp
    GROUP BY emp_no, new_dept_no
    HAVING COUNT(*) > 1
) AS conflicts

UNION ALL

SELECT 'dept_manager' AS table_name,
       COUNT(*) AS collision_groups
FROM (
    SELECT emp_no,
           CASE
               WHEN dept_no IN ('d005', 'd008') THEN 'd010'
               WHEN dept_no IN ('d001', 'd007') THEN 'd011'
               ELSE dept_no
           END AS new_dept_no
    FROM employees_lab3.dept_manager
    GROUP BY emp_no, new_dept_no
    HAVING COUNT(*) > 1
) AS conflicts;
SELECT COUNT(*) AS remaining_collisions
FROM (
    SELECT emp_no,
           CASE
               WHEN dept_no IN ('d005', 'd008') THEN 'd010'
               WHEN dept_no IN ('d001', 'd007') THEN 'd011'
               ELSE dept_no
           END AS new_dept_no,
           from_date
    FROM employees_lab3.dept_emp
    GROUP BY emp_no, new_dept_no, from_date
    HAVING COUNT(*) > 1
) AS conflicts;
INSERT INTO employees_lab3.departments
    (dept_no, dept_name)
VALUES
    ('d010', 'Research and Development'),
    ('d011', 'Marketing and Sales');
CREATE TABLE employees_lab3.department_merge_map (
    old_dept_no CHAR(4) PRIMARY KEY,
    new_dept_no CHAR(4) NOT NULL,
    FOREIGN KEY (old_dept_no)
        REFERENCES employees_lab3.departments(dept_no),
    FOREIGN KEY (new_dept_no)
        REFERENCES employees_lab3.departments(dept_no)
);
INSERT INTO employees_lab3.department_merge_map
    (old_dept_no, new_dept_no)
VALUES
    ('d005', 'd010'),
    ('d008', 'd010'),
    ('d001', 'd011'),
    ('d007', 'd011');
SELECT *
FROM employees_lab3.department_merge_map;
CREATE VIEW employees_lab3.merged_departments AS
SELECT dept_no, dept_name
FROM employees_lab3.departments
WHERE dept_no NOT IN (
    SELECT old_dept_no
    FROM employees_lab3.department_merge_map
);
SELECT *
FROM employees_lab3.merged_departments
ORDER BY dept_no;
CREATE VIEW employees_lab3.merged_dept_emp AS
SELECT
    de.emp_no,
    COALESCE(m.new_dept_no, de.dept_no) AS dept_no,
    de.from_date,
    de.to_date,
    de.dept_no AS original_dept_no
FROM employees_lab3.dept_emp AS de
LEFT JOIN employees_lab3.department_merge_map AS m
    ON de.dept_no = m.old_dept_no;
SELECT *
FROM employees_lab3.merged_dept_emp
LIMIT 10;
CREATE VIEW employees_lab3.merged_dept_manager AS
SELECT
    dm.emp_no,
    COALESCE(m.new_dept_no, dm.dept_no) AS dept_no,
    dm.from_date,
    dm.to_date,
    dm.dept_no AS original_dept_no
FROM employees_lab3.dept_manager AS dm
LEFT JOIN employees_lab3.department_merge_map AS m
    ON dm.dept_no = m.old_dept_no;
SELECT *
FROM employees_lab3.merged_dept_manager
ORDER BY dept_no, emp_no;
SELECT 'Original' AS source, COUNT(*) AS total_rows
FROM employees_lab3.dept_manager

UNION ALL

SELECT 'Merged View', COUNT(*)
FROM employees_lab3.merged_dept_manager;
SELECT 'Departments' AS object_name,
       COUNT(*) AS total_rows
FROM employees_lab3.merged_departments

UNION ALL

SELECT 'Employees',
       COUNT(*)
FROM employees_lab3.merged_dept_emp

UNION ALL

SELECT 'Managers',
       COUNT(*)
FROM employees_lab3.merged_dept_manager;
SELECT 'Departments' AS object_name,
       COUNT(*) AS total_rows
FROM employees_lab3.merged_departments

UNION ALL

SELECT 'Employees',
       COUNT(*)
FROM employees_lab3.merged_dept_emp

UNION ALL

SELECT 'Managers',
       COUNT(*)
FROM employees_lab3.merged_dept_manager;
SELECT 'Employees' AS object_name,
       COUNT(*) AS old_code_rows
FROM employees_lab3.merged_dept_emp
WHERE dept_no IN ('d005', 'd008', 'd001', 'd007')

UNION ALL

SELECT 'Managers',
       COUNT(*)
FROM employees_lab3.merged_dept_manager
WHERE dept_no IN ('d005', 'd008', 'd001', 'd007');
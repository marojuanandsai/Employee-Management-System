-- Table 1: Job Department
use employee_management_system
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);salarybonus
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
)

-- (1.) EMPLOYEE INSIGHTS--

-- 1. 	How many unique employees are currently in the system --

SELECT * FROM employee

SELECT COUNT(DISTINCT emp_ID) AS TotalUniqueEmployees
FROM employee;

-- 2.	Which departments have the highest number of employees--

SELECT * FROM jobdepartment

 SELECT jd.jobdept AS Department,
       COUNT(e.emp_ID) AS TotalEmployees
FROM employee e
JOIN jobdepartment jd
     ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY TotalEmployees DESC;



WITH dept_counts AS (
    SELECT jd.jobdept AS Department,
           COUNT(e.emp_ID) AS TotalEmployees
    FROM employee e
    JOIN jobdepartment jd
        ON e.Job_ID = jd.Job_ID
    GROUP BY jd.jobdept
),
max_emp AS (
    SELECT MAX(TotalEmployees) AS MaxTotal
    FROM dept_counts
)
SELECT Department, TotalEmployees
FROM dept_counts
WHERE TotalEmployees = (SELECT MaxTotal FROM max_emp);

-- 3. The average salary per department--

SELECT * FROM salarybonus

SELECT jd.jobdept AS Department,
       AVG(sb.amount) AS AverageSalary
FROM employee e
JOIN jobdepartment jd 
        ON e.Job_ID = jd.Job_ID
JOIN salarybonus sb 
        ON e.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

-- 4.  The top 5 highest-paid employees --

SELECT e.emp_ID, e.firstname, e.lastname, jd.jobdept AS Department, sb.amount AS Salary
FROM employee e
JOIN jobdepartment jd ON e.Job_ID = jd.Job_ID
JOIN salarybonus sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;


-- 5.  The total salary expenditure across the company --

SELECT SUM(sb.amount) AS TotalSalaryExpenditure
FROM employee e
JOIN salarybonus sb 
      ON e.Job_ID = sb.Job_ID;


-- JOB ROLE AND DEPARTMENT ANALYSIS --

-- 1. different job roles exist in each department --

SELECT jd.jobdept AS Department,
       COUNT(jd.name) AS TotalJobRoles
FROM jobdepartment jd
GROUP BY jd.jobdept;

-- 2. ●	What is the average salary range per department --

SELECT jd.jobdept AS Department,
       AVG(sb.amount) AS AverageSalary
FROM jobdepartment jd
JOIN salarybonus sb
      ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

-- 3. job roles offer the highest salary --

SELECT jd.name AS JobRole,
       jd.jobdept AS Department,
       sb.amount AS Salary
FROM jobdepartment jd
JOIN salarybonus sb 
       ON jd.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 4;


-- 4. Departments have the highest total salary  --

SELECT jd.jobdept AS Department,
       SUM(sb.amount) AS Highesttotalsalary
FROM jobdepartment jd
JOIN salarybonus sb 
        ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY Highesttotalsalary DESC;

-- QUALIFICATION AND SKILLS ANALYSIS--

SELECT * FROM qualification

-- 1. employees have at least one qualification listed--



SELECT DISTINCT e.Emp_ID,e.firstname,e.lastname
FROM employee e
JOIN qualification q ON e.emp_ID = q.Emp_ID

-- 2. positions require the most qualifications --

SELECT q.Position,
       COUNT(q.QualID) AS TotalQualifications
FROM qualification q
GROUP BY q.Position
ORDER BY TotalQualifications DESC;

-- 3.  which employees the highest number of qualifications --

SELECT e.emp_ID,
       e.firstname,
       e.lastname,
       COUNT(q.QualID) AS TotalQualifications
FROM employee e
JOIN qualification q 
        ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY TotalQualifications DESC;

-- LEAVE AND ABSENCE PATTERNS --

SELECT * FROM Leaves

-- 1.Which year had the most employees taking leaves --

SELECT YEAR(l.date) AS LeaveYear,
       COUNT(DISTINCT l.emp_ID) AS TotalEmployeesOnLeave
FROM leaves l
GROUP BY YEAR(l.date)
ORDER BY TotalEmployeesOnLeave DESC;

-- 2. average number of leave days taken by its employees per department --

SELECT jd.jobdept AS Department,
       AVG(emp_leave_count) AS AvgLeaveDaysPerEmployee
FROM (
    SELECT e.emp_ID,
           e.Job_ID,
           COUNT(l.leave_ID) AS emp_leave_count
    FROM employee e
    LEFT JOIN leaves l 
           ON e.emp_ID = l.emp_ID
    GROUP BY e.emp_ID, e.Job_ID
) AS t
JOIN jobdepartment jd 
      ON t.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- 3. Which employee has taken the most leaves --

SELECT e.emp_ID,e.firstname,e.lastname,
             COUNT(l.leave_ID) AS Totalleavestaken
FROM employee e
JOIN leaves l
ON e.emp_ID=l.emp_ID
GROUP BY e.emp_ID,e.firstname,e.lastname
ORDER BY Totalleavestaken DESC;

  -- 4.What is the total number of leave days taken company-wide --
  
SELECT COUNT(*) AS TotalLeaveDays
FROM leaves;

-- 5. How do leave days correlate with payroll amounts--

SELECT * FROM payroll

SELECT e.emp_ID,
       e.firstname,
       e.lastname,
       COUNT(l.leave_ID) AS TotalLeaveDays,
       p.total_amount AS PayrollAmount
FROM employee e
LEFT JOIN leaves l 
       ON e.emp_ID = l.emp_ID
JOIN payroll p 
       ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname, p.total_amount
ORDER BY TotalLeaveDays DESC
LIMIT 6;

-- . PAYROLL AND COMPENSATION ANALYSIS --

SELECT * FROM payroll

-- 1. What is the total monthly payroll processed --

SELECT DATE_FORMAT(p.date, '%Y-%m') AS Month,
       SUM(p.total_amount) AS TotalMonthlyPayroll
FROM payroll p
GROUP BY DATE_FORMAT(p.date, '%Y-%m')
ORDER BY Month;

-- 2. What is the average bonus given per department --

SELECT * FROM jobdepartment
SELECT * FROM salarybonus

SELECT jd.jobdept AS Department,
       AVG(sb.bonus) AS AvgBonus
FROM jobdepartment jd
JOIN salarybonus sb
      ON jd.job_ID=sb.job_ID
GROUP BY jd.jobdept
ORDER BY AvgBonus DESC;

-- 3.Which department receives the highest total bonuses --

SELECT jd.jobdept AS Department,
       SUM(sb.bonus) AS TotalBonus
FROM jobdepartment jd
JOIN salarybonus sb 
       ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY TotalBonus DESC;

-- 4. What is the average value of total_amount after considering leave deductions --

SELECT * FROM payroll

SELECT AVG(p.total_amount) AS Average_payroll_after_leavedeductions
FROM payroll p;


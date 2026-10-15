/* ==============================================================================
   MySQL Triggers
---------------------------------------------------------------------------------------
This script creates a logging table and a trigger, then performs an insert into the Sales.
Employees table to activate it. The trigger automatically logs details of newly added 
employees into the Sales.EmployeeLogs table."
========================================================================================
*/

-- Step 1: Create the Base Employees Table
CREATE TABLE IF NOT EXISTS Sales_Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName  VARCHAR(50),
    LastName   VARCHAR(50),
    Department VARCHAR(50),
    BirthDate  DATE,
    Gender     CHAR(1),
    Salary     DECIMAL(10, 2),
    ManagerID  INT
);
-- Step 2: Create the Log Table
CREATE TABLE IF NOT EXISTS Sales_EmployeeLogs (
    LogID      INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeID INT,
    LogMessage VARCHAR(255),
    LogDate    DATE
);

-- Step 3: Create the Trigger
DELIMITER //

DROP TRIGGER IF EXISTS trg_AfterInsertEmployee //

CREATE TRIGGER trg_AfterInsertEmployee
AFTER INSERT ON Sales_Employees
FOR EACH ROW
BEGIN
    INSERT INTO Sales_EmployeeLogs (EmployeeID, LogMessage, LogDate)
    VALUES (
        NEW.EmployeeID,
        CONCAT('New Employee Added = ', NEW.EmployeeID),
        CURDATE()
    );
END //

DELIMITER ;

-- Step 4: Insert New Data into Sales_Employees
INSERT INTO Sales_Employees (EmployeeID, FirstName, LastName, Department, BirthDate, Gender, Salary, ManagerID)
VALUES (6, 'Abdirahman', 'Doe', 'HR', '1999-01-12', 'M', 80000.00, 3);


-- Step 5: Verify the Trigger Execution
SELECT * FROM Sales_EmployeeLogs;

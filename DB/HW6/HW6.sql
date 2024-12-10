-- DB Assignment 6
-- Katrina Cwiertniewicz 
-- 12/10/2024
/* **************************************************************************************** */
-- when set, it prevents potentially dangerous updates and deletes
set SQL_SAFE_UPDATES=0;

-- when set, it disables the enforcement of foreign key constraints.
set FOREIGN_KEY_CHECKS=0;

/* **************************************************************************************** 
-- These control:
--     the maximum time (in seconds) that the client will wait while trying to establish a 
	   connection to the MySQL server 
--     how long the client will wait for a response from the server once a request has 
       been sent over
**************************************************************************************** */
SHOW SESSION VARIABLES LIKE '%timeout%';       
SET GLOBAL mysqlx_connect_timeout = 600;
SET GLOBAL mysqlx_read_timeout = 600;

/* **************************************************************************************** */
-- Task 1
-- Create the accounts table

drop table accounts;

CREATE TABLE accounts (
  account_num CHAR(5) PRIMARY KEY,    -- 5-digit account number (e.g., 00001, 00002, ...)
  branch_name VARCHAR(50),            -- Branch name (e.g., Brighton, Downtown, etc.)
  balance DECIMAL(10, 2),      -- Account balance, with two decimal places (e.g., 1000.50)
  account_type VARCHAR(50)            -- Type of the account (e.g., Savings, Checking)
);

alter table accounts drop primary key;
/* ***************************************************************************************************
-- Task 2 and Task 5
The procedure generates 50,000, 100,000 and 150,000, 200,000 records for the accounts table, with the account_num padded to 5 digits.
branch_name is randomly selected from one of the six predefined branches.
balance is generated randomly, between 0 and 100,000, rounded to two decimal places.
***************************************************************************************************** */
-- Change delimiter to allow semicolons inside the procedure
DELIMITER $$

CREATE PROCEDURE generate_accounts()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE branch_name VARCHAR(50);
  DECLARE account_type VARCHAR(50);
  
  -- Loop to generate 50,000, 100,000, 150,000, and 200,000 account records
  WHILE i <= 50000 DO
    -- Randomly select a branch from the list of branches
    SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    
    -- Randomly select an account type
    SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
    
    -- Insert account record
    INSERT INTO accounts (account_num, branch_name, balance, account_type)
    VALUES (
      LPAD(i, 5, '0'),                   -- Account number as just digits, padded to 5 digits (e.g., 00001, 00002, ...)
      branch_name,                       -- Randomly selected branch name
      ROUND((RAND() * 100000), 2),       -- Random balance between 0 and 100,000, rounded to 2 decimal places
      account_type                       -- Randomly selected account type (Savings/Checking)
    );

    SET i = i + 1;
  END WHILE;
END$$

-- Reset the delimiter back to the default semicolon
DELIMITER ;

-- ******************************************************************
-- execute the procedure
-- ******************************************************************
CALL generate_accounts();

select count(*) from accounts;

-- ******************************************************************
SHOW INDEXES from accounts;
-- ******************************************************************

-- ****************************************************************************************
-- This type of index will speed up queries that filter or search by the branch_name column.
-- *****************************************************************************************
CREATE INDEX idx_branch_name ON accounts (branch_name);
-- DROP INDEX idx_branch_name ON accounts;

-- ****************************************************************************************
-- Task 3
-- If you frequently run queries that filter or sort by both branch_name, account_type
-- balance creating a composite index on these two columns can improve performance.
-- ****************************************************************************************
CREATE INDEX idx_branch_account_type ON accounts (branch_name, account_type);
-- DROP INDEX idx_branch_account_type ON accounts;

CREATE INDEX idx_branch_balance ON accounts (branch_name, balance);
-- DROP INDEX idx_branch_account_type ON accounts;


-- ******************************************************************************************
-- Task 6 and Task 7
-- Stored Procedure Timing analysis 
-- ******************************************************************************************
-- Change delimiter to allow semicolons inside the procedure
DELIMITER $$
-- 7) Create Procedure to measure average execution times
CREATE PROCEDURE compute_average_times(IN query_text TEXT)
BEGIN
	DECLARE i INT DEFAULT 0;
    DECLARE total_execution_time_microseconds INT DEFAULT 0;
    DECLARE execution_time_microseconds INT;
    
    SET @query = query_text;
    
	-- Prepare the query
	PREPARE stmt FROM @query;
    
	-- Loop to execute query 10 times
	begin_loop: LOOP
		SET i = i + 1;

-- Capture the start time with microsecond precision (6)
		SET @start_time = NOW(6);

-- Execute the prepared statement with the provided parameters
		EXECUTE stmt;
    
-- Capture the end time with microsecond precision
		SET @end_time = NOW(6);

-- Calculate the difference in microseconds
		SET execution_time_microseconds = TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time);
    
-- Total microseconds of 10 executions
		SET total_execution_time_microseconds = total_execution_time_microseconds + execution_time_microseconds;
		
-- Loop 10 times
		IF i >= 10 THEN 
			LEAVE begin_loop;
		END IF;
		END LOOP;
    
    -- Average Execution Time
		SELECT total_execution_time_microseconds / 10 AS avg_execution_time_microseconds;

    -- Clean up the prepared statement
	DEALLOCATE PREPARE stmt;
END$$

-- Reset the delimiter back to the default semicolon
DELIMITER ;

-- Task 4
-- Calling Point Query 
CALL compute_average_times('SELECT * FROM accounts WHERE branch_name = "Brighton" AND balance = 38911.04');

-- Calling Range Query 
CALL compute_average_times('SELECT * FROM accounts WHERE branch_name = "Brighton" AND balance between 30000 and 50000');

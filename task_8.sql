--USE DATABASE
use kesavan_db
GO



/**
CREATE VIEW TEST
AS
SELECT 
    t.task_id,
    t.task_name,
    p.project_name
FROM task t
LEFT JOIN project p 
    ON t.project_id = p.project_id

select * from TEST

**/
--before table status
select * from project
-- Allow NULL in end_date if needed
ALTER TABLE project ALTER COLUMN end_date DATE NULL;

--inserting null values
INSERT INTO project (
    project_name, 
    start_date, 
    end_date, 
    budget, 
    status

)
vALUES (
    'Mobile Development', 
    '2025-02-01', 
    NULL, 
    50000, 
    'Completed'

)



/**
    --- VIEWS
**/



-- drop if already exists
DROP VIEW IF EXISTS dbo.vw_active_projects

--1. Create a view named vw_ActiveProjects that lists all projects that are currently active (i.e., EndDate is NULL).
CREATE VIEW vw_active_projects
AS
SELECT 
    project_name,
    start_date,
    end_date,
    status
FROM project
WHERE status IN ('In Progress','Not Started')
OR end_date IS NULL;
GO

select * from project

--display
SELECT * from vw_active_projects

DELETE FROM project
WHERE project_id = 5
-- drop if already exists
DROP VIEW IF EXISTS dbo.vw_high_priority_tasks
-- 2. Create a view named vw_HighPriorityTasks that lists all tasks with Priority set to 'High'.
CREATE VIEW vw_high_priority_tasks
AS
SELECT 
    task_name,
    description,
    start_date,
    due_date,
    priority,
    status
FROM task
WHERE priority = 'High';
GO

--display 
SELECT * FROM task
SELECT * FROM vw_high_priority_tasks;

/**
    --- CURSOR
**/

/*
--1. Create a cursor that iterates over all active projects and prints the project names..
*/

SET NOCOUNT ON;
-- Declare variable for project name
DECLARE @project_names VARCHAR(150);

-- Declare the cursor to select active project names
DECLARE active_projects_cursor CURSOR FOR
SELECT project_name
FROM vw_active_projects;  

-- Open the cursor
OPEN active_projects_cursor;

-- Fetch the first row
FETCH NEXT FROM active_projects_cursor INTO @project_names;

-- Loop through all rows
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Active Project: ' + @project_names;

    -- Fetch the next row
    FETCH NEXT FROM active_projects_cursor INTO @project_names;
END

-- Close and deallocate the cursor
CLOSE active_projects_cursor;

DEALLOCATE active_projects_cursor;
GO

/**
2. Create a cursor that iterates over all tasks, and if the current date is past the DueDate, update the Status to 'Overdue'.
**/

-- Declare variables for cursor
SET NOCOUNT ON;

DECLARE @task_id INT;
DECLARE @due_date DATE;
DECLARE @current_status VARCHAR(70);
DECLARE @task_name VARCHAR(150);

-- Cursor to get all tasks
DECLARE task_due_cursor CURSOR FOR
SELECT task_id, due_date, status, task_name
FROM task;

-- Open the cursor
OPEN task_due_cursor;

-- Fetch the first row
FETCH NEXT FROM task_due_cursor INTO @task_id, @due_date, @current_status, @task_name;

PRINT '--- Overdue Task Update Started ---';

-- Loop through all rows
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Check if task is overdue
    IF GETDATE() > @due_date 
       AND @current_status NOT IN ('Completed', 'Overdue')
    BEGIN
        UPDATE task
        SET status = 'Overdue'
        WHERE task_id = @task_id;

        PRINT 'Task: ' + @task_name + ' (ID: ' + CAST(@task_id AS VARCHAR) + ') marked as Overdue';
    END

    -- Fetch the next row
    FETCH NEXT FROM task_due_cursor INTO @task_id, @due_date, @current_status, @task_name;
END


-- Close and deallocate the cursor
CLOSE task_due_cursor;
DEALLOCATE task_due_cursor;

PRINT '--- Overdue Task Update Completed ---';
GO
-- Reset some tasks 
UPDATE task
SET status = 'In Prgress', due_date = DATEADD(DAY, -3, GETDATE())
WHERE task_id IN (2, 3, 5, 8, 10);

select * from task

--reverse process
UPDATE task
SET status = 'Pending'
WHERE status = 'Overdue';



--USE DATABASE
use kesavan_db
GO

/*
    SYSTEM DEFINED VIEW
  
SELECT *
FROM sys.tables;

*/

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
    'Software Development', 
    '2025-02-01', 
    NULL, 
    50000, 
    'In Progress'
)

UPDATE project
SET status = 'Not Started'
WHERE project_id = 5

/**
    --- VIEWS
**/



-- drop if already exists
DROP VIEW IF EXISTS dbo.vw_active_projects

--1. Create a view named vw_ActiveProjects that lists all projects that are currently active (i.e., EndDate is NULL).
CREATE VIEW vw_active_projects
AS
SELECT  *
FROM project
WHERE status IN ('In Progress')
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
SELECT *
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

DECLARE @project_names VARCHAR(150);
DECLARE @Results TABLE (ActiveProject VARCHAR(150));

DECLARE active_projects_cursor CURSOR FOR  
SELECT project_name  
FROM project;   

OPEN active_projects_cursor;

FETCH NEXT FROM active_projects_cursor INTO @project_names;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO @Results (ActiveProject)
    VALUES (@project_names);

    FETCH NEXT FROM active_projects_cursor INTO @project_names;
END

CLOSE active_projects_cursor;
DEALLOCATE active_projects_cursor;

-- Output in table format
SELECT * FROM @Results;


/**
2. Create a cursor that iterates over all tasks, and if the current date is past the DueDate, update the Status to 'Overdue'.
**/

SET NOCOUNT ON;

DECLARE @task_id INT;
DECLARE @due_date DATE;
DECLARE @current_status VARCHAR(70);
DECLARE @task_name VARCHAR(150);

DECLARE @UpdatedTasks TABLE (
    TaskID INT,
    TaskName VARCHAR(150),
    DueDate DATE,
    NewStatus VARCHAR(70)
);

DECLARE task_due_cursor CURSOR FOR
SELECT task_id, due_date, status, task_name
FROM task;

OPEN task_due_cursor;

FETCH NEXT FROM task_due_cursor INTO @task_id, @due_date, @current_status, @task_name;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF GETDATE() > @due_date 
       AND @current_status NOT IN ('Completed', 'Overdue','Not Started')
    BEGIN
        UPDATE task
        SET status = 'Overdue'
        WHERE task_id = @task_id;

        INSERT INTO @UpdatedTasks (TaskID, TaskName, DueDate, NewStatus)
        VALUES (@task_id, @task_name, @due_date, 'Overdue');
    END

    FETCH NEXT FROM task_due_cursor INTO @task_id, @due_date, @current_status, @task_name;
END

CLOSE task_due_cursor;
DEALLOCATE task_due_cursor;

SELECT * FROM @UpdatedTasks;

-- Reset some tasks 
UPDATE task
SET status = 'In Prgress', due_date = DATEADD(DAY, -3, GETDATE())
WHERE task_id IN (2, 3, 5, 8, 10);

select * from task

--reverse process
UPDATE task
SET status = 'Pending'
WHERE status = 'Overdue';



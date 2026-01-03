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

--to change null column to check its working or not
UPDATE project
SET end_date = NULL
WHERE project_id = 3


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
    starts_date,
    end_date,
    statuss
FROM project
WHERE statuss IN ('In Progress','Not Started')
--OR end_date IS NULL;
GO

select * from project

--display
SELECT * from vw_active_projects

-- drop if already exists
DROP VIEW IF EXISTS dbo.vw_high_priority_tasks
-- 2. Create a view named vw_HighPriorityTasks that lists all tasks with Priority set to 'High'.
CREATE VIEW vw_high_priority_tasks
AS
SELECT 
    task_name,
    descriptions,
    starts_date,
    due_date,
    prioritys,
    statuss
FROM task
WHERE prioritys = 'High';
GO

--display 
SELECT * FROM task
SELECT * FROM vw_high_priority_tasks;

/**
    --- CURSOR
**/

